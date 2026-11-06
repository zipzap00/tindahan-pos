// Sign in, account creation and first-time store setup.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/log.dart';
import '../../core/result.dart';
import '../firestore_support.dart';
import '../models/records.dart';

class AuthRepository {
  AuthRepository({required this.auth, required this.db});

  final FirebaseAuth auth;
  final FirebaseFirestore db;

  Future<Result<bool>> signIn({required String email, required String password}) async {
    const context = '[auth/signIn]';
    try {
      await auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return const Ok(true);
    } catch (error, stack) {
      logError(context, error, stack);
      return Err(mapError(error, context));
    }
  }

  /// Google sign-in through Firebase's own browser flow (no extra package).
  /// Works for new and returning owners: a new login has no store yet, so the
  /// session moves to `NeedsStore` and the app shows create-store.
  /// Returns `Ok(false)` when the user closes the Google page.
  Future<Result<bool>> signInWithGoogle() async {
    const context = '[auth/signInWithGoogle]';
    try {
      // The browser has no signInWithProvider; it uses a popup instead.
      if (kIsWeb) {
        await auth.signInWithPopup(GoogleAuthProvider());
      } else {
        await auth.signInWithProvider(GoogleAuthProvider());
      }
      return const Ok(true);
    } on FirebaseAuthException catch (error, stack) {
      if (_cancelCodes.contains(error.code)) return const Ok(false);
      logError(context, error, stack);
      return Err(mapError(error, context));
    } catch (error, stack) {
      logError(context, error, stack);
      return Err(mapError(error, context));
    }
  }

  static const Set<String> _cancelCodes = {
    'web-context-canceled',
    'web-context-cancelled',
    'canceled',
    'popup-closed-by-user',
  };

  /// Step 1 of owner sign-up: the login itself.
  Future<Result<bool>> createAccount({required String email, required String password}) async {
    const context = '[auth/createAccount]';
    try {
      await auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    } catch (error, stack) {
      logError(context, error, stack);
      return Err(mapError(error, context));
    }
    // The account exists now; if this send fails, the next screen can resend.
    await sendVerificationEmail();
    return const Ok(true);
  }

  /// Sends the link that proves the owner can read this inbox. Nothing can
  /// tell whether an address exists, so this is the only real check.
  Future<Result<bool>> sendVerificationEmail() async {
    const context = '[auth/sendVerification]';
    try {
      await auth.currentUser?.sendEmailVerification();
      return const Ok(true);
    } catch (error, stack) {
      logError(context, error, stack);
      return Err(mapError(error, context));
    }
  }

  /// Step 2 of owner sign-up: the store, the owner membership and the user
  /// profile that points at the store, written in one batch.
  Future<Result<bool>> createStore({
    required User user,
    required String storeName,
    required String ownerName,
  }) {
    const context = '[auth/createStore]';
    final storeRef = db.collection('stores').doc();
    final email = user.email ?? '';
    final batch = db.batch();
    batch.set(storeRef, {
      'name': storeName.trim(),
      'ownerUid': user.uid,
      'createdAt': serverNow(),
    });
    batch.set(storeRef.collection('members').doc(user.uid), {
      'role': Role.owner.name,
      'displayName': ownerName.trim(),
      'email': email,
      'active': true,
      'createdAt': serverNow(),
    });
    batch.set(db.collection('users').doc(user.uid), {
      'storeId': storeRef.id,
      'role': Role.owner.name,
      'displayName': ownerName.trim(),
      'email': email,
      'createdAt': serverNow(),
    });
    return commitBatch(batch, context);
  }

  Future<Result<bool>> sendPasswordReset(String email) async {
    const context = '[auth/reset]';
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
      return const Ok(true);
    } catch (error, stack) {
      logError(context, error, stack);
      return Err(mapError(error, context));
    }
  }

  /// The signed-in login, for the account screen.
  User? get currentUser => auth.currentUser;

  /// True when the login has an email-and-password sign-in (a Google-only
  /// login has no password to change).
  static bool hasPassword(User user) =>
      user.providerData.any((info) => info.providerId == EmailAuthProvider.PROVIDER_ID);

  static bool hasGoogle(User user) =>
      user.providerData.any((info) => info.providerId == GoogleAuthProvider.PROVIDER_ID);

  /// Checks the current password first (Firebase also needs a recent
  /// sign-in to change it), then sets the new one.
  Future<Result<bool>> changePassword({required String currentPassword, required String newPassword}) async {
    const context = '[auth/changePassword]';
    final user = auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      return const Err(AppError(AppErrorCode.permissionDenied, context: context));
    }
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: currentPassword),
      );
      await user.updatePassword(newPassword);
      return const Ok(true);
    } catch (error, stack) {
      logError(context, error, stack);
      return Err(mapError(error, context));
    }
  }

  Future<void> signOut() => auth.signOut();
}
