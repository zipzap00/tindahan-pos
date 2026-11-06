import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/manila_time.dart';
import '../../../core/money.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/sale.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../widgets/cards.dart';
import '../../widgets/layout.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/states.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.outcome});

  final SaleOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final sale = outcome.sale;
    final when = ManilaTime.formatDateTime(ManilaTime.now(), s);
    final isUtang = sale.paymentType == PaymentType.utang;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.xl),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
              child: Icon(Icons.check_rounded, size: 40, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Text(s.saleComplete, style: AppType.headline, textAlign: TextAlign.center),
          const SizedBox(height: AppSpace.xs),
          Text(
            '${s.receiptNo(sale.receiptNo)} · $when',
            style: AppType.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (!outcome.synced) ...[
            const SizedBox(height: AppSpace.lg),
            InlineNotice(icon: Icons.cloud_off_rounded, message: s.savedOffline),
          ],
          const SizedBox(height: AppSpace.xl),
          AppCard(
            tone: CardTone.raised,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in sale.items)
                  StatRow(label: '${item.qty} × ${item.name}', value: formatPeso(item.lineTotal)),
                const Divider(height: AppSpace.xl),
                StatRow(label: s.total, value: formatPeso(sale.total), emphasize: true),
                if (isUtang) ...[
                  StatRow(label: s.paymentMethod, value: s.paymentUtang),
                  StatRow(label: s.customer, value: sale.customerName ?? ''),
                ] else ...[
                  StatRow(label: s.cashReceived, value: formatPeso(sale.amountPaid)),
                  StatRow(label: s.changeLabel, value: formatPeso(sale.change), emphasize: true),
                  if (sale.customerName != null) StatRow(label: s.customer, value: sale.customerName!),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: PillButton(
          label: s.newSale,
          icon: Icons.add_rounded,
          expand: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
