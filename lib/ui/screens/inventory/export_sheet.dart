import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/language.dart';
import '../../../core/log.dart';
import '../../../core/manila_time.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/product.dart';
import '../../../data/models/records.dart';
import '../../../domain/csv_export.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/states.dart';

/// Export inventory or stock history as CSV. The file opens in Excel or
/// Google Sheets and can be sent through any app on the phone.
Future<void> showExportSheet(BuildContext context) {
  return showAppSheet<void>(context, builder: (_) => const _ExportSheet());
}

class _ExportSheet extends StatefulWidget {
  const _ExportSheet();

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  bool _busy = false;

  Future<void> _share(String filePrefix, String csv) async {
    final s = context.s;
    final stamp = ManilaTime.dayKey(ManilaTime.now());
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filePrefix-$stamp.csv');
      await file.writeAsBytes(utf8.encode('$utf8Bom$csv'), flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: '$filePrefix-$stamp.csv',
        ),
      );
    } catch (error, stack) {
      logError('[inventory/export]', error, stack);
      if (mounted) showMessage(context, s.exportFailed);
    }
  }

  Future<void> _exportInventory() async {
    final s = context.s;
    final products = StoreScope.of(context).products.value ?? const <Product>[];
    setState(() => _busy = true);
    await _share(s.exportInventoryFile, toCsv(inventoryRows(products, s)));
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _exportMovements() async {
    final s = context.s;
    final catalog = StoreScope.of(context).catalog;
    setState(() => _busy = true);
    final result = await catalog.fetchMovements();
    if (!mounted) return;
    final error = result.errorOrNull;
    if (error != null) {
      setState(() => _busy = false);
      showMessage(context, describeError(s, error));
      return;
    }
    final movements = result.when<List<StockMovement>>(
      ok: (value) => value,
      err: (_) => const <StockMovement>[],
    );
    await _share(s.exportMovementsFile, toCsv(movementRows(movements, s)));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.exportTitle, style: AppType.headingLg),
          const SizedBox(height: AppSpace.xs),
          Text(s.exportCaption, style: AppType.caption),
          const SizedBox(height: AppSpace.lg),
          if (_busy)
            const Padding(padding: EdgeInsets.all(AppSpace.xl), child: CenteredLoader())
          else
            ListCard(
              children: [
                ListRow(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: s.exportInventory,
                  subtitle: s.exportInventoryCaption,
                  trailing: const Icon(Icons.ios_share_rounded),
                  onTap: _exportInventory,
                ),
                ListRow(
                  leading: const Icon(Icons.history_rounded),
                  title: s.exportMovements,
                  subtitle: s.exportMovementsCaption,
                  trailing: const Icon(Icons.ios_share_rounded),
                  onTap: _exportMovements,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
