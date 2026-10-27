import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/result.dart';
import '../../../core/theme/tokens.dart';
import '../../scopes.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CenteredLoader(message: context.s.openingStore));
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
            PagePadding(child: Text(s.accessDisabledBody, style: AppType.bodyMd)),
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
                  Text(notConfigured ? s.setupNeededBody : s.startupFailedBody, style: AppType.bodyMd),
                  const SizedBox(height: AppSpace.lg),
                  if (notConfigured)
                    Container(
                      padding: const EdgeInsets.all(AppSpace.lg),
                      decoration: const BoxDecoration(color: AppColors.canvasNight, borderRadius: AppRadius.input),
                      child: Text(
                        'dart pub global activate flutterfire_cli\nflutterfire configure',
                        style: AppType.bodyMd.copyWith(color: AppColors.onDark, fontFamily: 'monospace'),
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
