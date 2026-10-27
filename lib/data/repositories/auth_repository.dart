// Sign in, account creation and first-time store setup.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  /// Step 1 of owner sign-up: the login itself.
  Future<Result<bool>> createAccount({required String email, required String password}) async {
    const context = '[auth/createAccount]';
    try {
      await auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
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

  Future<void> signOut() => auth.signOut();
}
