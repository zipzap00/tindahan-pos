import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tindahan_pos/app.dart';
import 'package:tindahan_pos/core/l10n/language.dart';
import 'package:tindahan_pos/core/l10n/strings_en.dart';
import 'package:tindahan_pos/core/l10n/strings_fil.dart';
import 'package:tindahan_pos/core/result.dart';

// Boots the app without Firebase: the start-up error path must render the
// setup screen instead of crashing, in both languages.
void main() {
  for (final language in AppLanguage.values) {
    testWidgets('shows the setup screen when Firebase is not configured (${language.name})', (tester) async {
      await tester.pumpWidget(TindahanApp(
        language: LanguageController(language),
        startupError: const AppError(AppErrorCode.notConfigured, context: '[test]'),
      ));
      await tester.pump();

      final s = language == AppLanguage.en ? const EnStrings() : const FilStrings();
      expect(find.text(s.setupNeededBody), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  }
}
