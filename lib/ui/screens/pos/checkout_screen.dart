import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/sale.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../../domain/cart.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';
import '../utang/customer_picker.dart';
import 'receipt_screen.dart';

/// Payment: cash with change, or utang charged to a customer.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, this.initialPayment = PaymentType.cash});

  /// The payment chosen in the cart.
  final PaymentType initialPayment;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _cash = TextEditingController();
  final _buyerName = TextEditingController();
  late PaymentType _payment = widget.initialPayment;
  Customer? _customer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (_payment == PaymentType.utang) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pickCustomer();
      });
    }
  }

  @override
  void dispose() {
    _cash.dispose();
    _buyerName.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final picked = await showCustomerPicker(context);
    if (picked != null && mounted) setState(() => _customer = picked);
  }

  Future<void> _complete() async {
    final s = context.s;
    final session = StoreScope.of(context);
    final cart = session.cart;
    final latest = session.productsById;
    cart.syncWith(latest);
    final customerId = _customer?.id;
    final freshCustomer = session.customerById(customerId) ?? _customer;

    setState(() => _busy = true);
    final result = await session.sales.checkout(
      CheckoutRequest(
        lines: cart.lines,
        paymentType: _payment,
        amountPaid: parsePesoToCents(_cash.text) ?? 0,
        customer: _payment == PaymentType.utang ? freshCustomer : null,
        buyerName: _payment == PaymentType.cash ? _buyerName.text : '',
      ),
      latest,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.when<void>(
      ok: (outcome) {
        cart.clear();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => ReceiptScreen(outcome: outcome)),
        );
      },
      err: (error) => showMessage(context, describeError(s, error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([session.cart, session.products, session.customers]),
      builder: (context, _) {
        final cart = session.cart;
        final total = cart.total;
        final paid = parsePesoToCents(_cash.text) ?? 0;
        final change = changeDue(total: total, paid: paid);
        final problems = cart.problems(session.productsById);
        final customer = session.customerById(_customer?.id) ?? _customer;
        final isCash = _payment == PaymentType.cash;
        final canComplete = !cart.isEmpty &&
            problems.isEmpty &&
            (isCash ? paid >= total : customer != null);

        return Scaffold(
          appBar: AppBar(title: Text(s.checkoutTitle)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, AppSpace.xl),
            children: [
              AppCard(
                tone: CardTone.featured,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.totalDue.toUpperCase(), style: AppType.overline),
                    const SizedBox(height: AppSpace.sm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(formatPeso(total), style: AppType.tabular(AppType.display)),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(s.itemCount(cart.itemCount), style: AppType.body),
                  ],
                ),
              ),
              if (problems.isNotEmpty) ...[
                const SizedBox(height: AppSpace.md),
                InlineNotice(
                  icon: Icons.warning_amber_rounded,
                  tone: NoticeTone.warning,
                  message: s.notEnoughStockFor(problems.map((p) => p.name).join(', ')),
                ),
              ],
              const SizedBox(height: AppSpace.xl),
              Text(s.paymentMethod, style: AppType.subhead),
              const SizedBox(height: AppSpace.md),
              SegmentedPills<PaymentType>(
                options: PaymentType.values,
                selected: _payment,
                labelOf: (type) => type == PaymentType.cash ? s.paymentCash : s.paymentUtang,
                iconOf: (type) => type == PaymentType.cash ? Icons.payments_outlined : Icons.menu_book_outlined,
                onSelected: (type) {
                  setState(() => _payment = type);
                  if (type == PaymentType.utang && _customer == null) _pickCustomer();
                },
              ),
              const SizedBox(height: AppSpace.xl),
              if (isCash) ...[
                PesoField(
                  label: s.cashReceived,
                  controller: _cash,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpace.md),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  children: [
                    for (final amount in quickCashOptions(total))
                      PillButton(
                        label: amount == total ? s.exactAmount : formatPesoCompact(amount),
                        variant: PillVariant.outline,
                        onPressed: () {
                          _cash.text = centsToInputText(amount);
                          setState(() {});
                        },
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.xl),
                AppCard(
                  tone: CardTone.band,
                  child: Row(
                    children: [
                      Expanded(child: Text(s.changeLabel, style: AppType.subhead)),
                      Text(
                        paid == 0 ? formatPeso(0) : formatPeso(change < 0 ? 0 : change),
                        style: AppType.tabular(AppType.headline),
                      ),
                    ],
                  ),
                ),
                if (paid > 0 && change < 0) ...[
                  const SizedBox(height: AppSpace.md),
                  InlineNotice(
                    icon: Icons.warning_amber_rounded,
                    tone: NoticeTone.warning,
                    message: s.cashShort(formatPeso(-change)),
                  ),
                ],
                const SizedBox(height: AppSpace.lg),
                AppTextField(
                  label: s.nameOptional,
                  controller: _buyerName,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                ),
              ] else ...[
                AppCard(
                  onTap: _pickCustomer,
                  child: Row(
                    children: [
                      if (customer != null) ...[
                        InitialsAvatar(name: customer.name),
                        const SizedBox(width: AppSpace.md),
                      ] else ...[
                        const Icon(Icons.person_add_alt_1_outlined),
                        const SizedBox(width: AppSpace.md),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer?.name ?? s.chooseCustomer, style: AppType.bodyStrong),
                            if (customer != null)
                              Text(s.currentBalance(formatPeso(customer.balance)), style: AppType.bodySmall),
                          ],
                        ),
                      ),
                      Text(customer == null ? '' : s.changeCustomer, style: AppType.bodySmall),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
                if (customer != null) ...[
                  const SizedBox(height: AppSpace.md),
                  AppCard(
                    tone: CardTone.band,
                    child: Column(
                      children: [
                        StatRow(label: s.addedToUtang, value: formatPeso(total)),
                        StatRow(
                          label: s.newBalanceLabel,
                          value: formatPeso(customer.balance + total),
                          emphasize: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              SectionHeader(title: s.itemsInSale),
              ListCard(
                children: [
                  for (final line in cart.lines)
                    ListRow(
                      title: line.name,
                      subtitle: '${line.qty} × ${formatPeso(line.unitPrice)}',
                      trailing: Text(formatPeso(line.lineTotal), style: AppType.tabular(AppType.bodyStrong)),
                    ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: BottomActionBar(
            child: PillButton(
              label: s.completeSale,
              icon: Icons.check_rounded,
              expand: true,
              loading: _busy,
              onPressed: canComplete ? _complete : null,
            ),
          ),
        );
      },
    );
  }
}
