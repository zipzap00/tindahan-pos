// CSV export. Files start with a UTF-8 byte order mark so Excel shows the ₱
// sign and Filipino characters correctly; money is written as plain decimal
// pesos so Excel treats the columns as numbers.

import '../core/manila_time.dart';
import '../core/l10n/strings.dart';
import '../data/models/product.dart';
import '../data/models/records.dart';

const String utf8Bom = '﻿';

String csvCell(String value) {
  final needsQuotes =
      value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r');
  final escaped = value.replaceAll('"', '""');
  return needsQuotes ? '"$escaped"' : escaped;
}

String toCsv(List<List<String>> rows) {
  return rows.map((row) => row.map(csvCell).join(',')).join('\r\n');
}

/// Centavos as a plain decimal peso amount: 123456 -> "1234.56".
String csvPesos(num centavos) {
  final rounded = centavos.round();
  final negative = rounded < 0;
  final abs = rounded.abs();
  final text = '${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
  return negative ? '-$text' : text;
}

String _status(Product product, Strings s) {
  if (product.archived) return s.archivedLabel;
  return s.stockStatusLabel(product.status);
}

List<List<String>> inventoryRows(List<Product> products, Strings s) {
  final sorted = [...products]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return [
    [
      s.csvName,
      s.csvCategory,
      s.csvBarcode,
      s.csvSku,
      s.csvSupplier,
      s.csvUnitCost,
      s.csvSellingPrice,
      s.csvStock,
      s.csvMinStock,
      s.csvStatus,
      s.csvStockValueCost,
      s.csvStockValueRetail,
      s.csvSoldQty,
      s.csvRevenue,
      s.csvProfit,
    ],
    for (final product in sorted)
      [
        product.name,
        product.category,
        product.barcode,
        product.sku,
        product.supplier,
        csvPesos(product.unitCost),
        csvPesos(product.sellingPrice),
        product.stock.toString(),
        product.minStock.toString(),
        _status(product, s),
        csvPesos(product.stock * product.unitCost),
        csvPesos(product.stock * product.sellingPrice),
        product.soldQty.toString(),
        csvPesos(product.revenue),
        csvPesos(product.realizedProfit),
      ],
  ];
}

List<List<String>> movementRows(List<StockMovement> movements, Strings s) {
  return [
    [
      s.csvDate,
      s.csvName,
      s.csvMovementType,
      s.csvQtyChange,
      s.csvStockBefore,
      s.csvStockAfter,
      s.csvUnitCost,
      s.csvReason,
      s.csvReference,
      s.csvBy,
    ],
    for (final movement in movements)
      [
        movement.createdAt == null
            ? ''
            : ManilaTime.formatDateTime(ManilaTime.toManila(movement.createdAt!), s),
        movement.productName,
        s.movementTypeLabel(movement.type),
        movement.qtyChange.toString(),
        movement.stockBefore.toString(),
        movement.stockAfter.toString(),
        movement.unitCost == null ? '' : csvPesos(movement.unitCost!),
        [
          if (movement.reason != null) s.adjustReasonLabel(movement.reason!),
          if (movement.note.isNotEmpty) movement.note,
        ].join(' – '),
        movement.refLabel,
        movement.byName,
      ],
  ];
}
