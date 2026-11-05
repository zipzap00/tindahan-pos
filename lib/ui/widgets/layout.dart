import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import 'cards.dart';

/// Holds the whole app, Navigator included, to [AppSpace.maxContentWidth], so
/// pushed screens, sheets and dialogs all stay in the same column on a wide
/// browser window. On a phone it changes nothing.
///
/// The widget tree is the same at every width: resizing the window across the
/// limit must not rebuild the Navigator and lose the user's place.
class AppViewport extends StatelessWidget {
  const AppViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final wide = media.size.width > AppSpace.maxContentWidth;
    final width = wide ? AppSpace.maxContentWidth : media.size.width;
    final edge = BorderSide(color: AppColors.hairline);
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: SizedBox(
          width: width,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              border: wide ? Border(left: edge, right: edge) : null,
            ),
            child: MediaQuery(
              data: media.copyWith(size: Size(width, media.size.height)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Large page title for tab screens: optional eyebrow, headline title,
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
                  Text(eyebrowText.toUpperCase(), style: AppType.overline.copyWith(color: AppColors.textSmall)),
                  const SizedBox(height: AppSpace.sm),
                ],
                Semantics(header: true, child: Text(title, style: AppType.headline)),
                if (captionText != null) ...[
                  const SizedBox(height: AppSpace.xs),
                  Text(captionText, style: AppType.bodySmall),
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
      padding: const EdgeInsets.only(top: AppSpace.section, bottom: AppSpace.md),
      child: Row(
        children: [
          Expanded(child: Semantics(header: true, child: Text(title, style: AppType.subhead))),
          if (label != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(48, AppSpace.minTouch),
                textStyle: AppType.chip,
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
              style: emphasize ? AppType.bodyStrong : AppType.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppType.tabular(emphasize ? AppType.bodyStrong : AppType.body),
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
              if (tileIcon != null) ...[IconChip(icon: tileIcon, size: 32), const SizedBox(width: AppSpace.sm)],
              Expanded(child: Text(label, style: AppType.bodySmall, maxLines: 2)),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppType.tabular(AppType.subhead)),
          ),
          if (captionText != null) ...[
            const SizedBox(height: AppSpace.xs),
            Text(captionText, style: AppType.caption, maxLines: 2),
          ],
        ],
      ),
    );
    final tap = onTap;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.hairline),
        boxShadow: AppShadows.subtle,
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
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
