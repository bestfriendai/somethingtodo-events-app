import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logging service for the application
class LoggingService {
  static const String _tag = 'SomethingToDo';
  
  /// Log debug information
  static void debug(String message, {String? tag, Object? error}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? _tag,
        level: 500, // Debug level
        error: error,
      );
    }
  }
  
  /// Log informational messages
  static void info(String message, {String? tag, Object? error}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800, // Info level
      error: error,
    );
  }
  
  /// Log warning messages
  static void warning(String message, {String? tag, Object? error}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900, // Warning level
      error: error,
    );
  }
  
  /// Log error messages
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log API requests
  static void apiRequest(String method, String path, {String? tag}) {
    debug('🚀 API Request: $method $path', tag: tag ?? 'API');
  }
  
  /// Log API responses
  static void apiResponse(int statusCode, String path, {String? tag}) {
    debug('✅ API Response: $statusCode $path', tag: tag ?? 'API');
  }
  
  /// Log API errors
  static void apiError(int? statusCode, String path, {String? tag, Object? error}) {
    warning('❌ API Error: $statusCode $path', tag: tag ?? 'API', error: error);
  }
  
  /// Log circuit breaker events
  static void circuitBreakerReset({String? tag}) {
    info('🔄 Circuit breaker reset - service recovered', tag: tag ?? 'CircuitBreaker');
  }
  
  /// Log circuit breaker opening
  static void circuitBreakerOpen({String? tag}) {
    warning('🚫 Circuit breaker opened - service temporarily disabled', tag: tag ?? 'CircuitBreaker');
  }
  
  /// Log circuit breaker half-open state
  static void circuitBreakerHalfOpen({String? tag}) {
    info('🔄 Circuit breaker half-open - attempting recovery', tag: tag ?? 'CircuitBreaker');
  }
  
  /// Log retry attempts
  static void retryAttempt(int attempt, int maxRetries, String operation, int delayMs, {String? tag}) {
    debug('🔄 Retry $attempt/$maxRetries for $operation in ${delayMs}ms', tag: tag ?? 'Retry');
  }
  
  /// Log event retrieval progress
  static void eventRetrievalStart(int targetEvents, {String? tag}) {
    info('🔍 Starting enhanced event retrieval (target: $targetEvents events)', tag: tag ?? 'Events');
  }
  
  /// Log parallel request execution
  static void parallelRequestsStart(int requestCount, {String? tag}) {
    info('🚀 Executing $requestCount parallel requests...', tag: tag ?? 'Events');
  }
  
  /// Log event retrieval completion
  static void eventRetrievalComplete(int eventCount, int sourceCount, {String? tag}) {
    info('✅ Retrieved $eventCount unique events from $sourceCount sources', tag: tag ?? 'Events');
  }
  
  /// Log search failures
  static void searchFailed(String searchType, String details, {String? tag, Object? error}) {
    warning('⚠️ $searchType search failed: $details', tag: tag ?? 'Search', error: error);
  }
  
  /// Log timeout events
  static void timeout(String operation, {String? tag}) {
    warning('⏰ $operation timed out, using partial results', tag: tag ?? 'Timeout');
  }
}
