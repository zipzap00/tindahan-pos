import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/live_query.dart';
import '../../../data/models/product.dart';
import '../../../data/models/records.dart';
import '../../../domain/pricing.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';
import '../../widgets/tags.dart';
import 'movements_screen.dart';
import 'product_form_screen.dart';
import 'stock_sheets.dart';

/// One product: price, stock, capital and income, sales so far, stock history.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  LiveQuery<List<StockMovement>>? _movements;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_movements != null) return;
    final catalog = StoreScope.of(context).catalog;
    _movements = LiveQuery<List<StockMovement>>(
      () => catalog.watchMovements(productId: widget.productId, limit: 10),
      context: '[product/movements]',
    );
  }

  @override
  void dispose() {
    _movements?.dispose();
    super.dispose();
  }

  Future<void> _toggleArchive(Product product) async {
    final s = context.s;
    final archiving = !product.archived;
    final confirmed = await showConfirmDialog(
      context,
      title: archiving ? s.archiveProductTitle : s.restoreProductTitle,
      message: archiving ? s.archiveProductMessage(product.name) : s.restoreProductMessage(product.name),
      confirmLabel: archiving ? s.archive : s.restore,
    );
    if (!confirmed || !mounted) return;
    final result = await StoreScope.of(context).catalog.setArchived(product, archived: archiving);
    if (!mounted) return;
    final error = result.errorOrNull;
    showMessage(context, error == null ? (archiving ? s.productArchived : s.productRestored) : describeError(s, error));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    final movements = _movements;
    if (movements == null) return const SizedBox.shrink();
    final isOwner = session.isOwner;
    return ListenableBuilder(
      listenable: Listenable.merge([session.products, movements]),
      builder: (context, _) {
        final product = session.productsById[widget.productId];
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: session.products.isLoading
                ? const CenteredLoader()
                : Padding(
                    padding: const EdgeInsets.all(AppSpace.screen),
                    child: EmptyState(icon: Icons.inventory_2_outlined, message: s.productNotFound),
                  ),
          );
        }
        final preview = ProfitPreview(
          quantity: product.stock < 0 ? 0 : product.stock,
          unitCost: product.unitCost,
          sellingPrice: product.sellingPrice,
        );
        final markup = preview.markupPercent;
        final movementError = movements.error;
        final history = movements.value ?? const <StockMovement>[];

        return Scaffold(
          appBar: AppBar(
            actions: [
              if (isOwner) ...[
                IconButton(
                  tooltip: s.editProduct,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => ProductFormScreen(existing: product)),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: s.moreActions,
                  onSelected: (_) => _toggleArchive(product),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'archive',
                      child: Text(product.archived ? s.restore : s.archive),
                    ),
                  ],
                ),
              ],
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.xl),
            children: [
              Text(product.name, style: AppType.headingXl),
              const SizedBox(height: AppSpace.sm),
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.sm,
                children: [
                  if (product.archived)
                    TagPill(label: s.archivedLabel, tone: TagTone.outline, icon: Icons.archive_outlined)
                  else
                    StockBadge(status: product.status),
                  if (product.category.isNotEmpty) TagPill(label: product.category, tone: TagTone.outline),
                ],
              ),
              const SizedBox(height: AppSpace.lg),
              AppCard(
                tone: CardTone.featured,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.sellingPricePerPiece.toUpperCase(), style: AppType.eyebrowCap),
                          const SizedBox(height: AppSpace.sm),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(formatPeso(product.sellingPrice), style: AppType.tabular(AppType.displayMd)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(s.onHand.toUpperCase(), style: AppType.eyebrowCap),
                        const SizedBox(height: AppSpace.sm),
                        Text('${product.stock}', style: AppType.tabular(AppType.headingXl)),
                        Text(s.minLevel(product.minStock), style: AppType.micro),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOwner) ...[
                SectionHeader(title: s.capitalAndIncome),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StatRow(label: s.costPerPiece, value: formatPeso(product.unitCost)),
                      StatRow(label: s.sellingPricePerPiece, value: formatPeso(product.sellingPrice)),
                      StatRow(
                        label: s.incomePerPiece,
                        value: markup == null
                            ? formatPeso(preview.marginPerPiece)
                            : '${formatPeso(preview.marginPerPiece)} (${s.markupPercent(markup)})',
                      ),
                      const Divider(height: AppSpace.xl),
                      StatRow(label: s.capitalForStock(product.stock), value: formatPeso(preview.capital)),
                      StatRow(label: s.salesIfAllSold, value: formatPeso(preview.expectedSales)),
                      StatRow(label: s.expectedIncome, value: formatPeso(preview.expectedIncome), emphasize: true),
                      if (preview.sellsBelowCost) ...[
                        const SizedBox(height: AppSpace.md),
                        InlineNotice(icon: Icons.warning_amber_rounded, message: s.priceBelowCost),
                      ],
                    ],
                  ),
                ),
                SectionHeader(title: s.salesSoFar),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StatRow(label: s.piecesSoldLabel, value: '${product.soldQty}'),
                      StatRow(label: s.revenue, value: formatPeso(product.revenue)),
                      StatRow(label: s.costOfGoodsSold, value: formatPeso(product.cogs)),
                      StatRow(label: s.realizedIncome, value: formatPeso(product.realizedProfit), emphasize: true),
                    ],
                  ),
                ),
              ],
              SectionHeader(title: s.details),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StatRow(label: s.barcode, value: product.barcode.isEmpty ? '—' : product.barcode),
                    StatRow(label: s.sku, value: product.sku.isEmpty ? '—' : product.sku),
                    StatRow(label: s.supplier, value: product.supplier.isEmpty ? '—' : product.supplier),
                    StatRow(label: s.minStockLevel, value: '${product.minStock}'),
                  ],
                ),
              ),
              SectionHeader(
                title: s.stockHistory,
                actionLabel: s.seeAll,
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MovementsScreen(productId: product.id, productName: product.name),
                  ),
                ),
              ),
              if (movementError != null)
                ErrorCard(error: movementError, onRetry: movements.retry)
              else if (movements.isLoading)
                const LoadingBlocks(count: 3)
              else if (history.isEmpty)
                EmptyState(icon: Icons.history_rounded, message: s.noMovementsYet)
              else
                ListCard(children: [for (final movement in history) MovementRow(movement: movement, showProduct: false)]),
            ],
          ),
          bottomNavigationBar: isOwner && !product.archived
              ? BottomActionBar(
                  child: Row(
                    children: [
                      Expanded(
                        child: PillButton(
                          label: s.adjustStock,
                          variant: PillVariant.outline,
                          expand: true,
                          onPressed: () => showAdjustSheet(context, product),
                        ),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: PillButton(
                          label: s.restock,
                          icon: Icons.add_box_outlined,
                          expand: true,
                          onPressed: () => showRestockSheet(context, product),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}
