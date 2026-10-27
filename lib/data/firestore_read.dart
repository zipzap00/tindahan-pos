// Defensive readers for Firestore maps. Documents written by older app
// versions or edited by hand in the console must never crash a screen.

import 'package:cloud_firestore/cloud_firestore.dart';

String readString(Object? value, [String fallback = '']) => value is String ? value : fallback;

String? readStringOrNull(Object? value) => value is String && value.isNotEmpty ? value : null;

int readInt(Object? value, [int fallback = 0]) => value is num ? value.round() : fallback;

double readDouble(Object? value, [double fallback = 0]) => value is num ? value.toDouble() : fallback;

bool readBool(Object? value, [bool fallback = false]) => value is bool ? value : fallback;

DateTime? readDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

Map<String, dynamic> readMap(Object? value) {
  if (value is Map<Object?, Object?>) {
    return value.map((key, v) => MapEntry<String, dynamic>(key.toString(), v));
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> readMapList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map<Object?, Object?>>().map(readMap).toList();
}
