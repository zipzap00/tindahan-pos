// Follows the signed-in user to their store membership:
// auth user -> users/{uid} (which store) -> stores/{id}/members/{uid} (role,
// active). Screens show whatever state this reports.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../core/log.dart';
import '../core/result.dart';
import 'firestore_read.dart';
import 'firestore_support.dart';
import 'models/records.dart';
import 'store_session.dart';

sealed class SessionState {
  const SessionState();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SignedOut extends SessionState {
  const SignedOut();
}

/// Signed in but no store yet: finish owner sign-up.
class NeedsStore extends SessionState {
  const NeedsStore(this.user);
  final User user;
}

/// The owner turned this account off, or it was removed from the store.
class AccessDisabled extends SessionState {
  const AccessDisabled();
}

class SessionReady extends SessionState {
  const SessionReady(this.session);
  final StoreSession session;
}

class SessionFailed extends SessionState {
  const SessionFailed(this.error);
  final AppError error;
}

class SessionController extends ChangeNotifier {
  SessionController({required this.auth, required this.db}) {
    _authSubscription = auth.authStateChanges().listen(
      _onAuthChanged,
      onError: (Object error, StackTrace stack) {
        logError('[session/auth]', error, stack);
        _setState(SessionFailed(mapError(error, '[session/auth]')));
      },
    );
  }

  final FirebaseAuth auth;
  final FirebaseFirestore db;

  SessionState _state = const SessionLoading();
  SessionState get state => _state;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Json>>? _userSubscription;
  StreamSubscription<DocumentSnapshot<Json>>? _memberSubscription;
  StoreSession? _session;
  String? _storeId;
  User? _user;

  void _onAuthChanged(User? user) {
    _stopUser();
    _user = user;
    if (user == null) {
      _setState(const SignedOut());
      return;
    }
    _setState(const SessionLoading());
    _userSubscription = db.collection('users').doc(user.uid).snapshots().listen(
      (doc) {
        final data = doc.data();
        final storeId = data == null ? '' : readString(data['storeId']);
        if (storeId.isEmpty) {
          _stopMember();
          _setState(NeedsStore(user));
          return;
        }
        if (storeId != _storeId) {
          _stopMember();
          _storeId = storeId;
          _listenToMember(user, storeId);
        }
      },
      onError: (Object error, StackTrace stack) {
        logError('[session/user]', error, stack);
        _setState(SessionFailed(mapError(error, '[session/user]')));
      },
    );
  }

  void _listenToMember(User user, String storeId) {
    _memberSubscription = db
        .collection('stores')
        .doc(storeId)
        .collection('members')
        .doc(user.uid)
        .snapshots()
        .listen(
      (doc) {
        final data = doc.data();
        final member = data == null ? null : Member.fromMap(user.uid, data);
        if (member == null || !member.active) {
          _endSession();
          _setState(const AccessDisabled());
          return;
        }
        final current = _session;
        if (current != null && current.member.value.role == member.role) {
          current.updateMember(member);
          return;
        }
        _endSession();
        final session = StoreSession(db: db, storeId: storeId, member: member);
        _session = session;
        _setState(SessionReady(session));
      },
      onError: (Object error, StackTrace stack) {
        logError('[session/member]', error, stack);
        _endSession();
        _setState(SessionFailed(mapError(error, '[session/member]')));
      },
    );
  }

  /// Re-reads the user profile, for the retry button on a failed state.
  void retry() => _onAuthChanged(_user);

  Future<void> signOut() async {
    _session?.cart.clear();
    await auth.signOut();
  }

  void _stopMember() {
    unawaited(_memberSubscription?.cancel());
    _memberSubscription = null;
    _storeId = null;
    _endSession();
  }

  void _stopUser() {
    unawaited(_userSubscription?.cancel());
    _userSubscription = null;
    _stopMember();
  }

  /// Disposes the old session after the next frame, once no widget is still
  /// listening to its live data.
  void _endSession() {
    final old = _session;
    _session = null;
    if (old == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  void _setState(SessionState value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    _stopUser();
    super.dispose();
  }
}
