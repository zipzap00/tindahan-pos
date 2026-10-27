import '../firestore_read.dart';

/// A customer who can buy on credit (utang).
class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.balance,
    this.phone = '',
    this.note = '',
    this.archived = false,
    this.lastActivityAt,
  });

  final String id;
  final String name;
  final String phone;
  final String note;

  /// What the customer owes the store, in centavos. Negative means the store
  /// owes the customer (for example after a refund on a paid utang).
  final int balance;
  final bool archived;
  final DateTime? lastActivityAt;

  factory Customer.fromMap(String id, Map<String, dynamic> map) => Customer(
        id: id,
        name: readString(map['name']),
        phone: readString(map['phone']),
        note: readString(map['note']),
        balance: readInt(map['balance']),
        archived: readBool(map['archived']),
        lastActivityAt: readDate(map['lastActivityAt']),
      );
}

enum LedgerType { charge, payment, refund, cancel }

class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.byName,
    this.receiptNo = '',
    this.saleId = '',
    this.note = '',
    this.createdAt,
  });

  final String id;
  final LedgerType type;

  /// Always positive; [type] says whether it raised or lowered the balance.
  final int amount;
  final int balanceAfter;
  final String byName;
  final String receiptNo;
  final String saleId;
  final String note;
  final DateTime? createdAt;

  bool get raisesBalance => type == LedgerType.charge;

  factory LedgerEntry.fromMap(String id, Map<String, dynamic> map) => LedgerEntry(
        id: id,
        type: LedgerType.values.firstWhere(
          (value) => value.name == readString(map['type']),
          orElse: () => LedgerType.charge,
        ),
        amount: readInt(map['amount']),
        balanceAfter: readInt(map['balanceAfter']),
        byName: readString(map['byName']),
        receiptNo: readString(map['receiptNo']),
        saleId: readString(map['saleId']),
        note: readString(map['note']),
        createdAt: readDate(map['createdAt']),
      );
}
