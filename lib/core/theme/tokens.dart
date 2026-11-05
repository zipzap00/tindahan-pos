// Design tokens. Light values come from DESIGN.md (BudgetZen). DESIGN.md has no
// dark theme, so the dark palette is built from the same families: the stone
// greys it already uses, and lighter steps of mint, amber and red for text on
// tints. Widgets never use raw colours, sizes or radii; they read these tokens.

import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';

/// One complete set of the colours that differ between light and dark. See
/// [AppColors] for what each one is for.
class AppPalette {
  const AppPalette({
    required this.primaryDark,
    required this.warningText,
    required this.errorDark,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.onInk,
    required this.warmGray,
    required this.stone,
    required this.stoneDark,
    required this.hairline,
    required this.inputBorder,
  });

  static const AppPalette light = AppPalette(
    primaryDark: Color(0xFF059669),
    warningText: Color(0xFFD97706),
    errorDark: Color(0xFFDC2626),
    background: Color(0xFFFAFFFE),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF5F5F4),
    ink: Color(0xFF1C1917),
    onInk: Color(0xFFFAFAFA),
    warmGray: Color(0xFFA8A29E),
    stone: Color(0xFF78716C),
    stoneDark: Color(0xFF57534E),
    hairline: Color(0xFFE7E5E4),
    inputBorder: Color(0xFFD6D3D1),
  );

  static const AppPalette dark = AppPalette(
    primaryDark: Color(0xFF34D399),
    warningText: Color(0xFFFBBF24),
    errorDark: Color(0xFFF87171),
    background: Color(0xFF1C1917),
    surface: Color(0xFF292524),
    surfaceMuted: Color(0xFF44403C),
    ink: Color(0xFFFAFAF9),
    onInk: Color(0xFF1C1917),
    warmGray: Color(0xFF78716C),
    stone: Color(0xFFA8A29E),
    stoneDark: Color(0xFFD6D3D1),
    hairline: Color(0xFF44403C),
    inputBorder: Color(0xFF57534E),
  );

  final Color primaryDark;
  final Color warningText;
  final Color errorDark;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color ink;
  final Color onInk;
  final Color warmGray;
  final Color stone;
  final Color stoneDark;
  final Color hairline;
  final Color inputBorder;
}

/// The colours of the active palette. Read them in `build`, never store them:
/// they change when the app switches between light and dark. The app rebuilds
/// every widget when that happens, including const ones (see `app.dart`).
abstract final class AppColors {
  static AppPalette _palette = AppPalette.light;

  static bool get isDark => identical(_palette, AppPalette.dark);

  /// Switches palette. Returns whether anything changed.
  static bool use(Brightness brightness) {
    final next = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
    if (identical(next, _palette)) return false;
    _palette = next;
    return true;
  }

  /// Mint: CTAs, progress, success.
  static const Color primary = Color(0xFF10B981);

  /// Pressed mint, and mint text on a tint (active chips, on-track status).
  static Color get primaryDark => _palette.primaryDark;
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Fixed logo colours: the store mark is the same artwork in both palettes.
  static const Color brandDeep = Color(0xFF059669);
  static const Color brandOff = Color(0xFFD6D3D1);
  static const Color brandPale = Color(0xFFE7E5E4);

  /// Mint at 10 %: active chips, status fills, the hero panel.
  static const Color primaryTint = Color(0x1A10B981);

  /// Mint at 5 %: selected rows, quiet summary bands.
  static const Color primaryWash = Color(0x0D10B981);

  /// Mint at 20 %: the border of a mint-tinted chip or card.
  static const Color primaryBorder = Color(0x3310B981);

  /// Sky: tips and helpful callouts.
  static const Color info = Color(0xFF38BDF8);
  static const Color infoTint = Color(0x1A38BDF8);
  static const Color infoBorder = Color(0x3338BDF8);

  /// Approaching a limit, review needed.
  static const Color warning = Color(0xFFF59E0B);
  static Color get warningText => _palette.warningText;
  static const Color warningTint = Color(0x1AF59E0B);
  static const Color warningBorder = Color(0x33F59E0B);

  /// Failed or blocked. Keep it rare: DESIGN.md asks for no red-heavy screens.
  static const Color error = Color(0xFFEF4444);
  static Color get errorDark => _palette.errorDark;
  static const Color errorTint = Color(0x1AEF4444);
  static const Color errorBorder = Color(0x33EF4444);

  /// Root canvas and panels.
  static Color get background => _palette.background;
  static Color get surface => _palette.surface;
  static Color get surfaceMuted => _palette.surfaceMuted;

  /// Main text. Snack bars and tooltips use it as a fill, with [onInk] on top.
  static Color get ink => _palette.ink;
  static Color get onInk => _palette.onInk;

  /// Warm grey: inactive states. Too pale for text.
  static Color get warmGray => _palette.warmGray;
  static Color get stone => _palette.stone;
  static Color get stoneDark => _palette.stoneDark;

  static Color get hairline => _palette.hairline;
  static Color get inputBorder => _palette.inputBorder;

  /// Secondary copy, and small print that needs a little more contrast.
  static Color get textSecondary => stone;
  static Color get textSmall => stoneDark;
}

/// DESIGN.md "Spacing": 8 px base unit, plus the component padding it names.
abstract final class AppSpace {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double huge = 64;

  /// Default card padding.
  static const double card = 20;

  /// Between major sections.
  static const double section = 40;

  /// Between an input's label and its field.
  static const double labelGap = 6;

  /// Side padding on phone screens.
  static const double screen = lg;

  /// Minimum touch target (48 px for operator screens).
  static const double minTouch = 48;

  /// Widest the app gets. It is a phone app; in a desktop browser it stays a
  /// centred column instead of stretching across the window.
  static const double maxContentWidth = 560;
}

/// DESIGN.md "Border Radius".
abstract final class AppRadius {
  static const double sm = 6;
  static const double tooltip = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 9999;

  static const BorderRadius chip = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius inner = BorderRadius.all(Radius.circular(tooltip));
  static const BorderRadius button = BorderRadius.all(Radius.circular(md));
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius cardElevated = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius modal = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius frame = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius sheetTop = BorderRadius.vertical(top: Radius.circular(lg));
}

/// DESIGN.md "Elevation": ink shadows, never harsh.
abstract final class AppShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0F1C1917), offset: Offset(0, 1), blurRadius: 3),
  ];
  static const List<BoxShadow> medium = [
    BoxShadow(color: Color(0x141C1917), offset: Offset(0, 4), blurRadius: 12),
  ];
  static const List<BoxShadow> large = [
    BoxShadow(color: Color(0x1A1C1917), offset: Offset(0, 8), blurRadius: 24),
  ];
  static const List<BoxShadow> overlay = [
    BoxShadow(color: Color(0x241C1917), offset: Offset(0, 16), blurRadius: 48),
  ];
}

/// DESIGN.md "Typography": Manrope for headings, Nunito for body, Source Code
/// Pro for code.
///
/// The bundled fonts are variable and default to their lightest weight, so
/// every style must set the `wght` axis. Build new styles with [_style], or
/// copy an existing one; never set only `fontWeight`.
abstract final class AppType {
  static const String headingFamily = 'Manrope';
  static const String bodyFamily = 'Nunito';
  static const String codeFamily = 'SourceCodePro';

  static TextStyle _style({
    required String family,
    required double size,
    required int weight,
    required double height,
    double tracking = 0,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      height: height,
      letterSpacing: size * tracking,
      fontWeight: FontWeight.values[weight ~/ 100 - 1],
      fontVariations: [FontVariation('wght', weight.toDouble())],
      color: color ?? AppColors.ink,
    );
  }

  /// The one big amount on a screen.
  static TextStyle get display =>
      _style(family: headingFamily, size: 36, weight: 800, height: 1.15, tracking: 0.02);

  /// Page titles.
  static TextStyle get headline =>
      _style(family: headingFamily, size: 28, weight: 700, height: 1.2, tracking: 0.01);

  /// Section and card titles, secondary figures.
  static TextStyle get subhead => _style(family: headingFamily, size: 20, weight: 600, height: 1.3);

  static TextStyle get bodyLarge => _style(family: bodyFamily, size: 18, weight: 400, height: 1.6);
  static TextStyle get body => _style(family: bodyFamily, size: 16, weight: 400, height: 1.6);

  /// Body at semibold, tighter so two-line row titles stay compact.
  static TextStyle get bodyStrong => _style(family: bodyFamily, size: 16, weight: 600, height: 1.4);

  static TextStyle get bodySmall => _style(
    family: bodyFamily,
    size: 14,
    weight: 400,
    height: 1.5,
    tracking: 0.01,
    color: AppColors.textSecondary,
  );
  static TextStyle get caption => _style(
    family: bodyFamily,
    size: 12,
    weight: 600,
    height: 1.4,
    tracking: 0.02,
    color: AppColors.textSmall,
  );

  /// caption at the strong weight: the selected tab label.
  static TextStyle get captionStrong => _style(
    family: bodyFamily,
    size: 12,
    weight: 800,
    height: 1.4,
    tracking: 0.02,
    color: AppColors.primaryDark,
  );
  static TextStyle get overline =>
      _style(family: headingFamily, size: 11, weight: 700, height: 1.2, tracking: 0.06);

  /// Input label: 14 / 600, above the field.
  static TextStyle get label =>
      _style(family: bodyFamily, size: 14, weight: 600, height: 1.4, color: AppColors.stoneDark);

  /// Input helper text: 13 / 400.
  static TextStyle get helper =>
      _style(family: bodyFamily, size: 13, weight: 400, height: 1.4, color: AppColors.stone);

  /// Chip and small link label: 13 / 600.
  static TextStyle get chip =>
      _style(family: bodyFamily, size: 13, weight: 600, height: 1.4, color: AppColors.stoneDark);

  /// Large button label: 17 px.
  static TextStyle get button => _style(family: bodyFamily, size: 17, weight: 700, height: 1.3);

  static TextStyle get code => _style(family: codeFamily, size: 14, weight: 400, height: 1.6);

  /// Same size and weight in Manrope with tabular figures, so changing amounts
  /// do not jump. Nunito has no tabular figures, so numbers always use this.
  static TextStyle tabular(TextStyle style) => style.copyWith(
        fontFamily: headingFamily,
        fontFeatures: const [FontFeature('tnum')],
      );
}
