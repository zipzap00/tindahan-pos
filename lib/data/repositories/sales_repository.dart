// Checkout, refunds and cancellations. Each is one atomic batch: the sale,
// every stock change, stock movement, daily stats, utang ledger and audit
// record are written together or not at all. Security rules reject any
// batch that would push a product's stock below zero.

import 'dart:math';

import '../../core/manila_time.dart';
import '../../core/result.dart';
import '../../domain/cart.dart';
import '../firestore_support.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/records.dart';
import '../models/sale.dart';

class CheckoutRequest {
  const CheckoutRequest({
    required this.lines,
    required this.paymentType,
    required this.amountPaid,
    this.customer,
  });

  final List<CartLine> lines;
  final PaymentType paymentType;

  /// Cash received, in centavos. Ignored for utang.
  final int amountPaid;
  final Customer? customer;
}

class SaleOutcome {
  const SaleOutcome({required this.sale, required this.synced});

  final Sale sale;

  /// False when saved on the phone and waiting for internet.
  final bool synced;
}

class SalesRepository {
  SalesRepository(this.refs, this.actor);

  final StoreRefs refs;
  final Actor actor;
  final Random _random = Random();

  static const String _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _suffix() => List.generate(2, (_) => _codeAlphabet[_random.nextInt(_codeAlphabet.length)]).join();

  Stream<List<Sale>> watchRecent({int limit = 8}) {
    return refs.sales.orderBy('createdAt', descending: true).limit(limit).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Sale.fromMap(doc.id, doc.data())).toList(),
        );
  }

  Stream<List<Sale>> watchDay(String dayKey) {
    return refs.sales
        .where('dayKey', isEqualTo: dayKey)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Sale.fromMap(doc.id, doc.data())).toList());
  }

  Stream<Sale?> watchSale(String saleId) {
    return refs.sales.doc(saleId).snapshots().map((doc) {
      final data = doc.data();
      return data == null ? null : Sale.fromMap(doc.id, data);
    });
  }

  Stream<List<Refund>> watchRefundsForSale(String saleId) {
    return refs.refunds.where('saleId', isEqualTo: saleId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Refund.fromMap(doc.id, doc.data())).toList(),
        );
  }

  Future<Result<SaleOutcome>> checkout(CheckoutRequest request, Map<String, Product> latest) async {
    const context = '[sales/checkout]';
    if (request.lines.isEmpty) {
      return const Err(AppError(AppErrorCode.invalidInput, context: context));
    }
    final problems = findCartProblems(request.lines, latest);
    if (problems.isNotEmpty) {
      return Err(AppError(
        AppErrorCode.insufficientStock,
        context: context,
        detail: problems.map((problem) => problem.name).join(', '),
      ));
    }
    final isUtang = request.paymentType == PaymentType.utang;
    final customer = request.customer;
    final total = request.lines.fold<int>(0, (sum, line) => sum + line.lineTotal);
    if (isUtang && customer == null) {
      return const Err(AppError(AppErrorCode.invalidInput, context: context));
    }
    if (!isUtang && request.amountPaid < total) {
      return const Err(AppError(AppErrorCode.invalidInput, context: context));
    }

    final now = ManilaTime.now();
    final dayKey = ManilaTime.dayKey(now);
    final receiptNo = ManilaTime.receiptNumber(now, _suffix());
    final saleRef = refs.sales.doc();
    final items = [
      for (final line in request.lines)
        SaleItem(
          productId: line.productId,
          name: line.name,
          qty: line.qty,
          unitPrice: line.unitPrice,
          unitCost: line.unitCost,
        ),
    ];
    final profit = items.fold<double>(0, (sum, item) => sum + item.lineProfit);
    final amountPaid = isUtang ? 0 : request.amountPaid;
    final change = isUtang ? 0 : request.amountPaid - total;

    final batch = refs.db.batch();
    batch.set(saleRef, {
      'receiptNo': receiptNo,
      'dayKey': dayKey,
      'monthKey': ManilaTime.monthKey(now),
      'cashierUid': actor.uid,
      'cashierName': actor.name,
      'items': items.map((item) => item.toMap()).toList(),
      'itemCount': items.fold<int>(0, (sum, item) => sum + item.qty),
      'subtotal': total,
      'total': total,
      'amountPaid': amountPaid,
      'change': change,
      'paymentType': request.paymentType.name,
      if (customer != null) 'customerId': customer.id,
      if (customer != null) 'customerName': customer.name,
      'status': SaleStatus.completed.name,
      'profit': profit,
      'refundedAmount': 0,
      'refundedProfit': 0,
      'createdAt': serverNow(),
    });

    final itemStats = <String, Object>{};
    for (final item in items) {
      final product = latest[item.productId];
      if (product == null) continue;
      batch.update(refs.products.doc(item.productId), {
        'stock': increment(-item.qty),
        'soldQty': increment(item.qty),
        'revenue': increment(item.lineTotal),
        'cogs': increment(item.qty * item.unitCost),
        'updatedAt': serverNow(),
      });
      batch.set(refs.stockMovements.doc(), {
        'productId': item.productId,
        'productName': item.name,
        'type': MovementType.sale.name,
        'qtyChange': -item.qty,
        'stockBefore': product.stock,
        'stockAfter': product.stock - item.qty,
        'unitCost': item.unitCost,
        'note': '',
        'refId': saleRef.id,
        'refLabel': receiptNo,
        'dayKey': dayKey,
        'byUid': actor.uid,
        'byName': actor.name,
        'createdAt': serverNow(),
      });
      itemStats[item.productId] = {
        'name': item.name,
        'qty': increment(item.qty),
        'revenue': increment(item.lineTotal),
      };
    }

    bumpDailyStats(batch, refs, dayKey, {
      'salesTotal': increment(total),
      'profit': increment(profit),
      'txnCount': increment(1),
      'items': itemStats,
      if (isUtang) 'utangCharged': increment(total),
    });

    if (isUtang && customer != null) {
      batch.update(refs.customers.doc(customer.id), {
        'balance': increment(total),
        'lastActivityAt': serverNow(),
      });
      batch.set(refs.ledger(customer.id).doc(), {
        'type': LedgerType.charge.name,
        'amount': total,
        'balanceAfter': customer.balance + total,
        'saleId': saleRef.id,
        'receiptNo': receiptNo,
        'note': '',
        'byUid': actor.uid,
        'byName': actor.name,
        'createdAt': serverNow(),
      });
    }

    final sale = Sale(
      id: saleRef.id,
      receiptNo: receiptNo,
      dayKey: dayKey,
      cashierUid: actor.uid,
      cashierName: actor.name,
      items: items,
      total: total,
      amountPaid: amountPaid,
      change: change,
      paymentType: request.paymentType,
      status: SaleStatus.completed,
      profit: profit,
      customerId: customer?.id,
      customerName: customer?.name,
      createdAt: DateTime.now(),
    );

    final result = await commitBatch(batch, context);
    return result.when<Result<SaleOutcome>>(
      ok: (synced) => Ok<SaleOutcome>(SaleOutcome(sale: sale, synced: synced)),
      err: (error) => Err<SaleOutcome>(error),
    );
  }

  /// Returns some or all items. [qtyByProduct] maps product id to pieces
  /// returned. When [restock] is true the pieces go back on the shelf;
  /// otherwise they are written off (damaged or spoiled).
  Future<Result<bool>> refund({
    required Sale sale,
    required Map<String, int> qtyByProduct,
    required bool restock,
    required String reason,
    required Map<String, Product> latest,
    Customer? customer,
  }) async {
    const context = '[sales/refund]';
    if (sale.isCancelled) return const Err(AppError(AppErrorCode.invalidInput, context: context));

    final refundItems = <RefundItem>[];
    final updatedItems = <SaleItem>[];
    for (final item in sale.items) {
      final requested = qtyByProduct[item.productId] ?? 0;
      if (requested < 0 || requested > item.refundableQty) {
        return const Err(AppError(AppErrorCode.invalidInput, context: context));
      }
      if (requested > 0) {
        refundItems.add(RefundItem(
          productId: item.productId,
          name: item.name,
          qty: requested,
          unitPrice: item.unitPrice,
          unitCost: item.unitCost,
        ));
      }
      updatedItems.add(item.withRefunded(requested));
    }
    if (refundItems.isEmpty) return const Err(AppError(AppErrorCode.invalidInput, context: context));

    final amount = refundItems.fold<int>(0, (sum, item) => sum + item.amount);
    // Restocked goods give back their cost; written-off goods do not, so the
    // whole selling price comes off profit.
    final profitReversal = refundItems.fold<double>(
      0,
      (sum, item) =>
          sum + item.qty * (restock ? item.unitPrice - item.unitCost : item.unitPrice.toDouble()),
    );
    final fullyRefunded = updatedItems.every((item) => item.refundableQty == 0);
    final now = ManilaTime.now();
    final today = ManilaTime.dayKey(now);

    final batch = refs.db.batch();
    batch.update(refs.sales.doc(sale.id), {
      'items': updatedItems.map((item) => item.toMap()).toList(),
      'refundedAmount': increment(amount),
      'refundedProfit': increment(profitReversal),
      'status': fullyRefunded ? SaleStatus.refunded.name : SaleStatus.completed.name,
      'lastRefundAt': serverNow(),
    });
    batch.set(refs.refunds.doc(), {
      'saleId': sale.id,
      'receiptNo': sale.receiptNo,
      'items': refundItems.map((item) => item.toMap()).toList(),
      'amount': amount,
      'profitReversal': profitReversal,
      'restocked': restock,
      'reason': reason.trim(),
      'paymentType': sale.paymentType.name,
      'dayKey': today,
      'monthKey': ManilaTime.monthKey(now),
      'byUid': actor.uid,
      'byName': actor.name,
      'createdAt': serverNow(),
    });

    final itemStats = <String, Object>{};
    for (final item in refundItems) {
      final product = latest[item.productId];
      if (product != null) {
        batch.update(refs.products.doc(item.productId), {
          if (restock) 'stock': increment(item.qty),
          'soldQty': increment(-item.qty),
          'revenue': increment(-item.amount),
          if (restock) 'cogs': increment(-item.qty * item.unitCost),
          'updatedAt': serverNow(),
        });
        if (restock) {
          batch.set(refs.stockMovements.doc(), {
            'productId': item.productId,
            'productName': item.name,
            'type': MovementType.refund.name,
            'qtyChange': item.qty,
            'stockBefore': product.stock,
            'stockAfter': product.stock + item.qty,
            'unitCost': item.unitCost,
            'note': reason.trim(),
            'refId': sale.id,
            'refLabel': sale.receiptNo,
            'dayKey': today,
            'byUid': actor.uid,
            'byName': actor.name,
            'createdAt': serverNow(),
          });
        }
      }
      itemStats[item.productId] = {
        'name': item.name,
        'qty': increment(-item.qty),
        'revenue': increment(-item.amount),
      };
    }

    bumpDailyStats(batch, refs, today, {
      'refundTotal': increment(amount),
      'refundProfit': increment(profitReversal),
      'items': itemStats,
    });

    final customerId = sale.customerId;
    if (sale.paymentType == PaymentType.utang && customerId != null) {
      batch.update(refs.customers.doc(customerId), {
        'balance': increment(-amount),
        'lastActivityAt': serverNow(),
      });
      batch.set(refs.ledger(customerId).doc(), {
        'type': LedgerType.refund.name,
        'amount': amount,
        'balanceAfter': (customer?.balance ?? amount) - amount,
        'saleId': sale.id,
        'receiptNo': sale.receiptNo,
        'note': reason.trim(),
        'byUid': actor.uid,
        'byName': actor.name,
        'createdAt': serverNow(),
      });
    }

    addAudit(batch, refs, actor, AuditAction.saleRefunded,
        subject: sale.receiptNo,
        amount: amount,
        qty: refundItems.fold<int>(0, (sum, item) => sum + item.qty),
        note: '${restock ? 'restocked' : 'written off'}: ${reason.trim()}');
    return commitBatch(batch, context);
  }

  /// Voids a whole sale that has no refunds. Stock returns to the shelf and
  /// the sale is removed from the totals of the day it was made.
  Future<Result<bool>> cancel({
    required Sale sale,
    required String reason,
    required Map<String, Product> latest,
    Customer? customer,
  }) async {
    const context = '[sales/cancel]';
    if (!sale.canCancel) return const Err(AppError(AppErrorCode.invalidInput, context: context));
    final today = ManilaTime.todayKey();

    final batch = refs.db.batch();
    batch.update(refs.sales.doc(sale.id), {
      'status': SaleStatus.cancelled.name,
      'cancelReason': reason.trim(),
      'cancelledAt': serverNow(),
      'cancelledByUid': actor.uid,
      'cancelledByName': actor.name,
    });

    final itemStats = <String, Object>{};
    for (final item in sale.items) {
      final product = latest[item.productId];
      if (product != null) {
        batch.update(refs.products.doc(item.productId), {
          'stock': increment(item.qty),
          'soldQty': increment(-item.qty),
          'revenue': increment(-item.lineTotal),
          'cogs': increment(-item.qty * item.unitCost),
          'updatedAt': serverNow(),
        });
        batch.set(refs.stockMovements.doc(), {
          'productId': item.productId,
          'productName': item.name,
          'type': MovementType.cancel.name,
          'qtyChange': item.qty,
          'stockBefore': product.stock,
          'stockAfter': product.stock + item.qty,
          'unitCost': item.unitCost,
          'note': reason.trim(),
          'refId': sale.id,
          'refLabel': sale.receiptNo,
          'dayKey': today,
          'byUid': actor.uid,
          'byName': actor.name,
          'createdAt': serverNow(),
        });
      }
      itemStats[item.productId] = {
        'name': item.name,
        'qty': increment(-item.qty),
        'revenue': increment(-item.lineTotal),
      };
    }

    final isUtang = sale.paymentType == PaymentType.utang;
    bumpDailyStats(batch, refs, sale.dayKey, {
      'salesTotal': increment(-sale.total),
      'profit': increment(-sale.profit),
      'txnCount': increment(-1),
      'cancelledCount': increment(1),
      'items': itemStats,
      if (isUtang) 'utangCharged': increment(-sale.total),
    });

    final customerId = sale.customerId;
    if (isUtang && customerId != null) {
      batch.update(refs.customers.doc(customerId), {
        'balance': increment(-sale.total),
        'lastActivityAt': serverNow(),
      });
      batch.set(refs.ledger(customerId).doc(), {
        'type': LedgerType.cancel.name,
        'amount': sale.total,
        'balanceAfter': (customer?.balance ?? sale.total) - sale.total,
        'saleId': sale.id,
        'receiptNo': sale.receiptNo,
        'note': reason.trim(),
        'byUid': actor.uid,
        'byName': actor.name,
        'createdAt': serverNow(),
      });
    }

    addAudit(batch, refs, actor, AuditAction.saleCancelled,
        subject: sale.receiptNo, amount: sale.total, note: reason.trim());
    return commitBatch(batch, context);
  }
}
