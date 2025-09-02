import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'rapidapi_exception.dart';
import 'logging_service.dart';
import 'cache_service.dart';

/// Comprehensive error handling service with offline mode and user-friendly messages
class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  // Connectivity monitoring
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = true;
  bool _offlineModeEnabled = false;
  
  // Error tracking
  final Map<String, int> _errorCounts = {};
  final Map<String, DateTime> _lastErrorTimes = {};
  
  // Configuration
  static const int _maxErrorsPerMinute = 10;
  static const Duration _errorCountWindow = Duration(minutes: 1);
  
  /// Initialize error handling service
  Future<void> initialize() async {
    await _initializeConnectivityMonitoring();
    LoggingService.info('Error handling service initialized', tag: 'ErrorHandling');
  }
  
  /// Initialize connectivity monitoring
  Future<void> _initializeConnectivityMonitoring() async {
    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    
    // Listen to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;
        
        if (wasOnline != _isOnline) {
          LoggingService.info(
            'Connectivity changed: ${_isOnline ? "online" : "offline"}',
            tag: 'ErrorHandling',
          );
          
          if (!_isOnline) {
            _enableOfflineMode();
          } else {
            _disableOfflineMode();
          }
        }
      },
    );
  }
  
  /// Enable offline mode
  void _enableOfflineMode() {
    _offlineModeEnabled = true;
    LoggingService.info('Offline mode enabled', tag: 'ErrorHandling');
  }
  
  /// Disable offline mode
  void _disableOfflineMode() {
    _offlineModeEnabled = false;
    LoggingService.info('Offline mode disabled', tag: 'ErrorHandling');
  }
  
  /// Handle errors with comprehensive categorization and recovery
  Future<ErrorHandlingResult> handleError(
    dynamic error, {
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    final errorKey = _getErrorKey(error, context);
    _trackError(errorKey);
    
    // Check if we're getting too many errors
    if (_isErrorRateLimited(errorKey)) {
      LoggingService.warning(
        'Error rate limit exceeded for $errorKey',
        tag: 'ErrorHandling',
      );
      return ErrorHandlingResult(
        type: ErrorType.rateLimited,
        userMessage: 'Too many errors occurred. Please wait a moment and try again.',
        shouldRetry: false,
        shouldEnableOfflineMode: true,
      );
    }
    
    // Handle specific error types
    if (error is RapidAPIException) {
      return _handleRapidAPIError(error);
    } else if (error is TimeoutException) {
      return _handleTimeoutError(error);
    } else if (error is FormatException) {
      return _handleFormatError(error);
    } else {
      return _handleGenericError(error, context);
    }
  }
  
  /// Handle RapidAPI specific errors
  ErrorHandlingResult _handleRapidAPIError(RapidAPIException error) {
    LoggingService.error(
      'RapidAPI error: ${error.message}',
      error: error,
      tag: 'ErrorHandling',
    );
    
    return ErrorHandlingResult(
      type: _mapRapidAPIErrorType(error.type),
      userMessage: error.userFriendlyMessage,
      technicalMessage: error.message,
      shouldRetry: error.isRecoverable,
      shouldEnableOfflineMode: error.shouldTriggerOfflineMode,
      recoveryAction: error.recoveryAction,
      originalError: error,
    );
  }
  
  /// Handle timeout errors
  ErrorHandlingResult _handleTimeoutError(TimeoutException error) {
    LoggingService.error(
      'Timeout error: ${error.message}',
      error: error,
      tag: 'ErrorHandling',
    );
    
    return ErrorHandlingResult(
      type: ErrorType.timeout,
      userMessage: 'Request timed out. Please check your connection and try again.',
      technicalMessage: error.message ?? 'Request timeout',
      shouldRetry: true,
      shouldEnableOfflineMode: !_isOnline,
      recoveryAction: 'Check your internet connection',
      originalError: error,
    );
  }
  
  /// Handle format/parsing errors
  ErrorHandlingResult _handleFormatError(FormatException error) {
    LoggingService.error(
      'Format error: ${error.message}',
      error: error,
      tag: 'ErrorHandling',
    );
    
    return ErrorHandlingResult(
      type: ErrorType.parsing,
      userMessage: 'Unable to process server response. Please try again.',
      technicalMessage: error.message,
      shouldRetry: false,
      shouldEnableOfflineMode: false,
      recoveryAction: 'Try again or contact support if the issue persists',
      originalError: error,
    );
  }
  
  /// Handle generic errors
  ErrorHandlingResult _handleGenericError(dynamic error, String? context) {
    final errorMessage = error.toString();
    LoggingService.error(
      'Generic error${context != null ? " in $context" : ""}: $errorMessage',
      error: error,
      tag: 'ErrorHandling',
    );
    
    return ErrorHandlingResult(
      type: ErrorType.unknown,
      userMessage: 'An unexpected error occurred. Please try again.',
      technicalMessage: errorMessage,
      shouldRetry: true,
      shouldEnableOfflineMode: false,
      recoveryAction: 'Try again or restart the app if the issue persists',
      originalError: error,
    );
  }
  
  /// Get cached data as fallback
  Future<T?> getCachedFallback<T>(String cacheKey) async {
    if (!_offlineModeEnabled) return null;
    
    try {
      final cachedData = await CacheService.instance.get<T>(cacheKey);
      if (cachedData != null) {
        LoggingService.info('Using cached fallback for $cacheKey', tag: 'ErrorHandling');
      }
      return cachedData;
    } catch (e) {
      LoggingService.error('Failed to get cached fallback', error: e, tag: 'ErrorHandling');
      return null;
    }
  }
  
  /// Check if offline mode should be enabled
  bool shouldEnableOfflineMode(ErrorHandlingResult result) {
    return result.shouldEnableOfflineMode || !_isOnline;
  }
  
  /// Get error key for tracking
  String _getErrorKey(dynamic error, String? context) {
    final errorType = error.runtimeType.toString();
    return context != null ? '${context}_$errorType' : errorType;
  }
  
  /// Track error occurrence
  void _trackError(String errorKey) {
    final now = DateTime.now();
    _errorCounts[errorKey] = (_errorCounts[errorKey] ?? 0) + 1;
    _lastErrorTimes[errorKey] = now;
    
    // Clean up old error counts
    _cleanupOldErrors();
  }
  
  /// Check if error is rate limited
  bool _isErrorRateLimited(String errorKey) {
    final count = _errorCounts[errorKey] ?? 0;
    final lastTime = _lastErrorTimes[errorKey];
    
    if (lastTime == null) return false;
    
    final timeSinceLastError = DateTime.now().difference(lastTime);
    return count >= _maxErrorsPerMinute && timeSinceLastError < _errorCountWindow;
  }
  
  /// Clean up old error tracking data
  void _cleanupOldErrors() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _lastErrorTimes.entries) {
      if (now.difference(entry.value) > _errorCountWindow) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _errorCounts.remove(key);
      _lastErrorTimes.remove(key);
    }
  }
  
  /// Map RapidAPI error types to generic error types
  ErrorType _mapRapidAPIErrorType(RapidAPIErrorType rapidApiType) {
    switch (rapidApiType) {
      case RapidAPIErrorType.networkError:
        return ErrorType.network;
      case RapidAPIErrorType.timeout:
        return ErrorType.timeout;
      case RapidAPIErrorType.authenticationError:
        return ErrorType.authentication;
      case RapidAPIErrorType.rateLimitExceeded:
        return ErrorType.rateLimited;
      case RapidAPIErrorType.serverError:
        return ErrorType.server;
      case RapidAPIErrorType.circuitBreakerOpen:
        return ErrorType.serviceUnavailable;
      case RapidAPIErrorType.maxRetriesExceeded:
        return ErrorType.maxRetriesExceeded;
      case RapidAPIErrorType.parsingError:
        return ErrorType.parsing;
      case RapidAPIErrorType.unknown:
        return ErrorType.unknown;
    }
  }
  
  /// Get current connectivity status
  bool get isOnline => _isOnline;
  
  /// Get offline mode status
  bool get isOfflineModeEnabled => _offlineModeEnabled;
  
  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _errorCounts.clear();
    _lastErrorTimes.clear();
  }
}

/// Error handling result
class ErrorHandlingResult {
  final ErrorType type;
  final String userMessage;
  final String? technicalMessage;
  final bool shouldRetry;
  final bool shouldEnableOfflineMode;
  final String? recoveryAction;
  final dynamic originalError;

  const ErrorHandlingResult({
    required this.type,
    required this.userMessage,
    this.technicalMessage,
    required this.shouldRetry,
    required this.shouldEnableOfflineMode,
    this.recoveryAction,
    this.originalError,
  });
}

/// Generic error types
enum ErrorType {
  network,
  timeout,
  authentication,
  rateLimited,
  server,
  serviceUnavailable,
  maxRetriesExceeded,
  parsing,
  unknown,
}
