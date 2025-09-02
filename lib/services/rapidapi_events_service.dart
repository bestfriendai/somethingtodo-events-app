import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../config/api_config.dart';
import '../models/event.dart';
import 'rapidapi_exception.dart';
import 'logging_service.dart';
import 'rate_limit_service.dart';
import 'enhanced_cache_service.dart';
import 'demo_data_service.dart';

/// Enhanced RapidAPI Events Service with intelligent pagination,
/// circuit breaker pattern, and comprehensive error handling
class RapidAPIEventsService {
  late final Dio _dio;
  final RateLimitService _rateLimitService = RateLimitService();
  final EnhancedCacheService _cacheService = EnhancedCacheService();

  // Circuit breaker state
  bool _circuitBreakerOpen = false;
  DateTime? _lastFailureTime;
  int _failureCount = 0;
  static const int _maxFailures = 5;
  static const Duration _circuitBreakerTimeout = Duration(minutes: 5);

  // Rate limiting
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 100);

  // Request retry configuration
  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(milliseconds: 500);

  RapidAPIEventsService() {
    _dio = Dio();
    _rateLimitService.initialize();
    _cacheService.initialize();
    
    // Configure API
    _dio.options.baseUrl = ApiConfig.rapidApiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 20);
    _dio.options.receiveTimeout = const Duration(seconds: 20);
    
    // Get API key from configuration
    final apiKey = ApiConfig.apiKey;
    
    if (!ApiConfig.isApiConfigured || ApiConfig.useDemoMode) {
      LoggingService.warning('RapidAPI not configured or demo mode enabled. Using demo data.');
    }
    
    _dio.options.headers = {
      if (apiKey.isNotEmpty) 'X-RapidAPI-Key': apiKey,
      'X-RapidAPI-Host': ApiConfig.rapidApiHost,
      'Content-Type': 'application/json',
    };

    // Add request/response interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          LoggingService.apiRequest(options.method, options.path);
          handler.next(options);
        },
        onResponse: (response, handler) {
          LoggingService.apiResponse(
            response.statusCode ?? 0,
            response.requestOptions.path,
          );
          _onRequestSuccess();
          handler.next(response);
        },
        onError: (error, handler) {
          LoggingService.apiError(
            error.response?.statusCode,
            error.requestOptions.path,
            error: error,
          );
          _onRequestFailure();
          handler.next(error);
        },
      ),
    );
  }

  /// Circuit breaker success handler
  void _onRequestSuccess() {
    if (_failureCount > 0) {
      _failureCount = 0;
      _circuitBreakerOpen = false;
      _lastFailureTime = null;
      LoggingService.circuitBreakerReset();
    }
  }

  /// Circuit breaker failure handler
  void _onRequestFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= _maxFailures) {
      _circuitBreakerOpen = true;
      LoggingService.circuitBreakerOpen();
    }
  }

  /// Check if circuit breaker should be closed
  bool _shouldAttemptRequest() {
    if (!_circuitBreakerOpen) return true;

    if (_lastFailureTime != null &&
        DateTime.now().difference(_lastFailureTime!) > _circuitBreakerTimeout) {
      _circuitBreakerOpen = false;
      _failureCount = 0;
      LoggingService.circuitBreakerHalfOpen();
      return true;
    }

    return false;
  }

  /// Rate limiting helper
  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final waitTime = _minRequestInterval - timeSinceLastRequest;
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Enhanced request wrapper with retry logic and error handling
  Future<T> _makeRequest<T>(
    Future<T> Function() request, {
    String operation = 'API request',
  }) async {
    if (!_shouldAttemptRequest()) {
      throw RapidAPIException(
        'Service temporarily unavailable (circuit breaker open)',
        type: RapidAPIErrorType.circuitBreakerOpen,
      );
    }

    await _enforceRateLimit();

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        return await request();
      } catch (e) {
        if (attempt == _maxRetries) {
          throw _handleError(e, operation);
        }

        // Exponential backoff with jitter
        final delay = Duration(
          milliseconds:
              _baseRetryDelay.inMilliseconds * pow(2, attempt).toInt() +
              Random().nextInt(100),
        );

        LoggingService.retryAttempt(
          attempt,
          _maxRetries,
          operation,
          delay.inMilliseconds,
        );
        await Future.delayed(delay);
      }
    }

    throw RapidAPIException(
      'Max retries exceeded for $operation',
      type: RapidAPIErrorType.maxRetriesExceeded,
    );
  }

  /// Comprehensive error handling
  RapidAPIException _handleError(dynamic error, String operation) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return RapidAPIException(
            'Request timeout during $operation',
            type: RapidAPIErrorType.timeout,
            originalError: error,
          );
        case DioExceptionType.connectionError:
          return RapidAPIException(
            'Network connection error during $operation',
            type: RapidAPIErrorType.networkError,
            originalError: error,
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 429) {
            return RapidAPIException(
              'Rate limit exceeded',
              type: RapidAPIErrorType.rateLimitExceeded,
              originalError: error,
            );
          } else if (statusCode == 401 || statusCode == 403) {
            return RapidAPIException(
              'Authentication failed - check API key',
              type: RapidAPIErrorType.authenticationError,
              originalError: error,
            );
          } else if (statusCode != null && statusCode >= 500) {
            return RapidAPIException(
              'Server error during $operation',
              type: RapidAPIErrorType.serverError,
              originalError: error,
            );
          }
          break;
        default:
          break;
      }
    }

    return RapidAPIException(
      'Unknown error during $operation: ${error.toString()}',
      type: RapidAPIErrorType.unknown,
      originalError: error,
    );
  }

  Future<List<Event>> searchEvents({
    required String query,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    // Use demo data if API is not configured or demo mode is enabled
    if (!ApiConfig.isApiConfigured || ApiConfig.useDemoMode) {
      LoggingService.info('Using demo data for search', tag: 'API');
      return await DemoEventMethods.getDemoEvents(
        location: location ?? 'San Francisco',
        limit: limit,
      );
    }
    
    // Check cache first
    final cacheKey = 'search_${query}_${location}_${startDate}_${endDate}_$limit';
    final cached = await _cacheService.getCachedEvents(cacheKey);
    if (cached != null) {
      LoggingService.info('Cache hit for search: $query', tag: 'Cache');
      return cached;
    }
    
    return await _rateLimitService.executeRequest<List<Event>>(
      endpoint: '/search-events',
      priority: 1,
      request: () async {
        return await _makeRequest<List<Event>>(() async {
      final response = await _dio.get(
        '/search-events',
        queryParameters: {
          'query': query,
          if (location != null) 'location': location,
          if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
          if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Handle both direct array and wrapped response
        List<dynamic> eventsList = [];
        
        if (responseData is List) {
          // Direct array response
          eventsList = responseData;
        } else if (responseData is Map) {
          // Check for wrapped response formats
          if (responseData['data'] is List) {
            eventsList = responseData['data'] as List;
          } else if (responseData['events'] is List) {
            eventsList = responseData['events'] as List;
          } else if (responseData['results'] is List) {
            eventsList = responseData['results'] as List;
          }
        }
        
        if (eventsList.isNotEmpty) {
          try {
            final events = eventsList
                .map((e) => _parseEventFromAPI(Map<String, dynamic>.from(e as Map)))
                .where((event) => event != null)
                .toList();
            
            print('Parsed ${events.length} events from API response');
            return events;
          } catch (e) {
            print('Error parsing events: $e');
            throw RapidAPIException(
              'Failed to parse events data',
              type: RapidAPIErrorType.parsingError,
              originalError: e,
            );
          }
        }
      }
      print('No events found in response');
      return <Event>[];
    }, operation: 'search events');
      },
    ).then((events) async {
      // Cache the results
      if (events.isNotEmpty) {
        await _cacheService.cacheEvents(
          cacheKey,
          events,
          queryType: 'search',
        );
      }
      return events;
    });
  }

  Future<List<Event>> getEventsNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    int limit = 50,
  }) async {
    // Use demo data if API is not configured or demo mode is enabled
    if (!ApiConfig.isApiConfigured || ApiConfig.useDemoMode) {
      LoggingService.info('Using demo data for location search', tag: 'API');
      return await DemoEventMethods.getDemoEvents(
        location: 'San Francisco',
        limit: limit,
      );
    }
    
    // Check cache first
    final cacheKey = 'location_${latitude}_${longitude}_${radiusKm}_$limit';
    final cached = await _cacheService.getCachedEvents(cacheKey);
    if (cached != null) {
      LoggingService.info('Cache hit for location search', tag: 'Cache');
      return cached;
    }
    
    return await _rateLimitService.executeRequest<List<Event>>(
      endpoint: '/search-events',
      priority: 2,
      request: () async {
        return await _makeRequest<List<Event>>(() async {
      final response = await _dio.get(
        '/search-events',
        queryParameters: {
          'query': 'events near me',
          'location': '$latitude,$longitude',
          'radius': radiusKm.toInt(),
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          try {
            return (data['data'] as List)
                .map(
                  (e) =>
                      _parseEventFromAPI(Map<String, dynamic>.from(e as Map)),
                )
                .toList();
          } catch (e) {
            throw RapidAPIException(
              'Failed to parse location-based events data',
              type: RapidAPIErrorType.parsingError,
              originalError: e,
            );
          }
        }
      }
      return <Event>[];
    }, operation: 'get events near location');
      },
    ).then((events) async {
      // Cache the results
      if (events.isNotEmpty) {
        await _cacheService.cacheEvents(
          cacheKey,
          events,
          queryType: 'location',
        );
      }
      return events;
    });
  }

  Future<List<Event>> getTrendingEvents({
    String? location,
    int limit = 50,
  }) async {
    // Use demo data if API is not configured or demo mode is enabled
    if (!ApiConfig.isApiConfigured || ApiConfig.useDemoMode) {
      LoggingService.info('Using demo data for trending events', tag: 'API');
      return await DemoEventMethods.getTrendingEvents(limit: limit);
    }
    
    // Check cache first (shorter TTL for trending)
    final cacheKey = 'trending_${location}_$limit';
    final cached = await _cacheService.getCachedEvents(cacheKey);
    if (cached != null) {
      LoggingService.info('Cache hit for trending events', tag: 'Cache');
      return cached;
    }
    
    return await _rateLimitService.executeRequest<List<Event>>(
      endpoint: '/search-events',
      priority: 3,
      request: () async {
        return await _makeRequest<List<Event>>(() async {
      final response = await _dio.get(
        '/search-events',
        queryParameters: {
          'query': 'popular events',
          if (location != null) 'location': location,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          try {
            return (data['data'] as List)
                .map(
                  (e) =>
                      _parseEventFromAPI(Map<String, dynamic>.from(e as Map)),
                )
                .toList();
          } catch (e) {
            throw RapidAPIException(
              'Failed to parse trending events data',
              type: RapidAPIErrorType.parsingError,
              originalError: e,
            );
          }
        }
      }
      return <Event>[];
    }, operation: 'get trending events');
      },
    ).then((events) async {
      // Cache the results with shorter TTL for trending
      if (events.isNotEmpty) {
        await _cacheService.cacheEvents(
          cacheKey,
          events,
          queryType: 'trending',
        );
      }
      return events;
    });
  }

  Future<Event?> getEventDetails(String eventId) async {
    try {
      return await _makeRequest<Event?>(() async {
        final response = await _dio.get(
          '/event-details',
          queryParameters: {'event_id': eventId},
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          try {
            if (data is Map && data['data'] != null) {
              return _parseEventFromAPI(
                Map<String, dynamic>.from(data['data'] as Map),
              );
            }
            if (data is Map) {
              return _parseEventFromAPI(Map<String, dynamic>.from(data));
            }
          } catch (e) {
            throw RapidAPIException(
              'Failed to parse event details',
              type: RapidAPIErrorType.parsingError,
              originalError: e,
            );
          }
        }
        return null;
      }, operation: 'get event details');
    } catch (e) {
      if (e is RapidAPIException) rethrow;
      return null; // For backwards compatibility, return null on unexpected errors
    }
  }

  Future<List<Event>> getEventsByCategory({
    required String category,
    String? location,
    int limit = 50,
  }) async {
    // Use demo data if API is not configured or demo mode is enabled
    if (!ApiConfig.isApiConfigured || ApiConfig.useDemoMode) {
      LoggingService.info('Using demo data for category: $category', tag: 'API');
      // Map category to EventCategory enum
      EventCategory? eventCategory;
      final categoryLower = category.toLowerCase();
      if (categoryLower.contains('music')) eventCategory = EventCategory.music;
      else if (categoryLower.contains('sport')) eventCategory = EventCategory.sports;
      else if (categoryLower.contains('art')) eventCategory = EventCategory.arts;
      else if (categoryLower.contains('food')) eventCategory = EventCategory.food;
      else if (categoryLower.contains('tech')) eventCategory = EventCategory.technology;
      
      final events = await DemoEventMethods.getDemoEvents(
        location: location ?? 'San Francisco',
        limit: limit * 2, // Get more to filter
      );
      
      // Filter by category if specified
      if (eventCategory != null) {
        return events.where((e) => e.category == eventCategory).take(limit).toList();
      }
      return events.take(limit).toList();
    }
    
    // Check cache first
    final cacheKey = 'category_${category}_${location}_$limit';
    final cached = await _cacheService.getCachedEvents(cacheKey);
    if (cached != null) {
      LoggingService.info('Cache hit for category: $category', tag: 'Cache');
      return cached;
    }
    
    return await _rateLimitService.executeRequest<List<Event>>(
      endpoint: '/search-events',
      priority: 2,
      request: () async {
        return await _makeRequest<List<Event>>(() async {
      final response = await _dio.get(
        '/search-events',
        queryParameters: {
          'query': category,
          if (location != null) 'location': location,
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          try {
            return (data['data'] as List)
                .map(
                  (e) =>
                      _parseEventFromAPI(Map<String, dynamic>.from(e as Map)),
                )
                .toList();
          } catch (e) {
            throw RapidAPIException(
              'Failed to parse category events data',
              type: RapidAPIErrorType.parsingError,
              originalError: e,
            );
          }
        }
      }
      return <Event>[];
    }, operation: 'get events by category');
      },
    ).then((events) async {
      // Cache the results
      if (events.isNotEmpty) {
        await _cacheService.cacheEvents(
          cacheKey,
          events,
          queryType: 'category',
        );
      }
      return events;
    });
  }

  Event _parseEventFromAPI(Map<String, dynamic> json) {
    final String id =
        json['event_id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final String title = (json['name'] ?? json['title'] ?? 'Untitled Event')
        .toString();
    final String description = (json['description'] ?? '').toString();

    DateTime startDateTime = DateTime.now();
    if (json['start_time'] != null) {
      try {
        startDateTime = DateTime.parse(json['start_time'].toString());
      } catch (e) {
        // Keep default
      }
    }

    final venueJson = json['venue'] ?? {};
    final venue = EventVenue(
      name: (venueJson['name'] ?? 'Unknown Venue').toString(),
      address: (venueJson['full_address'] ?? venueJson['address'] ?? '')
          .toString(),
      city: (venueJson['city'] ?? '').toString(),
      state: (venueJson['state'] ?? '').toString(),
      country: (venueJson['country'] ?? '').toString(),
      latitude: venueJson['latitude'] is num
          ? (venueJson['latitude'] as num).toDouble()
          : 0.0,
      longitude: venueJson['longitude'] is num
          ? (venueJson['longitude'] as num).toDouble()
          : 0.0,
    );

    EventCategory category = EventCategory.other;
    final categoryString = (json['category'] ?? json['type'] ?? '')
        .toString()
        .toLowerCase();

    if (categoryString.contains('music') ||
        categoryString.contains('concert')) {
      category = EventCategory.music;
    } else if (categoryString.contains('sport')) {
      category = EventCategory.sports;
    } else if (categoryString.contains('art') ||
        categoryString.contains('exhibit')) {
      category = EventCategory.arts;
    } else if (categoryString.contains('food') ||
        categoryString.contains('restaurant')) {
      category = EventCategory.food;
    } else if (categoryString.contains('tech') ||
        categoryString.contains('conference')) {
      category = EventCategory.technology;
    } else if (categoryString.contains('business') ||
        categoryString.contains('network')) {
      category = EventCategory.business;
    } else if (categoryString.contains('education') ||
        categoryString.contains('workshop')) {
      category = EventCategory.education;
    } else if (categoryString.contains('health') ||
        categoryString.contains('wellness')) {
      category = EventCategory.health;
    } else if (categoryString.contains('community') ||
        categoryString.contains('social')) {
      category = EventCategory.community;
    }

    final pricing = const EventPricing(isFree: true, price: 0, currency: 'USD');

    List<String> imageUrls = [];
    if (json['thumbnail'] != null) {
      imageUrls.add(json['thumbnail'].toString());
    }
    if (imageUrls.isEmpty) {
      imageUrls.add(
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800',
      );
    }

    final organizerName =
        (json['publisher'] ?? json['organizer_name'] ?? 'Event Organizer')
            .toString();

    List<String> tags = [];
    if (json['tags'] != null && json['tags'] is List) {
      tags = (json['tags'] as List).map((e) => e.toString()).toList();
    }

    return Event(
      id: id,
      title: title,
      description: description,
      organizerName: organizerName,
      venue: venue,
      imageUrls: imageUrls,
      category: category,
      pricing: pricing,
      startDateTime: startDateTime,
      endDateTime: startDateTime.add(const Duration(hours: 2)),
      tags: tags,
      attendeeCount: 0,
      maxAttendees: 0,
      favoriteCount: 0,
      status: EventStatus.active,
      websiteUrl: json['link']?.toString(),
      ticketUrl: json['link']?.toString(),
      isFeatured: false,
      isPremium: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'rapidapi',
    );
  }

  /// Enhanced method to get maximum events using intelligent strategies
  /// Implements parallel requests, temporal spreading, and smart deduplication
  Future<List<Event>> getMaximumEvents({
    String? query,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int maxEvents = 500,
    int batchSize = 50,
  }) async {
    final allEvents = <Event>[];
    final seenEventIds = <String>{};
    final List<Future<List<Event>>> futures = [];

    try {
      LoggingService.eventRetrievalStart(maxEvents);

      // Strategy 1: Parallel category-based searches
      final categories = [
        'music concerts',
        'sports games',
        'technology conferences',
        'food festivals',
        'art exhibitions',
        'entertainment shows',
        'business networking',
        'health wellness',
        'education workshops',
        'comedy shows',
        'theater performances',
        'dance events',
      ];

      // Create parallel requests for categories
      for (int i = 0; i < categories.length && futures.length < 6; i++) {
        futures.add(
          getEventsByCategory(
            category: categories[i],
            location: location,
            limit: batchSize,
          ).catchError((e) {
            LoggingService.searchFailed('Category', categories[i], error: e);
            return <Event>[];
          }),
        );
      }

      // Strategy 2: Temporal spreading - search different time periods
      final now = DateTime.now();
      final timeRanges = [
        (now, now.add(const Duration(days: 7))), // This week
        (
          now.add(const Duration(days: 7)),
          now.add(const Duration(days: 14)),
        ), // Next week
        (
          now.add(const Duration(days: 14)),
          now.add(const Duration(days: 30)),
        ), // This month
      ];

      for (final (start, end) in timeRanges) {
        if (futures.length >= 10) break; // Limit concurrent requests

        futures.add(
          searchEvents(
            query: query ?? 'events',
            location: location,
            startDate: start,
            endDate: end,
            limit: batchSize,
          ).catchError((e) {
            LoggingService.searchFailed(
              'Temporal',
              '${start.day}/${start.month}',
              error: e,
            );
            return <Event>[];
          }),
        );
      }

      // Strategy 3: Location-based radius searches if coordinates available
      if (location != null && location.contains(',')) {
        final coords = location.split(',');
        if (coords.length == 2) {
          final lat = double.tryParse(coords[0]);
          final lng = double.tryParse(coords[1]);
          if (lat != null && lng != null) {
            final radiuses = [10.0, 25.0, 50.0]; // Different radius searches
            for (final radius in radiuses) {
              if (futures.length >= 15) break;

              futures.add(
                getEventsNearLocation(
                  latitude: lat,
                  longitude: lng,
                  radiusKm: radius,
                  limit: batchSize,
                ).catchError((e) {
                  LoggingService.searchFailed(
                    'Location',
                    'radius $radius',
                    error: e,
                  );
                  return <Event>[];
                }),
              );
            }
          }
        }
      }

      LoggingService.parallelRequestsStart(futures.length);

      // Execute all requests in parallel with timeout
      final results = await Future.wait(futures, eagerError: false).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          LoggingService.timeout('Parallel requests');
          return futures.map((f) => <Event>[]).toList();
        },
      );

      // Collect and deduplicate results
      for (final eventList in results) {
        for (final event in eventList) {
          if (!seenEventIds.contains(event.id) &&
              allEvents.length < maxEvents) {
            seenEventIds.add(event.id);
            allEvents.add(event);
          }
        }
      }

      // Strategy 4: If still need more events, try trending searches
      if (allEvents.length < maxEvents) {
        try {
          final trendingEvents = await getTrendingEvents(
            location: location,
            limit: maxEvents - allEvents.length,
          );

          for (final event in trendingEvents) {
            if (!seenEventIds.contains(event.id) &&
                allEvents.length < maxEvents) {
              seenEventIds.add(event.id);
              allEvents.add(event);
            }
          }
        } catch (e) {
          LoggingService.searchFailed('Trending', 'trending events', error: e);
        }
      }

      // Sort by date and relevance
      allEvents.sort((a, b) {
        // Prioritize events starting sooner
        final dateComparison = a.startDateTime.compareTo(b.startDateTime);
        if (dateComparison != 0) return dateComparison;

        // Then by title alphabetically
        return a.title.compareTo(b.title);
      });

      LoggingService.eventRetrievalComplete(allEvents.length, results.length);
      return allEvents;
    } catch (e) {
      LoggingService.error(
        'Error in getMaximumEvents',
        error: e,
        tag: 'Events',
      );
      return allEvents; // Return whatever we managed to collect
    }
  }
}
