import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

enum CardTone {
  /// Default card: white, 1 px hairline, subtle shadow.
  plain,

  /// Mint tint: the one highlighted card on a screen.
  featured,

  /// Quiet mint wash for a group of facts.
  band,

  /// Elevated card: white, 16 px radius, medium shadow.
  raised,
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.tone = CardTone.plain,
    this.padding = const EdgeInsets.all(AppSpace.card),
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final CardTone tone;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      CardTone.plain || CardTone.raised => AppColors.surface,
      CardTone.featured => AppColors.primaryTint,
      CardTone.band => AppColors.primaryWash,
    };
    final radius = tone == CardTone.raised ? AppRadius.cardElevated : AppRadius.card;
    final decoration = BoxDecoration(
      color: color,
      borderRadius: radius,
      border: switch (tone) {
        CardTone.plain => Border.all(color: AppColors.hairline),
        CardTone.featured || CardTone.band => Border.all(color: AppColors.primaryBorder),
        CardTone.raised => null,
      },
      boxShadow: switch (tone) {
        CardTone.plain => AppShadows.subtle,
        CardTone.raised => AppShadows.medium,
        CardTone.featured || CardTone.band => null,
      },
    );
    final body = Padding(padding: padding, child: child);
    final tap = onTap;
    return Semantics(
      label: semanticLabel,
      button: tap != null,
      child: DecoratedBox(
        decoration: decoration,
        child: tap == null
            ? body
            : Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: radius,
                  onTap: tap,
                  child: body,
                ),
              ),
      ),
    );
  }
}

/// A white card holding rows separated by hairlines (ui-rules: lists live in
/// one card, rows are not separate cards).
class ListCard extends StatelessWidget {
  const ListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(const Divider(height: 1, indent: AppSpace.lg, endIndent: AppSpace.lg));
      rows.add(children[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.hairline),
        boxShadow: AppShadows.subtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }
}

/// One row inside a [ListCard]: 64 px minimum, optional leading and trailing.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.titleMaxLines = 2,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final lead = leading;
    final trail = trailing;
    final sub = subtitle;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
        child: Row(
          children: [
            if (lead != null) ...[lead, const SizedBox(width: AppSpace.md)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppType.bodyStrong, maxLines: titleMaxLines, overflow: TextOverflow.ellipsis),
                  if (sub != null && sub.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.xxs),
                    Text(sub, style: AppType.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            if (trail != null) ...[const SizedBox(width: AppSpace.md), trail],
          ],
        ),
      ),
    );
    final tap = onTap;
    if (tap == null) return content;
    return InkWell(onTap: tap, child: content);
  }
}

/// An icon in a round mint chip, so icons sit in panels with the same weight
/// as the initials avatars.
class IconChip extends StatelessWidget {
  const IconChip({super.key, required this.icon, this.size = 40, this.color = AppColors.primaryTint});

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: size * 0.55, color: AppColors.primaryDark),
    );
  }
}

/// Round initials avatar for people (customers, staff). No photos.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? '?'
        : (parts.length == 1
                ? parts.first.substring(0, 1)
                : '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}')
            .toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
      child: Text(initials, style: AppType.bodyStrong.copyWith(color: AppColors.primaryDark)),
    );
  }
}
