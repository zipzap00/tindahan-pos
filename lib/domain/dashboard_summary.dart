// Turns daily stats documents into the numbers the dashboard shows.
// Pure and unit tested; all day boundaries are in Philippine time.

import '../core/manila_time.dart';
import '../data/models/records.dart';

class PeriodTotals {
  const PeriodTotals({
    this.sales = 0,
    this.refunds = 0,
    this.profit = 0,
    this.transactions = 0,
    this.expenses = 0,
    this.restockCost = 0,
    this.utangCharged = 0,
    this.utangCollected = 0,
  });

  final int sales;
  final int refunds;

  /// Gross profit after refunds (selling price minus cost of goods).
  final double profit;
  final int transactions;
  final int expenses;
  final double restockCost;
  final int utangCharged;
  final int utangCollected;

  int get netSales => sales - refunds;

  /// Profit after day-to-day expenses (stock purchases are capital, not expense).
  double get profitAfterExpenses => profit - expenses;

  PeriodTotals operator +(DailyStats day) => PeriodTotals(
        sales: sales + day.salesTotal,
        refunds: refunds + day.refundTotal,
        profit: profit + day.netProfit,
        transactions: transactions + day.txnCount,
        expenses: expenses + day.expenses,
        restockCost: restockCost + day.restockCost,
        utangCharged: utangCharged + day.utangCharged,
        utangCollected: utangCollected + day.utangCollected,
      );
}

class BestSeller {
  const BestSeller({required this.productId, required this.name, required this.qty, required this.revenue});

  final String productId;
  final String name;
  final int qty;
  final int revenue;
}

class DayBar {
  const DayBar({required this.dayKey, required this.netSales, required this.isToday});

  final String dayKey;
  final int netSales;
  final bool isToday;
}

class DashboardSummary {
  const DashboardSummary({
    required this.today,
    required this.week,
    required this.month,
    required this.lastSevenDays,
    required this.bestSellers,
  });

  final PeriodTotals today;
  final PeriodTotals week;
  final PeriodTotals month;
  final List<DayBar> lastSevenDays;

  /// This month, by pieces sold.
  final List<BestSeller> bestSellers;

  /// The earliest day key the dashboard needs: the start of this week or of
  /// this month, whichever is earlier, and never later than six days ago.
  static String earliestKeyNeeded(DateTime manilaNow) {
    final weekStart = ManilaTime.startOfWeek(manilaNow);
    final monthStart = ManilaTime.startOfMonth(manilaNow);
    final sixDaysAgo = ManilaTime.startOfDay(manilaNow).subtract(const Duration(days: 6));
    var earliest = weekStart.isBefore(monthStart) ? weekStart : monthStart;
    if (sixDaysAgo.isBefore(earliest)) earliest = sixDaysAgo;
    return ManilaTime.dayKey(earliest);
  }

  factory DashboardSummary.from(List<DailyStats> days, DateTime manilaNow, {int topN = 5}) {
    final todayKey = ManilaTime.dayKey(manilaNow);
    final weekKey = ManilaTime.dayKey(ManilaTime.startOfWeek(manilaNow));
    final monthKey = ManilaTime.dayKey(ManilaTime.startOfMonth(manilaNow));
    final byKey = {for (final day in days) day.dayKey: day};

    var today = const PeriodTotals();
    var week = const PeriodTotals();
    var month = const PeriodTotals();
    final itemTotals = <String, BestSeller>{};

    for (final day in days) {
      final key = day.dayKey;
      if (key.compareTo(todayKey) > 0) continue;
      if (key == todayKey) today = today + day;
      if (key.compareTo(weekKey) >= 0) week = week + day;
      if (key.compareTo(monthKey) >= 0) {
        month = month + day;
        day.items.forEach((productId, stat) {
          final previous = itemTotals[productId];
          itemTotals[productId] = BestSeller(
            productId: productId,
            name: stat.name.isNotEmpty ? stat.name : (previous?.name ?? ''),
            qty: (previous?.qty ?? 0) + stat.qty,
            revenue: (previous?.revenue ?? 0) + stat.revenue,
          );
        });
      }
    }

    final bars = <DayBar>[];
    final startOfToday = ManilaTime.startOfDay(manilaNow);
    for (var offset = 6; offset >= 0; offset--) {
      final key = ManilaTime.dayKey(startOfToday.subtract(Duration(days: offset)));
      bars.add(DayBar(dayKey: key, netSales: byKey[key]?.netSales ?? 0, isToday: offset == 0));
    }

    final sellers = itemTotals.values.where((item) => item.qty > 0).toList()
      ..sort((a, b) {
        final byQty = b.qty.compareTo(a.qty);
        return byQty != 0 ? byQty : b.revenue.compareTo(a.revenue);
      });

    return DashboardSummary(
      today: today,
      week: week,
      month: month,
      lastSevenDays: bars,
      bestSellers: sellers.take(topN).toList(),
    );
  }
}
