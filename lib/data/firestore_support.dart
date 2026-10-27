// Shared Firestore plumbing: document paths, batch commits that work offline,
// error mapping, daily stats and audit helpers.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/log.dart';
import '../core/result.dart';
import 'models/records.dart';

typedef Json = Map<String, dynamic>;

/// Who is acting. Stored on records as uid plus display name.
class Actor {
  const Actor({required this.uid, required this.name});

  final String uid;
  final String name;
}

/// All collections for one store live under stores/{storeId}.
class StoreRefs {
  StoreRefs(this.db, this.storeId);

  final FirebaseFirestore db;
  final String storeId;

  DocumentReference<Json> get store => db.collection('stores').doc(storeId);
  CollectionReference<Json> get members => store.collection('members');
  CollectionReference<Json> get products => store.collection('products');
  CollectionReference<Json> get sales => store.collection('sales');
  CollectionReference<Json> get refunds => store.collection('refunds');
  CollectionReference<Json> get stockMovements => store.collection('stockMovements');
  CollectionReference<Json> get dailyStats => store.collection('dailyStats');
  CollectionReference<Json> get customers => store.collection('customers');
  CollectionReference<Json> get expenses => store.collection('expenses');
  CollectionReference<Json> get auditLogs => store.collection('auditLogs');

  CollectionReference<Json> ledger(String customerId) =>
      customers.doc(customerId).collection('ledger');
}

/// How long to wait for the server before treating a write as saved offline.
/// Firestore applies writes to the local cache at once and syncs later, but a
/// batch's Future only completes when the server confirms it.
const Duration serverWait = Duration(seconds: 3);

/// Commits a batch. Returns Ok(true) when the server confirmed it, Ok(false)
/// when it is saved on the phone and still waiting for a connection, or Err
/// when the server rejected it (for example a security rule or not enough
/// stock).
Future<Result<bool>> commitBatch(WriteBatch batch, String context) async {
  final commit = batch.commit();
  try {
    await commit.timeout(serverWait);
    return const Ok(true);
  } on TimeoutException {
    unawaited(commit.then<void>(
      (_) => logInfo(context, 'synced after reconnecting'),
      onError: (Object error, StackTrace stack) => logError(context, error, stack),
    ));
    return const Ok(false);
  } catch (error, stack) {
    logError(context, error, stack);
    return Err(mapError(error, context));
  }
}

AppError mapError(Object error, String context) {
  if (error is FirebaseAuthException) {
    final code = switch (error.code) {
      'email-already-in-use' => AppErrorCode.emailInUse,
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'INVALID_LOGIN_CREDENTIALS' =>
        AppErrorCode.wrongCredentials,
      'weak-password' => AppErrorCode.weakPassword,
      'invalid-email' => AppErrorCode.invalidEmail,
      'too-many-requests' => AppErrorCode.tooManyAttempts,
      'network-request-failed' => AppErrorCode.offline,
      'user-disabled' => AppErrorCode.permissionDenied,
      _ => AppErrorCode.unknown,
    };
    return AppError(code, context: context, cause: error);
  }
  if (error is FirebaseException) {
    final code = switch (error.code) {
      'permission-denied' => AppErrorCode.permissionDenied,
      'not-found' => AppErrorCode.notFound,
      'unavailable' || 'deadline-exceeded' => AppErrorCode.offline,
      'invalid-argument' => AppErrorCode.invalidInput,
      _ => AppErrorCode.unknown,
    };
    return AppError(code, context: context, cause: error);
  }
  if (error is UnsupportedError) {
    return AppError(AppErrorCode.notConfigured, context: context, cause: error);
  }
  return AppError(AppErrorCode.unknown, context: context, cause: error);
}

/// Adds increments to the daily stats document for [dayKey] (merge write).
void bumpDailyStats(WriteBatch batch, StoreRefs refs, String dayKey, Json fields) {
  batch.set(
    refs.dailyStats.doc(dayKey),
    {
      'dayKey': dayKey,
      'monthKey': dayKey.substring(0, 7),
      'updatedAt': FieldValue.serverTimestamp(),
      ...fields,
    },
    SetOptions(merge: true),
  );
}

/// Writes an audit record in the same batch as the change it describes.
void addAudit(
  WriteBatch batch,
  StoreRefs refs,
  Actor actor,
  AuditAction action, {
  String subject = '',
  num? amount,
  int? qty,
  String note = '',
}) {
  batch.set(refs.auditLogs.doc(), {
    'action': action.name,
    'subject': subject,
    if (amount != null) 'amount': amount,
    if (qty != null) 'qty': qty,
    'note': note,
    'byUid': actor.uid,
    'byName': actor.name,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

FieldValue increment(num value) => FieldValue.increment(value);

FieldValue serverNow() => FieldValue.serverTimestamp();
