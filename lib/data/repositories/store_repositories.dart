// Expenses, daily stats, audit log and staff.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/log.dart';
import '../../core/result.dart';
import '../firestore_support.dart';
import '../models/records.dart';

class ExpenseRepository {
  ExpenseRepository(this.refs, this.actor);

  final StoreRefs refs;
  final Actor actor;

  Stream<List<Expense>> watchMonth(String monthKey) {
    return refs.expenses
        .where('monthKey', isEqualTo: monthKey)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Expense.fromMap(doc.id, doc.data())).toList());
  }

  Future<Result<bool>> add({
    required int amount,
    required ExpenseCategory category,
    required String dayKey,
    String note = '',
  }) {
    const context = '[expenses/add]';
    if (amount <= 0) return Future.value(const Err(AppError(AppErrorCode.invalidInput, context: context)));
    final batch = refs.db.batch();
    batch.set(refs.expenses.doc(), {
      'amount': amount,
      'category': category.name,
      'note': note.trim(),
      'dayKey': dayKey,
      'monthKey': dayKey.substring(0, 7),
      'byUid': actor.uid,
      'byName': actor.name,
      'createdAt': serverNow(),
    });
    bumpDailyStats(batch, refs, dayKey, {'expenses': increment(amount)});
    addAudit(batch, refs, actor, AuditAction.expenseAdded, subject: category.name, amount: amount);
    return commitBatch(batch, context);
  }

  Future<Result<bool>> delete(Expense expense) {
    const context = '[expenses/delete]';
    final batch = refs.db.batch();
    batch.delete(refs.expenses.doc(expense.id));
    bumpDailyStats(batch, refs, expense.dayKey, {'expenses': increment(-expense.amount)});
    addAudit(batch, refs, actor, AuditAction.expenseDeleted,
        subject: expense.category.name, amount: expense.amount);
    return commitBatch(batch, context);
  }
}

class InsightsRepository {
  InsightsRepository(this.refs);

  final StoreRefs refs;

  /// Daily stats from [fromDayKey] up to today, oldest first.
  Stream<List<DailyStats>> watchDailyStatsSince(String fromDayKey) {
    return refs.dailyStats
        .where('dayKey', isGreaterThanOrEqualTo: fromDayKey)
        .orderBy('dayKey')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => DailyStats.fromMap(doc.id, doc.data())).toList());
  }

  Stream<DailyStats> watchDay(String dayKey) {
    return refs.dailyStats.doc(dayKey).snapshots().map((doc) {
      final data = doc.data();
      return data == null ? DailyStats(dayKey: dayKey) : DailyStats.fromMap(dayKey, data);
    });
  }

  Stream<List<AuditEntry>> watchAudit({int limit = 150}) {
    return refs.auditLogs.orderBy('createdAt', descending: true).limit(limit).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => AuditEntry.fromMap(doc.id, doc.data())).toList(),
        );
  }
}

class StaffRepository {
  StaffRepository(this.refs, this.actor);

  final StoreRefs refs;
  final Actor actor;

  Stream<List<Member>> watchMembers() {
    return refs.members.snapshots().map((snapshot) {
      final members = snapshot.docs.map((doc) => Member.fromMap(doc.id, doc.data())).toList();
      members.sort((a, b) {
        if (a.isOwner != b.isOwner) return a.isOwner ? -1 : 1;
        return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      });
      return members;
    });
  }

  /// Creates a cashier sign-in. A second Firebase app instance is used so the
  /// owner stays signed in while the new account is created.
  Future<Result<bool>> createCashier({
    required String displayName,
    required String email,
    required String password,
  }) async {
    const context = '[staff/create]';
    const appName = 'staff-creator';
    FirebaseApp? helperApp;
    try {
      helperApp = Firebase.apps.where((app) => app.name == appName).firstOrNull ??
          await Firebase.initializeApp(name: appName, options: Firebase.app().options);
      final helperAuth = FirebaseAuth.instanceFor(app: helperApp);
      final credential = await helperAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      await helperAuth.signOut();
      if (uid == null) return const Err(AppError(AppErrorCode.unknown, context: context));

      final batch = refs.db.batch();
      batch.set(refs.members.doc(uid), {
        'role': Role.cashier.name,
        'displayName': displayName.trim(),
        'email': email.trim(),
        'active': true,
        'createdAt': serverNow(),
      });
      batch.set(refs.db.collection('users').doc(uid), {
        'storeId': refs.storeId,
        'role': Role.cashier.name,
        'displayName': displayName.trim(),
        'email': email.trim(),
        'createdAt': serverNow(),
      });
      addAudit(batch, refs, actor, AuditAction.staffAdded, subject: displayName.trim());
      return await commitBatch(batch, context);
    } catch (error, stack) {
      logError(context, error, stack);
      return Err(mapError(error, context));
    } finally {
      final app = helperApp;
      if (app != null) {
        try {
          await app.delete();
        } catch (error) {
          logError(context, error);
        }
      }
    }
  }

  Future<Result<bool>> setActive(Member member, {required bool active}) {
    const context = '[staff/setActive]';
    final batch = refs.db.batch();
    batch.update(refs.members.doc(member.uid), {'active': active});
    addAudit(batch, refs, actor, active ? AuditAction.staffEnabled : AuditAction.staffDisabled,
        subject: member.displayName);
    return commitBatch(batch, context);
  }
}
