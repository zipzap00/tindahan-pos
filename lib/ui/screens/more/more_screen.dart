import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/records.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../expenses/expenses_screen.dart';
import '../inventory/movements_screen.dart';
import '../sales/sales_history_screen.dart';
import 'audit_screen.dart';
import 'staff_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _signOut(BuildContext context) async {
    final s = context.s;
    final controller = AppServices.of(context).sessionController;
    final cart = StoreScope.of(context).cart;
    final confirmed = await showConfirmDialog(
      context,
      title: s.signOutTitle,
      message: cart.isEmpty ? s.signOutMessage : s.signOutCartMessage,
      confirmLabel: s.signOut,
    );
    if (confirmed) await controller.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    final language = LanguageScope.of(context);
    return ValueListenableBuilder<Member>(
      valueListenable: session.member,
      builder: (context, member, _) {
        final isOwner = member.isOwner;
        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpace.xxl),
            children: [
              ListenableBuilder(
                listenable: session.storeName,
                builder: (context, _) => PageHeader(
                  title: s.moreTitle,
                  eyebrow: session.storeName.value,
                  caption: '${member.displayName} · ${isOwner ? s.roleOwner : s.roleCashier}',
                ),
              ),
              PagePadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListCard(
                      children: [
                        ListRow(
                          leading: const Icon(Icons.receipt_long_outlined),
                          title: s.salesHistoryTitle,
                          subtitle: s.salesHistoryCaption,
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _push(context, const SalesHistoryScreen()),
                        ),
                        if (isOwner) ...[
                          ListRow(
                            leading: const Icon(Icons.account_balance_wallet_outlined),
                            title: s.expensesTitle,
                            subtitle: s.expensesCaption,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _push(context, const ExpensesScreen()),
                          ),
                          ListRow(
                            leading: const Icon(Icons.history_rounded),
                            title: s.stockMovementsTitle,
                            subtitle: s.stockMovementsCaption,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _push(context, const MovementsScreen()),
                          ),
                          ListRow(
                            leading: const Icon(Icons.group_outlined),
                            title: s.staffTitle,
                            subtitle: s.staffCaption,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _push(context, const StaffScreen()),
                          ),
                          ListRow(
                            leading: const Icon(Icons.fact_check_outlined),
                            title: s.auditTitle,
                            subtitle: s.auditCaption,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _push(context, const AuditScreen()),
                          ),
                        ],
                      ],
                    ),
                    SectionHeader(title: s.languageTitle),
                    SegmentedPills<AppLanguage>(
                      options: AppLanguage.values,
                      selected: language.language,
                      labelOf: (value) => value == AppLanguage.fil ? 'Filipino' : 'English',
                      onSelected: language.setLanguage,
                    ),
                    SectionHeader(title: s.aboutTitle),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.aboutBody, style: AppType.bodyMd),
                          const SizedBox(height: AppSpace.sm),
                          Text(s.timeZoneNote, style: AppType.micro),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.xl),
                    PillButton(
                      label: s.signOut,
                      icon: Icons.logout_rounded,
                      variant: PillVariant.outline,
                      expand: true,
                      onPressed: () => _signOut(context),
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
