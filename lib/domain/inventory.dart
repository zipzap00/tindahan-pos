// Inventory search, filters, sorting and totals. Pure, unit tested.

import '../data/models/product.dart';
import 'pricing.dart';

enum InventoryFilter { all, inStock, low, out, archived }

enum InventorySort { name, stockLowFirst, priceHighFirst, bestSelling, newest }

bool _matchesText(Product product, String query) {
  if (query.isEmpty) return true;
  final q = query.toLowerCase();
  return product.name.toLowerCase().contains(q) ||
      product.barcode.toLowerCase() == q ||
      product.barcode.toLowerCase().contains(q) ||
      product.sku.toLowerCase().contains(q) ||
      product.category.toLowerCase().contains(q);
}

List<Product> applyInventoryQuery(
  List<Product> products, {
  String text = '',
  InventoryFilter filter = InventoryFilter.all,
  String? category,
  InventorySort sort = InventorySort.name,
}) {
  final query = text.trim();
  final result = products.where((product) {
    final archivedOk = filter == InventoryFilter.archived ? product.archived : !product.archived;
    if (!archivedOk) return false;
    final statusOk = switch (filter) {
      InventoryFilter.all || InventoryFilter.archived => true,
      InventoryFilter.inStock => product.stock > 0,
      InventoryFilter.low => product.status == StockStatus.low,
      InventoryFilter.out => product.status == StockStatus.out,
    };
    if (!statusOk) return false;
    if (category != null && category.isNotEmpty && product.category != category) return false;
    return _matchesText(product, query);
  }).toList();

  int byName(Product a, Product b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());

  final int Function(Product, Product) comparator = switch (sort) {
    InventorySort.name => byName,
    InventorySort.stockLowFirst => (Product a, Product b) {
        final c = a.stock.compareTo(b.stock);
        return c != 0 ? c : byName(a, b);
      },
    InventorySort.priceHighFirst => (Product a, Product b) {
        final c = b.sellingPrice.compareTo(a.sellingPrice);
        return c != 0 ? c : byName(a, b);
      },
    InventorySort.bestSelling => (Product a, Product b) {
        final c = b.soldQty.compareTo(a.soldQty);
        return c != 0 ? c : byName(a, b);
      },
    InventorySort.newest => (Product a, Product b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return byName(a, b);
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      },
  };
  result.sort(comparator);
  return result;
}

/// Products the POS can show: not archived, matching name, barcode or SKU.
List<Product> searchSellable(List<Product> products, String text, {String? category}) {
  return applyInventoryQuery(products, text: text, category: category)
    ..sort((a, b) {
      // Items that can be sold first, then out-of-stock items.
      final aOut = a.stock <= 0 ? 1 : 0;
      final bOut = b.stock <= 0 ? 1 : 0;
      if (aOut != bOut) return aOut - bOut;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
}

/// A barcode or SKU typed or scanned exactly; used to add to cart directly.
Product? exactCodeMatch(List<Product> products, String text) {
  final code = text.trim().toLowerCase();
  if (code.isEmpty) return null;
  for (final product in products) {
    if (product.archived) continue;
    if (product.barcode.isNotEmpty && product.barcode.toLowerCase() == code) return product;
    if (product.sku.isNotEmpty && product.sku.toLowerCase() == code) return product;
  }
  return null;
}

/// Sorted list of categories in use (for filter chips and form suggestions).
List<String> categoriesOf(List<Product> products) {
  final set = <String>{};
  for (final product in products) {
    if (!product.archived && product.category.trim().isNotEmpty) set.add(product.category.trim());
  }
  return set.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

InventoryValue inventoryValueOf(List<Product> products) {
  var capital = 0.0;
  var retail = 0;
  var inStock = 0;
  var low = 0;
  var out = 0;
  var units = 0;
  for (final product in products) {
    if (product.archived) continue;
    final onHand = product.stock < 0 ? 0 : product.stock;
    capital += onHand * product.unitCost;
    retail += onHand * product.sellingPrice;
    units += onHand;
    switch (product.status) {
      case StockStatus.inStock:
        inStock++;
      case StockStatus.low:
        low++;
      case StockStatus.out:
        out++;
    }
  }
  return InventoryValue(
    capital: capital,
    retail: retail,
    inStockCount: inStock,
    lowCount: low,
    outCount: out,
    totalUnits: units,
  );
}

/// Another active product already uses this barcode or SKU.
String? duplicateCodeOwner(
  List<Product> products, {
  required String code,
  required String? exceptId,
  required bool isBarcode,
}) {
  final value = code.trim().toLowerCase();
  if (value.isEmpty) return null;
  for (final product in products) {
    if (product.archived || product.id == exceptId) continue;
    final other = (isBarcode ? product.barcode : product.sku).trim().toLowerCase();
    if (other == value) return product.name;
  }
  return null;
}
