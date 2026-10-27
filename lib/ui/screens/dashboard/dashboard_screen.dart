import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/manila_time.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/live_query.dart';
import '../../../data/models/product.dart';
import '../../../data/models/records.dart';
import '../../../data/models/sale.dart';
import '../../../data/store_session.dart';
import '../../../domain/dashboard_summary.dart';
import '../../../domain/inventory.dart';
import '../../scopes.dart';
import '../../shell/home_shell.dart';
import '../../widgets/cards.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';
import '../../widgets/tags.dart';
import '../inventory/product_detail_screen.dart';
import '../sales/sale_detail_screen.dart';
import '../sales/sales_history_screen.dart';

/// Owner dashboard: today's sales, profit, expenses and transactions; stock
/// alerts; best sellers; recent transactions; today / week / month summary.
/// Every date boundary is Philippine time.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StoreSession? _session;
  LiveQuery<List<DailyStats>>? _stats;
  LiveQuery<List<Sale>>? _recent;
  String? _fromKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = StoreScope.of(context);
    if (!identical(session, _session)) {
      _session = session;
      _disposeQueries();
      _recent = LiveQuery<List<Sale>>(() => session.sales.watchRecent(limit: 8), context: '[dashboard/recent]');
      _openStats(session);
    }
  }

  void _openStats(StoreSession session) {
    final fromKey = DashboardSummary.earliestKeyNeeded(ManilaTime.now());
    _fromKey = fromKey;
    final old = _stats;
    _stats = LiveQuery<List<DailyStats>>(
      () => session.insights.watchDailyStatsSince(fromKey),
      context: '[dashboard/stats]',
    );
    if (old != null) WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  void _disposeQueries() {
    _stats?.dispose();
    _recent?.dispose();
    _stats = null;
    _recent = null;
  }

  @override
  void dispose() {
    _disposeQueries();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = StoreScope.of(context);
    // The app may stay open past midnight; move the window to the new day.
    final neededKey = DashboardSummary.earliestKeyNeeded(ManilaTime.now());
    if (neededKey != _fromKey) _openStats(session);
    final stats = _stats;
    final recent = _recent;
    if (stats == null || recent == null) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: Listenable.merge([stats, recent, session.products, session.customers, session.storeName]),
      builder: (context, _) => _DashboardBody(session: session, stats: stats, recent: recent),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.session, required this.stats, required this.recent});

  final StoreSession session;
  final LiveQuery<List<DailyStats>> stats;
  final LiveQuery<List<Sale>> recent;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final now = ManilaTime.now();
    final shell = ShellScope.maybeOf(context);
    final summary = DashboardSummary.from(stats.value ?? const [], now);
    final products = session.products.value ?? const <Product>[];
    final inventory = inventoryValueOf(products);
    final alerts = products.where((p) => !p.archived && p.status != StockStatus.inStock).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));
    final customers = session.customers.value ?? const [];
    final receivable = customers.fold<int>(0, (sum, c) => sum + (c.balance > 0 ? c.balance : 0));
    final debtors = customers.where((c) => c.balance > 0).length;
    final statsError = stats.error;
    final today = summary.today;

    void openInventory(InventoryFilter filter) {
      shell?.inventoryFilterRequest.value = filter;
      shell?.goTo(ShellTab.inventory);
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpace.xxl),
        children: [
          PageHeader(
            eyebrow: ManilaTime.formatLongDate(now, s),
            title: s.dashboardTitle,
            caption: session.storeName.value,
          ),
          PagePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (statsError != null) ...[
                  ErrorCard(error: statsError, onRetry: stats.retry),
                  const SizedBox(height: AppSpace.md),
                ],
                if (stats.isLoading)
                  const LoadingBlocks(count: 2, height: 140)
                else ...[
                  _TodayHero(
                    netSales: today.netSales,
                    profit: today.profit,
                    transactions: today.transactions,
                    onSell: () => shell?.goTo(ShellTab.pos),
                  ),
                  const SizedBox(height: AppSpace.md),
                  _TwoUp(
                    left: StatTile(
                      icon: Icons.trending_up_rounded,
                      label: s.todayProfit,
                      value: formatPeso(today.profit),
                      caption: s.afterExpenses(formatPeso(today.profitAfterExpenses)),
                    ),
                    right: StatTile(
                      icon: Icons.receipt_long_outlined,
                      label: s.todayExpenses,
                      value: formatPeso(today.expenses),
                      caption: today.restockCost > 0 ? s.restockSpend(formatPeso(today.restockCost)) : null,
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                  _TwoUp(
                    left: StatTile(
                      icon: Icons.shopping_bag_outlined,
                      label: s.todayTransactions,
                      value: '${today.transactions}',
                      caption: today.refunds > 0 ? s.refundsToday(formatPeso(today.refunds)) : null,
                    ),
                    right: StatTile(
                      icon: Icons.inventory_2_outlined,
                      label: s.productsInStock,
                      value: '${inventory.sellableCount}',
                      caption: s.unitsOnHand(inventory.totalUnits),
                      onTap: () => openInventory(InventoryFilter.inStock),
                    ),
                  ),
                  SectionHeader(title: s.salesSummary),
                  _PeriodTable(summary: summary),
                  const SizedBox(height: AppSpace.md),
                  _SevenDayBars(bars: summary.lastSevenDays),
                ],
                SectionHeader(
                  title: s.stockAlerts,
                  actionLabel: alerts.isEmpty ? null : s.seeAll,
                  onAction: () => openInventory(InventoryFilter.low),
                ),
                _TwoUp(
                  left: StatTile(
                    icon: Icons.trending_down_rounded,
                    label: s.lowStock,
                    value: '${inventory.lowCount}',
                    onTap: () => openInventory(InventoryFilter.low),
                  ),
                  right: StatTile(
                    icon: Icons.block_rounded,
                    label: s.outOfStock,
                    value: '${inventory.outCount}',
                    onTap: () => openInventory(InventoryFilter.out),
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                if (session.products.isLoading)
                  const LoadingBlocks(count: 2)
                else if (alerts.isEmpty)
                  EmptyState(icon: Icons.check_circle_outline_rounded, message: s.noStockAlerts)
                else
                  ListCard(
                    children: [
                      for (final product in alerts.take(5))
                        ListRow(
                          title: product.name,
                          subtitle: s.stockLeftOfMin(product.stock, product.minStock),
                          trailing: StockBadge(status: product.status),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => ProductDetailScreen(productId: product.id)),
                          ),
                        ),
                    ],
                  ),
                SectionHeader(title: s.bestSellersThisMonth),
                if (stats.isLoading)
                  const LoadingBlocks(count: 3)
                else if (summary.bestSellers.isEmpty)
                  EmptyState(icon: Icons.emoji_events_outlined, message: s.noSalesThisMonth)
                else
                  ListCard(
                    children: [
                      for (var i = 0; i < summary.bestSellers.length; i++)
                        ListRow(
                          leading: _Rank(rank: i + 1),
                          title: summary.bestSellers[i].name,
                          subtitle: s.piecesSold(summary.bestSellers[i].qty),
                          trailing: Text(
                            formatPeso(summary.bestSellers[i].revenue),
                            style: AppType.tabular(AppType.bodyStrong),
                          ),
                        ),
                    ],
                  ),
                SectionHeader(
                  title: s.recentTransactions,
                  actionLabel: s.seeAll,
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const SalesHistoryScreen()),
                  ),
                ),
                _RecentSales(recent: recent),
                SectionHeader(title: s.utangSummary),
                AppCard(
                  onTap: () => shell?.goTo(ShellTab.utang),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.totalReceivable, style: AppType.caption),
                            const SizedBox(height: AppSpace.xs),
                            Text(formatPeso(receivable), style: AppType.tabular(AppType.headingLg)),
                            const SizedBox(height: AppSpace.xs),
                            Text(s.customersWithBalance(debtors), style: AppType.micro),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayHero extends StatelessWidget {
  const _TodayHero({
    required this.netSales,
    required this.profit,
    required this.transactions,
    required this.onSell,
  });

  final int netSales;
  final double profit;
  final int transactions;
  final VoidCallback onSell;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AppCard(
      tone: CardTone.featured,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.todaySales.toUpperCase(), style: AppType.eyebrowCap),
          const SizedBox(height: AppSpace.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(formatPeso(netSales), style: AppType.tabular(AppType.displayMd)),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            '${s.estimatedProfitShort(formatPeso(profit))}  ·  ${s.transactionCount(transactions)}',
            style: AppType.bodyMd,
          ),
          const SizedBox(height: AppSpace.xl),
          PillButton(label: s.startSelling, icon: Icons.point_of_sale_rounded, onPressed: onSell),
        ],
      ),
    );
  }
}

class _TwoUp extends StatelessWidget {
  const _TwoUp({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: AppSpace.md),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _PeriodTable extends StatelessWidget {
  const _PeriodTable({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final header = AppType.eyebrowCap.copyWith(color: AppColors.textSmall);
    final value = AppType.tabular(AppType.bodyStrong);

    TableRow row(String label, PeriodTotals totals) => TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
              child: Text(label, style: AppType.bodyMd),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
              child: Text(formatPesoCompact(totals.netSales), style: value, textAlign: TextAlign.end),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
              child: Text(formatPesoCompact(totals.profit.round()), style: value, textAlign: TextAlign.end),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
              child: Text('${totals.transactions}', style: value, textAlign: TextAlign.end),
            ),
          ],
        );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.xs),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.1),
          1: FlexColumnWidth(1.3),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(0.6),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: const TableBorder(horizontalInside: BorderSide(color: AppColors.hairlineLight)),
        children: [
          TableRow(
            children: [
              Text('', style: header),
              Text(s.columnSales.toUpperCase(), style: header, textAlign: TextAlign.end),
              Text(s.columnProfit.toUpperCase(), style: header, textAlign: TextAlign.end),
              Text(s.columnCount.toUpperCase(), style: header, textAlign: TextAlign.end),
            ],
          ),
          row(s.periodToday, summary.today),
          row(s.periodWeek, summary.week),
          row(s.periodMonth, summary.month),
        ],
      ),
    );
  }
}

class _SevenDayBars extends StatelessWidget {
  const _SevenDayBars({required this.bars});

  final List<DayBar> bars;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final maxValue = bars.fold<int>(0, (max, bar) => bar.netSales > max ? bar.netSales : max);
    const chartHeight = 96.0;
    final description = bars
        .map((bar) => '${_dayLabel(bar.dayKey, s)} ${formatPeso(bar.netSales)}')
        .join(', ');
    return AppCard(
      tone: CardTone.band,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.lastSevenDays, style: AppType.headingSm),
          const SizedBox(height: AppSpace.xs),
          Text(s.highestDay(formatPesoCompact(maxValue)), style: AppType.micro),
          const SizedBox(height: AppSpace.lg),
          Semantics(
            label: description,
            excludeSemantics: true,
            child: SizedBox(
              height: chartHeight + 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final bar in bars)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: _barHeight(bar.netSales, maxValue, chartHeight),
                              decoration: BoxDecoration(
                                color: bar.isToday ? AppColors.ink : AppColors.shade50,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xs)),
                              ),
                            ),
                            const SizedBox(height: AppSpace.sm),
                            Text(
                              _dayLabel(bar.dayKey, s),
                              style: AppType.micro.copyWith(
                                color: bar.isToday ? AppColors.ink : AppColors.textSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static double _barHeight(int value, int maxValue, double chartHeight) {
    if (maxValue <= 0 || value <= 0) return 2;
    final height = value / maxValue * chartHeight;
    return height < 4 ? 4 : height;
  }

  static String _dayLabel(String dayKey, Strings s) =>
      s.weekdayShort(ManilaTime.fromDayKey(dayKey).weekday);
}

class _Rank extends StatelessWidget {
  const _Rank({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rank == 1 ? AppColors.aloe10 : AppColors.canvasCream,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.hairlineLight),
      ),
      child: Text('$rank', style: AppType.tabular(AppType.bodyStrong)),
    );
  }
}

class _RecentSales extends StatelessWidget {
  const _RecentSales({required this.recent});

  final LiveQuery<List<Sale>> recent;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final error = recent.error;
    if (error != null) return ErrorCard(error: error, onRetry: recent.retry);
    if (recent.isLoading) return const LoadingBlocks(count: 3);
    final sales = recent.value ?? const <Sale>[];
    if (sales.isEmpty) return EmptyState(icon: Icons.receipt_long_outlined, message: s.noSalesYet);
    return ListCard(children: [for (final sale in sales) SaleRow(sale: sale)]);
  }
}

/// One sale in a list: total, time, items, payment, status.
class SaleRow extends StatelessWidget {
  const SaleRow({super.key, required this.sale, this.showDate = false});

  final Sale sale;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final created = sale.createdAt;
    final when = created == null
        ? ''
        : (showDate
            ? ManilaTime.formatDateTime(ManilaTime.toManila(created), s)
            : ManilaTime.formatTime(ManilaTime.toManila(created)));
    final payment = sale.paymentType == PaymentType.utang
        ? s.utangFor(sale.customerName ?? '')
        : s.paymentCash;
    final Widget trailing = switch (sale.status) {
      SaleStatus.cancelled => TagPill(label: s.statusCancelled, tone: TagTone.ink, icon: Icons.block_rounded),
      SaleStatus.refunded => TagPill(label: s.statusRefunded, tone: TagTone.shade, icon: Icons.undo_rounded),
      SaleStatus.completed => sale.hasRefund
          ? TagPill(label: s.statusPartRefund, tone: TagTone.shade, icon: Icons.undo_rounded)
          : const Icon(Icons.chevron_right_rounded),
    };
    return ListRow(
      title: '${formatPeso(sale.total)}  ·  $when',
      subtitle: '${s.itemCount(sale.itemCount)} · $payment · ${sale.cashierName}',
      trailing: trailing,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => SaleDetailScreen(saleId: sale.id)),
      ),
    );
  }
}
