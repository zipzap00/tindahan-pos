import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/theme/tokens.dart';
import '../../scopes.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';

/// The one cinematic (night canvas) screen: black, thin display type, a
/// white-stroked pill. Everything after it is the light transactional track.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final language = LanguageScope.of(context);
    final isEnglish = language.language == AppLanguage.en;
    return Scaffold(
      backgroundColor: AppColors.canvasNight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpace.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.appName,
                            style: AppType.headingMd.copyWith(color: AppColors.onDark),
                          ),
                        ),
                        TextButton(
                          onPressed: () => language.setLanguage(isEnglish ? AppLanguage.fil : AppLanguage.en),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.onDark,
                            minimumSize: const Size(48, AppSpace.minTouch),
                            shape: const StadiumBorder(side: BorderSide(color: AppColors.onDark)),
                            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
                          ),
                          child: Text(
                            isEnglish ? 'Filipino' : 'English',
                            style: AppType.caption.copyWith(color: AppColors.onDark),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(height: AppSpace.huge),
                    Text(
                      s.welcomeEyebrow.toUpperCase(),
                      style: AppType.eyebrowCap.copyWith(color: AppColors.linkCool1),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    Text(s.welcomeHeadline, style: AppType.displayHero),
                    const SizedBox(height: AppSpace.xl),
                    Text(s.welcomeLead, style: AppType.bodyLg.copyWith(color: AppColors.linkCool3)),
                    const Spacer(),
                    const SizedBox(height: AppSpace.huge),
                    PillButton(
                      label: s.createStoreAccount,
                      variant: PillVariant.outlineOnDark,
                      expand: true,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    const GoogleSignInButton(variant: PillVariant.outlineOnDark),
                    const SizedBox(height: AppSpace.md),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.onDark,
                          minimumSize: const Size(48, AppSpace.minTouch),
                        ),
                        child: Text(
                          s.haveAccountSignIn,
                          style: AppType.bodyMd.copyWith(
                            color: AppColors.onDark,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.onDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Continue with Google": signs in or signs up in one step. A new account
/// goes on to create-store like an email sign-up does.
class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key, required this.variant});

  final PillVariant variant;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _busy = false;

  Future<void> _signIn() async {
    final s = context.s;
    setState(() => _busy = true);
    final result = await AppServices.of(context).authRepository.signInWithGoogle();
    if (!mounted) return;
    setState(() => _busy = false);
    final error = result.errorOrNull;
    if (error != null) showMessage(context, describeError(s, error));
  }

  @override
  Widget build(BuildContext context) {
    return PillButton(
      label: context.s.continueWithGoogle,
      variant: widget.variant,
      icon: Icons.account_circle_outlined,
      loading: _busy,
      expand: true,
      onPressed: _signIn,
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _hidePassword = true;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = context.s;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final result = await AppServices.of(context).authRepository.signIn(
          email: _email.text,
          password: _password.text,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = result.errorOrNull == null ? null : describeError(s, result.errorOrNull!);
    });
  }

  Future<void> _resetPassword() async {
    final s = context.s;
    if (_email.text.trim().isEmpty) {
      setState(() => _message = s.enterEmailFirst);
      return;
    }
    final result = await AppServices.of(context).authRepository.sendPasswordReset(_email.text);
    if (!mounted) return;
    final error = result.errorOrNull;
    showMessage(context, error == null ? s.resetEmailSent : describeError(s, error));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final message = _message;
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpace.xl),
          children: [
            PageHeader(title: s.signInTitle, caption: s.signInCaption),
            PagePadding(
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: s.email,
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) => (value ?? '').trim().contains('@') ? null : s.enterValidEmail,
                    ),
                    const SizedBox(height: AppSpace.lg),
                    AppTextField(
                      label: s.password,
                      controller: _password,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      validator: (value) => (value ?? '').isEmpty ? s.enterPassword : null,
                      suffix: IconButton(
                        tooltip: _hidePassword ? s.showPassword : s.hidePassword,
                        icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppSpace.lg),
                      InlineNotice(message: message, icon: Icons.error_outline_rounded),
                    ],
                    const SizedBox(height: AppSpace.xl),
                    PillButton(label: s.signIn, onPressed: _submit, loading: _busy, expand: true),
                    const SizedBox(height: AppSpace.sm),
                    PillButton(
                      label: s.forgotPassword,
                      variant: PillVariant.ghost,
                      onPressed: _busy ? null : _resetPassword,
                    ),
                    const SizedBox(height: AppSpace.lg),
                    const GoogleSignInButton(variant: PillVariant.outline),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
    final result = await AppServices.of(context).authRepository.createAccount(
          email: _email.text,
          password: _password.text,
        );
    if (!mounted) return;
    final error = result.errorOrNull;
    setState(() {
      _busy = false;
      _message = error == null ? null : describeError(s, error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final message = _message;
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpace.xl),
          children: [
            PageHeader(eyebrow: s.stepOneOfTwo, title: s.signUpTitle, caption: s.signUpCaption),
            PagePadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: s.email,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) => (value ?? '').trim().contains('@') ? null : s.enterValidEmail,
                  ),
                  const SizedBox(height: AppSpace.lg),
                  AppTextField(
                    label: s.password,
                    controller: _password,
                    obscureText: true,
                    helper: s.passwordRule,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) => (value ?? '').length >= 6 ? null : s.passwordRule,
                  ),
                  const SizedBox(height: AppSpace.lg),
                  AppTextField(
                    label: s.confirmPassword,
                    controller: _confirm,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: (value) => value == _password.text ? null : s.passwordsDoNotMatch,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: AppSpace.lg),
                    InlineNotice(message: message, icon: Icons.error_outline_rounded),
                  ],
                  const SizedBox(height: AppSpace.xl),
                  PillButton(label: s.createAccount, onPressed: _submit, loading: _busy, expand: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
