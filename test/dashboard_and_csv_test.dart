import 'package:flutter_test/flutter_test.dart';
import 'package:tindahan_pos/core/l10n/strings_en.dart';
import 'package:tindahan_pos/data/models/product.dart';
import 'package:tindahan_pos/data/models/records.dart';
import 'package:tindahan_pos/domain/csv_export.dart';
import 'package:tindahan_pos/domain/dashboard_summary.dart';

void main() {
  group('dashboard summary', () {
    // Tuesday 27 October 2026, Philippine time.
    final now = DateTime.utc(2026, 10, 27, 14);

    final days = [
      const DailyStats(
        dayKey: '2026-10-01',
        salesTotal: 10000,
        profit: 2000,
        txnCount: 4,
        items: {'kopiko': ItemStat(name: 'Kopiko', qty: 10, revenue: 10000)},
      ),
      const DailyStats(
        dayKey: '2026-10-26',
        salesTotal: 5000,
        profit: 1000,
        txnCount: 2,
        expenses: 300,
        items: {'coke': ItemStat(name: 'Coke', qty: 3, revenue: 5000)},
      ),
      const DailyStats(
        dayKey: '2026-10-27',
        salesTotal: 8000,
        profit: 1500,
        txnCount: 3,
        refundTotal: 1000,
        refundProfit: 200,
        expenses: 500,
        items: {'coke': ItemStat(name: 'Coke', qty: 5, revenue: 8000)},
      ),
    ];

    test('today, week and month totals', () {
      final summary = DashboardSummary.from(days, now);
      expect(summary.today.netSales, 7000);
      expect(summary.today.profit, 1300);
      expect(summary.today.transactions, 3);
      expect(summary.today.expenses, 500);
      expect(summary.today.profitAfterExpenses, 800);
      expect(summary.week.netSales, 12000); // Mon 26 + Tue 27
      expect(summary.month.netSales, 22000);
      expect(summary.month.transactions, 9);
    });

    test('best sellers are ranked by pieces for the month', () {
      final summary = DashboardSummary.from(days, now);
      expect(summary.bestSellers.map((b) => b.name), ['Kopiko', 'Coke']);
      expect(summary.bestSellers.last.qty, 8);
    });

    test('seven-day bars end today and fill missing days with zero', () {
      final summary = DashboardSummary.from(days, now);
      expect(summary.lastSevenDays, hasLength(7));
      expect(summary.lastSevenDays.last.dayKey, '2026-10-27');
      expect(summary.lastSevenDays.last.isToday, isTrue);
      expect(summary.lastSevenDays.first.netSales, 0);
    });

    test('earliest key covers the week, the month and the last seven days', () {
      expect(DashboardSummary.earliestKeyNeeded(now), '2026-10-01');
      // Early in a month, the last seven days reach into the previous month.
      expect(DashboardSummary.earliestKeyNeeded(DateTime.utc(2026, 11, 2, 9)), '2026-10-27');
    });
  });

  group('CSV export', () {
    test('escapes commas, quotes and new lines', () {
      expect(csvCell('plain'), 'plain');
      expect(csvCell('a,b'), '"a,b"');
      expect(csvCell('say "hi"'), '"say ""hi"""');
      expect(toCsv([
        ['a', 'b'],
        ['1', 'x,y'],
      ]), 'a,b\r\n1,"x,y"');
    });

    test('money is written as plain decimal pesos', () {
      expect(csvPesos(123456), '1234.56');
      expect(csvPesos(5), '0.05');
      expect(csvPesos(-1250), '-12.50');
      expect(csvPesos(833.33), '8.33');
    });

    test('inventory rows include header, stock values and status', () {
      const s = EnStrings();
      final rows = inventoryRows([
        const Product(id: '1', name: 'Kopiko, 3-in-1', unitCost: 1000, sellingPrice: 1200, stock: 10, minStock: 3),
      ], s);
      expect(rows, hasLength(2));
      expect(rows.first.first, 'Name');
      expect(rows[1][0], 'Kopiko, 3-in-1');
      expect(rows[1][5], '10.00');
      expect(rows[1][6], '12.00');
      expect(rows[1][9], 'In stock');
      expect(rows[1][10], '100.00');
      expect(rows[1][11], '120.00');
      expect(toCsv(rows).split('\r\n')[1].startsWith('"Kopiko, 3-in-1"'), isTrue);
    });
  });
}
