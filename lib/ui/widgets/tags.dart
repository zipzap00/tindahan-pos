import 'package:flutter/material.dart';

import '../../core/l10n/language.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/product.dart';

enum TagTone {
  /// pill-tag-mint: good state (in stock, paid).
  mint,

  /// pill-tag-shade: neutral or needs attention (low stock, refunded).
  shade,

  /// Inverse ink pill: strongest state (out of stock, cancelled).
  ink,

  /// White pill with hairline: plain information.
  outline,
}

/// Small status pill. Never tappable. Always words plus an icon, never colour
/// alone.
class TagPill extends StatelessWidget {
  const TagPill({super.key, required this.label, this.tone = TagTone.shade, this.icon});

  final String label;
  final TagTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, Border? border) = switch (tone) {
      TagTone.mint => (AppColors.aloe10, AppColors.ink, null),
      TagTone.shade => (AppColors.shade30, AppColors.ink, null),
      TagTone.ink => (AppColors.ink, AppColors.onPrimary, null),
      TagTone.outline => (AppColors.canvasLight, AppColors.ink, Border.all(color: AppColors.hairlineLight)),
    };
    final tagIcon = icon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.xs),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tagIcon != null) ...[
            Icon(tagIcon, size: 14, color: foreground),
            const SizedBox(width: AppSpace.xs),
          ],
          Text(label.toUpperCase(), style: AppType.eyebrowCap.copyWith(color: foreground)),
        ],
      ),
    );
  }
}

class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.status});

  final StockStatus status;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return switch (status) {
      StockStatus.inStock =>
        TagPill(label: s.stockStatusLabel(status), tone: TagTone.mint, icon: Icons.check_rounded),
      StockStatus.low =>
        TagPill(label: s.stockStatusLabel(status), tone: TagTone.shade, icon: Icons.trending_down_rounded),
      StockStatus.out =>
        TagPill(label: s.stockStatusLabel(status), tone: TagTone.ink, icon: Icons.block_rounded),
    };
  }
}
