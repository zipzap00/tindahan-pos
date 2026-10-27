import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/manila_time.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/live_query.dart';
import '../../../data/models/records.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/states.dart';

/// Stock movement history: every sale, restock, adjustment, refund and
/// cancellation, newest first. For one product or the whole store.
class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key, this.productId, this.productName});

  final String? productId;
  final String? productName;

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  LiveQuery<List<StockMovement>>? _movements;
  MovementType? _type;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_movements != null) return;
    final catalog = StoreScope.of(context).catalog;
    _movements = LiveQuery<List<StockMovement>>(
      () => catalog.watchMovements(productId: widget.productId, limit: 300),
      context: '[inventory/movements]',
    );
  }

  @override
  void dispose() {
    _movements?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final movements = _movements;
    if (movements == null) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: Text(widget.productName ?? s.stockMovementsTitle)),
      body: ListenableBuilder(
        listenable: movements,
        builder: (context, _) {
          final error = movements.error;
          final all = movements.value ?? const <StockMovement>[];
          final shown = _type == null ? all : all.where((m) => m.type == _type).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpace.xl),
            children: [
              ChoiceChipRow<MovementType?>(
                options: [null, ...MovementType.values],
                selected: _type,
                labelOf: (type) => type == null ? s.allTypes : s.movementTypeLabel(type),
                onSelected: (type) => setState(() => _type = type),
              ),
              const SizedBox(height: AppSpace.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
                child: error != null
                    ? ErrorCard(error: error, onRetry: movements.retry)
                    : movements.isLoading
                        ? const LoadingBlocks(count: 6)
                        : shown.isEmpty
                            ? EmptyState(icon: Icons.history_rounded, message: s.noMovementsYet)
                            : ListCard(
                                children: [
                                  for (final movement in shown)
                                    MovementRow(movement: movement, showProduct: widget.productId == null),
                                ],
                              ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MovementRow extends StatelessWidget {
  const MovementRow({super.key, required this.movement, required this.showProduct});

  final StockMovement movement;
  final bool showProduct;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final created = movement.createdAt;
    final reason = movement.reason;
    final change = movement.qtyChange > 0 ? '+${movement.qtyChange}' : '${movement.qtyChange}';
    final title = showProduct
        ? '${movement.productName} · ${s.movementTypeLabel(movement.type)}'
        : s.movementTypeLabel(movement.type);
    final details = [
      if (created != null) ManilaTime.formatDateTime(ManilaTime.toManila(created), s),
      if (reason != null) s.adjustReasonLabel(reason),
      if (movement.refLabel.isNotEmpty) movement.refLabel,
      if (movement.note.isNotEmpty) movement.note,
      movement.byName,
    ].join(' · ');
    return ListRow(
      leading: Icon(_iconFor(movement.type)),
      title: title,
      subtitle: details,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(change, style: AppType.tabular(AppType.bodyStrong)),
          Text(s.stockNow(movement.stockAfter), style: AppType.micro),
        ],
      ),
    );
  }

  static IconData _iconFor(MovementType type) => switch (type) {
        MovementType.initial => Icons.fiber_new_outlined,
        MovementType.sale => Icons.shopping_bag_outlined,
        MovementType.restock => Icons.add_box_outlined,
        MovementType.adjustment => Icons.tune_rounded,
        MovementType.refund => Icons.undo_rounded,
        MovementType.cancel => Icons.block_rounded,
      };
}
