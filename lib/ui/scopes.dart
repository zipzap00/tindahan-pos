import 'package:flutter/widgets.dart';

import '../data/repositories/auth_repository.dart';
import '../data/session_controller.dart';
import '../data/store_session.dart';

/// App-wide services that exist before anyone signs in.
class AppServices extends InheritedWidget {
  const AppServices({
    super.key,
    required this.sessionController,
    required this.authRepository,
    required super.child,
  });

  final SessionController sessionController;
  final AuthRepository authRepository;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppServices>();
    assert(scope != null, 'AppServices missing above this widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppServices oldWidget) =>
      sessionController != oldWidget.sessionController || authRepository != oldWidget.authRepository;
}

/// The signed-in member's store. Placed above the Navigator so pushed screens
/// can reach it too.
class StoreScope extends InheritedWidget {
  const StoreScope({super.key, required this.session, required super.child});

  final StoreSession? session;

  static StoreSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    final session = scope?.session;
    if (session == null) {
      throw StateError('StoreScope.of called outside a signed-in session');
    }
    return session;
  }

  @override
  bool updateShouldNotify(StoreScope oldWidget) => session != oldWidget.session;
}
