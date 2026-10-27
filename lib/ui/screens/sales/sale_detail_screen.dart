import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/manila_time.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/live_query.dart';
import '../../../data/models/sale.dart';
import '../../../data/store_session.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';
import '../../widgets/tags.dart';

/// Receipt view of one sale. Owners can refund items or cancel the sale;
/// both return stock and leave an audit record.
class SaleDetailScreen extends StatefulWidget {
  const SaleDetailScreen({super.key, required this.saleId});

  final String saleId;

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  LiveQuery<Sale?>? _sale;
  LiveQuery<List<Refund>>? _refunds;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sale != null) return;
    final sales = StoreScope.of(context).sales;
    _sale = LiveQuery<Sale?>(() => sales.watchSale(widget.saleId), context: '[sale/detail]');
    _refunds = LiveQuery<List<Refund>>(() => sales.watchRefundsForSale(widget.saleId), context: '[sale/refunds]');
  }

  @override
  void dispose() {
    _sale?.dispose();
    _refunds?.dispose();
    super.dispose();
  }

  Future<void> _cancel(StoreSession session, Sale sale) async {
    final s = context.s;
    final reason = await showReasonDialog(
      context,
      title: s.cancelSaleTitle,
      message: s.cancelSaleMessage(formatPeso(sale.total)),
      confirmLabel: s.cancelSale,
    );
    if (reason == null || !mounted) return;
    final result = await session.sales.cancel(
      sale: sale,
      reason: reason,
      latest: session.productsById,
      customer: session.customerById(sale.customerId),
    );
    if (!mounted) return;
    final error = result.errorOrNull;
    showMessage(context, error == null ? s.saleCancelled : describeError(s, error));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    final saleQuery = _sale;
    final refundsQuery = _refunds;
    if (saleQuery == null || refundsQuery == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: Listenable.merge([saleQuery, refundsQuery]),
      builder: (context, _) {
        final sale = saleQuery.value;
        final error = saleQuery.error;
        if (sale == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(AppSpace.screen),
              child: error != null
                  ? ErrorCard(error: error, onRetry: saleQuery.retry)
                  : saleQuery.isLoading
                      ? const CenteredLoader()
                      : EmptyState(icon: Icons.receipt_long_outlined, message: s.saleNotFound),
            ),
          );
        }
        final created = sale.createdAt;
        final refunds = refundsQuery.value ?? const <Refund>[];
        final isOwner = session.isOwner;
        return Scaffold(
          appBar: AppBar(title: Text(s.receiptNo(sale.receiptNo))),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, AppSpace.xl),
            children: [
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.sm,
                children: [
                  if (sale.isCancelled)
                    TagPill(label: s.statusCancelled, tone: TagTone.ink, icon: Icons.block_rounded)
                  else if (sale.status == SaleStatus.refunded)
                    TagPill(label: s.statusRefunded, tone: TagTone.shade, icon: Icons.undo_rounded)
                  else if (sale.hasRefund)
                    TagPill(label: s.statusPartRefund, tone: TagTone.shade, icon: Icons.undo_rounded)
                  else
                    TagPill(label: s.statusCompleted, tone: TagTone.mint, icon: Icons.check_rounded),
                  TagPill(
                    label: sale.paymentType == PaymentType.utang ? s.paymentUtang : s.paymentCash,
                    tone: TagTone.outline,
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              AppCard(
                tone: CardTone.raised,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (created != null)
                      Text(ManilaTime.formatDateTime(ManilaTime.toManila(created), s), style: AppType.caption),
                    Text(s.soldBy(sale.cashierName), style: AppType.caption),
                    const Divider(height: AppSpace.xl),
                    for (final item in sale.items)
                      StatRow(
                        label: item.refundedQty > 0
                            ? '${item.qty} × ${item.name}  (${s.refundedQty(item.refundedQty)})'
                            : '${item.qty} × ${item.name}',
                        value: formatPeso(item.lineTotal),
                      ),
                    const Divider(height: AppSpace.xl),
                    StatRow(label: s.total, value: formatPeso(sale.total), emphasize: true),
                    if (sale.paymentType == PaymentType.cash) ...[
                      StatRow(label: s.cashReceived, value: formatPeso(sale.amountPaid)),
                      StatRow(label: s.changeLabel, value: formatPeso(sale.change)),
                    ] else
                      StatRow(label: s.customer, value: sale.customerName ?? ''),
                    if (sale.refundedAmount > 0)
                      StatRow(label: s.refunded, value: '−${formatPeso(sale.refundedAmount)}'),
                    if (isOwner && !sale.isCancelled)
                      StatRow(label: s.estimatedProfit, value: formatPeso(sale.profit - sale.refundedProfit)),
                  ],
                ),
              ),
              if (sale.isCancelled) ...[
                const SizedBox(height: AppSpace.md),
                InlineNotice(
                  icon: Icons.block_rounded,
                  message: s.cancelledBecause(sale.cancelReason ?? ''),
                ),
              ],
              if (refunds.isNotEmpty) ...[
                SectionHeader(title: s.refunds),
                ListCard(
                  children: [
                    for (final refund in refunds)
                      ListRow(
                        title: '−${formatPeso(refund.amount)}',
                        subtitle: [
                          if (refund.createdAt != null)
                            ManilaTime.formatDateTime(ManilaTime.toManila(refund.createdAt!), s),
                          refund.items.map((item) => '${item.qty} × ${item.name}').join(', '),
                          refund.restocked ? s.returnedToStock : s.writtenOff,
                          refund.reason,
                          refund.byName,
                        ].where((part) => part.isNotEmpty).join(' · '),
                      ),
                  ],
                ),
              ],
            ],
          ),
          bottomNavigationBar: isOwner && !sale.isCancelled && (sale.canRefund || sale.canCancel)
              ? BottomActionBar(
                  child: Row(
                    children: [
                      if (sale.canCancel)
                        Expanded(
                          child: PillButton(
                            label: s.cancelSale,
                            variant: PillVariant.ghost,
                            expand: true,
                            onPressed: () => _cancel(session, sale),
                          ),
                        ),
                      if (sale.canCancel && sale.canRefund) const SizedBox(width: AppSpace.md),
                      if (sale.canRefund)
                        Expanded(
                          child: PillButton(
                            label: s.refundItems,
                            variant: PillVariant.outline,
                            icon: Icons.undo_rounded,
                            expand: true,
                            onPressed: () => showAppSheet<void>(
                              context,
                              builder: (_) => _RefundSheet(session: session, sale: sale),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _RefundSheet extends StatefulWidget {
  const _RefundSheet({required this.session, required this.sale});

  final StoreSession session;
  final Sale sale;

  @override
  State<_RefundSheet> createState() => _RefundSheetState();
}

class _RefundSheetState extends State<_RefundSheet> {
  final Map<String, int> _qty = {};
  final _reason = TextEditingController();
  bool _restock = true;
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  int get _amount {
    var total = 0;
    for (final item in widget.sale.items) {
      total += (_qty[item.productId] ?? 0) * item.unitPrice;
    }
    return total;
  }

  Future<void> _save() async {
    final s = context.s;
    final session = widget.session;
    setState(() => _busy = true);
    final result = await session.sales.refund(
      sale: widget.sale,
      qtyByProduct: Map<String, int>.of(_qty),
      restock: _restock,
      reason: _reason.text,
      latest: session.productsById,
      customer: session.customerById(widget.sale.customerId),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.when<void>(
      ok: (_) {
        Navigator.of(context).pop();
        showMessage(context, s.refundSaved(formatPeso(_amount)));
      },
      err: (error) => showMessage(context, describeError(s, error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final amount = _amount;
    final canSave = amount > 0 && _reason.text.trim().isNotEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.refundItems, style: AppType.headingLg),
          Text(s.refundCaption, style: AppType.caption),
          const SizedBox(height: AppSpace.lg),
          for (final item in widget.sale.items)
            if (item.refundableQty > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppType.bodyStrong),
                          Text(
                            s.refundableOf(item.refundableQty, formatPeso(item.unitPrice)),
                            style: AppType.caption,
                          ),
                        ],
                      ),
                    ),
                    QtyStepper(
                      value: _qty[item.productId] ?? 0,
                      canDecrement: (_qty[item.productId] ?? 0) > 0,
                      canIncrement: (_qty[item.productId] ?? 0) < item.refundableQty,
                      onDecrement: () => setState(() => _qty[item.productId] = (_qty[item.productId] ?? 0) - 1),
                      onIncrement: () => setState(() => _qty[item.productId] = (_qty[item.productId] ?? 0) + 1),
                    ),
                  ],
                ),
              ),
          const Divider(height: AppSpace.xl),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _restock,
            onChanged: (value) => setState(() => _restock = value),
            title: Text(s.returnToStock),
            subtitle: Text(_restock ? s.returnToStockOn : s.returnToStockOff),
          ),
          const SizedBox(height: AppSpace.md),
          AppTextField(
            label: s.reason,
            controller: _reason,
            hint: s.refundReasonHint,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpace.lg),
          StatRow(
            label: widget.sale.paymentType == PaymentType.utang ? s.deductFromUtang : s.cashToReturn,
            value: formatPeso(amount),
            emphasize: true,
          ),
          const SizedBox(height: AppSpace.xl),
          PillButton(
            label: s.confirmRefund,
            onPressed: canSave ? _save : null,
            loading: _busy,
            expand: true,
          ),
        ],
      ),
    );
  }
}
