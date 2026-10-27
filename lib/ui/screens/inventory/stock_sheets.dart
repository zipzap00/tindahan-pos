import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/product.dart';
import '../../../data/models/records.dart';
import '../../../domain/pricing.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';
import 'product_form_screen.dart' show CostMode;

Future<void> showRestockSheet(BuildContext context, Product product) {
  return showAppSheet<void>(context, builder: (_) => _RestockSheet(product: product));
}

Future<void> showAdjustSheet(BuildContext context, Product product) {
  return showAppSheet<void>(context, builder: (_) => _AdjustSheet(product: product));
}

/// Receive new stock. Cost can be entered as the total paid or per piece.
class _RestockSheet extends StatefulWidget {
  const _RestockSheet({required this.product});

  final Product product;

  @override
  State<_RestockSheet> createState() => _RestockSheetState();
}

class _RestockSheetState extends State<_RestockSheet> {
  final _formKey = GlobalKey<FormState>();
  final _qty = TextEditingController();
  late final TextEditingController _cost =
      TextEditingController(text: centsToInputText(widget.product.unitCost));
  late final TextEditingController _supplier = TextEditingController(text: widget.product.supplier);
  final _note = TextEditingController();
  CostMode _mode = CostMode.perPiece;
  bool _busy = false;

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    _supplier.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _qtyValue => int.tryParse(_qty.text) ?? 0;

  double get _unitCost {
    final entered = parsePesoToCents(_cost.text) ?? 0;
    return _mode == CostMode.total ? unitCostFromTotal(entered, _qtyValue) : entered.toDouble();
  }

  Future<void> _save() async {
    final s = context.s;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final result = await StoreScope.of(context).catalog.restock(
          product: widget.product,
          qty: _qtyValue,
          unitCost: _unitCost,
          supplier: _supplier.text,
          note: _note.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    result.when<void>(
      ok: (_) {
        Navigator.of(context).pop();
        showMessage(context, s.restockSaved(_qtyValue, widget.product.name));
      },
      err: (error) => showMessage(context, describeError(s, error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final product = widget.product;
    final qty = _qtyValue;
    final newAverage = weightedAverageCost(
      currentStock: product.stock,
      currentUnitCost: product.unitCost,
      addedQty: qty,
      addedUnitCost: _unitCost,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.restockTitle, style: AppType.headingLg),
            Text(product.name, style: AppType.caption),
            const SizedBox(height: AppSpace.lg),
            QuantityField(
              label: s.quantityReceived,
              controller: _qty,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              validator: (value) => (int.tryParse(value ?? '') ?? 0) > 0 ? null : s.enterQuantity,
            ),
            const SizedBox(height: AppSpace.lg),
            SegmentedPills<CostMode>(
              options: CostMode.values,
              selected: _mode,
              labelOf: (mode) => mode == CostMode.total ? s.costModeTotal : s.costModePerPiece,
              onSelected: (mode) => setState(() {
                final entered = parsePesoToCents(_cost.text);
                if (entered != null && qty > 0) {
                  _cost.text = mode == CostMode.perPiece
                      ? centsToInputText(unitCostFromTotal(entered, qty))
                      : centsToInputText(entered * qty);
                }
                _mode = mode;
              }),
            ),
            const SizedBox(height: AppSpace.lg),
            PesoField(
              label: _mode == CostMode.total ? s.totalCostLabel : s.costPerPieceLabel,
              controller: _cost,
              onChanged: (_) => setState(() {}),
              validator: (value) => parsePesoToCents(value ?? '') == null ? s.enterAmount : null,
            ),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: s.supplierOptional,
              controller: _supplier,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: s.noteOptional,
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpace.lg),
            AppCard(
              tone: CardTone.band,
              padding: const EdgeInsets.all(AppSpace.lg),
              child: Column(
                children: [
                  StatRow(label: s.stockAfter, value: '${product.stock} → ${product.stock + qty}'),
                  StatRow(label: s.totalCostLabel, value: formatPeso(_unitCost * qty)),
                  StatRow(
                    label: s.newAverageCost,
                    value: '${formatPeso(product.unitCost)} → ${formatPeso(newAverage)}',
                    emphasize: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(s.averageCostExplainer, style: AppType.micro),
            const SizedBox(height: AppSpace.xl),
            PillButton(label: s.saveRestock, onPressed: _save, loading: _busy, expand: true),
          ],
        ),
      ),
    );
  }
}

/// Correct stock after a count, or record damage, expiry and loss.
class _AdjustSheet extends StatefulWidget {
  const _AdjustSheet({required this.product});

  final Product product;

  @override
  State<_AdjustSheet> createState() => _AdjustSheetState();
}

class _AdjustSheetState extends State<_AdjustSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _count = TextEditingController(text: '${widget.product.stock}');
  final _note = TextEditingController();
  AdjustReason _reason = AdjustReason.recount;
  bool _busy = false;

  @override
  void dispose() {
    _count.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = context.s;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final newStock = int.tryParse(_count.text) ?? widget.product.stock;
    if (newStock == widget.product.stock) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _busy = true);
    final result = await StoreScope.of(context).catalog.adjust(
          product: widget.product,
          newStock: newStock,
          reason: _reason,
          note: _note.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    result.when<void>(
      ok: (_) {
        Navigator.of(context).pop();
        showMessage(context, s.adjustSaved(widget.product.name));
      },
      err: (error) => showMessage(context, describeError(s, error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final product = widget.product;
    final newStock = int.tryParse(_count.text);
    final delta = newStock == null ? 0 : newStock - product.stock;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.adjustTitle, style: AppType.headingLg),
            Text(product.name, style: AppType.caption),
            const SizedBox(height: AppSpace.lg),
            StatRow(label: s.stockInApp, value: '${product.stock}'),
            const SizedBox(height: AppSpace.md),
            QuantityField(
              label: s.actualCount,
              controller: _count,
              autofocus: true,
              helper: s.actualCountHelper,
              onChanged: (_) => setState(() {}),
              validator: (value) => int.tryParse(value ?? '') == null ? s.enterQuantity : null,
            ),
            const SizedBox(height: AppSpace.lg),
            Text(s.reason, style: AppType.caption.copyWith(color: AppColors.ink)),
            const SizedBox(height: AppSpace.sm),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                for (final reason in AdjustReason.values)
                  ChoicePill(
                    label: s.adjustReasonLabel(reason),
                    selected: reason == _reason,
                    onTap: () => setState(() => _reason = reason),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: s.noteOptional,
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpace.lg),
            AppCard(
              tone: CardTone.band,
              padding: const EdgeInsets.all(AppSpace.lg),
              child: Column(
                children: [
                  StatRow(
                    label: s.stockChange,
                    value: delta == 0 ? '0' : (delta > 0 ? '+$delta' : '$delta'),
                    emphasize: true,
                  ),
                  if (delta < 0)
                    StatRow(label: s.valueLost, value: formatPeso(-delta * product.unitCost)),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.xl),
            PillButton(label: s.saveAdjustment, onPressed: _save, loading: _busy, expand: true),
          ],
        ),
      ),
    );
  }
}
