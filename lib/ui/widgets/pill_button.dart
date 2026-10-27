import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// DESIGN.md button vocabulary. Every button is a pill; variants differ only
/// in fill, border and canvas.
enum PillVariant {
  /// button-primary-pill: black fill, white label. One per screen.
  primary,

  /// button-outline-on-light: white fill, 1 px ink border.
  outline,

  /// button-aloe-pill: mint fill for a featured action.
  aloe,

  /// Text-only pill for low-emphasis actions (cancel, see all).
  ghost,

  /// button-outline-on-dark: 2 px white border on the night canvas.
  outlineOnDark,
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

    Color background(Set<WidgetState> states) {
      final disabled = states.contains(WidgetState.disabled);
      final pressed = states.contains(WidgetState.pressed);
      return switch (variant) {
        PillVariant.primary =>
          disabled && !loading ? AppColors.shade30 : (pressed ? AppColors.shade70 : AppColors.primary),
        PillVariant.outline => pressed ? AppColors.canvasCream : AppColors.canvasLight,
        PillVariant.aloe => pressed ? AppColors.pistachio10 : AppColors.aloe10,
        PillVariant.ghost => pressed ? AppColors.hairlineLight : Colors.transparent,
        PillVariant.outlineOnDark => pressed ? AppColors.canvasNightElevated : AppColors.canvasNight,
      };
    }

    Color foreground(Set<WidgetState> states) {
      final disabled = states.contains(WidgetState.disabled) && !loading;
      return switch (variant) {
        PillVariant.primary => disabled ? AppColors.shade60 : AppColors.onPrimary,
        PillVariant.outlineOnDark => disabled ? AppColors.shade50 : AppColors.onDark,
        _ => disabled ? AppColors.shade50 : AppColors.ink,
      };
    }

    BorderSide side(Set<WidgetState> states) {
      final disabled = states.contains(WidgetState.disabled) && !loading;
      return switch (variant) {
        PillVariant.outline =>
          BorderSide(color: disabled ? AppColors.shade30 : AppColors.ink),
        PillVariant.outlineOnDark =>
          BorderSide(color: disabled ? AppColors.shade60 : AppColors.onDark, width: 2),
        _ => BorderSide.none,
      };
    }

    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(background),
      foregroundColor: WidgetStateProperty.resolveWith(foreground),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      side: WidgetStateProperty.resolveWith(side),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      minimumSize: WidgetStatePropertyAll(Size(expand ? double.infinity : 48, AppSpace.minTouch)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpace.xl, vertical: AppSpace.md),
      ),
      textStyle: WidgetStatePropertyAll(AppType.bodyStrong),
      tapTargetSize: MaterialTapTargetSize.padded,
      elevation: const WidgetStatePropertyAll(0),
    );

    final Color spinnerColor = variant == PillVariant.primary || variant == PillVariant.outlineOnDark
        ? AppColors.onPrimary
        : AppColors.ink;

    final Widget content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor),
          )
        : _label();

    return Semantics(
      button: true,
      enabled: enabled,
      child: TextButton(
        style: style,
        onPressed: enabled ? onPressed : (loading ? () {} : null),
        child: content,
      ),
    );
  }
}
