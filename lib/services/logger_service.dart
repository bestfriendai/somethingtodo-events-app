import 'package:flutter/foundation.dart';

/// Production-ready logging service
///
/// Replaces debug print statements with proper logging levels
/// that can be disabled in production builds
class Logger {
  static const String _tag = 'SomethingToDo';

  /// Log debug messages (only in debug mode)
  static void debug(String message, [dynamic error]) {
    if (kDebugMode) {
      debugPrint('[$_tag] DEBUG: $message');
      if (error != null) {
        debugPrint('[$_tag] ERROR: $error');
      }
    }
  }

  /// Log info messages
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] INFO: $message');
    }
  }

  /// Log warning messages
  static void warning(String message, [dynamic error]) {
    if (kDebugMode) {
      debugPrint('[$_tag] WARNING: $message');
      if (error != null) {
        debugPrint('[$_tag] ERROR: $error');
      }
    }
  }

  /// Log error messages
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // In production, this would send to crash reporting
    if (kDebugMode) {
      debugPrint('[$_tag] ERROR: $message');
      if (error != null) {
        debugPrint('[$_tag] ERROR DETAILS: $error');
      }
      if (stackTrace != null) {
        debugPrint('[$_tag] STACK TRACE: $stackTrace');
      }
    } else {
      // In production, send to crash reporting service
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }

  /// Log network requests (only in debug mode)
  static void network(String method, String url, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('[$_tag] NETWORK: $method $url');
      if (data != null) {
        debugPrint('[$_tag] DATA: $data');
      }
    }
  }

  /// Log analytics events
  static void analytics(String event, [Map<String, dynamic>? parameters]) {
    if (kDebugMode) {
      debugPrint('[$_tag] ANALYTICS: $event');
      if (parameters != null) {
        debugPrint('[$_tag] PARAMS: $parameters');
      }
    }
  }

  /// Log performance metrics
  static void performance(String metric, Duration duration) {
    if (kDebugMode) {
      debugPrint(
        '[$_tag] PERFORMANCE: $metric took ${duration.inMilliseconds}ms',
      );
    }
  }
}
