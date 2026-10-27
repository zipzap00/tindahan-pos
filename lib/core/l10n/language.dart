import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../log.dart';
import 'strings.dart';
import 'strings_en.dart';
import 'strings_fil.dart';

/// Filipino (Taglish) is the default; English is a full alternative.
enum AppLanguage { fil, en }

class LanguageController extends ChangeNotifier {
  LanguageController(this._language);

  static const String _prefsKey = 'language';

  AppLanguage _language;
  AppLanguage get language => _language;

  Strings get strings => _language == AppLanguage.en ? const EnStrings() : const FilStrings();

  static Future<LanguageController> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      return LanguageController(saved == 'en' ? AppLanguage.en : AppLanguage.fil);
    } catch (error, stack) {
      logError('[l10n/load]', error, stack);
      return LanguageController(AppLanguage.fil);
    }
  }

  Future<void> setLanguage(AppLanguage value) async {
    if (value == _language) return;
    _language = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, value.name);
    } catch (error, stack) {
      logError('[l10n/save]', error, stack);
    }
  }
}

class LanguageScope extends InheritedNotifier<LanguageController> {
  const LanguageScope({super.key, required LanguageController controller, required super.child})
      : super(notifier: controller);

  static LanguageController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LanguageScope>();
    assert(scope != null, 'LanguageScope missing above this widget');
    return scope!.notifier!;
  }
}

extension StringsContext on BuildContext {
  /// Current translations. Rebuilds the widget when the language changes.
  Strings get s => LanguageScope.of(this).strings;
}
