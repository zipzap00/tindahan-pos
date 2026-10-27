import 'package:flutter/material.dart';

import '../../core/l10n/language.dart';
import '../../core/l10n/strings.dart';
import '../../core/result.dart';
import '../../core/theme/tokens.dart';
import 'cards.dart';
import 'pill_button.dart';

/// Human message for an error. Raw exceptions are never shown.
String describeError(Strings s, AppError error) {
  final detail = error.detail;
  if (error.code == AppErrorCode.insufficientStock && detail != null) {
    return s.notEnoughStockFor(detail);
  }
  return s.errorMessage(error.code);
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message, this.actionLabel, this.onAction});

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return AppCard(
      tone: CardTone.band,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl, vertical: AppSpace.xxl),
      child: Column(
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: AppSpace.md),
          Text(message, style: AppType.bodyMd, textAlign: TextAlign.center),
          if (label != null && onAction != null) ...[
            const SizedBox(height: AppSpace.lg),
            PillButton(label: label, onPressed: onAction, variant: PillVariant.outline),
          ],
        ],
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.error, this.onRetry});

  final AppError error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 28),
          const SizedBox(height: AppSpace.sm),
          Text(describeError(s, error), style: AppType.bodyMd),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpace.lg),
            PillButton(label: s.retry, onPressed: onRetry, variant: PillVariant.outline, icon: Icons.refresh_rounded),
          ],
        ],
      ),
    );
  }
}

/// Grey blocks shaped like the content that is loading.
class LoadingBlocks extends StatelessWidget {
  const LoadingBlocks({super.key, this.count = 4, this.height = 64});

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.s.loading,
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            Container(
              height: height,
              margin: const EdgeInsets.only(bottom: AppSpace.md),
              decoration: const BoxDecoration(color: AppColors.hairlineLight, borderRadius: AppRadius.card),
            ),
        ],
      ),
    );
  }
}

class CenteredLoader extends StatelessWidget {
  const CenteredLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (text != null) ...[
            const SizedBox(height: AppSpace.lg),
            Text(text, style: AppType.caption, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Small ink note with an icon, used for warnings (no warning colour exists
/// in the design system, so the icon and words carry the meaning).
class InlineNotice extends StatelessWidget {
  const InlineNotice({super.key, required this.message, this.icon = Icons.info_outline_rounded});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.canvasLight,
        borderRadius: AppRadius.input,
        border: Border.all(color: AppColors.ink),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppSpace.sm),
          Expanded(child: Text(message, style: AppType.bodyMd)),
        ],
      ),
    );
  }
}
