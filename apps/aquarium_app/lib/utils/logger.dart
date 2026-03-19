import 'package:flutter/foundation.dart';

/// Centralized logging that respects build mode.
/// In release/profile mode, all log calls are no-ops.
void appLog(Object? message, {String? tag}) {
  if (kDebugMode) {
    if (tag != null) {
      debugPrint('[$tag] $message');
    } else {
      debugPrint(message?.toString());
    }
  }
}

void logError(Object? error, {Object? stackTrace, String? tag}) {
  if (kDebugMode) {
    if (tag != null) {
      debugPrint('[$tag] ERROR: $error');
    } else {
      debugPrint('ERROR: $error');
    }
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
