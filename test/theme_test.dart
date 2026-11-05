import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tindahan_pos/core/theme/app_theme.dart';
import 'package:tindahan_pos/core/theme/appearance.dart';
import 'package:tindahan_pos/core/theme/tokens.dart';

/// WCAG contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final (hi, lo) = a.computeLuminance() > b.computeLuminance() ? (a, b) : (b, a);
  return (hi.computeLuminance() + 0.05) / (lo.computeLuminance() + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('dark palette', () {
    const dark = AppPalette.dark;

    test('text stays readable on every dark surface', () {
      for (final canvas in [dark.background, dark.surface]) {
        expect(_contrast(dark.ink, canvas), greaterThan(7));
        expect(_contrast(dark.stoneDark, canvas), greaterThan(4.5));
        expect(_contrast(dark.stone, canvas), greaterThan(4.5));
        expect(_contrast(dark.primaryDark, canvas), greaterThan(4.5));
        expect(_contrast(dark.warningText, canvas), greaterThan(4.5));
        expect(_contrast(dark.errorDark, canvas), greaterThan(4.5));
      }
    });

    test('the theme and text styles follow the active palette', () {
      addTearDown(() => AppColors.use(Brightness.light));
      expect(AppColors.use(Brightness.dark), isTrue);
      expect(AppColors.use(Brightness.dark), isFalse);
      final theme = buildAppTheme();
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, dark.background);
      expect(AppType.body.color, dark.ink);
      expect(AppType.bodySmall.color, dark.stone);
    });
  });

  group('appearance', () {
    test('follows the phone when nothing is saved', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = await AppearanceController.load();
      expect(controller.mode, ThemeMode.system);
      expect(controller.resolve(Brightness.dark), Brightness.dark);
      expect(controller.resolve(Brightness.light), Brightness.light);
    });

    test('a chosen mode overrides the phone and is saved', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = await AppearanceController.load();
      await controller.setMode(ThemeMode.dark);
      expect(controller.resolve(Brightness.light), Brightness.dark);
      final reloaded = await AppearanceController.load();
      expect(reloaded.mode, ThemeMode.dark);
    });

    test('an unknown saved value falls back to the phone', () async {
      SharedPreferences.setMockInitialValues({'appearance': 'sepia'});
      expect((await AppearanceController.load()).mode, ThemeMode.system);
    });
  });

  group('type', () {
    test('every theme style sets the wght axis', () {
      // The bundled fonts default to their lightest weight, so a style without
      // the axis would render hairline-thin.
      final theme = buildAppTheme().textTheme;
      final styles = {
        'displayLarge': theme.displayLarge,
        'displayMedium': theme.displayMedium,
        'displaySmall': theme.displaySmall,
        'headlineLarge': theme.headlineLarge,
        'headlineMedium': theme.headlineMedium,
        'headlineSmall': theme.headlineSmall,
        'titleLarge': theme.titleLarge,
        'titleMedium': theme.titleMedium,
        'titleSmall': theme.titleSmall,
        'bodyLarge': theme.bodyLarge,
        'bodyMedium': theme.bodyMedium,
        'bodySmall': theme.bodySmall,
        'labelLarge': theme.labelLarge,
        'labelMedium': theme.labelMedium,
        'labelSmall': theme.labelSmall,
      };
      for (final MapEntry(key: name, value: style) in styles.entries) {
        final axes = style?.fontVariations?.map((variation) => variation.axis);
        expect(axes, contains('wght'), reason: name);
      }
    });

    test('headings use Manrope and body text uses Nunito', () {
      expect(AppType.display.fontFamily, AppType.headingFamily);
      expect(AppType.subhead.fontFamily, AppType.headingFamily);
      expect(AppType.body.fontFamily, AppType.bodyFamily);
      expect(AppType.code.fontFamily, AppType.codeFamily);
    });

    test('tabular keeps the size and weight and moves to a font with tnum', () {
      final style = AppType.tabular(AppType.body);
      expect(style.fontFamily, AppType.headingFamily);
      expect(style.fontFeatures, contains(const FontFeature('tnum')));
      expect(style.fontSize, AppType.body.fontSize);
      expect(style.fontVariations, AppType.body.fontVariations);
    });
  });

  group('RingInputBorder', () {
    final idle = RingInputBorder(color: AppColors.inputBorder);
    final focused = RingInputBorder(color: AppColors.primary, ring: AppColors.primaryBorder);

    test('stays a ring border while animating between states', () {
      final halfway = focused.lerpFrom(idle, 0.5);
      expect(halfway, isA<RingInputBorder>());
      expect((halfway! as RingInputBorder).ring.a, closeTo(AppColors.primaryBorder.a / 2, 0.01));
      expect(idle.lerpTo(focused, 1), focused);
    });

    test('borders differ by ring as well as by colour', () {
      expect(RingInputBorder(color: AppColors.primary), isNot(focused));
      expect(RingInputBorder(color: AppColors.primary, ring: AppColors.primaryBorder), focused);
    });

    test('the theme uses it for the focused and error states', () {
      final inputs = buildAppTheme().inputDecorationTheme;
      expect(inputs.focusedBorder, isA<RingInputBorder>());
      expect((inputs.focusedBorder! as RingInputBorder).ring.a, greaterThan(0));
      expect(inputs.errorBorder?.borderSide.color, AppColors.error);
    });
  });
}
