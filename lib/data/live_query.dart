import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/log.dart';
import '../core/result.dart';
import 'firestore_support.dart';

/// Holds the latest value of a Firestore stream for widgets to listen to.
///
/// One subscription is shared by every screen that needs the same data
/// (for example the product list used by the POS, inventory and dashboard),
/// so switching tabs never re-downloads it. Firestore serves cached data first
/// when offline.
class LiveQuery<T> extends ChangeNotifier {
  LiveQuery(this._create, {required this.context}) {
    _listen();
  }

  final Stream<T> Function() _create;
  final String context;

  StreamSubscription<T>? _subscription;
  T? _value;
  AppError? _error;
  bool _loading = true;
  bool _disposed = false;

  T? get value => _value;
  AppError? get error => _error;
  bool get isLoading => _loading && _value == null;
  bool get hasValue => _value != null;

  void _listen() {
    unawaited(_subscription?.cancel());
    _subscription = _create().listen(
      (data) {
        _value = data;
        _error = null;
        _loading = false;
        _notify();
      },
      onError: (Object error, StackTrace stack) {
        logError(context, error, stack);
        _error = mapError(error, context);
        _loading = false;
        _notify();
      },
    );
  }

  void retry() {
    _error = null;
    _loading = true;
    _notify();
    _listen();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
