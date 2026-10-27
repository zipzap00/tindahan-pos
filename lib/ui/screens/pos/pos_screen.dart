import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/language.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/product.dart';
import '../../../domain/cart.dart';
import '../../../domain/inventory.dart';
import '../../scopes.dart';
import '../../shell/home_shell.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';
import '../../widgets/tags.dart';
import 'cart_sheet.dart';

/// Point of sale: search or tap products, then pay. Tapping a card adds one
/// piece. A typed or scanned barcode / SKU that matches exactly is added
/// straight away.
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _search = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _add(Product product) {
    final s = context.s;
    final cart = StoreScope.of(context).cart;
    switch (cart.add(product)) {
      case AddOutcome.added:
        HapticFeedback.selectionClick();
      case AddOutcome.atStockLimit:
        showMessage(context, s.onlyNInStock(product.stock, product.name));
      case AddOutcome.outOfStock:
        showMessage(context, s.outOfStockMessage(product.name));
      case AddOutcome.unavailable:
        showMessage(context, s.productUnavailable(product.name));
    }
  }

  void _onSubmitted(String text) {
    final products = StoreScope.of(context).products.value ?? const <Product>[];
    final match = exactCodeMatch(products, text);
    if (match != null) {
      _add(match);
      _search.clear();
      setState(() => _query = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([session.products, session.cart]),
      builder: (context, _) {
        final products = session.products.value ?? const <Product>[];
        final categories = categoriesOf(products);
        final category = categories.contains(_category) ? _category : null;
        final results = searchSellable(products, _query, category: category);
        final cart = session.cart;
        final productsError = session.products.error;

        Widget body;
        if (productsError != null) {
          body = PagePadding(child: ErrorCard(error: productsError, onRetry: session.products.retry));
        } else if (session.products.isLoading) {
          body = const PagePadding(child: LoadingBlocks(count: 4, height: 120));
        } else if (products.where((p) => !p.archived).isEmpty) {
          body = PagePadding(
            child: EmptyState(
              icon: Icons.inventory_2_outlined,
              message: session.isOwner ? s.noProductsOwner : s.noProductsCashier,
              actionLabel: session.isOwner ? s.goToInventory : null,
              onAction: session.isOwner ? () => ShellScope.maybeOf(context)?.goTo(ShellTab.inventory) : null,
            ),
          );
        } else if (results.isEmpty) {
          body = PagePadding(child: EmptyState(icon: Icons.search_off_rounded, message: s.noSearchResults));
        } else {
          body = GridView.builder(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.xl),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisExtent: 156,
              crossAxisSpacing: AppSpace.md,
              mainAxisSpacing: AppSpace.md,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final product = results[index];
              return _ProductTile(
                product: product,
                inCart: cart.qtyOf(product.id),
                onTap: () => _add(product),
              );
            },
          );
        }

        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.lg, AppSpace.screen, AppSpace.md),
                child: Semantics(header: true, child: Text(s.posTitle, style: AppType.headingXl)),
              ),
              PagePadding(
                child: SearchField(
                  controller: _search,
                  hint: s.searchProductHint,
                  onChanged: (value) => setState(() => _query = value),
                  onSubmitted: _onSubmitted,
                ),
              ),
              const SizedBox(height: AppSpace.md),
              if (categories.isNotEmpty) ...[
                ChoiceChipRow<String?>(
                  options: [null, ...categories],
                  selected: category,
                  labelOf: (value) => value ?? s.allCategories,
                  onSelected: (value) => setState(() => _category = value),
                ),
                const SizedBox(height: AppSpace.md),
              ],
              Expanded(child: body),
              if (!cart.isEmpty)
                BottomActionBar(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(s.itemCount(cart.itemCount), style: AppType.caption),
                            Text(formatPeso(cart.total), style: AppType.tabular(AppType.headingLg)),
                          ],
                        ),
                      ),
                      PillButton(
                        label: s.viewCart,
                        icon: Icons.shopping_basket_outlined,
                        onPressed: () => showCartSheet(context),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.inCart, required this.onTap});

  final Product product;
  final int inCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final out = product.stock <= 0;
    final selected = inCart > 0;
    return Semantics(
      button: true,
      label: '${product.name}, ${formatPeso(product.sellingPrice)}, ${s.stockCount(product.stock)}'
          '${selected ? ', ${s.inCartCount(inCart)}' : ''}',
      excludeSemantics: true,
      child: Material(
        color: AppColors.canvasLight,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: selected ? AppColors.ink : AppColors.hairlineLight, width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: onTap,
          child: Opacity(
            opacity: out ? 0.55 : 1,
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppType.bodyStrong,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(width: AppSpace.xs),
                        Container(
                          constraints: const BoxConstraints(minWidth: 28),
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            '$inCart',
                            style: AppType.tabular(AppType.caption).copyWith(color: AppColors.onPrimary),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  Text(formatPeso(product.sellingPrice), style: AppType.tabular(AppType.headingMd)),
                  const SizedBox(height: AppSpace.xs),
                  if (out || product.status == StockStatus.low)
                    StockBadge(status: product.status)
                  else
                    Text(s.stockCount(product.stock), style: AppType.micro),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
