import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/manila_time.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/live_query.dart';
import '../../../data/models/records.dart';
import '../../../data/models/sale.dart';
import '../../../data/store_session.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/layout.dart';
import '../../widgets/states.dart';
import '../dashboard/dashboard_screen.dart' show SaleRow;

/// All sales for one Philippine day, with that day's totals.
class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  late DateTime _day = ManilaTime.startOfDay(ManilaTime.now());
  StoreSession? _session;
  LiveQuery<List<Sale>>? _sales;
  LiveQuery<DailyStats>? _stats;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = StoreScope.of(context);
    if (!identical(session, _session)) {
      _session = session;
      _open();
    }
  }

  void _open() {
    final session = _session;
    if (session == null) return;
    _sales?.dispose();
    _stats?.dispose();
    final key = ManilaTime.dayKey(_day);
    _sales = LiveQuery<List<Sale>>(() => session.sales.watchDay(key), context: '[sales/day]');
    _stats = LiveQuery<DailyStats>(() => session.insights.watchDay(key), context: '[sales/dayStats]');
  }

  void _moveDay(int days) {
    final next = _day.add(Duration(days: days));
    if (next.isAfter(ManilaTime.startOfDay(ManilaTime.now()))) return;
    setState(() {
      _day = next;
      _open();
    });
  }

  @override
  void dispose() {
    _sales?.dispose();
    _stats?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final sales = _sales;
    final stats = _stats;
    final session = _session;
    if (sales == null || stats == null || session == null) return const SizedBox.shrink();
    final isToday = ManilaTime.dayKey(_day) == ManilaTime.todayKey();

    return Scaffold(
      appBar: AppBar(title: Text(s.salesHistoryTitle)),
      body: ListenableBuilder(
        listenable: Listenable.merge([sales, stats]),
        builder: (context, _) {
          final error = sales.error;
          final list = sales.value ?? const <Sale>[];
          final day = stats.value ?? DailyStats(dayKey: ManilaTime.dayKey(_day));
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.xl),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: s.previousDay,
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => _moveDay(-1),
                  ),
                  Expanded(
                    child: Text(
                      isToday ? s.todayWithDate(ManilaTime.formatDate(_day, s)) : ManilaTime.formatLongDate(_day, s),
                      style: AppType.bodyStrong,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    tooltip: s.nextDay,
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: isToday ? null : () => _moveDay(1),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              AppCard(
                tone: CardTone.band,
                child: Column(
                  children: [
                    StatRow(label: s.columnSales, value: formatPeso(day.salesTotal)),
                    if (day.refundTotal > 0) StatRow(label: s.refunds, value: '−${formatPeso(day.refundTotal)}'),
                    StatRow(label: s.netSales, value: formatPeso(day.netSales), emphasize: true),
                    if (session.isOwner) StatRow(label: s.estimatedProfit, value: formatPeso(day.netProfit)),
                    StatRow(label: s.todayTransactions, value: '${day.txnCount}'),
                    if (day.cancelledCount > 0) StatRow(label: s.cancelledSales, value: '${day.cancelledCount}'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              if (error != null)
                ErrorCard(error: error, onRetry: sales.retry)
              else if (sales.isLoading)
                const LoadingBlocks(count: 5)
              else if (list.isEmpty)
                EmptyState(icon: Icons.receipt_long_outlined, message: s.noSalesThisDay)
              else
                ListCard(children: [for (final sale in list) SaleRow(sale: sale)]),
            ],
          );
        },
      ),
    );
  }
}
