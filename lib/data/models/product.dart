import '../firestore_read.dart';

enum StockStatus { inStock, low, out }

/// Out of stock at zero; low when at or below the owner's minimum level.
StockStatus stockStatusOf(int stock, int minStock) {
  if (stock <= 0) return StockStatus.out;
  if (stock <= minStock) return StockStatus.low;
  return StockStatus.inStock;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.unitCost,
    required this.sellingPrice,
    required this.stock,
    this.category = '',
    this.barcode = '',
    this.sku = '',
    this.supplier = '',
    this.minStock = 0,
    this.archived = false,
    this.soldQty = 0,
    this.revenue = 0,
    this.cogs = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String category;
  final String barcode;
  final String sku;
  final String supplier;

  /// Average cost per piece in centavos (may be fractional).
  final double unitCost;

  /// Selling price per piece in centavos.
  final int sellingPrice;
  final int stock;
  final int minStock;
  final bool archived;

  /// Lifetime pieces sold (net of refunds and cancellations).
  final int soldQty;

  /// Lifetime sales revenue in centavos (net of refunds).
  final int revenue;

  /// Lifetime cost of goods sold in centavos.
  final double cogs;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  StockStatus get status => stockStatusOf(stock, minStock);

  double get realizedProfit => revenue - cogs;

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: readString(map['name']),
      category: readString(map['category']),
      barcode: readString(map['barcode']),
      sku: readString(map['sku']),
      supplier: readString(map['supplier']),
      unitCost: readDouble(map['unitCost']),
      sellingPrice: readInt(map['sellingPrice']),
      stock: readInt(map['stock']),
      minStock: readInt(map['minStock']),
      archived: readBool(map['archived']),
      soldQty: readInt(map['soldQty']),
      revenue: readInt(map['revenue']),
      cogs: readDouble(map['cogs']),
      createdAt: readDate(map['createdAt']),
      updatedAt: readDate(map['updatedAt']),
    );
  }

  /// Fields the owner edits in the product form. Stock is never edited here;
  /// it only changes through sales, restocks, refunds and adjustments.
  Map<String, dynamic> toDetailsMap() {
    return {
      'name': name.trim(),
      'nameLower': name.trim().toLowerCase(),
      'category': category.trim(),
      'barcode': barcode.trim(),
      'sku': sku.trim(),
      'supplier': supplier.trim(),
      'unitCost': unitCost,
      'sellingPrice': sellingPrice,
      'minStock': minStock,
    };
  }
}
