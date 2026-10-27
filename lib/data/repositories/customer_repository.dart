// Utang (credit) customers, payments and their ledger.

import '../../core/manila_time.dart';
import '../../core/result.dart';
import '../firestore_support.dart';
import '../models/customer.dart';
import '../models/records.dart';

class CustomerRepository {
  CustomerRepository(this.refs, this.actor);

  final StoreRefs refs;
  final Actor actor;

  Stream<List<Customer>> watchCustomers() {
    return refs.customers.orderBy('nameLower').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Customer.fromMap(doc.id, doc.data())).toList(),
        );
  }

  Stream<List<LedgerEntry>> watchLedger(String customerId, {int limit = 100}) {
    return refs
        .ledger(customerId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LedgerEntry.fromMap(doc.id, doc.data())).toList());
  }

  Future<Result<Customer>> create({required String name, String phone = '', String note = ''}) async {
    const context = '[customers/create]';
    final trimmed = name.trim();
    if (trimmed.isEmpty) return const Err(AppError(AppErrorCode.invalidInput, context: context));
    final ref = refs.customers.doc();
    final batch = refs.db.batch();
    batch.set(ref, {
      'name': trimmed,
      'nameLower': trimmed.toLowerCase(),
      'phone': phone.trim(),
      'note': note.trim(),
      'balance': 0,
      'archived': false,
      'createdAt': serverNow(),
      'lastActivityAt': serverNow(),
    });
    final result = await commitBatch(batch, context);
    return result.when<Result<Customer>>(
      ok: (_) => Ok<Customer>(Customer(id: ref.id, name: trimmed, phone: phone.trim(), note: note.trim(), balance: 0)),
      err: (error) => Err<Customer>(error),
    );
  }

  Future<Result<bool>> updateDetails(Customer customer, {required String name, required String phone, required String note}) {
    const context = '[customers/update]';
    final trimmed = name.trim();
    final batch = refs.db.batch();
    batch.update(refs.customers.doc(customer.id), {
      'name': trimmed,
      'nameLower': trimmed.toLowerCase(),
      'phone': phone.trim(),
      'note': note.trim(),
    });
    return commitBatch(batch, context);
  }

  /// Customer pays some or all of what they owe.
  Future<Result<bool>> recordPayment(Customer customer, {required int amount, String note = ''}) {
    const context = '[customers/payment]';
    if (amount <= 0) return Future.value(const Err(AppError(AppErrorCode.invalidInput, context: context)));
    final today = ManilaTime.todayKey();
    final batch = refs.db.batch();
    batch.update(refs.customers.doc(customer.id), {
      'balance': increment(-amount),
      'lastActivityAt': serverNow(),
    });
    batch.set(refs.ledger(customer.id).doc(), {
      'type': LedgerType.payment.name,
      'amount': amount,
      'balanceAfter': customer.balance - amount,
      'saleId': '',
      'receiptNo': '',
      'note': note.trim(),
      'byUid': actor.uid,
      'byName': actor.name,
      'createdAt': serverNow(),
    });
    bumpDailyStats(batch, refs, today, {'utangCollected': increment(amount)});
    addAudit(batch, refs, actor, AuditAction.utangPayment, subject: customer.name, amount: amount);
    return commitBatch(batch, context);
  }

  /// Old debt written down from a notebook, or credit given outside the POS.
  Future<Result<bool>> recordManualCharge(Customer customer, {required int amount, required String note}) {
    const context = '[customers/charge]';
    if (amount <= 0) return Future.value(const Err(AppError(AppErrorCode.invalidInput, context: context)));
    final today = ManilaTime.todayKey();
    final batch = refs.db.batch();
    batch.update(refs.customers.doc(customer.id), {
      'balance': increment(amount),
      'lastActivityAt': serverNow(),
    });
    batch.set(refs.ledger(customer.id).doc(), {
      'type': LedgerType.charge.name,
      'amount': amount,
      'balanceAfter': customer.balance + amount,
      'saleId': '',
      'receiptNo': '',
      'note': note.trim(),
      'byUid': actor.uid,
      'byName': actor.name,
      'createdAt': serverNow(),
    });
    bumpDailyStats(batch, refs, today, {'utangCharged': increment(amount)});
    addAudit(batch, refs, actor, AuditAction.utangManualCharge,
        subject: customer.name, amount: amount, note: note.trim());
    return commitBatch(batch, context);
  }
}
