import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

enum CardTone {
  /// card-pricing: white, 1 px hairline, flat.
  plain,

  /// card-pricing-featured: aloe fill. The one highlighted card on a screen.
  featured,

  /// card-pistachio-band: wide pistachio band for a group of facts.
  band,

  /// White with DESIGN.md level-3 stacked shadows.
  raised,
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.tone = CardTone.plain,
    this.padding = const EdgeInsets.all(AppSpace.xl),
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
      CardTone.plain || CardTone.raised => AppColors.canvasLight,
      CardTone.featured => AppColors.aloe10,
      CardTone.band => AppColors.pistachio10,
    };
    final decoration = BoxDecoration(
      color: color,
      borderRadius: AppRadius.card,
      border: tone == CardTone.plain ? Border.all(color: AppColors.hairlineLight) : null,
      boxShadow: tone == CardTone.raised ? AppShadows.level3 : null,
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
                  borderRadius: AppRadius.card,
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
        color: AppColors.canvasLight,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.hairlineLight),
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
                    Text(sub, style: AppType.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
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
      decoration: const BoxDecoration(color: AppColors.pistachio10, shape: BoxShape.circle),
      child: Text(initials, style: AppType.bodyStrong),
    );
  }
}
