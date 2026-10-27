import '../firestore_read.dart';

enum PaymentType { cash, utang }

enum SaleStatus { completed, refunded, cancelled }

class SaleItem {
  const SaleItem({
    required this.productId,
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.unitCost,
    this.refundedQty = 0,
  });

  final String productId;
  final String name;
  final int qty;

  /// Centavos, at the time of sale.
  final int unitPrice;

  /// Average cost in centavos at the time of sale (snapshot for profit).
  final double unitCost;
  final int refundedQty;

  int get lineTotal => qty * unitPrice;
  int get refundableQty => qty - refundedQty;
  double get lineProfit => qty * (unitPrice - unitCost);

  SaleItem withRefunded(int extra) => SaleItem(
        productId: productId,
        name: name,
        qty: qty,
        unitPrice: unitPrice,
        unitCost: unitCost,
        refundedQty: refundedQty + extra,
      );

  factory SaleItem.fromMap(Map<String, dynamic> map) => SaleItem(
        productId: readString(map['productId']),
        name: readString(map['name']),
        qty: readInt(map['qty']),
        unitPrice: readInt(map['unitPrice']),
        unitCost: readDouble(map['unitCost']),
        refundedQty: readInt(map['refundedQty']),
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'qty': qty,
        'unitPrice': unitPrice,
        'unitCost': unitCost,
        'refundedQty': refundedQty,
      };
}

class Sale {
  const Sale({
    required this.id,
    required this.receiptNo,
    required this.dayKey,
    required this.cashierUid,
    required this.cashierName,
    required this.items,
    required this.total,
    required this.amountPaid,
    required this.change,
    required this.paymentType,
    required this.status,
    required this.profit,
    this.customerId,
    this.customerName,
    this.refundedAmount = 0,
    this.refundedProfit = 0,
    this.cancelReason,
    this.cancelledAt,
    this.createdAt,
  });

  final String id;
  final String receiptNo;
  final String dayKey;
  final String cashierUid;
  final String cashierName;
  final List<SaleItem> items;

  /// Centavos. There is no tax or discount line, so subtotal equals total.
  final int total;
  final int amountPaid;
  final int change;
  final PaymentType paymentType;
  final SaleStatus status;

  /// Gross profit of the original sale in centavos.
  final double profit;
  final String? customerId;
  final String? customerName;
  final int refundedAmount;
  final double refundedProfit;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime? createdAt;

  int get itemCount => items.fold(0, (sum, item) => sum + item.qty);
  bool get isCancelled => status == SaleStatus.cancelled;
  bool get hasRefund => refundedAmount > 0;
  bool get canRefund => !isCancelled && items.any((item) => item.refundableQty > 0);
  bool get canCancel => status == SaleStatus.completed && refundedAmount == 0;
  int get netTotal => isCancelled ? 0 : total - refundedAmount;

  factory Sale.fromMap(String id, Map<String, dynamic> map) {
    final paymentText = readString(map['paymentType'], 'cash');
    final statusText = readString(map['status'], 'completed');
    return Sale(
      id: id,
      receiptNo: readString(map['receiptNo']),
      dayKey: readString(map['dayKey']),
      cashierUid: readString(map['cashierUid']),
      cashierName: readString(map['cashierName']),
      items: readMapList(map['items']).map(SaleItem.fromMap).toList(),
      total: readInt(map['total']),
      amountPaid: readInt(map['amountPaid']),
      change: readInt(map['change']),
      paymentType: paymentText == 'utang' ? PaymentType.utang : PaymentType.cash,
      status: switch (statusText) {
        'cancelled' => SaleStatus.cancelled,
        'refunded' => SaleStatus.refunded,
        _ => SaleStatus.completed,
      },
      profit: readDouble(map['profit']),
      customerId: readStringOrNull(map['customerId']),
      customerName: readStringOrNull(map['customerName']),
      refundedAmount: readInt(map['refundedAmount']),
      refundedProfit: readDouble(map['refundedProfit']),
      cancelReason: readStringOrNull(map['cancelReason']),
      cancelledAt: readDate(map['cancelledAt']),
      createdAt: readDate(map['createdAt']),
    );
  }
}

class RefundItem {
  const RefundItem({
    required this.productId,
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.unitCost,
  });

  final String productId;
  final String name;
  final int qty;
  final int unitPrice;
  final double unitCost;

  int get amount => qty * unitPrice;

  factory RefundItem.fromMap(Map<String, dynamic> map) => RefundItem(
        productId: readString(map['productId']),
        name: readString(map['name']),
        qty: readInt(map['qty']),
        unitPrice: readInt(map['unitPrice']),
        unitCost: readDouble(map['unitCost']),
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'qty': qty,
        'unitPrice': unitPrice,
        'unitCost': unitCost,
      };
}

class Refund {
  const Refund({
    required this.id,
    required this.saleId,
    required this.receiptNo,
    required this.items,
    required this.amount,
    required this.profitReversal,
    required this.restocked,
    required this.reason,
    required this.byName,
    this.createdAt,
  });

  final String id;
  final String saleId;
  final String receiptNo;
  final List<RefundItem> items;
  final int amount;
  final double profitReversal;
  final bool restocked;
  final String reason;
  final String byName;
  final DateTime? createdAt;

  factory Refund.fromMap(String id, Map<String, dynamic> map) => Refund(
        id: id,
        saleId: readString(map['saleId']),
        receiptNo: readString(map['receiptNo']),
        items: readMapList(map['items']).map(RefundItem.fromMap).toList(),
        amount: readInt(map['amount']),
        profitReversal: readDouble(map['profitReversal']),
        restocked: readBool(map['restocked']),
        reason: readString(map['reason']),
        byName: readString(map['byName']),
        createdAt: readDate(map['createdAt']),
      );
}
