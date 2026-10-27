// POS cart. Lives for the whole signed-in session so switching tabs keeps the
// customer's items. Quantities can never exceed the stock the app knows about;
// Firestore security rules enforce the same limit on the server.

import 'package:flutter/foundation.dart';

import '../data/models/product.dart';

class CartLine {
  const CartLine({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.unitCost,
    required this.qty,
  });

  final String productId;
  final String name;

  /// Centavos.
  final int unitPrice;

  /// Centavos (may be fractional).
  final double unitCost;
  final int qty;

  int get lineTotal => unitPrice * qty;
  double get lineProfit => (unitPrice - unitCost) * qty;

  CartLine withQty(int value) => CartLine(
        productId: productId,
        name: name,
        unitPrice: unitPrice,
        unitCost: unitCost,
        qty: value,
      );
}

enum AddOutcome { added, atStockLimit, outOfStock, unavailable }

/// A line that can no longer be sold as requested because stock changed,
/// the product was archived, or its price changed.
class CartProblem {
  const CartProblem({
    required this.productId,
    required this.name,
    required this.requested,
    required this.available,
  });

  final String productId;
  final String name;
  final int requested;

  /// 0 when the product was archived or deleted.
  final int available;
}

class CartController extends ChangeNotifier {
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);
  bool get isEmpty => _lines.isEmpty;
  int get itemCount => _lines.fold(0, (sum, line) => sum + line.qty);
  int get total => _lines.fold(0, (sum, line) => sum + line.lineTotal);
  double get estimatedProfit => _lines.fold(0.0, (sum, line) => sum + line.lineProfit);

  int qtyOf(String productId) {
    for (final line in _lines) {
      if (line.productId == productId) return line.qty;
    }
    return 0;
  }

  /// Adds one piece of [product], using its current price and cost.
  AddOutcome add(Product product) {
    if (product.archived) return AddOutcome.unavailable;
    if (product.stock <= 0) return AddOutcome.outOfStock;
    final index = _lines.indexWhere((line) => line.productId == product.id);
    if (index == -1) {
      _lines.add(CartLine(
        productId: product.id,
        name: product.name,
        unitPrice: product.sellingPrice,
        unitCost: product.unitCost,
        qty: 1,
      ));
      notifyListeners();
      return AddOutcome.added;
    }
    final current = _lines[index];
    if (current.qty >= product.stock) return AddOutcome.atStockLimit;
    _lines[index] = current.withQty(current.qty + 1);
    notifyListeners();
    return AddOutcome.added;
  }

  void decrement(String productId) {
    final index = _lines.indexWhere((line) => line.productId == productId);
    if (index == -1) return;
    final current = _lines[index];
    if (current.qty <= 1) {
      _lines.removeAt(index);
    } else {
      _lines[index] = current.withQty(current.qty - 1);
    }
    notifyListeners();
  }

  /// Sets an exact quantity, capped at [maxStock]. Zero removes the line.
  void setQty(String productId, int qty, {required int maxStock}) {
    final index = _lines.indexWhere((line) => line.productId == productId);
    if (index == -1) return;
    final capped = qty > maxStock ? maxStock : qty;
    if (capped <= 0) {
      _lines.removeAt(index);
    } else {
      _lines[index] = _lines[index].withQty(capped);
    }
    notifyListeners();
  }

  void remove(String productId) {
    _lines.removeWhere((line) => line.productId == productId);
    notifyListeners();
  }

  void clear() {
    if (_lines.isEmpty) return;
    _lines.clear();
    notifyListeners();
  }

  /// Refreshes names, prices and costs from the latest product data so the
  /// sale always uses current values.
  void syncWith(Map<String, Product> latest) {
    var changed = false;
    for (var i = 0; i < _lines.length; i++) {
      final line = _lines[i];
      final product = latest[line.productId];
      if (product == null) continue;
      if (product.sellingPrice != line.unitPrice ||
          product.unitCost != line.unitCost ||
          product.name != line.name) {
        _lines[i] = CartLine(
          productId: line.productId,
          name: product.name,
          unitPrice: product.sellingPrice,
          unitCost: product.unitCost,
          qty: line.qty,
        );
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Lines that cannot be checked out as they are.
  List<CartProblem> problems(Map<String, Product> latest) {
    return findCartProblems(_lines, latest);
  }
}

List<CartProblem> findCartProblems(List<CartLine> lines, Map<String, Product> latest) {
  final problems = <CartProblem>[];
  for (final line in lines) {
    final product = latest[line.productId];
    final available = (product == null || product.archived) ? 0 : product.stock;
    if (line.qty > available) {
      problems.add(CartProblem(
        productId: line.productId,
        name: line.name,
        requested: line.qty,
        available: available < 0 ? 0 : available,
      ));
    }
  }
  return problems;
}

/// Change to hand back. Negative means the payment is short.
int changeDue({required int total, required int paid}) => paid - total;

/// Quick-cash buttons: the exact amount, then common bills that cover it.
List<int> quickCashOptions(int total) {
  const bills = [2000, 5000, 10000, 20000, 50000, 100000];
  final options = <int>[total];
  for (final bill in bills) {
    if (bill > total && !options.contains(bill)) options.add(bill);
    if (options.length >= 5) break;
  }
  if (options.length < 5 && total > 100000) {
    // Round up to the next ₱500 and ₱1,000 for larger totals.
    final next500 = ((total + 49999) ~/ 50000) * 50000;
    final next1000 = ((total + 99999) ~/ 100000) * 100000;
    for (final value in [next500, next1000]) {
      if (value > total && !options.contains(value)) options.add(value);
    }
  }
  return options;
}
