// Money is stored in centavos. Selling prices and totals are whole centavos
// (int). Unit cost can be a fraction of a centavo (for example ₱100 for 12
// pieces is 833.33 centavos each), so cost values are doubles and are only
// rounded for display.

import 'package:flutter/services.dart';

const String pesoSign = '₱';

/// Formats centavos as Philippine pesos: 123450 -> "₱1,234.50".
String formatPeso(num centavos, {bool showSign = false}) {
  final rounded = centavos.round();
  final negative = rounded < 0;
  final abs = rounded.abs();
  final pesos = abs ~/ 100;
  final cents = abs % 100;
  final grouped = _groupThousands(pesos.toString());
  final body = '$pesoSign$grouped.${cents.toString().padLeft(2, '0')}';
  if (negative) return '−$body';
  if (showSign && rounded > 0) return '+$body';
  return body;
}

/// Short form for tight spaces: whole pesos when there are no centavos.
String formatPesoCompact(num centavos) {
  final rounded = centavos.round();
  if (rounded % 100 == 0) {
    final negative = rounded < 0;
    final body = '$pesoSign${_groupThousands((rounded.abs() ~/ 100).toString())}';
    return negative ? '−$body' : body;
  }
  return formatPeso(rounded);
}

String _groupThousands(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  return buffer.toString();
}

/// Parses a peso amount typed by the user ("12", "12.5", "1,250.75") into
/// centavos. Returns null when the text is empty or not a valid amount.
int? parsePesoToCents(String input) {
  final cleaned = input.replaceAll(',', '').replaceAll(pesoSign, '').trim();
  if (cleaned.isEmpty) return null;
  if (!RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(cleaned)) return null;
  final parts = cleaned.split('.');
  final whole = int.parse(parts[0]);
  var cents = 0;
  if (parts.length == 2 && parts[1].isNotEmpty) {
    cents = int.parse(parts[1].padRight(2, '0'));
  }
  return whole * 100 + cents;
}

/// Text for a peso input field from centavos: 1250 -> "12.50", 1200 -> "12".
String centsToInputText(num centavos) {
  final rounded = centavos.round();
  final pesos = rounded ~/ 100;
  final cents = rounded % 100;
  if (cents == 0) return pesos.toString();
  return '$pesos.${cents.toString().padLeft(2, '0')}';
}

/// Allows up to 7 whole-peso digits and 2 decimal places while typing.
class PesoInputFormatter extends TextInputFormatter {
  static final RegExp _pattern = RegExp(r'^\d{0,7}(\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty || _pattern.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}

/// Whole-number quantity input (pieces), up to 6 digits.
class QuantityInputFormatter extends TextInputFormatter {
  static final RegExp _pattern = RegExp(r'^\d{0,6}$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (_pattern.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}
