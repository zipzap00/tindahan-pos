import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tindahan_pos/core/l10n/language.dart';
import 'package:tindahan_pos/core/l10n/strings_en.dart';
import 'package:tindahan_pos/core/l10n/strings_fil.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('language', () {
    test('English is the default when nothing is saved', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = await LanguageController.load();
      expect(controller.language, AppLanguage.en);
      expect(controller.strings, isA<EnStrings>());
    });

    test('a saved choice of Filipino is kept', () async {
      SharedPreferences.setMockInitialValues({'language': 'fil'});
      final controller = await LanguageController.load();
      expect(controller.language, AppLanguage.fil);
      expect(controller.strings, isA<FilStrings>());
    });

    test('switching saves the choice for next start', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = await LanguageController.load();
      await controller.setLanguage(AppLanguage.fil);
      final reloaded = await LanguageController.load();
      expect(reloaded.language, AppLanguage.fil);
    });
  });
}
