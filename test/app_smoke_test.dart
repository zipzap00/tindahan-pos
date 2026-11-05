import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tindahan_pos/app.dart';
import 'package:tindahan_pos/core/l10n/language.dart';
import 'package:tindahan_pos/core/l10n/strings_en.dart';
import 'package:tindahan_pos/core/l10n/strings_fil.dart';
import 'package:tindahan_pos/core/result.dart';
import 'package:tindahan_pos/core/theme/appearance.dart';
import 'package:tindahan_pos/core/theme/tokens.dart';

// Boots the app without Firebase: the start-up error path must render the
// setup screen instead of crashing, in both languages.
void main() {
  for (final language in AppLanguage.values) {
    testWidgets('shows the setup screen when Firebase is not configured (${language.name})', (tester) async {
      await tester.pumpWidget(TindahanApp(
        language: LanguageController(language),
        appearance: AppearanceController(ThemeMode.light),
        startupError: const AppError(AppErrorCode.notConfigured, context: '[test]'),
      ));
      await tester.pump();

      final s = language == AppLanguage.en ? const EnStrings() : const FilStrings();
      expect(find.text(s.setupNeededBody), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  }

  testWidgets('switching to dark recolours the open screen, const widgets included', (tester) async {
    addTearDown(() => AppColors.use(Brightness.light));
    SharedPreferences.setMockInitialValues({});
    final appearance = AppearanceController(ThemeMode.light);
    await tester.pumpWidget(TindahanApp(
      language: LanguageController(AppLanguage.en),
      appearance: appearance,
      startupError: const AppError(AppErrorCode.notConfigured, context: '[test]'),
    ));
    await tester.pump();
    final scaffold = find.byType(Scaffold);
    final text = find.text(const EnStrings().setupNeededBody);
    final screen = tester.state(scaffold);
    expect(Theme.of(tester.element(scaffold)).scaffoldBackgroundColor, AppPalette.light.background);

    // Saving the choice needs real async; the test clock would never finish it.
    await tester.runAsync(() => appearance.setMode(ThemeMode.dark));
    await tester.pump();

    expect(Theme.of(tester.element(scaffold)).brightness, Brightness.dark);
    expect(Theme.of(tester.element(scaffold)).scaffoldBackgroundColor, AppPalette.dark.background);
    expect(tester.widget<Text>(text).style?.color, AppPalette.dark.ink);
    expect(tester.state(scaffold), same(screen), reason: 'the screen must keep its state');
    expect(tester.takeException(), isNull);
  });
}
