// Philippine time (Asia/Manila) is UTC+8 all year, with no daylight saving,
// so a fixed offset is exact and no time-zone database is needed.
//
// "Manila wall clock" values below are DateTime objects in UTC whose fields
// (year, month, hour...) read as Manila local time. They are only used for
// keys and display, never sent back to Firestore as instants.

import 'l10n/strings.dart';

abstract final class ManilaTime {
  static const Duration offset = Duration(hours: 8);

  /// Override in tests to freeze "now".
  static DateTime Function() clock = DateTime.now;

  /// Current Manila wall clock.
  static DateTime now() => toManila(clock());

  /// Converts any instant to Manila wall clock.
  static DateTime toManila(DateTime instant) => instant.toUtc().add(offset);

  /// Start of a Manila day (wall clock, 00:00).
  static DateTime startOfDay(DateTime manila) =>
      DateTime.utc(manila.year, manila.month, manila.day);

  /// Monday of the week containing [manila] (weeks start on Monday).
  static DateTime startOfWeek(DateTime manila) {
    final day = startOfDay(manila);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static DateTime startOfMonth(DateTime manila) => DateTime.utc(manila.year, manila.month);

  /// "2026-10-27". Sorts correctly as a string, so it is used for range queries.
  static String dayKey(DateTime manila) =>
      '${_four(manila.year)}-${_two(manila.month)}-${_two(manila.day)}';

  /// "2026-10".
  static String monthKey(DateTime manila) => '${_four(manila.year)}-${_two(manila.month)}';

  static String todayKey() => dayKey(now());

  /// Parses a day key back into a Manila wall-clock date.
  static DateTime fromDayKey(String key) {
    final parts = key.split('-');
    return DateTime.utc(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  /// "3:05 PM"
  static String formatTime(DateTime manila) {
    final hour12 = manila.hour % 12 == 0 ? 12 : manila.hour % 12;
    final period = manila.hour < 12 ? 'AM' : 'PM';
    return '$hour12:${_two(manila.minute)} $period';
  }

  /// "27 Okt 2026" / "27 Oct 2026"
  static String formatDate(DateTime manila, Strings s) =>
      '${manila.day} ${s.monthShort(manila.month)} ${manila.year}';

  /// "Martes, 27 Okt 2026"
  static String formatLongDate(DateTime manila, Strings s) =>
      '${s.weekdayName(manila.weekday)}, ${formatDate(manila, s)}';

  /// "27 Okt 2026, 3:05 PM"
  static String formatDateTime(DateTime manila, Strings s) =>
      '${formatDate(manila, s)}, ${formatTime(manila)}';

  /// Receipt number: "261027-153012-K7" (date, time, two random characters).
  static String receiptNumber(DateTime manila, String suffix) {
    final yy = _two(manila.year % 100);
    return '$yy${_two(manila.month)}${_two(manila.day)}-'
        '${_two(manila.hour)}${_two(manila.minute)}${_two(manila.second)}-$suffix';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
  static String _four(int value) => value.toString().padLeft(4, '0');
}
