import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/manila_time.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/live_query.dart';
import '../../../data/models/customer.dart';
import '../../../data/store_session.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';
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
        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name),
            actions: [
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
                    Text(s.balanceOwed.toUpperCase(), style: AppType.eyebrowCap),
                    const SizedBox(height: AppSpace.sm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(formatPeso(customer.balance), style: AppType.tabular(AppType.displayMd)),
                    ),
                    if (customer.balance < 0)
                      Text(s.storeOwesCustomer(formatPeso(-customer.balance)), style: AppType.bodyMd),
                    if (customer.phone.isNotEmpty) Text(customer.phone, style: AppType.bodyMd),
                    if (customer.note.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.xs),
                      Text(customer.note, style: AppType.caption),
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
                            Text(s.balanceShort, style: AppType.micro),
                            Text(formatPeso(entry.balanceAfter), style: AppType.tabular(AppType.caption)),
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
            child: Row(
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
                    expand: true,
                    onPressed: customer.balance > 0
                        ? () => _showAmountSheet(context, session, customer, isPayment: true)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            Text(widget.isPayment ? s.recordPayment : s.addUtang, style: AppType.headingLg),
            const SizedBox(height: AppSpace.xs),
            Text(s.currentBalance(formatPeso(balance)), style: AppType.caption),
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
