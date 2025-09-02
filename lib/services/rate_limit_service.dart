import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:dio/dio.dart';
import 'logging_service.dart';

/// Advanced rate limiting service with request queuing, 
/// exponential backoff, and intelligent throttling
class RateLimitService {
  static final RateLimitService _instance = RateLimitService._internal();
  factory RateLimitService() => _instance;
  RateLimitService._internal();

  // Rate limit configuration
  static const int _maxRequestsPerMinute = 30; // Conservative limit
  static const int _maxRequestsPerHour = 500;
  static const int _maxConcurrentRequests = 3;
  static const Duration _requestWindow = Duration(minutes: 1);
  static const Duration _hourlyWindow = Duration(hours: 1);
  
  // Request tracking
  final Queue<DateTime> _requestTimestamps = Queue<DateTime>();
  final Queue<DateTime> _hourlyTimestamps = Queue<DateTime>();
  final Queue<_QueuedRequest> _requestQueue = Queue<_QueuedRequest>();
  final Set<String> _inFlightRequests = {};
  
  // Rate limit state
  bool _isRateLimited = false;
  DateTime? _rateLimitResetTime;
  int _consecutiveRateLimitHits = 0;
  
  // Backoff configuration
  static const Duration _minBackoff = Duration(milliseconds: 500);
  static const Duration _maxBackoff = Duration(minutes: 5);
  static const double _backoffMultiplier = 2.0;
  static const double _jitterFactor = 0.3;
  
  // Request prioritization
  final Map<String, int> _endpointPriorities = {
    '/search-events': 1,
    '/event-details': 2,
    '/trending-events': 3,
  };
  
  // Statistics
  int _totalRequests = 0;
  int _rateLimitHits = 0;
  int _queuedRequests = 0;
  DateTime _startTime = DateTime.now();
  
  Timer? _queueProcessor;
  
  /// Initialize the rate limit service
  void initialize() {
    _startQueueProcessor();
    LoggingService.info('Rate limit service initialized', tag: 'RateLimit');
  }
  
  /// Start the queue processor
  void _startQueueProcessor() {
    _queueProcessor?.cancel();
    _queueProcessor = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _processQueue();
    });
  }
  
  /// Clean up old timestamps
  void _cleanupTimestamps() {
    final now = DateTime.now();
    
    // Clean minute window
    while (_requestTimestamps.isNotEmpty &&
           now.difference(_requestTimestamps.first) > _requestWindow) {
      _requestTimestamps.removeFirst();
    }
    
    // Clean hourly window
    while (_hourlyTimestamps.isNotEmpty &&
           now.difference(_hourlyTimestamps.first) > _hourlyWindow) {
      _hourlyTimestamps.removeFirst();
    }
  }
  
  /// Check if we can make a request
  bool _canMakeRequest() {
    _cleanupTimestamps();
    
    // Check if we're in a rate limit cooldown
    if (_isRateLimited && _rateLimitResetTime != null) {
      if (DateTime.now().isBefore(_rateLimitResetTime!)) {
        return false;
      } else {
        _isRateLimited = false;
        _rateLimitResetTime = null;
        LoggingService.info('Rate limit cooldown expired', tag: 'RateLimit');
      }
    }
    
    // Check concurrent requests
    if (_inFlightRequests.length >= _maxConcurrentRequests) {
      return false;
    }
    
    // Check minute limit
    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      return false;
    }
    
    // Check hourly limit
    if (_hourlyTimestamps.length >= _maxRequestsPerHour) {
      return false;
    }
    
    return true;
  }
  
  /// Calculate backoff duration with jitter
  Duration _calculateBackoff(int attemptNumber) {
    if (attemptNumber <= 0) return _minBackoff;
    
    // Exponential backoff
    final exponentialMs = _minBackoff.inMilliseconds * 
                          pow(_backoffMultiplier, attemptNumber - 1);
    
    // Cap at maximum
    final cappedMs = min(exponentialMs, _maxBackoff.inMilliseconds);
    
    // Add jitter to prevent thundering herd
    final jitterMs = cappedMs * _jitterFactor * Random().nextDouble();
    final totalMs = cappedMs + jitterMs;
    
    return Duration(milliseconds: totalMs.toInt());
  }
  
  /// Execute a request with rate limiting
  Future<T> executeRequest<T>({
    required Future<T> Function() request,
    required String endpoint,
    String? requestId,
    int priority = 5,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    requestId ??= '${endpoint}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Get priority from endpoint mapping or use provided
    final effectivePriority = _endpointPriorities[endpoint] ?? priority;
    
    // Create queued request
    final queuedRequest = _QueuedRequest(
      id: requestId,
      endpoint: endpoint,
      priority: effectivePriority,
      request: request,
      maxRetries: maxRetries,
    );
    
    // Try immediate execution if possible
    if (_canMakeRequest()) {
      return await _executeRequestWithRetry(queuedRequest);
    }
    
    // Queue the request
    return await _queueRequest(queuedRequest);
  }
  
  /// Queue a request for later execution
  Future<T> _queueRequest<T>(_QueuedRequest request) async {
    _queuedRequests++;
    
    LoggingService.info(
      'Request queued: ${request.endpoint} (position: ${_requestQueue.length + 1})',
      tag: 'RateLimit',
    );
    
    // Add to priority queue (simple insertion sort for small queues)
    if (_requestQueue.isEmpty) {
      _requestQueue.add(request);
    } else {
      final tempList = _requestQueue.toList();
      tempList.add(request);
      tempList.sort((a, b) => a.priority.compareTo(b.priority));
      _requestQueue.clear();
      _requestQueue.addAll(tempList);
    }
    
    // Wait for execution
    return await request.completer.future as T;
  }
  
  /// Process the request queue
  void _processQueue() {
    if (_requestQueue.isEmpty || !_canMakeRequest()) {
      return;
    }
    
    final request = _requestQueue.removeFirst();
    _executeRequestWithRetry(request);
  }
  
  /// Execute a request with retry logic
  Future<dynamic> _executeRequestWithRetry(_QueuedRequest queuedRequest) async {
    for (int attempt = 0; attempt <= queuedRequest.maxRetries; attempt++) {
      try {
        // Mark request as in-flight
        _inFlightRequests.add(queuedRequest.id);
        
        // Record timestamps
        final now = DateTime.now();
        _requestTimestamps.add(now);
        _hourlyTimestamps.add(now);
        _totalRequests++;
        
        LoggingService.info(
          'Executing request: ${queuedRequest.endpoint} (attempt ${attempt + 1}/${queuedRequest.maxRetries + 1})',
          tag: 'RateLimit',
        );
        
        // Execute the actual request
        final result = await queuedRequest.request();
        
        // Success - reset consecutive rate limit counter
        if (_consecutiveRateLimitHits > 0) {
          _consecutiveRateLimitHits = 0;
          LoggingService.info('Rate limit pressure relieved', tag: 'RateLimit');
        }
        
        // Complete the request
        if (!queuedRequest.completer.isCompleted) {
          queuedRequest.completer.complete(result);
        }
        
        return result;
        
      } on DioException catch (e) {
        // Handle rate limit error
        if (e.response?.statusCode == 429) {
          _handleRateLimitError(e.response);
          
          if (attempt < queuedRequest.maxRetries) {
            final backoff = _calculateBackoff(_consecutiveRateLimitHits);
            LoggingService.warning(
              'Rate limit hit, backing off for ${backoff.inMilliseconds}ms',
              tag: 'RateLimit',
            );
            await Future.delayed(backoff);
            continue;
          }
        }
        
        // Other errors - retry with backoff
        if (attempt < queuedRequest.maxRetries) {
          final backoff = _calculateBackoff(attempt);
          LoggingService.warning(
            'Request failed, retrying after ${backoff.inMilliseconds}ms',
            tag: 'RateLimit',
          );
          await Future.delayed(backoff);
          continue;
        }
        
        // Max retries exceeded
        if (!queuedRequest.completer.isCompleted) {
          queuedRequest.completer.completeError(e);
        }
        rethrow;
        
      } catch (e) {
        // Non-Dio errors
        if (attempt < queuedRequest.maxRetries) {
          final backoff = _calculateBackoff(attempt);
          await Future.delayed(backoff);
          continue;
        }
        
        if (!queuedRequest.completer.isCompleted) {
          queuedRequest.completer.completeError(e);
        }
        rethrow;
        
      } finally {
        // Remove from in-flight set
        _inFlightRequests.remove(queuedRequest.id);
      }
    }
    
    // Should not reach here
    final error = Exception('Max retries exceeded for ${queuedRequest.endpoint}');
    if (!queuedRequest.completer.isCompleted) {
      queuedRequest.completer.completeError(error);
    }
    throw error;
  }
  
  /// Handle rate limit error response
  void _handleRateLimitError(Response? response) {
    _rateLimitHits++;
    _consecutiveRateLimitHits++;
    _isRateLimited = true;
    
    // Try to parse reset time from headers
    final resetHeader = response?.headers.value('x-ratelimit-reset');
    final retryAfter = response?.headers.value('retry-after');
    
    if (resetHeader != null) {
      try {
        final resetTimestamp = int.parse(resetHeader);
        _rateLimitResetTime = DateTime.fromMillisecondsSinceEpoch(resetTimestamp * 1000);
      } catch (_) {
        // Fallback to exponential backoff
        _rateLimitResetTime = DateTime.now().add(
          _calculateBackoff(_consecutiveRateLimitHits),
        );
      }
    } else if (retryAfter != null) {
      try {
        final retrySeconds = int.parse(retryAfter);
        _rateLimitResetTime = DateTime.now().add(Duration(seconds: retrySeconds));
      } catch (_) {
        _rateLimitResetTime = DateTime.now().add(
          _calculateBackoff(_consecutiveRateLimitHits),
        );
      }
    } else {
      // No headers - use exponential backoff
      _rateLimitResetTime = DateTime.now().add(
        _calculateBackoff(_consecutiveRateLimitHits),
      );
    }
    
    LoggingService.error(
      'Rate limit hit! Reset at: ${_rateLimitResetTime?.toIso8601String()}',
      tag: 'RateLimit',
    );
  }
  
  /// Get current rate limit status
  Map<String, dynamic> getStatus() {
    _cleanupTimestamps();
    
    final runtime = DateTime.now().difference(_startTime);
    final requestsPerMinute = _requestTimestamps.length;
    final requestsPerHour = _hourlyTimestamps.length;
    
    return {
      'isRateLimited': _isRateLimited,
      'rateLimitResetTime': _rateLimitResetTime?.toIso8601String(),
      'requestsPerMinute': requestsPerMinute,
      'requestsPerHour': requestsPerHour,
      'maxRequestsPerMinute': _maxRequestsPerMinute,
      'maxRequestsPerHour': _maxRequestsPerHour,
      'queueLength': _requestQueue.length,
      'inFlightRequests': _inFlightRequests.length,
      'totalRequests': _totalRequests,
      'rateLimitHits': _rateLimitHits,
      'queuedRequests': _queuedRequests,
      'runtime': runtime.toString(),
      'averageRequestsPerMinute': runtime.inMinutes > 0 
          ? (_totalRequests / runtime.inMinutes).toStringAsFixed(2)
          : '0',
    };
  }
  
  /// Reset rate limit state (useful for testing)
  void reset() {
    _requestTimestamps.clear();
    _hourlyTimestamps.clear();
    _requestQueue.clear();
    _inFlightRequests.clear();
    _isRateLimited = false;
    _rateLimitResetTime = null;
    _consecutiveRateLimitHits = 0;
    _totalRequests = 0;
    _rateLimitHits = 0;
    _queuedRequests = 0;
    _startTime = DateTime.now();
    
    LoggingService.info('Rate limit service reset', tag: 'RateLimit');
  }
  
  /// Dispose of resources
  void dispose() {
    _queueProcessor?.cancel();
    _queueProcessor = null;
    
    // Complete any pending requests with cancellation
    for (final request in _requestQueue) {
      if (!request.completer.isCompleted) {
        request.completer.completeError(
          Exception('Rate limit service disposed'),
        );
      }
    }
    _requestQueue.clear();
  }
}

/// Represents a queued request
class _QueuedRequest {
  final String id;
  final String endpoint;
  final int priority;
  final Future<dynamic> Function() request;
  final int maxRetries;
  final Completer<dynamic> completer = Completer<dynamic>();
  
  _QueuedRequest({
    required this.id,
    required this.endpoint,
    required this.priority,
    required this.request,
    required this.maxRetries,
  });
}