// Smaller records: expenses, stock movements, members, daily stats, audit log.

import '../firestore_read.dart';

// ── Expenses ──────────────────────────────────────────────────────────────

/// Expense categories. Stored by [name]; labels come from Strings.
enum ExpenseCategory { electricity, water, rent, transport, supplies, food, other }

class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.dayKey,
    required this.byName,
    this.note = '',
    this.createdAt,
  });

  final String id;
  final int amount;
  final ExpenseCategory category;
  final String dayKey;
  final String byName;
  final String note;
  final DateTime? createdAt;

  factory Expense.fromMap(String id, Map<String, dynamic> map) => Expense(
        id: id,
        amount: readInt(map['amount']),
        category: ExpenseCategory.values.firstWhere(
          (value) => value.name == readString(map['category']),
          orElse: () => ExpenseCategory.other,
        ),
        dayKey: readString(map['dayKey']),
        byName: readString(map['byName']),
        note: readString(map['note']),
        createdAt: readDate(map['createdAt']),
      );
}

// ── Stock movements ───────────────────────────────────────────────────────

enum MovementType { initial, sale, restock, adjustment, refund, cancel }

/// Reasons for a manual stock adjustment. Stored by [name].
enum AdjustReason { recount, damaged, expired, lost, personalUse, other }

class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.qtyChange,
    required this.stockBefore,
    required this.stockAfter,
    required this.byName,
    this.unitCost,
    this.totalCost,
    this.reason,
    this.note = '',
    this.refLabel = '',
    this.createdAt,
  });

  final String id;
  final String productId;
  final String productName;
  final MovementType type;

  /// Positive when stock came in, negative when it went out.
  final int qtyChange;
  final int stockBefore;
  final int stockAfter;
  final String byName;
  final double? unitCost;
  final double? totalCost;
  final AdjustReason? reason;
  final String note;

  /// Receipt number for sale, refund and cancel movements.
  final String refLabel;
  final DateTime? createdAt;

  factory StockMovement.fromMap(String id, Map<String, dynamic> map) {
    final reasonText = readStringOrNull(map['reason']);
    return StockMovement(
      id: id,
      productId: readString(map['productId']),
      productName: readString(map['productName']),
      type: MovementType.values.firstWhere(
        (value) => value.name == readString(map['type']),
        orElse: () => MovementType.adjustment,
      ),
      qtyChange: readInt(map['qtyChange']),
      stockBefore: readInt(map['stockBefore']),
      stockAfter: readInt(map['stockAfter']),
      byName: readString(map['byName']),
      unitCost: map['unitCost'] is num ? readDouble(map['unitCost']) : null,
      totalCost: map['totalCost'] is num ? readDouble(map['totalCost']) : null,
      reason: reasonText == null
          ? null
          : AdjustReason.values.firstWhere(
              (value) => value.name == reasonText,
              orElse: () => AdjustReason.other,
            ),
      note: readString(map['note']),
      refLabel: readString(map['refLabel']),
      createdAt: readDate(map['createdAt']),
    );
  }
}

// ── Members ───────────────────────────────────────────────────────────────

enum Role { owner, cashier }

class Member {
  const Member({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    required this.active,
  });

  final String uid;
  final String displayName;
  final String email;
  final Role role;
  final bool active;

  bool get isOwner => role == Role.owner;

  factory Member.fromMap(String uid, Map<String, dynamic> map) => Member(
        uid: uid,
        displayName: readString(map['displayName']),
        email: readString(map['email']),
        role: readString(map['role']) == 'owner' ? Role.owner : Role.cashier,
        active: readBool(map['active']),
      );
}

// ── Daily stats ───────────────────────────────────────────────────────────

class ItemStat {
  const ItemStat({required this.name, required this.qty, required this.revenue});

  final String name;
  final int qty;
  final int revenue;
}

/// One document per Manila day, updated in the same batch as each sale,
/// refund, cancellation, expense and restock. The dashboard reads at most a
/// month of these instead of every sale.
class DailyStats {
  const DailyStats({
    required this.dayKey,
    this.salesTotal = 0,
    this.profit = 0,
    this.txnCount = 0,
    this.refundTotal = 0,
    this.refundProfit = 0,
    this.cancelledCount = 0,
    this.expenses = 0,
    this.restockCost = 0,
    this.utangCharged = 0,
    this.utangCollected = 0,
    this.items = const {},
  });

  final String dayKey;
  final int salesTotal;
  final double profit;
  final int txnCount;
  final int refundTotal;
  final double refundProfit;
  final int cancelledCount;
  final int expenses;
  final double restockCost;
  final int utangCharged;
  final int utangCollected;
  final Map<String, ItemStat> items;

  int get netSales => salesTotal - refundTotal;
  double get netProfit => profit - refundProfit;

  factory DailyStats.fromMap(String dayKey, Map<String, dynamic> map) {
    final itemMap = readMap(map['items']);
    return DailyStats(
      dayKey: dayKey,
      salesTotal: readInt(map['salesTotal']),
      profit: readDouble(map['profit']),
      txnCount: readInt(map['txnCount']),
      refundTotal: readInt(map['refundTotal']),
      refundProfit: readDouble(map['refundProfit']),
      cancelledCount: readInt(map['cancelledCount']),
      expenses: readInt(map['expenses']),
      restockCost: readDouble(map['restockCost']),
      utangCharged: readInt(map['utangCharged']),
      utangCollected: readInt(map['utangCollected']),
      items: itemMap.map((productId, value) {
        final stat = readMap(value);
        return MapEntry(
          productId,
          ItemStat(
            name: readString(stat['name']),
            qty: readInt(stat['qty']),
            revenue: readInt(stat['revenue']),
          ),
        );
      }),
    );
  }
}

// ── Audit log ─────────────────────────────────────────────────────────────

enum AuditAction {
  productCreated,
  productEdited,
  priceChanged,
  productArchived,
  productRestored,
  stockRestocked,
  stockAdjusted,
  saleRefunded,
  saleCancelled,
  utangPayment,
  utangManualCharge,
  expenseAdded,
  expenseDeleted,
  staffAdded,
  staffDisabled,
  staffEnabled,
}

class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.action,
    required this.byName,
    this.subject = '',
    this.amount,
    this.qty,
    this.note = '',
    this.createdAt,
  });

  final String id;
  final AuditAction action;
  final String byName;

  /// What it was about: product name, receipt number, expense category.
  final String subject;
  final num? amount;
  final int? qty;
  final String note;
  final DateTime? createdAt;

  factory AuditEntry.fromMap(String id, Map<String, dynamic> map) => AuditEntry(
        id: id,
        action: AuditAction.values.firstWhere(
          (value) => value.name == readString(map['action']),
          orElse: () => AuditAction.productEdited,
        ),
        byName: readString(map['byName']),
        subject: readString(map['subject']),
        amount: map['amount'] is num ? map['amount'] as num : null,
        qty: map['qty'] is num ? readInt(map['qty']) : null,
        note: readString(map['note']),
        createdAt: readDate(map['createdAt']),
      );
}
