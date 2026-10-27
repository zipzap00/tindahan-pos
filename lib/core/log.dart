import 'dart:developer' as developer;

// Logs use a context prefix in brackets and never include personal data
// (names, phone numbers, emails). Log IDs and error codes only.

void logInfo(String context, String message) {
  developer.log('$context $message', name: 'tindahan');
}

void logError(String context, Object error, [StackTrace? stackTrace]) {
  developer.log(context, name: 'tindahan', error: error, stackTrace: stackTrace, level: 1000);
}
