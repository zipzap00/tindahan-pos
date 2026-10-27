// Products, restocking, stock adjustments and stock movement history.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/manila_time.dart';
import '../../core/result.dart';
import '../../domain/pricing.dart';
import '../firestore_support.dart';
import '../models/product.dart';
import '../models/records.dart';

class NewProductInput {
  const NewProductInput({required this.details, required this.initialStock});

  /// Product with id ignored; its stock field is ignored too.
  final Product details;
  final int initialStock;
}

class CatalogRepository {
  CatalogRepository(this.refs, this.actor);

  final StoreRefs refs;
  final Actor actor;

  /// Every product, archived included, sorted by name.
  Stream<List<Product>> watchProducts() {
    return refs.products.orderBy('nameLower').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList(),
        );
  }

  Stream<List<StockMovement>> watchMovements({String? productId, int limit = 100}) {
    Query<Json> query = refs.stockMovements;
    if (productId != null) query = query.where('productId', isEqualTo: productId);
    return query.orderBy('createdAt', descending: true).limit(limit).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => StockMovement.fromMap(doc.id, doc.data())).toList(),
        );
  }

  /// One-time read of recent movements for CSV export.
  Future<Result<List<StockMovement>>> fetchMovements({int limit = 2000}) async {
    const context = '[catalog/fetchMovements]';
    try {
      final snapshot =
          await refs.stockMovements.orderBy('createdAt', descending: true).limit(limit).get();
      return Ok(snapshot.docs.map((doc) => StockMovement.fromMap(doc.id, doc.data())).toList());
    } catch (error) {
      return Err(mapError(error, context));
    }
  }

  Future<Result<String>> createProduct(NewProductInput input) async {
    const context = '[catalog/create]';
    final today = ManilaTime.todayKey();
    final ref = refs.products.doc();
    final details = input.details;
    final stock = input.initialStock < 0 ? 0 : input.initialStock;
    final batch = refs.db.batch();
    batch.set(ref, {
      ...details.toDetailsMap(),
      'stock': stock,
      'archived': false,
      'soldQty': 0,
      'revenue': 0,
      'cogs': 0,
      'createdAt': serverNow(),
      'updatedAt': serverNow(),
    });
    if (stock > 0) {
      final totalCost = stock * details.unitCost;
      batch.set(refs.stockMovements.doc(), {
        'productId': ref.id,
        'productName': details.name.trim(),
        'type': MovementType.initial.name,
        'qtyChange': stock,
        'stockBefore': 0,
        'stockAfter': stock,
        'unitCost': details.unitCost,
        'totalCost': totalCost,
        'note': '',
        'refLabel': '',
        'dayKey': today,
        'byUid': actor.uid,
        'byName': actor.name,
        'createdAt': serverNow(),
      });
      bumpDailyStats(batch, refs, today, {'restockCost': increment(totalCost)});
    }
    addAudit(batch, refs, actor, AuditAction.productCreated,
        subject: details.name.trim(), qty: stock, amount: details.sellingPrice);
    final result = await commitBatch(batch, context);
    return result.when<Result<String>>(ok: (_) => Ok<String>(ref.id), err: (error) => Err<String>(error));
  }

  /// Saves name, codes, prices and minimum level. Stock is not touched.
  Future<Result<bool>> updateDetails({required Product before, required Product after}) async {
    const context = '[catalog/update]';
    final batch = refs.db.batch();
    batch.update(refs.products.doc(before.id), {
      ...after.toDetailsMap(),
      'updatedAt': serverNow(),
    });
    final priceChanged =
        before.sellingPrice != after.sellingPrice || before.unitCost != after.unitCost;
    addAudit(
      batch,
      refs,
      actor,
      priceChanged ? AuditAction.priceChanged : AuditAction.productEdited,
      subject: after.name.trim(),
      amount: priceChanged ? after.sellingPrice : null,
      note: priceChanged
          ? 'price ${before.sellingPrice}->${after.sellingPrice}; '
              'cost ${before.unitCost.toStringAsFixed(2)}->${after.unitCost.toStringAsFixed(2)}'
          : '',
    );
    return commitBatch(batch, context);
  }

  Future<Result<bool>> setArchived(Product product, {required bool archived}) async {
    const context = '[catalog/archive]';
    final batch = refs.db.batch();
    batch.update(refs.products.doc(product.id), {'archived': archived, 'updatedAt': serverNow()});
    addAudit(batch, refs, actor, archived ? AuditAction.productArchived : AuditAction.productRestored,
        subject: product.name);
    return commitBatch(batch, context);
  }

  /// Receives new stock. The product's cost becomes the weighted average of
  /// the old and new stock.
  Future<Result<bool>> restock({
    required Product product,
    required int qty,
    required double unitCost,
    String supplier = '',
    String note = '',
  }) async {
    const context = '[catalog/restock]';
    if (qty <= 0) return const Err(AppError(AppErrorCode.invalidInput, context: context));
    final today = ManilaTime.todayKey();
    final newAverage = weightedAverageCost(
      currentStock: product.stock,
      currentUnitCost: product.unitCost,
      addedQty: qty,
      addedUnitCost: unitCost,
    );
    final totalCost = qty * unitCost;
    final batch = refs.db.batch();
    batch.update(refs.products.doc(product.id), {
      'stock': increment(qty),
      'unitCost': newAverage,
      if (supplier.trim().isNotEmpty) 'supplier': supplier.trim(),
      'updatedAt': serverNow(),
    });
    batch.set(refs.stockMovements.doc(), {
      'productId': product.id,
      'productName': product.name,
      'type': MovementType.restock.name,
      'qtyChange': qty,
      'stockBefore': product.stock,
      'stockAfter': product.stock + qty,
      'unitCost': unitCost,
      'totalCost': totalCost,
      'note': note.trim(),
      'refLabel': supplier.trim(),
      'dayKey': today,
      'byUid': actor.uid,
      'byName': actor.name,
      'createdAt': serverNow(),
    });
    bumpDailyStats(batch, refs, today, {'restockCost': increment(totalCost)});
    addAudit(batch, refs, actor, AuditAction.stockRestocked,
        subject: product.name, qty: qty, amount: totalCost, note: note.trim());
    return commitBatch(batch, context);
  }

  /// Corrects stock to match a count, or records damage, expiry and loss.
  Future<Result<bool>> adjust({
    required Product product,
    required int newStock,
    required AdjustReason reason,
    String note = '',
  }) async {
    const context = '[catalog/adjust]';
    if (newStock < 0) return const Err(AppError(AppErrorCode.invalidInput, context: context));
    final delta = newStock - product.stock;
    if (delta == 0) return const Ok(true);
    final today = ManilaTime.todayKey();
    final batch = refs.db.batch();
    batch.update(refs.products.doc(product.id), {
      'stock': increment(delta),
      'updatedAt': serverNow(),
    });
    batch.set(refs.stockMovements.doc(), {
      'productId': product.id,
      'productName': product.name,
      'type': MovementType.adjustment.name,
      'qtyChange': delta,
      'stockBefore': product.stock,
      'stockAfter': newStock,
      'unitCost': product.unitCost,
      'reason': reason.name,
      'note': note.trim(),
      'refLabel': '',
      'dayKey': today,
      'byUid': actor.uid,
      'byName': actor.name,
      'createdAt': serverNow(),
    });
    if (delta < 0) {
      // Value of stock lost; kept for reports, not subtracted from sales profit.
      bumpDailyStats(batch, refs, today, {'stockLossCost': increment(-delta * product.unitCost)});
    }
    addAudit(batch, refs, actor, AuditAction.stockAdjusted,
        subject: product.name, qty: delta, note: '${reason.name} ${note.trim()}'.trim());
    return commitBatch(batch, context);
  }
}
