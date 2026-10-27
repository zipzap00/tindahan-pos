import 'package:flutter_test/flutter_test.dart';
import 'package:tindahan_pos/core/l10n/strings_en.dart';
import 'package:tindahan_pos/core/l10n/strings_fil.dart';
import 'package:tindahan_pos/core/manila_time.dart';
import 'package:tindahan_pos/core/money.dart';

void main() {
  group('formatPeso', () {
    test('formats centavos with grouping and two decimals', () {
      expect(formatPeso(0), '₱0.00');
      expect(formatPeso(1200), '₱12.00');
      expect(formatPeso(123450), '₱1,234.50');
      expect(formatPeso(123456789), '₱1,234,567.89');
    });

    test('rounds fractional centavos and marks negatives', () {
      expect(formatPeso(833.33), '₱8.33');
      expect(formatPeso(-1250), '−₱12.50');
      expect(formatPeso(500, showSign: true), '+₱5.00');
    });

    test('compact form drops .00', () {
      expect(formatPesoCompact(2000), '₱20');
      expect(formatPesoCompact(2050), '₱20.50');
      expect(formatPesoCompact(100000), '₱1,000');
    });
  });

  group('parsePesoToCents', () {
    test('parses whole and decimal amounts', () {
      expect(parsePesoToCents('12'), 1200);
      expect(parsePesoToCents('12.5'), 1250);
      expect(parsePesoToCents('12.05'), 1205);
      expect(parsePesoToCents('1,250.75'), 125075);
      expect(parsePesoToCents('₱ 10'), 1000);
    });

    test('rejects empty and invalid text', () {
      expect(parsePesoToCents(''), isNull);
      expect(parsePesoToCents('abc'), isNull);
      expect(parsePesoToCents('1.234'), isNull);
      expect(parsePesoToCents('-5'), isNull);
    });

    test('round-trips through the input text helper', () {
      expect(centsToInputText(1200), '12');
      expect(centsToInputText(1205), '12.05');
      expect(parsePesoToCents(centsToInputText(98765)), 98765);
    });
  });

  group('ManilaTime', () {
    test('converts UTC instants to Philippine wall clock (UTC+8)', () {
      final manila = ManilaTime.toManila(DateTime.utc(2026, 10, 27, 17, 30));
      expect(manila.day, 28);
      expect(manila.hour, 1);
      expect(ManilaTime.dayKey(manila), '2026-10-28');
    });

    test('day, month and week keys', () {
      final manila = DateTime.utc(2026, 10, 27, 15, 5); // Tuesday
      expect(ManilaTime.dayKey(manila), '2026-10-27');
      expect(ManilaTime.monthKey(manila), '2026-10');
      expect(ManilaTime.dayKey(ManilaTime.startOfWeek(manila)), '2026-10-26');
      expect(ManilaTime.dayKey(ManilaTime.startOfMonth(manila)), '2026-10-01');
    });

    test('week starts on Monday even on a Sunday', () {
      final sunday = DateTime.utc(2026, 11, 1, 9);
      expect(ManilaTime.dayKey(ManilaTime.startOfWeek(sunday)), '2026-10-26');
    });

    test('formats dates and times in both languages', () {
      final manila = DateTime.utc(2026, 10, 27, 15, 5);
      expect(ManilaTime.formatTime(manila), '3:05 PM');
      expect(ManilaTime.formatTime(DateTime.utc(2026, 10, 27, 0, 0)), '12:00 AM');
      expect(ManilaTime.formatDate(manila, const FilStrings()), '27 Okt 2026');
      expect(ManilaTime.formatLongDate(manila, const EnStrings()), 'Tuesday, 27 Oct 2026');
      expect(ManilaTime.formatLongDate(manila, const FilStrings()), 'Martes, 27 Okt 2026');
    });

    test('receipt number encodes date and time', () {
      final manila = DateTime.utc(2026, 10, 27, 15, 30, 12);
      expect(ManilaTime.receiptNumber(manila, 'K7'), '261027-153012-K7');
    });

    test('now() follows the injectable clock', () {
      final saved = ManilaTime.clock;
      ManilaTime.clock = () => DateTime.utc(2026, 12, 31, 16, 30);
      expect(ManilaTime.todayKey(), '2027-01-01');
      ManilaTime.clock = saved;
    });
  });
}
