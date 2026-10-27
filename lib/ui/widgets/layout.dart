import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// Large page title for tab screens: optional eyebrow, thin display title,
/// optional caption and up to two actions.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.caption,
    this.actions = const [],
  });

  final String title;
  final String? eyebrow;
  final String? caption;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final eyebrowText = eyebrow;
    final captionText = caption;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.lg, AppSpace.sm, AppSpace.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrowText != null) ...[
                  Text(eyebrowText.toUpperCase(), style: AppType.eyebrowCap.copyWith(color: AppColors.textSmall)),
                  const SizedBox(height: AppSpace.sm),
                ],
                Semantics(header: true, child: Text(title, style: AppType.displayMobile)),
                if (captionText != null) ...[
                  const SizedBox(height: AppSpace.xs),
                  Text(captionText, style: AppType.caption),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.xl, bottom: AppSpace.md),
      child: Row(
        children: [
          Expanded(child: Semantics(header: true, child: Text(title, style: AppType.headingSm))),
          if (label != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink,
                minimumSize: const Size(48, AppSpace.minTouch),
                textStyle: AppType.caption.copyWith(
                  color: AppColors.ink,
                  decoration: TextDecoration.underline,
                ),
              ),
              child: Text(label),
            ),
        ],
      ),
    );
  }
}

/// Label on the left, value on the right.
class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.label, required this.value, this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xs + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasize ? AppType.bodyStrong : AppType.bodyMd.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppType.tabular(emphasize ? AppType.bodyStrong : AppType.bodyMd),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small figure card for dashboard grids.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.caption, this.icon, this.onTap});

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final captionText = caption;
    final tileIcon = icon;
    final content = Padding(
      padding: const EdgeInsets.all(AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (tileIcon != null) ...[Icon(tileIcon, size: 18), const SizedBox(width: AppSpace.xs + 2)],
              Expanded(child: Text(label, style: AppType.caption, maxLines: 2)),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppType.tabular(AppType.headingLg)),
          ),
          if (captionText != null) ...[
            const SizedBox(height: AppSpace.xs),
            Text(captionText, style: AppType.micro, maxLines: 2),
          ],
        ],
      ),
    );
    final tap = onTap;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvasLight,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.hairlineLight),
      ),
      child: tap == null
          ? content
          : Material(
              type: MaterialType.transparency,
              child: InkWell(borderRadius: AppRadius.card, onTap: tap, child: content),
            ),
    );
  }
}

/// White bar pinned to the bottom of a screen for its main action.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvasLight,
        border: Border(top: BorderSide(color: AppColors.hairlineLight)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.md),
      child: SafeArea(top: false, child: child),
    );
  }
}

/// Standard scrolling page body with screen padding.
class PagePadding extends StatelessWidget {
  const PagePadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen), child: child);
  }
}
