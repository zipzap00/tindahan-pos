import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/result.dart';
import '../../../core/theme/tokens.dart';
import '../../scopes.dart';
import '../../widgets/brand.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';

/// Start-up loading screen. The store opens: the awning unrolls stripe by
/// stripe, the lights come on, then the name appears.
///
/// It starts from the closed store that the Android and iOS launch images and
/// web/index.html show, with the mark dead centre and at the same size, so the
/// hand-over from the platform to Flutter is not visible. Keep [markHeight] and
/// the bar position in step with those (tool/generate_brand_assets.dart and
/// web/index.html).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const double markHeight = 120;
  static const double _barWidth = 144;
  static const double _barHeight = 4;

  /// Shorter than [AuthGate.minSplash], so the opening always finishes.
  static const Duration openingDuration = Duration(milliseconds: 1300);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _opening =
      AnimationController(vsync: this, duration: SplashScreen.openingDuration);
  late final Animation<double> _awning =
      CurvedAnimation(parent: _opening, curve: const Interval(0.05, 0.62, curve: Curves.easeInOut));
  late final Animation<double> _lights =
      CurvedAnimation(parent: _opening, curve: const Interval(0.55, 0.78, curve: Curves.easeOut));
  late final Animation<double> _name =
      CurvedAnimation(parent: _opening, curve: const Interval(0.6, 0.92, curve: Curves.easeOut));
  late final Animation<Offset> _nameRise =
      Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(_name);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _opening.value = 1;
    } else {
      _opening.forward();
    }
  }

  @override
  void dispose() {
    _opening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    // Equal space above and below keeps the mark exactly centred.
    const belowMark = SplashScreen.markHeight;
    return Scaffold(
      body: Center(
        child: Semantics(
          liveRegion: true,
          label: s.openingStore,
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: belowMark),
                RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _opening,
                    builder: (context, _) => AppLogoMark(
                      height: SplashScreen.markHeight,
                      awning: _awning.value,
                      lights: _lights.value,
                    ),
                  ),
                ),
                SizedBox(
                  height: belowMark,
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpace.xl),
                      SizedBox(
                        height: AppSpace.xl,
                        child: FadeTransition(
                          opacity: _name,
                          child: SlideTransition(position: _nameRise, child: const AppWordmark(height: AppSpace.xl)),
                        ),
                      ),
                      const SizedBox(height: AppSpace.lg + AppSpace.xs),
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          SizedBox(
                            width: SplashScreen._barWidth,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
                              child: LinearProgressIndicator(
                                minHeight: SplashScreen._barHeight,
                                backgroundColor: AppColors.hairline,
                              ),
                            ),
                          ),
                          Positioned(
                            top: SplashScreen._barHeight + AppSpace.md,
                            child: FadeTransition(
                              opacity: _name,
                              child: Text(s.openingStore, style: AppType.bodySmall, maxLines: 1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// New email-and-password sign-ups wait here until they open the emailed link.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false;
  bool _sending = false;
  String? _message;
  NoticeTone _tone = NoticeTone.info;

  void _show(String message, NoticeTone tone) {
    setState(() {
      _checking = false;
      _sending = false;
      _message = message;
      _tone = tone;
    });
  }

  Future<void> _check() async {
    final s = context.s;
    setState(() {
      _checking = true;
      _message = null;
    });
    final result = await AppServices.of(context).sessionController.checkEmailVerified();
    if (!mounted) return;
    result.when<void>(
      ok: (verified) {
        if (!verified) _show(s.emailNotConfirmedYet, NoticeTone.warning);
      },
      err: (error) => _show(describeError(s, error), NoticeTone.warning),
    );
  }

  Future<void> _resend() async {
    final s = context.s;
    setState(() {
      _sending = true;
      _message = null;
    });
    final result = await AppServices.of(context).authRepository.sendVerificationEmail();
    if (!mounted) return;
    result.when<void>(
      ok: (_) => _show(s.verificationSent, NoticeTone.info),
      err: (error) => _show(describeError(s, error), NoticeTone.warning),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final message = _message;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpace.xl),
          children: [
            PageHeader(eyebrow: s.stepOneOfTwo, title: s.verifyEmailTitle, caption: widget.email),
            PagePadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.verifyEmailBody, style: AppType.body),
                  const SizedBox(height: AppSpace.lg),
                  if (message != null) ...[
                    InlineNotice(message: message, tone: _tone),
                    const SizedBox(height: AppSpace.lg),
                  ],
                  PillButton(label: s.emailConfirmedButton, expand: true, loading: _checking, onPressed: _check),
                  const SizedBox(height: AppSpace.md),
                  PillButton(
                    label: s.resendEmail,
                    variant: PillVariant.outline,
                    expand: true,
                    loading: _sending,
                    onPressed: _resend,
                  ),
                  const SizedBox(height: AppSpace.md),
                  PillButton(
                    label: s.signOut,
                    variant: PillVariant.ghost,
                    expand: true,
                    onPressed: AppServices.of(context).sessionController.signOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccessDisabledScreen extends StatelessWidget {
  const AccessDisabledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpace.xl),
          children: [
            PageHeader(title: s.accessDisabledTitle),
            PagePadding(child: Text(s.accessDisabledBody, style: AppType.body)),
            const SizedBox(height: AppSpace.xl),
            PagePadding(
              child: PillButton(
                label: s.signOut,
                variant: PillVariant.outline,
                onPressed: () => AppServices.of(context).sessionController.signOut(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionErrorScreen extends StatelessWidget {
  const SessionErrorScreen({super.key, required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final controller = AppServices.of(context).sessionController;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpace.xl),
          children: [
            PageHeader(title: s.somethingWentWrong),
            PagePadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ErrorCard(error: error, onRetry: controller.retry),
                  const SizedBox(height: AppSpace.lg),
                  PillButton(label: s.signOut, variant: PillVariant.ghost, onPressed: controller.signOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when lib/firebase_options.dart has not been generated yet.
class SetupNeededScreen extends StatelessWidget {
  const SetupNeededScreen({super.key, this.error});

  final AppError? error;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final notConfigured = error?.code == AppErrorCode.notConfigured;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpace.xl),
          children: [
            PageHeader(title: s.setupNeededTitle),
            PagePadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(notConfigured ? s.setupNeededBody : s.startupFailedBody, style: AppType.body),
                  const SizedBox(height: AppSpace.lg),
                  if (notConfigured)
                    Container(
                      padding: const EdgeInsets.all(AppSpace.lg),
                      decoration: BoxDecoration(color: AppColors.ink, borderRadius: AppRadius.input),
                      child: Text(
                        'dart pub global activate flutterfire_cli\nflutterfire configure',
                        style: AppType.code.copyWith(color: AppColors.onInk),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
