import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/result.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/records.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';

/// Who is signed in (name, email, sign-in method, role, store) and, for
/// email-and-password logins, changing the password. Passwords are never
/// shown: Firebase keeps only a one-way hash.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    final user = AppServices.of(context).authRepository.currentUser;
    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder<Member>(
        valueListenable: session.member,
        builder: (context, member, _) {
          final email = user?.email ?? member.email;
          final usesPassword = user != null && AuthRepository.hasPassword(user);
          final usesGoogle = user != null && AuthRepository.hasGoogle(user);
          final method = [
            if (usesGoogle) s.accountSignInGoogle,
            if (usesPassword) s.accountSignInPassword,
          ].join(' · ');
          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpace.xxl),
            children: [
              PageHeader(title: s.accountTitle, caption: email),
              PagePadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListCard(
                      children: [
                        ListRow(
                          leading: const Icon(Icons.person_outline_rounded),
                          title: member.displayName,
                          subtitle: s.accountName,
                          trailing: const Icon(Icons.edit_outlined),
                          onTap: () => _edit(
                            context,
                            title: s.editName,
                            label: s.accountName,
                            initial: member.displayName,
                            done: s.nameUpdated,
                            save: (name) => session.staff.renameMe(member.displayName, name),
                          ),
                        ),
                        ListRow(
                          leading: const Icon(Icons.mail_outline_rounded),
                          title: email,
                          subtitle: s.email,
                        ),
                        if (method.isNotEmpty)
                          ListRow(
                            leading: const Icon(Icons.login_rounded),
                            title: method,
                            subtitle: s.accountSignInMethod,
                          ),
                        ListRow(
                          leading: const Icon(Icons.badge_outlined),
                          title: member.isOwner ? s.roleOwner : s.roleCashier,
                          subtitle: s.accountRole,
                        ),
                        ListenableBuilder(
                          listenable: session.storeName,
                          builder: (context, _) => ListRow(
                            leading: const Icon(Icons.storefront_outlined),
                            title: session.storeName.value ?? '',
                            subtitle: s.accountStore,
                            // The rules let only the owner change the store.
                            trailing: member.isOwner ? const Icon(Icons.edit_outlined) : null,
                            onTap: member.isOwner
                                ? () {
                                    final current = session.storeName.value ?? '';
                                    _edit(
                                      context,
                                      title: s.editStoreName,
                                      label: s.storeName,
                                      initial: current,
                                      done: s.storeNameUpdated,
                                      save: (name) => session.staff.renameStore(current, name),
                                    );
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                    SectionHeader(title: s.accountPasswordTitle),
                    if (usesPassword)
                      _ChangePasswordForm(email: email)
                    else
                      InlineNotice(message: s.accountGooglePasswordNote, icon: Icons.info_outline_rounded),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _edit(
  BuildContext context, {
  required String title,
  required String label,
  required String initial,
  required String done,
  required Future<Result<bool>> Function(String name) save,
}) {
  showAppSheet<void>(
    context,
    builder: (_) => _EditNameSheet(title: title, label: label, initial: initial, done: done, save: save),
  );
}

class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet({
    required this.title,
    required this.label,
    required this.initial,
    required this.done,
    required this.save,
  });

  final String title;
  final String label;
  final String initial;
  final String done;
  final Future<Result<bool>> Function(String name) save;

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.initial);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = context.s;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _name.text.trim();
    if (name == widget.initial) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.save(name);
    if (!mounted) return;
    setState(() => _busy = false);
    result.when<void>(
      ok: (synced) {
        showMessage(context, synced ? widget.done : s.savedOffline);
        Navigator.of(context).pop();
      },
      err: (error) => setState(() => _error = describeError(s, error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final error = _error;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: AppType.subhead),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: widget.label,
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              validator: (value) => (value ?? '').trim().isEmpty ? s.required : null,
            ),
            if (error != null) ...[
              const SizedBox(height: AppSpace.lg),
              InlineNotice(message: error, tone: NoticeTone.warning),
            ],
            const SizedBox(height: AppSpace.xl),
            PillButton(label: s.save, onPressed: _save, loading: _busy, expand: true),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  const _ChangePasswordForm({required this.email});

  final String email;

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _hide = true;
  String? _message;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = context.s;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final result = await AppServices.of(context).authRepository.changePassword(
          currentPassword: _current.text,
          newPassword: _next.text,
        );
    if (!mounted) return;
    final error = result.errorOrNull;
    setState(() {
      _busy = false;
      _message = error == null
          ? null
          : error.code == AppErrorCode.wrongCredentials
              ? s.accountCurrentPasswordWrong
              : describeError(s, error);
    });
    if (error == null) {
      _formKey.currentState?.reset();
      _current.clear();
      _next.clear();
      _confirm.clear();
      showMessage(context, s.accountPasswordChanged);
    }
  }

  Future<void> _sendReset() async {
    final s = context.s;
    final result = await AppServices.of(context).authRepository.sendPasswordReset(widget.email);
    if (!mounted) return;
    final error = result.errorOrNull;
    showMessage(context, error == null ? s.resetEmailSent : describeError(s, error));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final message = _message;
    final toggle = IconButton(
      tooltip: _hide ? s.showPassword : s.hidePassword,
      icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
      onPressed: () => setState(() => _hide = !_hide),
    );
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InlineNotice(message: s.accountPasswordNotShown, icon: Icons.lock_outline_rounded),
          const SizedBox(height: AppSpace.lg),
          AppTextField(
            label: s.accountCurrentPassword,
            controller: _current,
            obscureText: _hide,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.password],
            validator: (value) => (value ?? '').isEmpty ? s.enterPassword : null,
            suffix: toggle,
          ),
          const SizedBox(height: AppSpace.lg),
          AppTextField(
            label: s.accountNewPassword,
            controller: _next,
            obscureText: _hide,
            helper: s.passwordRule,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            validator: (value) {
              final text = value ?? '';
              if (text.length < 6) return s.passwordRule;
              if (text == _current.text) return s.accountSamePassword;
              return null;
            },
          ),
          const SizedBox(height: AppSpace.lg),
          AppTextField(
            label: s.confirmPassword,
            controller: _confirm,
            obscureText: _hide,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (value) => value == _next.text ? null : s.passwordsDoNotMatch,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpace.lg),
            InlineNotice(message: message, icon: Icons.error_outline_rounded, tone: NoticeTone.error),
          ],
          const SizedBox(height: AppSpace.xl),
          PillButton(label: s.accountChangePassword, onPressed: _submit, loading: _busy, expand: true),
          const SizedBox(height: AppSpace.sm),
          PillButton(
            label: s.forgotPassword,
            variant: PillVariant.ghost,
            onPressed: _busy ? null : _sendReset,
          ),
        ],
      ),
    );
  }
}
