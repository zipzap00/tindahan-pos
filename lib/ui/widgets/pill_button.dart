import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// DESIGN.md button vocabulary. The name is historic: every button is the
/// Large size, 48 px high with a 12 px radius, which also meets the touch target.
enum PillVariant {
  /// Primary: mint fill, white label. One per screen.
  primary,

  /// Secondary: no fill, mint label, 1.5 px mint border.
  outline,

  /// Ghost: no fill, stone label, for low-emphasis actions (cancel, see all).
  ghost,

  /// Destructive: red fill, white label. Only to confirm losing something.
  destructive,
}

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PillVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  /// Label with optional icon. Only a full-width button may let its text
  /// flex; an intrinsic-width button can sit in a Row with unbounded width.
  Widget _label() {
    final text = Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis);
    final leading = icon;
    if (leading == null) return text;
    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(leading, size: 20),
        const SizedBox(width: AppSpace.sm),
        if (expand) Flexible(child: text) else text,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final disabled = onPressed == null && !loading;

    Color background(Set<WidgetState> states) {
      final pressed = states.contains(WidgetState.pressed);
      return switch (variant) {
        PillVariant.primary =>
          disabled ? AppColors.warmGray : (pressed ? AppColors.primaryDark : AppColors.primary),
        PillVariant.destructive =>
          disabled ? AppColors.warmGray : (pressed ? AppColors.errorDark : AppColors.error),
        PillVariant.outline => pressed ? AppColors.primaryTint : Colors.transparent,
        PillVariant.ghost => pressed ? AppColors.surfaceMuted : Colors.transparent,
      };
    }

    final Color foreground = switch (variant) {
      PillVariant.primary || PillVariant.destructive => AppColors.onPrimary,
      PillVariant.outline => disabled ? AppColors.stone : AppColors.primaryDark,
      PillVariant.ghost => AppColors.stoneDark,
    };

    final BorderSide side = variant == PillVariant.outline
        ? BorderSide(color: disabled ? AppColors.warmGray : AppColors.primary, width: 1.5)
        : BorderSide.none;

    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(background),
      foregroundColor: WidgetStatePropertyAll(foreground),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      side: WidgetStatePropertyAll(side),
      shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: AppRadius.button)),
      minimumSize: WidgetStatePropertyAll(Size(expand ? double.infinity : 48, AppSpace.minTouch)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpace.xl, vertical: AppSpace.md),
      ),
      textStyle: WidgetStatePropertyAll(AppType.button),
      tapTargetSize: MaterialTapTargetSize.padded,
      elevation: const WidgetStatePropertyAll(0),
    );

    final Widget content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : _label();

    return Semantics(
      button: true,
      enabled: enabled,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: TextButton(
          style: style,
          onPressed: enabled ? onPressed : (loading ? () {} : null),
          child: content,
        ),
      ),
    );
  }
}
