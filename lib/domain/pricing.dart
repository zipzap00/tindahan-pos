// Capital and income maths. Pure functions, unit tested.
//
// Example from the owner: bought 10 pieces for ₱100 in total, sells each for
// ₱12. Unit cost ₱10, capital ₱100, sales if all are sold ₱120, income ₱20.

/// Cost per piece in centavos from a total purchase cost.
double unitCostFromTotal(int totalCostCents, int quantity) {
  if (quantity <= 0) return 0;
  return totalCostCents / quantity;
}

class ProfitPreview {
  const ProfitPreview({
    required this.quantity,
    required this.unitCost,
    required this.sellingPrice,
  });

  final int quantity;

  /// Centavos per piece (may be fractional).
  final double unitCost;

  /// Centavos per piece.
  final int sellingPrice;

  /// Puhunan: what the pieces cost.
  double get capital => unitCost * quantity;

  /// Benta: what the pieces bring in when all are sold.
  int get expectedSales => sellingPrice * quantity;

  /// Kita: sales minus capital.
  double get expectedIncome => expectedSales - capital;

  double get marginPerPiece => sellingPrice - unitCost;

  /// Patong (markup) as a percentage of cost; null when cost is zero.
  double? get markupPercent => unitCost <= 0 ? null : (sellingPrice - unitCost) / unitCost * 100;

  bool get sellsBelowCost => sellingPrice < unitCost;
}

/// New average cost per piece after receiving more stock at a new cost.
/// Old stock and new stock are blended by quantity (weighted average).
double weightedAverageCost({
  required int currentStock,
  required double currentUnitCost,
  required int addedQty,
  required double addedUnitCost,
}) {
  final existing = currentStock < 0 ? 0 : currentStock;
  final totalQty = existing + addedQty;
  if (totalQty <= 0) return addedUnitCost;
  return (existing * currentUnitCost + addedQty * addedUnitCost) / totalQty;
}

/// Totals for the whole inventory (non-archived products).
class InventoryValue {
  const InventoryValue({
    required this.capital,
    required this.retail,
    required this.inStockCount,
    required this.lowCount,
    required this.outCount,
    required this.totalUnits,
  });

  /// Stock on hand at cost (puhunan na nakatengga).
  final double capital;

  /// Stock on hand at selling price.
  final int retail;
  final int inStockCount;
  final int lowCount;
  final int outCount;
  final int totalUnits;

  double get potentialIncome => retail - capital;

  /// Products that can be sold right now (in stock or low, not out).
  int get sellableCount => inStockCount + lowCount;
}
