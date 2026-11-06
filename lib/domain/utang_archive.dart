// Which paid-up customers still show in the utang archive. Pure and unit
// tested. Dates here are Manila wall clock (see ManilaTime).

import 'dart:math';

import '../data/models/customer.dart';

/// One calendar month after [archived], at the same time of day. A day the
/// next month does not have falls on its last day: 31 Jan becomes 28 Feb.
DateTime archiveRemovalDate(DateTime archived) {
  final lastDayOfNextMonth = DateTime.utc(archived.year, archived.month + 2, 0).day;
  return DateTime.utc(
    archived.year,
    archived.month + 1,
    min(archived.day, lastDayOfNextMonth),
    archived.hour,
    archived.minute,
    archived.second,
  );
}

/// A customer stays listed for a month after archiving. One whose balance
/// is not zero stays until it is settled, so no money goes out of sight.
bool isShownInArchive(Customer customer, DateTime manilaNow, DateTime? archivedManila) {
  if (!customer.archived || customer.removed) return false;
  if (customer.balance != 0 || archivedManila == null) return true;
  return manilaNow.isBefore(archiveRemovalDate(archivedManila));
}
