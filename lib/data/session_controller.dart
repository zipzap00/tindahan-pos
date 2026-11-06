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
/// Signed in with an email not yet confirmed, and no store. Google logins
/// arrive confirmed. Anyone with a store never comes here, so existing owners
/// and cashiers (whose emails the owner typed in) are not locked out.
class NeedsEmailVerification extends SessionState {
  const NeedsEmailVerification(this.user);
  final User user;
}

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
  Timer? _serverWaitTimer;
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
          final latest = auth.currentUser ?? user;
          _setState(latest.emailVerified ? NeedsStore(latest) : NeedsEmailVerification(latest));
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
        .snapshots(includeMetadataChanges: true)
        .listen(
      (doc) {
        final data = doc.data();
        final member = data == null ? null : Member.fromMap(user.uid, data);
        if (member == null || !member.active) {
          _cancelServerWait();
          _endSession();
          _setState(const AccessDisabled());
          return;
        }
        final current = _session;
        if (current != null && current.member.value.role == member.role) {
          current.updateMember(member);
          return;
        }
        // A store just created on this phone shows up here before the server
        // has saved it. Reading the store now would be refused for good, so
        // wait for the server, or carry on offline after [serverWait].
        if (doc.metadata.hasPendingWrites) {
          _serverWaitTimer ??= Timer(serverWait, () => _startSession(storeId, member));
          return;
        }
        _startSession(storeId, member);
      },
      onError: (Object error, StackTrace stack) {
        logError('[session/member]', error, stack);
        _endSession();
        _setState(SessionFailed(mapError(error, '[session/member]')));
      },
    );
  }

  void _startSession(String storeId, Member member) {
    _cancelServerWait();
    _endSession();
    final session = StoreSession(db: db, storeId: storeId, member: member);
    _session = session;
    _setState(SessionReady(session));
  }

  void _cancelServerWait() {
    _serverWaitTimer?.cancel();
    _serverWaitTimer = null;
  }

  /// Asks Firebase whether the emailed link was opened, and moves on if so.
  /// Returns `Ok(false)` when it has not been opened yet.
  Future<Result<bool>> checkEmailVerified() async {
    const context = '[session/checkEmail]';
    try {
      await auth.currentUser?.reload();
      final user = auth.currentUser;
      if (user == null || !user.emailVerified) return const Ok(false);
      // The next writes must carry a token that says the email is confirmed.
      await user.getIdToken(true);
      _user = user;
      _setState(NeedsStore(user));
      return const Ok(true);
    } catch (error, stack) {
      logError(context, error, stack);
      return Err(mapError(error, context));
    }
  }

  /// Re-reads the user profile, for the retry button on a failed state.
  void retry() => _onAuthChanged(_user);

  Future<void> signOut() async {
    _session?.cart.clear();
    await auth.signOut();
  }

  void _stopMember() {
    _cancelServerWait();
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
