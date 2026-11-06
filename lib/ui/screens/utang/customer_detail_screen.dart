import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/manila_time.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/live_query.dart';
import '../../../data/models/customer.dart';
import '../../../data/store_session.dart';
import '../../../domain/utang_archive.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';
import '../../widgets/tags.dart';
import '../sales/sale_detail_screen.dart';
import 'customer_picker.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  LiveQuery<List<LedgerEntry>>? _ledger;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ledger != null) return;
    final repo = StoreScope.of(context).customerRepo;
    _ledger = LiveQuery<List<LedgerEntry>>(
      () => repo.watchLedger(widget.customerId),
      context: '[utang/ledger]',
    );
  }

  @override
  void dispose() {
    _ledger?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    final ledger = _ledger;
    if (ledger == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: Listenable.merge([session.customers, ledger]),
      builder: (context, _) {
        final customer = session.customerById(widget.customerId);
        if (customer == null) {
          return Scaffold(
            appBar: AppBar(),
            body: session.customers.isLoading
                ? const CenteredLoader()
                : Padding(
                    padding: const EdgeInsets.all(AppSpace.screen),
                    child: EmptyState(icon: Icons.person_off_outlined, message: s.customerNotFound),
                  ),
          );
        }
        final ledgerError = ledger.error;
        final entries = ledger.value ?? const <LedgerEntry>[];
        final historyKnown = ledger.hasValue && ledgerError == null;
        final canRemove = !customer.archived && customer.balance == 0 && historyKnown && entries.isEmpty;
        final canMarkPaidUp = customer.balance > 0 || (customer.balance == 0 && historyKnown && entries.isNotEmpty);
        final archivedAt = customer.archivedAt;
        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name),
            actions: [
              if (canRemove)
                IconButton(
                  tooltip: s.removeCustomer,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _remove(session, customer),
                ),
              IconButton(
                tooltip: s.editCustomer,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => showCustomerForm(context, existing: customer),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, AppSpace.xl),
            children: [
              AppCard(
                tone: CardTone.featured,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.balanceOwed.toUpperCase(), style: AppType.overline),
                    const SizedBox(height: AppSpace.sm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(formatPeso(customer.balance), style: AppType.tabular(AppType.display)),
                    ),
                    if (customer.balance < 0)
                      Text(s.storeOwesCustomer(formatPeso(-customer.balance)), style: AppType.body),
                    if (customer.phone.isNotEmpty) Text(customer.phone, style: AppType.body),
                    if (customer.note.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.xs),
                      Text(customer.note, style: AppType.bodySmall),
                    ],
                    if (customer.archived) ...[
                      const SizedBox(height: AppSpace.md),
                      TagPill(label: s.archivedLabel, icon: Icons.inventory_2_outlined),
                      if (archivedAt != null) ...[
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          s.removalDate(
                            ManilaTime.formatDate(archiveRemovalDate(ManilaTime.toManila(archivedAt)), s),
                          ),
                          style: AppType.bodySmall,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              SectionHeader(title: s.utangHistory),
              if (ledgerError != null)
                ErrorCard(error: ledgerError, onRetry: ledger.retry)
              else if (ledger.isLoading)
                const LoadingBlocks(count: 3)
              else if (entries.isEmpty)
                EmptyState(icon: Icons.history_rounded, message: s.noUtangHistory)
              else
                ListCard(
                  children: [
                    for (final entry in entries)
                      ListRow(
                        title: '${s.ledgerTypeLabel(entry.type)} · '
                            '${entry.raisesBalance ? '+' : '−'}${formatPeso(entry.amount)}',
                        subtitle: [
                          if (entry.createdAt != null)
                            ManilaTime.formatDateTime(ManilaTime.toManila(entry.createdAt!), s),
                          if (entry.receiptNo.isNotEmpty) s.receiptNo(entry.receiptNo),
                          if (entry.note.isNotEmpty) entry.note,
                          entry.byName,
                        ].join(' · '),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(s.balanceShort, style: AppType.caption),
                            Text(formatPeso(entry.balanceAfter), style: AppType.tabular(AppType.bodySmall)),
                          ],
                        ),
                        onTap: entry.saleId.isEmpty
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(builder: (_) => SaleDetailScreen(saleId: entry.saleId)),
                                ),
                      ),
                  ],
                ),
            ],
          ),
          bottomNavigationBar: BottomActionBar(
            child: customer.archived
                ? PillButton(
                    label: s.restore,
                    icon: Icons.undo_rounded,
                    expand: true,
                    loading: _busy,
                    onPressed: () => _restore(session, customer),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: PillButton(
                              label: s.addUtang,
                              variant: PillVariant.outline,
                              expand: true,
                              onPressed: () => _showAmountSheet(context, session, customer, isPayment: false),
                            ),
                          ),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: PillButton(
                              label: s.recordPayment,
                              variant: PillVariant.outline,
                              expand: true,
                              onPressed: customer.balance > 0
                                  ? () => _showAmountSheet(context, session, customer, isPayment: true)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      if (canMarkPaidUp) ...[
                        const SizedBox(height: AppSpace.sm),
                        PillButton(
                          label: s.paidUp,
                          icon: Icons.check_rounded,
                          expand: true,
                          loading: _busy,
                          onPressed: () => _markPaidUp(session, customer),
                        ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<void> _markPaidUp(StoreSession session, Customer customer) async {
    final s = context.s;
    final confirmed = await showConfirmDialog(
      context,
      title: s.paidUpTitle(customer.name),
      message: customer.balance > 0 ? s.paidUpMessage(formatPeso(customer.balance)) : s.paidUpNoBalanceMessage,
      confirmLabel: s.paidUp,
    );
    if (!confirmed || !mounted) return;
    await _run(session.customerRepo.markPaidUp(customer), s.movedToArchive, leave: true);
  }

  Future<void> _restore(StoreSession session, Customer customer) {
    return _run(session.customerRepo.restore(customer), context.s.customerRestored, leave: false);
  }

  Future<void> _remove(StoreSession session, Customer customer) async {
    final s = context.s;
    final confirmed = await showConfirmDialog(
      context,
      title: s.removeCustomerTitle(customer.name),
      message: s.removeCustomerMessage,
      confirmLabel: s.removeCustomer,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _run(session.customerRepo.remove(customer), s.customerRemoved, leave: true);
  }

  /// Saves, then says what happened. [leave] closes this screen afterwards.
  Future<void> _run(Future<Result<bool>> save, String done, {required bool leave}) async {
    final s = context.s;
    setState(() => _busy = true);
    final result = await save;
    if (!mounted) return;
    setState(() => _busy = false);
    result.when<void>(
      ok: (synced) {
        showMessage(context, synced ? done : s.savedOffline);
        if (leave) Navigator.of(context).pop();
      },
      err: (error) => showMessage(context, describeError(s, error)),
    );
  }

  Future<void> _showAmountSheet(
    BuildContext context,
    StoreSession session,
    Customer customer, {
    required bool isPayment,
  }) {
    return showAppSheet<void>(
      context,
      builder: (_) => _AmountSheet(session: session, customer: customer, isPayment: isPayment),
    );
  }
}

class _AmountSheet extends StatefulWidget {
  const _AmountSheet({required this.session, required this.customer, required this.isPayment});

  final StoreSession session;
  final Customer customer;
  final bool isPayment;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = context.s;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = parsePesoToCents(_amount.text) ?? 0;
    setState(() => _busy = true);
    final repo = widget.session.customerRepo;
    final result = widget.isPayment
        ? await repo.recordPayment(widget.customer, amount: amount, note: _note.text)
        : await repo.recordManualCharge(widget.customer, amount: amount, note: _note.text);
    if (!mounted) return;
    setState(() => _busy = false);
    result.when<void>(
      ok: (_) {
        Navigator.of(context).pop();
        showMessage(context, widget.isPayment ? s.paymentRecorded : s.utangAdded);
      },
      err: (error) => showMessage(context, describeError(s, error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final balance = widget.customer.balance;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.isPayment ? s.recordPayment : s.addUtang, style: AppType.subhead),
            const SizedBox(height: AppSpace.xs),
            Text(s.currentBalance(formatPeso(balance)), style: AppType.bodySmall),
            const SizedBox(height: AppSpace.lg),
            PesoField(
              label: widget.isPayment ? s.amountPaid : s.amount,
              controller: _amount,
              autofocus: true,
              validator: (value) {
                final cents = parsePesoToCents(value ?? '');
                if (cents == null || cents <= 0) return s.enterAmount;
                if (widget.isPayment && cents > balance) return s.paymentOverBalance(formatPeso(balance));
                return null;
              },
            ),
            if (widget.isPayment && balance > 0) ...[
              const SizedBox(height: AppSpace.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: PillButton(
                  label: s.payFullBalance(formatPeso(balance)),
                  variant: PillVariant.outline,
                  onPressed: () => setState(() => _amount.text = centsToInputText(balance)),
                ),
              ),
            ],
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: widget.isPayment ? s.noteOptional : s.whatWasItFor,
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              validator: widget.isPayment ? null : (value) => (value ?? '').trim().isEmpty ? s.required : null,
            ),
            const SizedBox(height: AppSpace.xl),
            PillButton(label: s.save, onPressed: _save, loading: _busy, expand: true),
          ],
        ),
      ),
    );
  }
}
