import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../log.dart';

/// Light, dark, or follow the phone. Following the phone is the default.
class AppearanceController extends ChangeNotifier {
  AppearanceController(this._mode);

  static const String _prefsKey = 'appearance';

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  /// What to show, given what the phone is set to.
  Brightness resolve(Brightness platform) => switch (_mode) {
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
        ThemeMode.system => platform,
      };

  static Future<AppearanceController> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      return AppearanceController(
        ThemeMode.values.firstWhere((mode) => mode.name == saved, orElse: () => ThemeMode.system),
      );
    } catch (error, stack) {
      logError('[appearance/load]', error, stack);
      return AppearanceController(ThemeMode.system);
    }
  }

  Future<void> setMode(ThemeMode value) async {
    if (value == _mode) return;
    _mode = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, value.name);
    } catch (error, stack) {
      logError('[appearance/save]', error, stack);
    }
  }
}

class AppearanceScope extends InheritedNotifier<AppearanceController> {
  const AppearanceScope({super.key, required AppearanceController controller, required super.child})
      : super(notifier: controller);

  static AppearanceController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppearanceScope>();
    assert(scope != null, 'AppearanceScope missing above this widget');
    return scope!.notifier!;
  }
}
