import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/product.dart';
import '../../../domain/inventory.dart';
import '../../scopes.dart';
import '../../shell/home_shell.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/states.dart';
import '../../widgets/tags.dart';
import 'export_sheet.dart';
import 'movements_screen.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _search = TextEditingController();
  String _query = '';
  InventoryFilter _filter = InventoryFilter.all;
  InventorySort _sort = InventorySort.name;
  String? _category;
  ValueNotifier<InventoryFilter?>? _filterRequest;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = ShellScope.maybeOf(context)?.inventoryFilterRequest;
    if (request != _filterRequest) {
      _filterRequest?.removeListener(_applyRequest);
      _filterRequest = request;
      request?.addListener(_applyRequest);
      _applyRequest();
    }
  }

  /// Another tab asked to show a filter (for example "low stock").
  void _applyRequest() {
    final requested = _filterRequest?.value;
    if (requested == null) return;
    setState(() {
      _filter = requested;
      _category = null;
      _query = '';
      _search.clear();
    });
    _filterRequest?.value = null;
  }

  @override
  void dispose() {
    _filterRequest?.removeListener(_applyRequest);
    _search.dispose();
    super.dispose();
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ProductDetailScreen(productId: product.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    final isOwner = session.isOwner;
    final filters = [
      InventoryFilter.all,
      InventoryFilter.inStock,
      InventoryFilter.low,
      InventoryFilter.out,
      if (isOwner) InventoryFilter.archived,
    ];

    return ListenableBuilder(
      listenable: session.products,
      builder: (context, _) {
        final products = session.products.value ?? const <Product>[];
        final categories = categoriesOf(products);
        final category = categories.contains(_category) ? _category : null;
        final shown = applyInventoryQuery(
          products,
          text: _query,
          filter: _filter,
          category: category,
          sort: _sort,
        );
        final value = inventoryValueOf(products);
        final activeCount = products.where((p) => !p.archived).length;
        final error = session.products.error;

        return SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PageHeader(
                  title: s.inventoryTitle,
                  caption: s.productCount(activeCount),
                  actions: [
                    if (isOwner) ...[
                      IconButton(
                        tooltip: s.exportTitle,
                        icon: const Icon(Icons.file_download_outlined),
                        onPressed: () => showExportSheet(context),
                      ),
                      IconButton(
                        tooltip: s.stockMovementsTitle,
                        icon: const Icon(Icons.history_rounded),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const MovementsScreen()),
                        ),
                      ),
                      IconButton(
                        tooltip: s.addProduct,
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const ProductFormScreen()),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: PagePadding(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isOwner) ...[
                        AppCard(
                          tone: CardTone.band,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(s.inventoryValueTitle, style: AppType.headingSm),
                              const SizedBox(height: AppSpace.sm),
                              StatRow(label: s.capitalInStock, value: formatPeso(value.capital)),
                              StatRow(label: s.valueAtSellingPrice, value: formatPeso(value.retail)),
                              StatRow(
                                label: s.expectedIncome,
                                value: formatPeso(value.potentialIncome),
                                emphasize: true,
                              ),
                              const SizedBox(height: AppSpace.xs),
                              Text(s.unitsOnHand(value.totalUnits), style: AppType.micro),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpace.lg),
                      ],
                      SearchField(
                        controller: _search,
                        hint: s.searchInventoryHint,
                        onChanged: (text) => setState(() => _query = text),
                      ),
                      const SizedBox(height: AppSpace.md),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ChoiceChipRow<InventoryFilter>(
                  options: filters,
                  selected: _filter,
                  labelOf: (filter) => s.inventoryFilterLabel(filter, _countFor(filter, products)),
                  onSelected: (filter) => setState(() => _filter = filter),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.sm, AppSpace.sm),
                  child: Row(
                    children: [
                      Expanded(
                        // An empty value means "all categories" (PopupMenuButton
                        // treats a null value as cancelling the menu).
                        child: PopupMenuButton<String>(
                          tooltip: s.category,
                          onSelected: (value) => setState(() => _category = value.isEmpty ? null : value),
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(value: '', child: Text(s.allCategories)),
                            for (final name in categories) PopupMenuItem<String>(value: name, child: Text(name)),
                          ],
                          child: _MenuLabel(icon: Icons.category_outlined, label: category ?? s.allCategories),
                        ),
                      ),
                      PopupMenuButton<InventorySort>(
                        tooltip: s.sortBy,
                        onSelected: (value) => setState(() => _sort = value),
                        itemBuilder: (context) => [
                          for (final option in InventorySort.values)
                            CheckedPopupMenuItem<InventorySort>(
                              value: option,
                              checked: option == _sort,
                              child: Text(s.inventorySortLabel(option)),
                            ),
                        ],
                        child: _MenuLabel(icon: Icons.sort_rounded, label: s.inventorySortLabel(_sort)),
                      ),
                    ],
                  ),
                ),
              ),
              if (error != null)
                SliverToBoxAdapter(
                  child: PagePadding(child: ErrorCard(error: error, onRetry: session.products.retry)),
                )
              else if (session.products.isLoading)
                const SliverToBoxAdapter(child: PagePadding(child: LoadingBlocks(count: 6)))
              else if (activeCount == 0 && _filter != InventoryFilter.archived)
                SliverToBoxAdapter(
                  child: PagePadding(
                    child: EmptyState(
                      icon: Icons.inventory_2_outlined,
                      message: isOwner ? s.noProductsOwner : s.noProductsCashier,
                      actionLabel: isOwner ? s.addProduct : null,
                      onAction: isOwner
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute<void>(builder: (_) => const ProductFormScreen()),
                              )
                          : null,
                    ),
                  ),
                )
              else if (shown.isEmpty)
                SliverToBoxAdapter(
                  child: PagePadding(child: EmptyState(icon: Icons.search_off_rounded, message: s.noSearchResults)),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
                  sliver: DecoratedSliver(
                    decoration: BoxDecoration(
                      color: AppColors.canvasLight,
                      borderRadius: AppRadius.card,
                      border: Border.all(color: AppColors.hairlineLight),
                    ),
                    sliver: SliverList.builder(
                      itemCount: shown.length,
                      itemBuilder: (context, index) {
                        final product = shown[index];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (index > 0) const Divider(height: 1, indent: AppSpace.lg, endIndent: AppSpace.lg),
                            _InventoryRow(
                              product: product,
                              showCost: isOwner,
                              onTap: () => _openProduct(product),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpace.xxl)),
            ],
          ),
        );
      },
    );
  }

  int _countFor(InventoryFilter filter, List<Product> products) {
    return switch (filter) {
      InventoryFilter.all => products.where((p) => !p.archived).length,
      InventoryFilter.inStock => products.where((p) => !p.archived && p.stock > 0).length,
      InventoryFilter.low => products.where((p) => !p.archived && p.status == StockStatus.low).length,
      InventoryFilter.out => products.where((p) => !p.archived && p.status == StockStatus.out).length,
      InventoryFilter.archived => products.where((p) => p.archived).length,
    };
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpace.minTouch),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: AppSpace.xs + 2),
            // No Flexible here: the sort menu sits in a Row without a width bound.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                label,
                style: AppType.caption.copyWith(color: AppColors.ink),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.product, required this.showCost, required this.onTap});

  final Product product;
  final bool showCost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final details = [
      if (product.category.isNotEmpty) product.category,
      formatPeso(product.sellingPrice),
      if (showCost) s.costShort(formatPeso(product.unitCost)),
    ].join(' · ');
    return ListRow(
      title: product.name,
      subtitle: details,
      onTap: onTap,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${product.stock}', style: AppType.tabular(AppType.headingMd)),
          const SizedBox(height: AppSpace.xxs),
          if (product.archived)
            TagPill(label: s.archivedLabel, tone: TagTone.outline)
          else
            StockBadge(status: product.status),
        ],
      ),
    );
  }
}
