import 'package:flutter/material.dart';

import 'tokens.dart';

/// Material theme built only from the tokens, for the active palette.
ThemeData buildAppTheme() {
  final scheme = ColorScheme(
    brightness: AppColors.isDark ? Brightness.dark : Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryTint,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.info,
    onSecondary: AppColors.ink,
    tertiary: AppColors.warmGray,
    onTertiary: AppColors.ink,
    error: AppColors.error,
    onError: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.inputBorder,
    outlineVariant: AppColors.hairline,
    surfaceContainerHighest: AppColors.surfaceMuted,
  );

  // Every slot is set: an unset one would fall back to the fonts' default
  // (lightest) weight. See AppType.
  final textTheme = TextTheme(
    displayLarge: AppType.display,
    displayMedium: AppType.display,
    displaySmall: AppType.headline,
    headlineLarge: AppType.headline,
    headlineMedium: AppType.headline,
    headlineSmall: AppType.subhead,
    titleLarge: AppType.subhead,
    titleMedium: AppType.bodyStrong,
    titleSmall: AppType.label,
    bodyLarge: AppType.body,
    bodyMedium: AppType.body,
    bodySmall: AppType.bodySmall,
    labelLarge: AppType.bodyStrong,
    labelMedium: AppType.chip,
    labelSmall: AppType.caption,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: AppType.bodyFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppType.subhead,
    ),
    dividerTheme: DividerThemeData(color: AppColors.hairline, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? AppColors.surfaceMuted : AppColors.surface,
      ),
      hoverColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
      border: RingInputBorder(color: AppColors.inputBorder),
      enabledBorder: RingInputBorder(color: AppColors.inputBorder),
      disabledBorder: RingInputBorder(color: AppColors.hairline),
      focusedBorder: RingInputBorder(color: AppColors.primary, ring: const Color(0x2610B981)),
      errorBorder: RingInputBorder(color: AppColors.error, ring: const Color(0x1FEF4444)),
      focusedErrorBorder: RingInputBorder(color: AppColors.error, ring: const Color(0x1FEF4444)),
      labelStyle: AppType.label,
      floatingLabelStyle: AppType.label,
      hintStyle: AppType.body.copyWith(color: AppColors.textSecondary),
      helperStyle: AppType.helper,
      errorStyle: AppType.helper.copyWith(color: AppColors.errorDark),
      prefixStyle: AppType.body,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primaryBorder,
      selectionHandleColor: AppColors.primary,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primaryTint,
      indicatorShape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppType.captionStrong : AppType.caption,
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppColors.primaryDark : AppColors.stone,
          size: 24,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      showDragHandle: true,
      dragHandleColor: AppColors.inputBorder,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.modal),
      titleTextStyle: AppType.subhead,
      contentTextStyle: AppType.body,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: AppType.body.copyWith(color: AppColors.onInk),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: AppRadius.inner),
      textStyle: AppType.helper.copyWith(color: AppColors.onInk),
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.sm),
      waitDuration: const Duration(milliseconds: 400),
      exitDuration: const Duration(milliseconds: 100),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.hairline,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(AppColors.surface),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.primary : AppColors.inputBorder,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),
      side: BorderSide(color: AppColors.inputBorder, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(AppColors.onPrimary),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.primary : AppColors.inputBorder,
      ),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: AppType.bodyStrong,
      subtitleTextStyle: AppType.bodySmall,
      iconColor: AppColors.stoneDark,
      minVerticalPadding: AppSpace.md,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      textStyle: AppType.body,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
    ),
  );
}

/// DESIGN.md's input border: 1.5 px, with a soft 3 px ring outside it when the
/// field has focus. Material input borders have no ring of their own.
class RingInputBorder extends OutlineInputBorder {
  RingInputBorder({required Color color, this.ring = Colors.transparent})
      : super(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: color, width: _width),
        );

  static const double _width = 1.5;
  static const double _ringWidth = 3;

  /// The ring's colour; transparent when the field is not focused.
  final Color ring;

  static RingInputBorder _lerp(RingInputBorder a, RingInputBorder b, double t) => RingInputBorder(
        color: Color.lerp(a.borderSide.color, b.borderSide.color, t)!,
        ring: Color.lerp(a.ring, b.ring, t)!,
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) =>
      a is RingInputBorder ? _lerp(a, this, t) : super.lerpFrom(a, t);

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) =>
      b is RingInputBorder ? _lerp(this, b, t) : super.lerpTo(b, t);

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    if (ring.a > 0) {
      canvas.drawRRect(
        borderRadius.toRRect(rect).inflate((_ringWidth + _width) / 2),
        Paint()
          ..color = ring
          ..style = PaintingStyle.stroke
          ..strokeWidth = _ringWidth,
      );
    }
    super.paint(
      canvas,
      rect,
      gapStart: gapStart,
      gapExtent: gapExtent,
      gapPercentage: gapPercentage,
      textDirection: textDirection,
    );
  }

  @override
  bool operator ==(Object other) => super == other && other is RingInputBorder && other.ring == ring;

  @override
  int get hashCode => Object.hash(super.hashCode, ring);
}
