import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/live_query.dart';
import '../../../data/models/records.dart';
import '../../../data/store_session.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';
import '../../widgets/tags.dart';

/// Owner adds cashiers and turns their access on or off. Cashiers can sell,
/// view stock and record utang; they cannot see costs or profit, edit
/// products, refund or cancel sales.
class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  LiveQuery<List<Member>>? _members;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_members != null) return;
    final staff = StoreScope.of(context).staff;
    _members = LiveQuery<List<Member>>(staff.watchMembers, context: '[staff/list]');
  }

  @override
  void dispose() {
    _members?.dispose();
    super.dispose();
  }

  Future<void> _setActive(StoreSession session, Member member, bool active) async {
    final s = context.s;
    if (!active) {
      final confirmed = await showConfirmDialog(
        context,
        title: s.disableCashierTitle,
        message: s.disableCashierMessage(member.displayName),
        confirmLabel: s.disable,
      );
      if (!confirmed || !mounted) return;
    }
    final result = await session.staff.setActive(member, active: active);
    if (!mounted) return;
    final error = result.errorOrNull;
    if (error != null) showMessage(context, describeError(s, error));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    final members = _members;
    if (members == null) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: Text(s.staffTitle)),
      body: ListenableBuilder(
        listenable: members,
        builder: (context, _) {
          final error = members.error;
          final list = members.value ?? const <Member>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.xl),
            children: [
              Text(s.cashierRightsNote, style: AppType.caption),
              const SizedBox(height: AppSpace.lg),
              if (error != null)
                ErrorCard(error: error, onRetry: members.retry)
              else if (members.isLoading)
                const LoadingBlocks(count: 2)
              else
                ListCard(
                  children: [
                    for (final member in list)
                      ListRow(
                        leading: InitialsAvatar(name: member.displayName),
                        title: member.displayName,
                        subtitle: member.email,
                        trailing: member.isOwner
                            ? TagPill(label: s.roleOwner, tone: TagTone.mint)
                            : Switch(
                                value: member.active,
                                onChanged: (value) => _setActive(session, member, value),
                              ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomActionBar(
        child: PillButton(
          label: s.addCashier,
          icon: Icons.person_add_alt_1_outlined,
          expand: true,
          onPressed: () => showAppSheet<void>(context, builder: (_) => _AddCashierSheet(session: session)),
        ),
      ),
    );
  }
}

class _AddCashierSheet extends StatefulWidget {
  const _AddCashierSheet({required this.session});

  final StoreSession session;

  @override
  State<_AddCashierSheet> createState() => _AddCashierSheetState();
}

class _AddCashierSheetState extends State<_AddCashierSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = context.s;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final result = await widget.session.staff.createCashier(
      displayName: _name.text,
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.when<void>(
      ok: (_) {
        Navigator.of(context).pop();
        showMessage(context, s.cashierAdded);
      },
      err: (error) => showMessage(context, describeError(s, error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.addCashier, style: AppType.headingLg),
            const SizedBox(height: AppSpace.xs),
            Text(s.addCashierCaption, style: AppType.caption),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: s.cashierName,
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) => (value ?? '').trim().isEmpty ? s.required : null,
            ),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: s.email,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) => (value ?? '').trim().contains('@') ? null : s.enterValidEmail,
            ),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: s.temporaryPassword,
              controller: _password,
              helper: s.passwordRule,
              validator: (value) => (value ?? '').length >= 6 ? null : s.passwordRule,
            ),
            const SizedBox(height: AppSpace.xl),
            PillButton(label: s.addCashier, onPressed: _save, loading: _busy, expand: true),
          ],
        ),
      ),
    );
  }
}
