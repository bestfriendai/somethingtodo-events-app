/// Exception types for RapidAPI service errors
enum RapidAPIErrorType {
  /// Network connection error
  networkError,

  /// Request timeout
  timeout,

  /// Authentication failed (401/403)
  authenticationError,

  /// Rate limit exceeded (429)
  rateLimitExceeded,

  /// Server error (5xx)
  serverError,

  /// Circuit breaker is open
  circuitBreakerOpen,

  /// Maximum retries exceeded
  maxRetriesExceeded,

  /// API response parsing error
  parsingError,

  /// Unknown error
  unknown,
}

/// Custom exception for RapidAPI service errors
class RapidAPIException implements Exception {
  final String message;
  final RapidAPIErrorType type;
  final dynamic originalError;
  final DateTime timestamp;

  RapidAPIException(this.message, {required this.type, this.originalError})
    : timestamp = DateTime.now();

  RapidAPIException.withTimestamp(
    this.message, {
    required this.type,
    this.originalError,
  }) : timestamp = DateTime.now();

  /// Get user-friendly error message
  String get userFriendlyMessage {
    switch (type) {
      case RapidAPIErrorType.networkError:
        return 'Unable to connect to the internet. Please check your connection and try again.';
      case RapidAPIErrorType.timeout:
        return 'Request timed out. Please try again.';
      case RapidAPIErrorType.authenticationError:
        return 'Authentication failed. Please contact support.';
      case RapidAPIErrorType.rateLimitExceeded:
        return 'Too many requests. Please wait a moment and try again.';
      case RapidAPIErrorType.serverError:
        return 'Server is temporarily unavailable. Please try again later.';
      case RapidAPIErrorType.circuitBreakerOpen:
        return 'Service is temporarily unavailable. Please try again in a few minutes.';
      case RapidAPIErrorType.maxRetriesExceeded:
        return 'Unable to complete request after multiple attempts. Please try again later.';
      case RapidAPIErrorType.parsingError:
        return 'Unable to process server response. Please try again.';
      case RapidAPIErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get recovery action suggestion
  String get recoveryAction {
    switch (type) {
      case RapidAPIErrorType.networkError:
        return 'Check your internet connection';
      case RapidAPIErrorType.timeout:
        return 'Try again with a better connection';
      case RapidAPIErrorType.authenticationError:
        return 'Contact support';
      case RapidAPIErrorType.rateLimitExceeded:
        return 'Wait a few minutes before trying again';
      case RapidAPIErrorType.serverError:
        return 'Try again in a few minutes';
      case RapidAPIErrorType.circuitBreakerOpen:
        return 'Service will recover automatically';
      case RapidAPIErrorType.maxRetriesExceeded:
        return 'Check your connection and try again';
      case RapidAPIErrorType.parsingError:
        return 'Try again or contact support if the issue persists';
      case RapidAPIErrorType.unknown:
        return 'Try again or contact support if the issue persists';
    }
  }

  /// Check if error is recoverable
  bool get isRecoverable {
    switch (type) {
      case RapidAPIErrorType.networkError:
      case RapidAPIErrorType.timeout:
      case RapidAPIErrorType.rateLimitExceeded:
      case RapidAPIErrorType.serverError:
      case RapidAPIErrorType.circuitBreakerOpen:
      case RapidAPIErrorType.maxRetriesExceeded:
        return true;
      case RapidAPIErrorType.authenticationError:
      case RapidAPIErrorType.parsingError:
      case RapidAPIErrorType.unknown:
        return false;
    }
  }

  /// Check if error should trigger offline mode
  bool get shouldTriggerOfflineMode {
    switch (type) {
      case RapidAPIErrorType.networkError:
      case RapidAPIErrorType.timeout:
      case RapidAPIErrorType.circuitBreakerOpen:
        return true;
      default:
        return false;
    }
  }

  @override
  String toString() {
    return 'RapidAPIException: $message (Type: $type)';
  }

  /// Convert to map for logging/analytics
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRecoverable': isRecoverable,
      'shouldTriggerOfflineMode': shouldTriggerOfflineMode,
      'originalError': originalError?.toString(),
    };
  }
}
