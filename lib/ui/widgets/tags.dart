import 'package:flutter/material.dart';

import '../../core/l10n/language.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/product.dart';

enum TagTone {
  /// On track: in stock, paid, completed.
  success,

  /// At risk: low stock.
  warning,

  /// Over budget: out of stock, cancelled. Keep it rare.
  error,

  /// Plain information: category, archived, refunded.
  neutral,
}

/// Small status chip. Never tappable. A status always has words and an icon,
/// never colour alone.
class TagPill extends StatelessWidget {
  const TagPill({super.key, required this.label, this.tone = TagTone.neutral, this.icon});

  final String label;
  final TagTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, Color border) = switch (tone) {
      TagTone.success => (AppColors.primaryTint, AppColors.primaryDark, AppColors.primaryBorder),
      TagTone.warning => (AppColors.warningTint, AppColors.warningText, AppColors.warningBorder),
      TagTone.error => (AppColors.errorTint, AppColors.errorDark, AppColors.errorBorder),
      TagTone.neutral => (AppColors.surfaceMuted, AppColors.stoneDark, AppColors.hairline),
    };
    final tagIcon = icon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: AppSpace.xs),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.chip,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tagIcon != null) ...[
            Icon(tagIcon, size: 14, color: foreground),
            const SizedBox(width: AppSpace.xs),
          ],
          Text(label, style: AppType.caption.copyWith(color: foreground)),
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
        TagPill(label: s.stockStatusLabel(status), tone: TagTone.success, icon: Icons.check_rounded),
      StockStatus.low =>
        TagPill(label: s.stockStatusLabel(status), tone: TagTone.warning, icon: Icons.trending_down_rounded),
      StockStatus.out =>
        TagPill(label: s.stockStatusLabel(status), tone: TagTone.error, icon: Icons.block_rounded),
    };
  }
}
