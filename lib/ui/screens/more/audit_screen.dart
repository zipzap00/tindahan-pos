import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/manila_time.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/live_query.dart';
import '../../../data/models/records.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/states.dart';

/// Who changed what: price changes, restocks, adjustments, refunds,
/// cancellations, utang payments, expenses and staff changes.
class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  LiveQuery<List<AuditEntry>>? _entries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entries != null) return;
    final insights = StoreScope.of(context).insights;
    _entries = LiveQuery<List<AuditEntry>>(insights.watchAudit, context: '[audit/list]');
  }

  @override
  void dispose() {
    _entries?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final entries = _entries;
    if (entries == null) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: Text(s.auditTitle)),
      body: ListenableBuilder(
        listenable: entries,
        builder: (context, _) {
          final error = entries.error;
          final list = entries.value ?? const <AuditEntry>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.xl),
            children: [
              if (error != null)
                ErrorCard(error: error, onRetry: entries.retry)
              else if (entries.isLoading)
                const LoadingBlocks(count: 6)
              else if (list.isEmpty)
                EmptyState(icon: Icons.fact_check_outlined, message: s.noAuditYet)
              else
                ListCard(
                  children: [
                    for (final entry in list)
                      ListRow(
                        title: s.auditActionLabel(entry.action),
                        subtitle: [
                          if (entry.subject.isNotEmpty) _subject(entry, s.expenseCategoryLabelByName),
                          if (entry.createdAt != null)
                            ManilaTime.formatDateTime(ManilaTime.toManila(entry.createdAt!), s),
                          entry.byName,
                        ].join(' · '),
                        trailing: _trailing(entry),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  static String _subject(AuditEntry entry, String Function(String) expenseLabel) {
    if (entry.action == AuditAction.expenseAdded || entry.action == AuditAction.expenseDeleted) {
      return expenseLabel(entry.subject);
    }
    return entry.subject;
  }

  static Widget? _trailing(AuditEntry entry) {
    final amount = entry.amount;
    final qty = entry.qty;
    final parts = <String>[
      if (qty != null && qty != 0) (qty > 0 ? '+$qty' : '$qty'),
      if (amount != null && entry.action != AuditAction.productCreated) formatPeso(amount),
    ];
    if (parts.isEmpty) return null;
    return Text(parts.join('\n'), textAlign: TextAlign.end, style: AppType.tabular(AppType.caption));
  }
}
