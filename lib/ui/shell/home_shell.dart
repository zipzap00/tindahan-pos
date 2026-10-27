import 'package:flutter/material.dart';

import '../../core/l10n/language.dart';
import '../../domain/inventory.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/inventory/inventory_screen.dart';
import '../screens/more/more_screen.dart';
import '../screens/pos/pos_screen.dart';
import '../screens/utang/utang_screen.dart';

enum ShellTab { dashboard, pos, inventory, utang, more }

/// Lets screens switch tabs (for example the dashboard's low-stock card
/// opening the inventory filtered to low stock).
class ShellScope extends InheritedWidget {
  const ShellScope({
    super.key,
    required this.goTo,
    required this.inventoryFilterRequest,
    required super.child,
  });

  final void Function(ShellTab tab) goTo;

  /// Set by other tabs; the inventory screen applies it and clears it.
  final ValueNotifier<InventoryFilter?> inventoryFilterRequest;

  static ShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellScope>();

  @override
  bool updateShouldNotify(ShellScope oldWidget) =>
      goTo != oldWidget.goTo || inventoryFilterRequest != oldWidget.inventoryFilterRequest;
}

/// Bottom navigation. Owners: Buod, Benta, Paninda, Utang, Iba pa.
/// Cashiers: Benta, Paninda, Utang, Iba pa (no money totals or costs).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.isOwner});

  final bool isOwner;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final ValueNotifier<InventoryFilter?> _inventoryFilterRequest = ValueNotifier<InventoryFilter?>(null);
  late final List<ShellTab> _tabs = widget.isOwner
      ? const [ShellTab.dashboard, ShellTab.pos, ShellTab.inventory, ShellTab.utang, ShellTab.more]
      : const [ShellTab.pos, ShellTab.inventory, ShellTab.utang, ShellTab.more];
  int _index = 0;

  @override
  void dispose() {
    _inventoryFilterRequest.dispose();
    super.dispose();
  }

  void _goTo(ShellTab tab) {
    final index = _tabs.indexOf(tab);
    if (index >= 0 && index != _index) setState(() => _index = index);
  }

  Widget _screenFor(ShellTab tab) => switch (tab) {
        ShellTab.dashboard => const DashboardScreen(),
        ShellTab.pos => const PosScreen(),
        ShellTab.inventory => const InventoryScreen(),
        ShellTab.utang => const UtangScreen(),
        ShellTab.more => const MoreScreen(),
      };

  NavigationDestination _destinationFor(ShellTab tab, BuildContext context) {
    final s = context.s;
    return switch (tab) {
      ShellTab.dashboard => NavigationDestination(
          icon: const Icon(Icons.insights_outlined),
          selectedIcon: const Icon(Icons.insights_rounded),
          label: s.tabDashboard,
        ),
      ShellTab.pos => NavigationDestination(
          icon: const Icon(Icons.point_of_sale_outlined),
          selectedIcon: const Icon(Icons.point_of_sale_rounded),
          label: s.tabPos,
        ),
      ShellTab.inventory => NavigationDestination(
          icon: const Icon(Icons.inventory_2_outlined),
          selectedIcon: const Icon(Icons.inventory_2_rounded),
          label: s.tabInventory,
        ),
      ShellTab.utang => NavigationDestination(
          icon: const Icon(Icons.menu_book_outlined),
          selectedIcon: const Icon(Icons.menu_book_rounded),
          label: s.tabUtang,
        ),
      ShellTab.more => NavigationDestination(
          icon: const Icon(Icons.more_horiz_rounded),
          selectedIcon: const Icon(Icons.more_horiz_rounded),
          label: s.tabMore,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ShellScope(
      goTo: _goTo,
      inventoryFilterRequest: _inventoryFilterRequest,
      child: PopScope(
        canPop: _index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _index = 0);
        },
        child: Scaffold(
          body: IndexedStack(
            index: _index,
            children: [for (final tab in _tabs) _screenFor(tab)],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (index) => setState(() => _index = index),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [for (final tab in _tabs) _destinationFor(tab, context)],
          ),
        ),
      ),
    );
  }
}
