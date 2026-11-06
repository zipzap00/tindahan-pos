import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/sale.dart';
import '../../../data/store_session.dart';
import '../../scopes.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';
import 'checkout_screen.dart';

Future<void> showCartSheet(BuildContext context) async {
  final session = StoreScope.of(context);
  session.cart.syncWith(session.productsById);
  final payment = await showAppSheet<PaymentType>(context, builder: (_) => _CartSheet(session: session));
  if (payment != null && context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CheckoutScreen(initialPayment: payment)),
    );
  }
}

class _CartSheet extends StatelessWidget {
  const _CartSheet({required this.session});

  final StoreSession session;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return ListenableBuilder(
      listenable: Listenable.merge([session.cart, session.products]),
      builder: (context, _) {
        final cart = session.cart;
        final latest = session.productsById;
        final problems = cart.problems(latest);
        final problemIds = {for (final problem in problems) problem.productId: problem};
        if (cart.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpace.xl),
            child: EmptyState(icon: Icons.shopping_basket_outlined, message: s.cartEmpty),
          );
        }
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.sm, AppSpace.sm),
                child: Row(
                  children: [
                    Expanded(child: Text(s.cartTitle, style: AppType.subhead)),
                    PillButton(
                      label: s.clearCart,
                      variant: PillVariant.ghost,
                      onPressed: () async {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: s.clearCartTitle,
                          message: s.clearCartMessage,
                          confirmLabel: s.clearCart,
                          destructive: true,
                        );
                        if (confirmed) cart.clear();
                      },
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                  itemCount: cart.lines.length,
                  separatorBuilder: (context, index) => const Divider(height: AppSpace.xl),
                  itemBuilder: (context, index) {
                    final line = cart.lines[index];
                    final available = latest[line.productId]?.stock ?? 0;
                    final problem = problemIds[line.productId];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(line.name, style: AppType.bodyStrong),
                                  const SizedBox(height: AppSpace.xxs),
                                  Text(
                                    s.priceEach(formatPeso(line.unitPrice)),
                                    style: AppType.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(formatPeso(line.lineTotal), style: AppType.tabular(AppType.bodyStrong)),
                          ],
                        ),
                        const SizedBox(height: AppSpace.sm),
                        Row(
                          children: [
                            QtyStepper(
                              value: line.qty,
                              onDecrement: () => cart.decrement(line.productId),
                              onIncrement: () {
                                final product = latest[line.productId];
                                if (product != null) cart.add(product);
                              },
                              canIncrement: line.qty < available,
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: s.removeItem,
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () => cart.remove(line.productId),
                            ),
                          ],
                        ),
                        if (problem != null) ...[
                          const SizedBox(height: AppSpace.sm),
                          InlineNotice(
                            icon: Icons.warning_amber_rounded,
                            tone: NoticeTone.warning,
                            message: problem.available <= 0
                                ? s.cartLineUnavailable(line.name)
                                : s.cartLineTooMany(line.name, problem.available),
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: PillButton(
                              label: problem.available <= 0 ? s.removeItem : s.useAvailable(problem.available),
                              variant: PillVariant.outline,
                              onPressed: () =>
                                  cart.setQty(line.productId, problem.available, maxStock: problem.available),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              BottomActionBar(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StatRow(label: s.itemCount(cart.itemCount), value: formatPeso(cart.total), emphasize: true),
                    const SizedBox(height: AppSpace.md),
                    Row(
                      children: [
                        Expanded(
                          child: PillButton(
                            label: s.paymentUtang,
                            icon: Icons.menu_book_outlined,
                            variant: PillVariant.outline,
                            expand: true,
                            onPressed: problems.isEmpty ? () => Navigator.of(context).pop(PaymentType.utang) : null,
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: PillButton(
                            label: s.paymentCash,
                            icon: Icons.payments_outlined,
                            expand: true,
                            onPressed: problems.isEmpty ? () => Navigator.of(context).pop(PaymentType.cash) : null,
                          ),
                        ),
                      ],
                    ),
                    if (problems.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      Text(s.fixCartFirst, style: AppType.caption, textAlign: TextAlign.center),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
