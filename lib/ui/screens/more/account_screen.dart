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
