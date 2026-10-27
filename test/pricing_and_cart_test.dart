import 'package:flutter_test/flutter_test.dart';
import 'package:tindahan_pos/data/models/product.dart';
import 'package:tindahan_pos/domain/cart.dart';
import 'package:tindahan_pos/domain/inventory.dart';
import 'package:tindahan_pos/domain/pricing.dart';

Product product({
  String id = 'p1',
  String name = 'Kopiko',
  double unitCost = 1000,
  int price = 1200,
  int stock = 10,
  int minStock = 3,
  bool archived = false,
  String barcode = '',
  String sku = '',
  String category = '',
}) {
  return Product(
    id: id,
    name: name,
    unitCost: unitCost,
    sellingPrice: price,
    stock: stock,
    minStock: minStock,
    archived: archived,
    barcode: barcode,
    sku: sku,
    category: category,
  );
}

void main() {
  group('capital and income', () {
    test("owner's example: 10 pieces for ₱100, sold at ₱12 each", () {
      final unitCost = unitCostFromTotal(10000, 10);
      final preview = ProfitPreview(quantity: 10, unitCost: unitCost, sellingPrice: 1200);
      expect(unitCost, 1000);
      expect(preview.capital, 10000);
      expect(preview.expectedSales, 12000);
      expect(preview.expectedIncome, 2000);
      expect(preview.marginPerPiece, 200);
      expect(preview.markupPercent, closeTo(20, 0.001));
      expect(preview.sellsBelowCost, isFalse);
    });

    test('keeps fractional cost so capital stays exact', () {
      final unitCost = unitCostFromTotal(10000, 12); // ₱100 for 12 pieces
      final preview = ProfitPreview(quantity: 12, unitCost: unitCost, sellingPrice: 1000);
      expect(preview.capital, closeTo(10000, 0.0001));
      expect(preview.expectedIncome, closeTo(2000, 0.0001));
    });

    test('zero quantity and zero cost are safe', () {
      expect(unitCostFromTotal(5000, 0), 0);
      const preview = ProfitPreview(quantity: 5, unitCost: 0, sellingPrice: 1000);
      expect(preview.markupPercent, isNull);
    });

    test('flags selling below cost', () {
      const preview = ProfitPreview(quantity: 1, unitCost: 1500, sellingPrice: 1200);
      expect(preview.sellsBelowCost, isTrue);
      expect(preview.expectedIncome, -300);
    });

    test('weighted average cost after restock', () {
      // 10 pieces at ₱10, then 10 more at ₱12 → ₱11 average.
      expect(
        weightedAverageCost(currentStock: 10, currentUnitCost: 1000, addedQty: 10, addedUnitCost: 1200),
        1100,
      );
      // Empty shelf: the new cost wins.
      expect(
        weightedAverageCost(currentStock: 0, currentUnitCost: 900, addedQty: 5, addedUnitCost: 1200),
        1200,
      );
    });
  });

  group('cart', () {
    test('adds, increments and totals', () {
      final cart = CartController();
      final kopiko = product();
      expect(cart.add(kopiko), AddOutcome.added);
      expect(cart.add(kopiko), AddOutcome.added);
      expect(cart.itemCount, 2);
      expect(cart.total, 2400);
      expect(cart.estimatedProfit, 400);
    });

    test('never goes past the stock on hand', () {
      final cart = CartController();
      final last = product(stock: 2);
      cart.add(last);
      cart.add(last);
      expect(cart.add(last), AddOutcome.atStockLimit);
      expect(cart.qtyOf('p1'), 2);
    });

    test('refuses out-of-stock and archived products', () {
      final cart = CartController();
      expect(cart.add(product(stock: 0)), AddOutcome.outOfStock);
      expect(cart.add(product(archived: true)), AddOutcome.unavailable);
      expect(cart.isEmpty, isTrue);
    });

    test('decrement removes the line at zero', () {
      final cart = CartController();
      cart.add(product());
      cart.decrement('p1');
      expect(cart.isEmpty, isTrue);
    });

    test('reports lines that no longer have enough stock', () {
      final cart = CartController();
      final p = product(stock: 5);
      for (var i = 0; i < 4; i++) {
        cart.add(p);
      }
      final problems = cart.problems({'p1': product(stock: 2)});
      expect(problems, hasLength(1));
      expect(problems.first.available, 2);
      expect(cart.problems({}), hasLength(1));
      expect(cart.problems({'p1': product(stock: 9)}), isEmpty);
    });

    test('picks up price changes before checkout', () {
      final cart = CartController();
      cart.add(product());
      cart.syncWith({'p1': product(price: 1500)});
      expect(cart.total, 1500);
    });

    test('change and quick cash', () {
      expect(changeDue(total: 4750, paid: 5000), 250);
      expect(changeDue(total: 4750, paid: 4000), -750);
      final options = quickCashOptions(4750);
      expect(options.first, 4750);
      expect(options, containsAllInOrder([5000, 10000]));
      expect(options.every((value) => value >= 4750), isTrue);
    });
  });

  group('inventory', () {
    final products = [
      product(id: 'a', name: 'Bear Brand', stock: 0, minStock: 2, barcode: '4800361', category: 'Gatas'),
      product(id: 'b', name: 'Coke Mismo', stock: 2, minStock: 5, sku: 'COKE-M', category: 'Inumin'),
      product(id: 'c', name: 'Asin', stock: 40, minStock: 5, category: 'Rekado'),
      product(id: 'd', name: 'Lumang sabon', stock: 3, archived: true),
    ];

    test('stock status', () {
      expect(stockStatusOf(0, 5), StockStatus.out);
      expect(stockStatusOf(5, 5), StockStatus.low);
      expect(stockStatusOf(6, 5), StockStatus.inStock);
    });

    test('filters and search', () {
      expect(applyInventoryQuery(products).map((p) => p.id), ['c', 'a', 'b']);
      expect(applyInventoryQuery(products, filter: InventoryFilter.low).map((p) => p.id), ['b']);
      expect(applyInventoryQuery(products, filter: InventoryFilter.out).map((p) => p.id), ['a']);
      expect(applyInventoryQuery(products, filter: InventoryFilter.archived).map((p) => p.id), ['d']);
      expect(applyInventoryQuery(products, text: 'coke').map((p) => p.id), ['b']);
      expect(applyInventoryQuery(products, category: 'Rekado').map((p) => p.id), ['c']);
    });

    test('exact barcode or SKU match for the POS', () {
      expect(exactCodeMatch(products, '4800361')?.id, 'a');
      expect(exactCodeMatch(products, 'coke-m')?.id, 'b');
      expect(exactCodeMatch(products, 'nothing'), isNull);
    });

    test('POS lists sellable items before out-of-stock ones', () {
      expect(searchSellable(products, '').map((p) => p.id), ['c', 'b', 'a']);
    });

    test('inventory value ignores archived products', () {
      final value = inventoryValueOf(products);
      expect(value.totalUnits, 42);
      expect(value.capital, 42 * 1000);
      expect(value.retail, 42 * 1200);
      expect(value.outCount, 1);
      expect(value.lowCount, 1);
      expect(value.sellableCount, 2);
    });

    test('duplicate codes are detected', () {
      expect(duplicateCodeOwner(products, code: '4800361', exceptId: null, isBarcode: true), 'Bear Brand');
      expect(duplicateCodeOwner(products, code: '4800361', exceptId: 'a', isBarcode: true), isNull);
    });
  });
}
