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
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl, vertical: AppSpace.xxl),
      child: Column(
        children: [
          IconChip(icon: icon, size: AppSpace.huge),
          const SizedBox(height: AppSpace.lg),
          Text(message, style: AppType.body, textAlign: TextAlign.center),
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
          const Icon(Icons.error_outline_rounded, size: 28, color: AppColors.error),
          const SizedBox(height: AppSpace.sm),
          Text(describeError(s, error), style: AppType.body),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpace.lg),
            PillButton(label: s.retry, onPressed: onRetry, variant: PillVariant.outline, icon: Icons.refresh_rounded),
          ],
        ],
      ),
    );
  }
}

/// Grey blocks shaped like the content that is loading. They pulse gently so
/// a slow connection does not look like a frozen screen.
class LoadingBlocks extends StatefulWidget {
  const LoadingBlocks({super.key, this.count = 4, this.height = 64});

  final int count;
  final double height;

  @override
  State<LoadingBlocks> createState() => _LoadingBlocksState();
}

class _LoadingBlocksState extends State<LoadingBlocks> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final Animation<double> _opacity =
      Tween<double>(begin: 1, end: 0.5).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.s.loading,
      child: FadeTransition(
        opacity: _opacity,
        child: Column(
          children: [
            for (var i = 0; i < widget.count; i++)
              Container(
                height: widget.height,
                margin: const EdgeInsets.only(bottom: AppSpace.md),
                decoration: BoxDecoration(color: AppColors.hairline, borderRadius: AppRadius.card),
              ),
          ],
        ),
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
            Text(text, style: AppType.bodySmall, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

enum NoticeTone {
  /// Sky: tips and helpful information.
  info,

  /// Amber: look at this before going on.
  warning,

  /// Red: something failed.
  error,
}

/// Small tinted note with an icon. The icon and words carry the meaning; the
/// tone only supports them.
class InlineNotice extends StatelessWidget {
  const InlineNotice({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.tone = NoticeTone.info,
  });

  final String message;
  final IconData icon;
  final NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color fill, Color border, Color iconColor) = switch (tone) {
      NoticeTone.info => (AppColors.infoTint, AppColors.infoBorder, AppColors.info),
      NoticeTone.warning => (AppColors.warningTint, AppColors.warningBorder, AppColors.warningText),
      NoticeTone.error => (AppColors.errorTint, AppColors.errorBorder, AppColors.errorDark),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: AppRadius.card,
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: AppSpace.sm),
          Expanded(child: Text(message, style: AppType.body)),
        ],
      ),
    );
  }
}
