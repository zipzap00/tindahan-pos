// Design tokens. Every value comes from DESIGN.md (transactional light track
// for the app, cinematic night track for the welcome screen). Widgets never
// use raw colours, sizes or radii; they read these constants.

import 'package:flutter/painting.dart';

/// DESIGN.md `colors`.
abstract final class AppColors {
  static const Color primary = Color(0xFF000000);
  static const Color ink = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onDark = Color(0xFFFFFFFF);

  static const Color canvasNight = Color(0xFF000000);
  static const Color canvasNightElevated = Color(0xFF0A0A0A);
  static const Color canvasLight = Color(0xFFFFFFFF);
  static const Color canvasCream = Color(0xFFFBFBF5);
  static const Color surfaceElevatedDark = Color(0xFF1E2C31);

  static const Color shade30 = Color(0xFFD4D4D8);
  static const Color shade40 = Color(0xFFA1A1AA);
  static const Color shade50 = Color(0xFF71717A);
  static const Color shade60 = Color(0xFF52525B);
  static const Color shade70 = Color(0xFF3F3F46);

  static const Color hairlineLight = Color(0xFFE4E4E7);
  static const Color hairlineDark = Color(0xFF1E2C31);

  static const Color aloe10 = Color(0xFFC1FBD4);
  static const Color pistachio10 = Color(0xFFD4F9E0);

  static const Color linkCool1 = Color(0xFF9DABAD);
  static const Color linkCool2 = Color(0xFF9797A2);
  static const Color linkCool3 = Color(0xFFBDBDCA);
  static const Color linkMint = Color(0xFF99B3AD);

  /// Secondary text on light canvas. shade-40 fails 4.5:1 on cream, so
  /// readable secondary copy uses shade-50 and small print uses shade-60.
  static const Color textSecondary = shade50;
  static const Color textSmall = shade60;
}

/// DESIGN.md `spacing` (8 px base unit).
abstract final class AppSpace {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double huge = 64;

  /// Side padding on phone screens.
  static const double screen = lg;

  /// Minimum touch target (ui-rules: 48 px for operator screens).
  static const double minTouch = 48;
}

/// DESIGN.md `rounded`.
abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 5;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 20;
  static const double pill = 9999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius frame = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius sheetTop = BorderRadius.vertical(top: Radius.circular(xl));
}

/// DESIGN.md "Elevation & Depth".
abstract final class AppShadows {
  /// Level 3: stacked tiny shadows, the paper halo used on featured cards.
  static const List<BoxShadow> level3 = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 8), blurRadius: 8),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 4),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 2),
    BoxShadow(color: Color(0x1A000000), spreadRadius: 1),
  ];

  /// Level 4: modal or floating panel on light.
  static const List<BoxShadow> level4 = [
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 25), blurRadius: 50, spreadRadius: -12),
  ];
}

/// DESIGN.md `typography`, collapsed for phones as its Responsive section
/// describes (display sizes step down to 36 px on mobile).
///
/// Neue Haas Grotesk Display is proprietary; DESIGN.md names Inter Display at
/// light weights as the open substitute, so display roles use Inter's opsz 32
/// optical size. Every role enables the `ss03` stylistic set.
abstract final class AppType {
  static const String family = 'Inter';
  static const List<FontFeature> _features = [FontFeature('ss03')];

  static TextStyle _style({
    required double size,
    required double weight,
    required double height,
    double tracking = 0,
    bool display = false,
    Color color = AppColors.ink,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      height: height,
      letterSpacing: tracking,
      fontWeight: _nearestWeight(weight),
      fontVariations: [
        FontVariation('wght', weight),
        FontVariation('opsz', display ? 32 : 14),
      ],
      fontFeatures: _features,
      color: color,
    );
  }

  static FontWeight _nearestWeight(double weight) {
    if (weight < 350) return FontWeight.w300;
    if (weight < 450) return FontWeight.w400;
    if (weight < 525) return FontWeight.w500;
    return FontWeight.w600;
  }

  /// Mobile step of display-xxl (DESIGN.md: "drops to ~56–64px"): the
  /// cinematic welcome headline only.
  static final TextStyle displayHero =
      _style(size: 56, weight: 330, height: 1.0, display: true, color: AppColors.onDark);

  /// display-md (48 / 330): the one big amount on a screen, like the price
  /// on DESIGN.md's pricing card.
  static final TextStyle displayMd = _style(size: 48, weight: 330, height: 1.14, display: true);

  /// Mobile display step (36 / 330): page titles.
  static final TextStyle displayMobile = _style(size: 36, weight: 330, height: 1.1, display: true);

  static final TextStyle headingXl =
      _style(size: 28, weight: 500, height: 1.28, tracking: 0.42, display: true);
  static final TextStyle headingLg =
      _style(size: 24, weight: 400, height: 1.14, tracking: 0.36, display: true);
  static final TextStyle headingMd =
      _style(size: 20, weight: 500, height: 1.4, tracking: 0.3, display: true);
  static final TextStyle headingSm =
      _style(size: 18, weight: 500, height: 1.25, tracking: 0.72, display: true);

  static final TextStyle bodyLg = _style(size: 18, weight: 550, height: 1.56);
  static final TextStyle bodyMd = _style(size: 16, weight: 420, height: 1.5);
  static final TextStyle bodyStrong = _style(size: 16, weight: 550, height: 1.5);
  static final TextStyle caption =
      _style(size: 14, weight: 500, height: 1.49, tracking: 0.28, color: AppColors.textSecondary);
  static final TextStyle micro =
      _style(size: 13, weight: 500, height: 1.5, tracking: -0.13, color: AppColors.textSmall);
  static final TextStyle eyebrowCap = _style(size: 12, weight: 400, height: 1.2, tracking: 0.72);

  /// Same style with tabular figures, so changing amounts do not jump.
  static TextStyle tabular(TextStyle style) =>
      style.copyWith(fontFeatures: const [FontFeature('ss03'), FontFeature('tnum')]);
}
