import 'package:flutter/material.dart';

import '../../../core/l10n/language.dart';
import '../../../core/manila_time.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/customer.dart';
import '../../../data/store_session.dart';
import '../../../domain/utang_archive.dart';
import '../../scopes.dart';
import '../../widgets/cards.dart';
import '../../widgets/states.dart';
import 'customer_detail_screen.dart';

/// Customers still shown in the archive, most recently paid first.
List<Customer> archivedCustomers(StoreSession session) {
  final now = ManilaTime.now();
  DateTime? archivedOn(Customer customer) {
    final at = customer.archivedAt;
    return at == null ? null : ManilaTime.toManila(at);
  }

  return (session.customers.value ?? const <Customer>[])
      .where((customer) => isShownInArchive(customer, now, archivedOn(customer)))
      .toList()
    ..sort((a, b) {
      final first = a.archivedAt;
      final second = b.archivedAt;
      if (first == null || second == null) return first == null ? -1 : 1;
      return second.compareTo(first);
    });
}

/// Paid-up customers, kept for a month with their history.
class UtangArchiveScreen extends StatelessWidget {
  const UtangArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final session = StoreScope.of(context);
    return ListenableBuilder(
      listenable: session.customers,
      builder: (context, _) {
        final error = session.customers.error;
        final customers = archivedCustomers(session);
        return Scaffold(
          appBar: AppBar(title: Text(s.utangArchiveTitle)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, AppSpace.xl),
            children: [
              InlineNotice(message: s.utangArchiveCaption),
              const SizedBox(height: AppSpace.lg),
              if (error != null)
                ErrorCard(error: error, onRetry: session.customers.retry)
              else if (session.customers.isLoading)
                const LoadingBlocks()
              else if (customers.isEmpty)
                EmptyState(icon: Icons.inventory_2_outlined, message: s.noArchivedCustomers)
              else
                ListCard(
                  children: [
                    for (final customer in customers)
                      ListRow(
                        leading: InitialsAvatar(name: customer.name),
                        title: customer.name,
                        subtitle: _dates(context, customer),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CustomerDetailScreen(customerId: customer.id),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  String? _dates(BuildContext context, Customer customer) {
    final at = customer.archivedAt;
    if (at == null) return null;
    final s = context.s;
    final archived = ManilaTime.toManila(at);
    return s.archiveDates(
      ManilaTime.formatDate(archived, s),
      ManilaTime.formatDate(archiveRemovalDate(archived), s),
    );
  }
}
