import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event.dart';
import 'logging_service.dart';

/// Enhanced caching service with aggressive API rate limit reduction
class EnhancedCacheService {
  static final EnhancedCacheService _instance = EnhancedCacheService._internal();
  factory EnhancedCacheService() => _instance;
  EnhancedCacheService._internal();

  late Box<dynamic> _cacheBox;
  late Box<dynamic> _metadataBox;
  bool _isInitialized = false;

  // Cache TTL configurations
  static const Duration _shortTtl = Duration(minutes: 5);
  static const Duration _mediumTtl = Duration(minutes: 30);
  static const Duration _longTtl = Duration(hours: 2);
  static const Duration _veryLongTtl = Duration(hours: 24);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();
      
      _cacheBox = await Hive.openBox('enhanced_cache');
      _metadataBox = await Hive.openBox('cache_metadata');
      
      _isInitialized = true;
      LoggingService.info('Enhanced cache service initialized');
      
      // Start background cleanup
      _startCleanupTimer();
    } catch (e) {
      LoggingService.error('Failed to initialize enhanced cache: $e');
      rethrow;
    }
  }

  /// Cache events with intelligent TTL based on query type
  Future<void> cacheEvents(
    String key,
    List<Event> events, {
    Duration? ttl,
    String? queryType,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Determine TTL based on query type
      final effectiveTtl = ttl ?? _getTtlForQueryType(queryType);
      
      final cacheEntry = {
        'data': events.map((e) => _eventToSimpleJson(e)).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': effectiveTtl.inMilliseconds,
        'query_type': queryType,
        'count': events.length,
      };

      await _cacheBox.put(key, cacheEntry);
      
      // Update metadata
      await _metadataBox.put('${key}_meta', {
        'last_updated': DateTime.now().millisecondsSinceEpoch,
        'size': jsonEncode(cacheEntry).length,
        'hits': 0,
      });

      LoggingService.info('Cached ${events.length} events with key: $key (TTL: ${effectiveTtl.inMinutes}min)');
    } catch (e) {
      LoggingService.error('Failed to cache events: $e');
    }
  }

  /// Get cached events with hit tracking
  Future<List<Event>?> getCachedEvents(String key) async {
    if (!_isInitialized) await initialize();

    try {
      final cacheEntry = _cacheBox.get(key);
      if (cacheEntry == null) return null;

      final timestamp = cacheEntry['timestamp'] as int;
      final ttl = cacheEntry['ttl'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check if cache is expired
      if (now - timestamp > ttl) {
        await _cacheBox.delete(key);
        await _metadataBox.delete('${key}_meta');
        LoggingService.info('Cache expired and removed: $key');
        return null;
      }

      // Update hit count
      final metadata = _metadataBox.get('${key}_meta') ?? {};
      metadata['hits'] = (metadata['hits'] ?? 0) + 1;
      metadata['last_accessed'] = now;
      await _metadataBox.put('${key}_meta', metadata);

      // Convert back to events
      final eventJsonList = cacheEntry['data'] as List<dynamic>;
      final events = eventJsonList
          .map((json) => _eventFromSimpleJson(Map<String, dynamic>.from(json as Map)))
          .toList();

      LoggingService.info('Cache hit for key: $key (${events.length} events)');
      return events;
    } catch (e) {
      LoggingService.error('Failed to get cached events: $e');
      return null;
    }
  }

  /// Generate cache key based on search parameters
  String generateCacheKey({
    String? query,
    String? location,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    double? latitude,
    double? longitude,
    int? limit,
  }) {
    final params = <String, dynamic>{
      if (query != null && query.isNotEmpty) 'q': query.toLowerCase(),
      if (location != null && location.isNotEmpty) 'loc': location.toLowerCase(),
      if (category != null && category.isNotEmpty) 'cat': category.toLowerCase(),
      if (startDate != null) 'start': startDate.millisecondsSinceEpoch,
      if (endDate != null) 'end': endDate.millisecondsSinceEpoch,
      if (latitude != null) 'lat': latitude.toStringAsFixed(3),
      if (longitude != null) 'lng': longitude.toStringAsFixed(3),
      if (limit != null) 'limit': limit,
    };

    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return 'events_${sortedParams.entries.map((e) => '${e.key}:${e.value}').join('_')}';
  }

  /// Check if we should use cache instead of making API call
  Future<bool> shouldUseCache(String key, {Duration? forceRefreshAfter}) async {
    if (!_isInitialized) await initialize();

    final cacheEntry = _cacheBox.get(key);
    if (cacheEntry == null) return false;

    final timestamp = cacheEntry['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Check force refresh threshold
    if (forceRefreshAfter != null) {
      if (now - timestamp > forceRefreshAfter.inMilliseconds) {
        return false;
      }
    }

    final ttl = cacheEntry['ttl'] as int;
    return (now - timestamp) < ttl;
  }

  /// Get cache statistics for monitoring
  Future<Map<String, dynamic>> getCacheStats() async {
    if (!_isInitialized) await initialize();

    final allKeys = _cacheBox.keys.toList();
    int totalEntries = allKeys.length;
    int totalSize = 0;
    int expiredCount = 0;
    int totalHits = 0;

    for (final key in allKeys) {
      final entry = _cacheBox.get(key);
      if (entry != null) {
        final timestamp = entry['timestamp'] as int;
        final ttl = entry['ttl'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;

        if (now - timestamp > ttl) {
          expiredCount++;
        }

        final metadata = _metadataBox.get('${key}_meta') ?? {};
        totalSize += (metadata['size'] ?? 0) as int;
        totalHits += (metadata['hits'] ?? 0) as int;
      }
    }

    return {
      'total_entries': totalEntries,
      'expired_entries': expiredCount,
      'total_size_bytes': totalSize,
      'total_hits': totalHits,
      'hit_ratio': totalEntries > 0 ? totalHits / totalEntries : 0.0,
      'cache_efficiency': totalEntries > 0 ? (totalEntries - expiredCount) / totalEntries : 0.0,
    };
  }

  /// Clean up expired entries
  Future<void> cleanup() async {
    if (!_isInitialized) await initialize();

    final allKeys = _cacheBox.keys.toList();
    int removedCount = 0;

    for (final key in allKeys) {
      final entry = _cacheBox.get(key);
      if (entry != null) {
        final timestamp = entry['timestamp'] as int;
        final ttl = entry['ttl'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;

        if (now - timestamp > ttl) {
          await _cacheBox.delete(key);
          await _metadataBox.delete('${key}_meta');
          removedCount++;
        }
      }
    }

    LoggingService.info('Cache cleanup removed $removedCount expired entries');
  }

  /// Get TTL based on query type for intelligent caching
  Duration _getTtlForQueryType(String? queryType) {
    switch (queryType?.toLowerCase()) {
      case 'trending':
      case 'popular':
        return _shortTtl; // Trending data changes quickly
      
      case 'location':
      case 'nearby':
        return _mediumTtl; // Location-based results fairly stable
      
      case 'category':
      case 'search':
        return _longTtl; // Category results relatively stable
      
      case 'featured':
      case 'recommended':
        return _veryLongTtl; // Featured content changes slowly
      
      default:
        return _mediumTtl; // Default fallback
    }
  }

  /// Start background cleanup timer
  void _startCleanupTimer() {
    Timer.periodic(const Duration(hours: 1), (timer) {
      cleanup();
    });
  }

  /// Pre-warm cache with popular queries
  Future<void> prewarmCache() async {
    LoggingService.info('Pre-warming cache with popular queries');
    
    // This would be called during app initialization to cache
    // popular/common queries to reduce initial API calls
    final popularQueries = [
      'music events',
      'food events', 
      'sports events',
      'art events',
      'technology events',
    ];

    // Note: This would integrate with the actual RapidAPI service
    // to fetch and cache popular query results during off-peak times
    for (final query in popularQueries) {
      LoggingService.info('Would pre-warm cache for: $query');
    }
  }

  /// Clear all cache data
  Future<void> clearAll() async {
    if (!_isInitialized) await initialize();
    
    await _cacheBox.clear();
    await _metadataBox.clear();
    LoggingService.info('All cache data cleared');
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _cacheBox.close();
      await _metadataBox.close();
      _isInitialized = false;
    }
  }
  
  /// Convert Event to simple JSON for Hive storage
  Map<String, dynamic> _eventToSimpleJson(Event event) {
    try {
      // Convert to JSON and ensure simple types
      final json = event.toJson();
      // Recursively convert to simple types
      return _toSimpleTypes(json);
    } catch (e) {
      LoggingService.error('Error converting event to simple JSON: $e');
      // Return minimal event data
      return {
        'id': event.id,
        'title': event.title,
        'description': event.description,
      };
    }
  }
  
  /// Convert complex types to simple types for Hive
  dynamic _toSimpleTypes(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    } else if (value is DateTime) {
      return value.toIso8601String();
    } else if (value is List) {
      return value.map((e) => _toSimpleTypes(e)).toList();
    } else if (value is Map) {
      final Map<String, dynamic> result = {};
      value.forEach((key, val) {
        if (key is String) {
          result[key] = _toSimpleTypes(val);
        }
      });
      return result;
    } else {
      return value.toString();
    }
  }
  
  /// Create Event from simple JSON
  Event _eventFromSimpleJson(Map<String, dynamic> json) {
    try {
      return Event.fromJson(json);
    } catch (e) {
      LoggingService.error('Error creating event from JSON: $e');
      // Return a minimal event
      return Event(
        id: json['id'] ?? 'unknown',
        title: json['title'] ?? 'Unknown Event',
        description: json['description'] ?? '',
        organizerName: 'Unknown',
        venue: const EventVenue(
          name: 'Unknown Venue',
          address: '',
          latitude: 0.0,
          longitude: 0.0,
        ),
        imageUrls: [],
        category: EventCategory.other,
        pricing: const EventPricing(isFree: true),
        startDateTime: DateTime.now(),
        endDateTime: DateTime.now().add(const Duration(hours: 2)),
        status: EventStatus.active,
        createdBy: 'system',
      );
    }
  }
}