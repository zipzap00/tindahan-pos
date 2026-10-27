import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../domain/inventory.dart';
import '../../../domain/pricing.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';

enum CostMode { total, perPiece }

/// Add a product (with the stock you bought) or edit an existing one.
///
/// Example: bought 10 pieces for ₱100 total, sell at ₱12 each. The live
/// calculation shows capital ₱100, sales ₱120 and income ₱20.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.existing});

  final Product? existing;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _barcode;
  late final TextEditingController _sku;
  late final TextEditingController _supplier;
  late final TextEditingController _quantity;
  late final TextEditingController _cost;
  late final TextEditingController _price;
  late final TextEditingController _minStock;
  CostMode _costMode = CostMode.total;
  bool _busy = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.name ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _barcode = TextEditingController(text: p?.barcode ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _supplier = TextEditingController(text: p?.supplier ?? '');
    _quantity = TextEditingController();
    _cost = TextEditingController(text: p == null ? '' : centsToInputText(p.unitCost));
    _price = TextEditingController(text: p == null ? '' : centsToInputText(p.sellingPrice));
    _minStock = TextEditingController(text: p == null ? '5' : '${p.minStock}');
    if (p != null) _costMode = CostMode.perPiece;
  }

  @override
  void dispose() {
    for (final controller in [_name, _category, _barcode, _sku, _supplier, _quantity, _cost, _price, _minStock]) {
      controller.dispose();
    }
    super.dispose();
  }

  int get _quantityValue => int.tryParse(_quantity.text) ?? 0;

  /// Quantity used for the capital and income preview.
  int get _previewQuantity => _isEdit ? (widget.existing?.stock ?? 0) : _quantityValue;

  double get _unitCost {
    final entered = parsePesoToCents(_cost.text) ?? 0;
    if (_costMode == CostMode.total) return unitCostFromTotal(entered, _quantityValue);
    return entered.toDouble();
  }

  Future<void> _save() async {
    final s = context.s;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final session = StoreScope.of(context);
    final existing = widget.existing;
    final details = Product(
      id: existing?.id ?? '',
      name: _name.text,
      category: _category.text,
      barcode: _barcode.text,
      sku: _sku.text,
      supplier: _supplier.text,
      unitCost: _unitCost,
      sellingPrice: parsePesoToCents(_price.text) ?? 0,
      stock: existing?.stock ?? _quantityValue,
      minStock: int.tryParse(_minStock.text) ?? 0,
    );
    setState(() => _busy = true);
    final result = existing == null
        ? (await session.catalog.createProduct(NewProductInput(details: details, initialStock: _quantityValue)))
            .when<AppError?>(ok: (_) => null, err: (error) => error)
        : (await session.catalog.updateDetails(before: existing, after: details))
            .when<AppError?>(ok: (_) => null, err: (error) => error);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result == null) {
      Navigator.of(context).pop();
      showMessage(context, existing == null ? s.productAdded : s.productSaved);
    } else {
      showMessage(context, describeError(s, result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    final products = session.products.value ?? const <Product>[];
    final categories = categoriesOf(products);
    final existing = widget.existing;
    final preview = ProfitPreview(
      quantity: _previewQuantity,
      unitCost: _unitCost,
      sellingPrice: parsePesoToCents(_price.text) ?? 0,
    );
    final markup = preview.markupPercent;

    String? codeValidator(String? value, {required bool isBarcode}) {
      final owner = duplicateCodeOwner(
        products,
        code: value ?? '',
        exceptId: existing?.id,
        isBarcode: isBarcode,
      );
      return owner == null ? null : s.codeAlreadyUsed(owner);
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? s.editProduct : s.addProduct)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, AppSpace.xl),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.productDetailsSection, style: AppType.headingSm),
                  const SizedBox(height: AppSpace.lg),
                  AppTextField(
                    label: s.productName,
                    controller: _name,
                    hint: s.productNameHint,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value ?? '').trim().isEmpty ? s.required : null,
                  ),
                  const SizedBox(height: AppSpace.lg),
                  AppTextField(
                    label: s.categoryOptional,
                    controller: _category,
                    hint: s.categoryHint,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  if (categories.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.sm),
                    ChoiceChipRow<String>(
                      padding: EdgeInsets.zero,
                      options: categories,
                      selected: _category.text.trim(),
                      labelOf: (value) => value,
                      onSelected: (value) => setState(() => _category.text = value),
                    ),
                  ],
                  const SizedBox(height: AppSpace.lg),
                  AppTextField(
                    label: s.barcodeOptional,
                    controller: _barcode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) => codeValidator(value, isBarcode: true),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  AppTextField(
                    label: s.skuOptional,
                    controller: _sku,
                    helper: s.skuHelper,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    validator: (value) => codeValidator(value, isBarcode: false),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  AppTextField(
                    label: s.supplierOptional,
                    controller: _supplier,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_isEdit ? s.priceSection : s.priceAndStockSection, style: AppType.headingSm),
                  const SizedBox(height: AppSpace.lg),
                  if (!_isEdit) ...[
                    QuantityField(
                      label: s.quantityBought,
                      controller: _quantity,
                      helper: s.quantityBoughtHelper,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (_costMode == CostMode.total && (int.tryParse(value ?? '') ?? 0) <= 0) {
                          return s.quantityNeededForTotal;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpace.lg),
                    SegmentedPills<CostMode>(
                      options: CostMode.values,
                      selected: _costMode,
                      labelOf: (mode) => mode == CostMode.total ? s.costModeTotal : s.costModePerPiece,
                      onSelected: (mode) => setState(() {
                        // Keep the same money meaning when switching modes.
                        final entered = parsePesoToCents(_cost.text);
                        if (entered != null && _quantityValue > 0) {
                          _cost.text = mode == CostMode.perPiece
                              ? centsToInputText(unitCostFromTotal(entered, _quantityValue))
                              : centsToInputText(entered * _quantityValue);
                        }
                        _costMode = mode;
                      }),
                    ),
                    const SizedBox(height: AppSpace.lg),
                  ] else ...[
                    StatRow(label: s.currentStock, value: '${existing?.stock ?? 0}'),
                    Text(s.stockChangesHint, style: AppType.micro),
                    const SizedBox(height: AppSpace.lg),
                  ],
                  PesoField(
                    label: _costMode == CostMode.total ? s.totalCostLabel : s.costPerPieceLabel,
                    controller: _cost,
                    helper: _costMode == CostMode.total ? s.totalCostHelper : s.costPerPieceHelper,
                    onChanged: (_) => setState(() {}),
                    validator: (value) => parsePesoToCents(value ?? '') == null ? s.enterAmount : null,
                  ),
                  const SizedBox(height: AppSpace.lg),
                  PesoField(
                    label: s.sellingPricePerPiece,
                    controller: _price,
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final cents = parsePesoToCents(value ?? '');
                      return cents == null || cents <= 0 ? s.enterSellingPrice : null;
                    },
                  ),
                  const SizedBox(height: AppSpace.lg),
                  QuantityField(
                    label: s.minStockLevel,
                    controller: _minStock,
                    helper: s.minStockHelper,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.md),
            AppCard(
              tone: CardTone.band,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.calculationTitle, style: AppType.headingSm),
                  const SizedBox(height: AppSpace.xs),
                  Text(s.calculationCaption(preview.quantity), style: AppType.micro),
                  const SizedBox(height: AppSpace.md),
                  StatRow(label: s.costPerPiece, value: formatPeso(preview.unitCost)),
                  StatRow(label: s.capitalLabel, value: formatPeso(preview.capital)),
                  StatRow(label: s.totalSalesLabel, value: formatPeso(preview.expectedSales)),
                  StatRow(label: s.incomeLabel, value: formatPeso(preview.expectedIncome), emphasize: true),
                  StatRow(
                    label: s.incomePerPiece,
                    value: markup == null
                        ? formatPeso(preview.marginPerPiece)
                        : '${formatPeso(preview.marginPerPiece)} (${s.markupPercent(markup)})',
                  ),
                  if (preview.sellsBelowCost && preview.sellingPrice > 0) ...[
                    const SizedBox(height: AppSpace.md),
                    InlineNotice(icon: Icons.warning_amber_rounded, message: s.priceBelowCost),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: PillButton(
          label: _isEdit ? s.saveChanges : s.saveProduct,
          expand: true,
          loading: _busy,
          onPressed: _save,
        ),
      ),
    );
  }
}
