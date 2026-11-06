import 'package:flutter_test/flutter_test.dart';
import 'package:tindahan_pos/data/models/customer.dart';
import 'package:tindahan_pos/domain/utang_archive.dart';

Customer customer({bool archived = true, bool removed = false, int balance = 0}) =>
    Customer(id: 'c1', name: 'Suki', balance: balance, archived: archived, removed: removed);

void main() {
  group('archiveRemovalDate', () {
    test('is the same date and time next month', () {
      expect(archiveRemovalDate(DateTime.utc(2026, 11, 6, 20, 42, 5)), DateTime.utc(2026, 12, 6, 20, 42, 5));
    });

    test('crosses the year', () {
      expect(archiveRemovalDate(DateTime.utc(2026, 12, 15)), DateTime.utc(2027, 1, 15));
    });

    test('falls on the last day of a shorter month', () {
      expect(archiveRemovalDate(DateTime.utc(2026, 1, 31)), DateTime.utc(2026, 2, 28));
      expect(archiveRemovalDate(DateTime.utc(2028, 1, 31)), DateTime.utc(2028, 2, 29));
      expect(archiveRemovalDate(DateTime.utc(2026, 10, 31)), DateTime.utc(2026, 11, 30));
    });
  });

  group('isShownInArchive', () {
    final archived = DateTime.utc(2026, 11, 6, 12);

    test('shows until the exact removal moment', () {
      final justBefore = DateTime.utc(2026, 12, 6, 11, 59, 59);
      final exactly = DateTime.utc(2026, 12, 6, 12);
      expect(isShownInArchive(customer(), justBefore, archived), isTrue);
      expect(isShownInArchive(customer(), exactly, archived), isFalse);
    });

    test('ignores active and removed customers', () {
      expect(isShownInArchive(customer(archived: false), archived, archived), isFalse);
      expect(isShownInArchive(customer(removed: true), archived, archived), isFalse);
    });

    test('keeps a customer with a balance past the month', () {
      final later = DateTime.utc(2027, 3, 1);
      expect(isShownInArchive(customer(balance: -1500), later, archived), isTrue);
    });

    test('shows a customer whose archive date has not synced yet', () {
      expect(isShownInArchive(customer(), DateTime.utc(2027, 3, 1), null), isTrue);
    });
  });
}
