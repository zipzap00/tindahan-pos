import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/customer.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/states.dart';
import '../../widgets/tags.dart';
import 'customer_detail_screen.dart';
import 'customer_picker.dart';

/// Utang notebook: who owes how much.
class UtangScreen extends StatefulWidget {
  const UtangScreen({super.key});

  @override
  State<UtangScreen> createState() => _UtangScreenState();
}

class _UtangScreenState extends State<UtangScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    return ListenableBuilder(
      listenable: session.customers,
      builder: (context, _) {
        final all = (session.customers.value ?? const <Customer>[]).where((c) => !c.archived).toList();
        final receivable = all.fold<int>(0, (sum, c) => sum + (c.balance > 0 ? c.balance : 0));
        final debtors = all.where((c) => c.balance > 0).length;
        final query = _query.trim().toLowerCase();
        final shown = all
            .where((c) => query.isEmpty || c.name.toLowerCase().contains(query) || c.phone.contains(query))
            .toList()
          ..sort((a, b) {
            if ((a.balance > 0) != (b.balance > 0)) return a.balance > 0 ? -1 : 1;
            if (a.balance != b.balance) return b.balance.compareTo(a.balance);
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
        final error = session.customers.error;

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpace.xxl),
            children: [
              PageHeader(
                title: s.utangTitle,
                caption: s.utangCaption,
                actions: [
                  IconButton(
                    tooltip: s.addCustomer,
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    onPressed: () => showCustomerForm(context),
                  ),
                ],
              ),
              PagePadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      tone: CardTone.featured,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.totalReceivable.toUpperCase(), style: AppType.eyebrowCap),
                          const SizedBox(height: AppSpace.sm),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(formatPeso(receivable), style: AppType.tabular(AppType.displayMd)),
                          ),
                          Text(s.customersWithBalance(debtors), style: AppType.bodyMd),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    SearchField(
                      controller: _search,
                      hint: s.searchCustomerHint,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    if (error != null)
                      ErrorCard(error: error, onRetry: session.customers.retry)
                    else if (session.customers.isLoading)
                      const LoadingBlocks()
                    else if (all.isEmpty)
                      EmptyState(
                        icon: Icons.menu_book_outlined,
                        message: s.noCustomersYet,
                        actionLabel: s.addCustomer,
                        onAction: () => showCustomerForm(context),
                      )
                    else if (shown.isEmpty)
                      EmptyState(icon: Icons.search_off_rounded, message: s.noCustomersFound)
                    else
                      ListCard(
                        children: [
                          for (final customer in shown)
                            ListRow(
                              leading: InitialsAvatar(name: customer.name),
                              title: customer.name,
                              subtitle: customer.phone,
                              trailing: customer.balance > 0
                                  ? Text(formatPeso(customer.balance), style: AppType.tabular(AppType.bodyStrong))
                                  : TagPill(label: s.paidUp, tone: TagTone.mint, icon: Icons.check_rounded),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => CustomerDetailScreen(customerId: customer.id),
                                ),
                              ),
                            ),
                        ],
                      ),
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
