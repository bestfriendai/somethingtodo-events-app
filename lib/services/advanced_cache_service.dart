import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/event.dart';
import '../services/logging_service.dart';

/// Advanced caching service with multi-level caching, intelligent eviction, and performance optimization
class AdvancedCacheService {
  static final AdvancedCacheService _instance =
      AdvancedCacheService._internal();
  factory AdvancedCacheService() => _instance;
  AdvancedCacheService._internal();

  // Cache configuration
  static const String _l1CacheBoxName = 'l1_memory_cache';
  static const String _l2CacheBoxName = 'l2_disk_cache';
  static const String _metadataBoxName = 'cache_metadata';
  static const String _analyticsBoxName = 'cache_analytics';

  // Cache policies
  static const Duration _defaultTtl = Duration(hours: 6);
  static const Duration _longTermTtl = Duration(days: 7);
  static const Duration _shortTermTtl = Duration(minutes: 30);
  static const int _maxMemoryCacheSize = 100; // Max items in memory

  // Cache boxes
  Box<dynamic>? _l1Box; // Memory cache (fast access)
  Box<dynamic>? _l2Box; // Disk cache (persistent)
  Box<dynamic>? _metadataBox; // Cache metadata
  Box<dynamic>? _analyticsBox; // Cache analytics

  // In-memory cache for ultra-fast access
  final Map<String, CacheEntry> _memoryCache = <String, CacheEntry>{};
  final Map<String, int> _accessCount = <String, int>{};
  final Map<String, DateTime> _lastAccess = <String, DateTime>{};

  // Cache statistics
  int _hitCount = 0;
  int _missCount = 0;
  int _evictionCount = 0;

  // Connectivity monitoring
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = true;

  /// Initialize the advanced cache service
  Future<void> initialize() async {
    try {
      // Open cache boxes
      _l1Box = await Hive.openBox(_l1CacheBoxName);
      _l2Box = await Hive.openBox(_l2CacheBoxName);
      _metadataBox = await Hive.openBox(_metadataBoxName);
      _analyticsBox = await Hive.openBox(_analyticsBoxName);

      // Load cache statistics
      await _loadCacheStatistics();

      // Start connectivity monitoring
      _startConnectivityMonitoring();

      // Perform initial cache cleanup
      await _performCacheCleanup();

      LoggingService.info(
        'Advanced cache service initialized',
        tag: 'AdvancedCache',
      );
    } catch (e) {
      LoggingService.error(
        'Failed to initialize advanced cache service',
        error: e,
        tag: 'AdvancedCache',
      );
    }
  }

  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final wasConnected = _isConnected;
      _isConnected =
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);

      if (!wasConnected && _isConnected) {
        LoggingService.info(
          'Connection restored, triggering cache refresh',
          tag: 'AdvancedCache',
        );
        _onConnectivityRestored();
      }
    });
  }

  /// Handle connectivity restoration
  void _onConnectivityRestored() {
    // Trigger background cache refresh for stale data
    _refreshStaleCache();
  }

  /// Generate cache key from input data
  String _generateCacheKey(String prefix, Map<String, dynamic> params) {
    final paramString = json.encode(params);
    final keyString = '$prefix:$paramString';
    // Simple hash function to generate consistent keys
    return keyString.hashCode.abs().toString();
  }

  /// Store data in cache with intelligent placement
  Future<void> store<T>(
    String key,
    T data, {
    Duration? ttl,
    CachePriority priority = CachePriority.normal,
    List<String>? tags,
  }) async {
    try {
      final effectiveTtl = ttl ?? _getTtlForPriority(priority);
      final expiryTime = DateTime.now().add(effectiveTtl);

      final entry = CacheEntry<T>(
        key: key,
        data: data,
        expiryTime: expiryTime,
        priority: priority,
        tags: tags ?? [],
        createdAt: DateTime.now(),
        accessCount: 0,
        size: _calculateDataSize(data),
      );

      // Store in memory cache if high priority or frequently accessed
      if (priority == CachePriority.high || _shouldStoreInMemory(key)) {
        _memoryCache[key] = entry;
        _enforceMemoryCacheLimit();
      }

      // Store in L1 cache (fast disk access)
      if (_l1Box != null) {
        await _l1Box!.put(key, entry.toJson());
      }

      // Store in L2 cache for long-term persistence
      if (priority != CachePriority.low && _l2Box != null) {
        await _l2Box!.put(key, entry.toJson());
      }

      // Update metadata
      await _updateCacheMetadata(key, entry);

      LoggingService.debug('Cached data with key: $key', tag: 'AdvancedCache');
    } catch (e) {
      LoggingService.error(
        'Failed to store cache entry',
        error: e,
        tag: 'AdvancedCache',
      );
    }
  }

  /// Retrieve data from cache with intelligent fallback
  Future<T?> get<T>(
    String key, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final now = DateTime.now();

      // Check memory cache first (fastest)
      if (_memoryCache.containsKey(key)) {
        final entry = _memoryCache[key]!;
        if (entry.expiryTime.isAfter(now)) {
          _recordCacheHit(key);
          return entry.data as T;
        } else {
          _memoryCache.remove(key);
        }
      }

      // Check L1 cache (fast disk)
      if (_l1Box != null) {
        final entryJson = _l1Box!.get(key);
        if (entryJson != null) {
          final entry = CacheEntry.fromJson(entryJson);
          if (entry.expiryTime.isAfter(now)) {
            // Promote to memory cache if frequently accessed
            if (_shouldPromoteToMemory(key)) {
              _memoryCache[key] = entry;
            }
            _recordCacheHit(key);
            return _deserializeData<T>(entry.data, fromJson);
          } else {
            await _l1Box!.delete(key);
          }
        }
      }

      // Check L2 cache (persistent disk)
      if (_l2Box != null) {
        final entryJson = _l2Box!.get(key);
        if (entryJson != null) {
          final entry = CacheEntry.fromJson(entryJson);
          if (entry.expiryTime.isAfter(now)) {
            // Promote to L1 cache
            if (_l1Box != null) {
              await _l1Box!.put(key, entryJson);
            }
            _recordCacheHit(key);
            return _deserializeData<T>(entry.data, fromJson);
          } else {
            await _l2Box!.delete(key);
          }
        }
      }

      _recordCacheMiss(key);
      return null;
    } catch (e) {
      LoggingService.error(
        'Failed to retrieve cache entry',
        error: e,
        tag: 'AdvancedCache',
      );
      _recordCacheMiss(key);
      return null;
    }
  }

  /// Store events with intelligent caching strategy
  Future<void> storeEvents(
    List<Event> events, {
    String? locationKey,
    String? categoryKey,
    Duration? ttl,
  }) async {
    final key = _generateCacheKey('events', {
      'location': locationKey ?? 'global',
      'category': categoryKey ?? 'all',
    });

    await store(
      key,
      events.map((e) => e.toJson()).toList(),
      ttl: ttl ?? _defaultTtl,
      priority: CachePriority.high,
      tags: [
        'events',
        if (locationKey != null) 'location:$locationKey',
        if (categoryKey != null) 'category:$categoryKey',
      ],
    );
  }

  /// Retrieve cached events
  Future<List<Event>?> getEvents({
    String? locationKey,
    String? categoryKey,
  }) async {
    final key = _generateCacheKey('events', {
      'location': locationKey ?? 'global',
      'category': categoryKey ?? 'all',
    });

    final eventsJson = await get<List<dynamic>>(key);
    if (eventsJson == null) return null;

    try {
      return eventsJson
          .cast<Map<String, dynamic>>()
          .map((json) => Event.fromJson(json))
          .toList();
    } catch (e) {
      LoggingService.error(
        'Failed to deserialize cached events',
        error: e,
        tag: 'AdvancedCache',
      );
      return null;
    }
  }

  /// Store single event
  Future<void> storeEvent(Event event, {Duration? ttl}) async {
    await store(
      'event:${event.id}',
      event.toJson(),
      ttl: ttl ?? _longTermTtl,
      priority: CachePriority.normal,
      tags: ['event', 'event:${event.id}'],
    );
  }

  /// Retrieve single event
  Future<Event?> getEvent(String eventId) async {
    final eventJson = await get<Map<String, dynamic>>('event:$eventId');
    if (eventJson == null) return null;

    try {
      return Event.fromJson(eventJson);
    } catch (e) {
      LoggingService.error(
        'Failed to deserialize cached event',
        error: e,
        tag: 'AdvancedCache',
      );
      return null;
    }
  }

  /// Clear cache by tags
  Future<void> clearByTags(List<String> tags) async {
    try {
      final keysToDelete = <String>[];

      // Check metadata for tagged entries
      if (_metadataBox != null) {
        for (final key in _metadataBox!.keys) {
          final metadata = _metadataBox!.get(key);
          if (metadata != null && metadata['tags'] != null) {
            final entryTags = List<String>.from(metadata['tags']);
            if (tags.any((tag) => entryTags.contains(tag))) {
              keysToDelete.add(key.toString());
            }
          }
        }
      }

      // Delete from all cache levels
      for (final key in keysToDelete) {
        await delete(key);
      }

      LoggingService.info(
        'Cleared ${keysToDelete.length} cache entries by tags: $tags',
        tag: 'AdvancedCache',
      );
    } catch (e) {
      LoggingService.error(
        'Failed to clear cache by tags',
        error: e,
        tag: 'AdvancedCache',
      );
    }
  }

  /// Delete specific cache entry
  Future<void> delete(String key) async {
    try {
      _memoryCache.remove(key);
      await _l1Box?.delete(key);
      await _l2Box?.delete(key);
      await _metadataBox?.delete(key);

      LoggingService.debug('Deleted cache entry: $key', tag: 'AdvancedCache');
    } catch (e) {
      LoggingService.error(
        'Failed to delete cache entry',
        error: e,
        tag: 'AdvancedCache',
      );
    }
  }

  /// Get cache statistics
  CacheStatistics getStatistics() {
    final hitRate = _hitCount + _missCount > 0
        ? _hitCount / (_hitCount + _missCount)
        : 0.0;

    return CacheStatistics(
      hitCount: _hitCount,
      missCount: _missCount,
      hitRate: hitRate,
      evictionCount: _evictionCount,
      memoryCacheSize: _memoryCache.length,
      l1CacheSize: _l1Box?.length ?? 0,
      l2CacheSize: _l2Box?.length ?? 0,
    );
  }

  // Helper methods
  Duration _getTtlForPriority(CachePriority priority) {
    switch (priority) {
      case CachePriority.low:
        return _shortTermTtl;
      case CachePriority.high:
        return _longTermTtl;
      case CachePriority.normal:
        return _defaultTtl;
    }
  }

  bool _shouldStoreInMemory(String key) {
    final accessCount = _accessCount[key] ?? 0;
    return accessCount > 2; // Store in memory if accessed more than twice
  }

  bool _shouldPromoteToMemory(String key) {
    final accessCount = _accessCount[key] ?? 0;
    return accessCount > 1;
  }

  void _enforceMemoryCacheLimit() {
    if (_memoryCache.length <= _maxMemoryCacheSize) return;

    // Remove least recently used items
    final sortedEntries = _memoryCache.entries.toList()
      ..sort((a, b) {
        final aLastAccess = _lastAccess[a.key] ?? DateTime(1970);
        final bLastAccess = _lastAccess[b.key] ?? DateTime(1970);
        return aLastAccess.compareTo(bLastAccess);
      });

    final itemsToRemove = _memoryCache.length - _maxMemoryCacheSize;
    for (int i = 0; i < itemsToRemove; i++) {
      final key = sortedEntries[i].key;
      _memoryCache.remove(key);
      _evictionCount++;
    }
  }

  void _recordCacheHit(String key) {
    _hitCount++;
    _accessCount[key] = (_accessCount[key] ?? 0) + 1;
    _lastAccess[key] = DateTime.now();
  }

  void _recordCacheMiss(String key) {
    _missCount++;
  }

  int _calculateDataSize(dynamic data) {
    try {
      final jsonString = json.encode(data);
      return utf8.encode(jsonString).length;
    } catch (e) {
      return 0;
    }
  }

  T? _deserializeData<T>(
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    if (data is T) return data;
    if (fromJson != null && data is Map<String, dynamic>) {
      return fromJson(data);
    }
    return data as T?;
  }

  Future<void> _updateCacheMetadata(String key, CacheEntry entry) async {
    if (_metadataBox == null) return;

    try {
      await _metadataBox!.put(key, {
        'tags': entry.tags,
        'priority': entry.priority.index,
        'size': entry.size,
        'createdAt': entry.createdAt.millisecondsSinceEpoch,
        'expiryTime': entry.expiryTime.millisecondsSinceEpoch,
      });
    } catch (e) {
      LoggingService.error(
        'Failed to update cache metadata',
        error: e,
        tag: 'AdvancedCache',
      );
    }
  }

  Future<void> _loadCacheStatistics() async {
    if (_analyticsBox == null) return;

    try {
      _hitCount = _analyticsBox!.get('hitCount', defaultValue: 0);
      _missCount = _analyticsBox!.get('missCount', defaultValue: 0);
      _evictionCount = _analyticsBox!.get('evictionCount', defaultValue: 0);
    } catch (e) {
      LoggingService.error(
        'Failed to load cache statistics',
        error: e,
        tag: 'AdvancedCache',
      );
    }
  }

  Future<void> _saveCacheStatistics() async {
    if (_analyticsBox == null) return;

    try {
      await _analyticsBox!.put('hitCount', _hitCount);
      await _analyticsBox!.put('missCount', _missCount);
      await _analyticsBox!.put('evictionCount', _evictionCount);
    } catch (e) {
      LoggingService.error(
        'Failed to save cache statistics',
        error: e,
        tag: 'AdvancedCache',
      );
    }
  }

  Future<void> _performCacheCleanup() async {
    try {
      final now = DateTime.now();
      final keysToDelete = <String>[];

      // Check L1 cache for expired entries
      if (_l1Box != null) {
        for (final key in _l1Box!.keys) {
          final entryJson = _l1Box!.get(key);
          if (entryJson != null) {
            try {
              final entry = CacheEntry.fromJson(entryJson);
              if (entry.expiryTime.isBefore(now)) {
                keysToDelete.add(key.toString());
              }
            } catch (e) {
              keysToDelete.add(key.toString()); // Remove corrupted entries
            }
          }
        }
      }

      // Delete expired entries
      for (final key in keysToDelete) {
        await delete(key);
      }

      LoggingService.info(
        'Cache cleanup completed: removed ${keysToDelete.length} expired entries',
        tag: 'AdvancedCache',
      );
    } catch (e) {
      LoggingService.error(
        'Failed to perform cache cleanup',
        error: e,
        tag: 'AdvancedCache',
      );
    }
  }

  Future<void> _refreshStaleCache() async {
    // This would trigger background refresh of stale cache entries
    // Implementation depends on specific app requirements
    LoggingService.info('Triggering stale cache refresh', tag: 'AdvancedCache');
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _saveCacheStatistics();
    await _connectivitySubscription?.cancel();
    _memoryCache.clear();
    _accessCount.clear();
    _lastAccess.clear();
  }
}

/// Cache entry model
class CacheEntry<T> {
  final String key;
  final T data;
  final DateTime expiryTime;
  final CachePriority priority;
  final List<String> tags;
  final DateTime createdAt;
  final int accessCount;
  final int size;

  CacheEntry({
    required this.key,
    required this.data,
    required this.expiryTime,
    required this.priority,
    required this.tags,
    required this.createdAt,
    required this.accessCount,
    required this.size,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'expiryTime': expiryTime.millisecondsSinceEpoch,
      'priority': priority.index,
      'tags': tags,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'accessCount': accessCount,
      'size': size,
    };
  }

  static CacheEntry fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      key: json['key'],
      data: json['data'],
      expiryTime: DateTime.fromMillisecondsSinceEpoch(json['expiryTime']),
      priority: CachePriority.values[json['priority']],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      accessCount: json['accessCount'] ?? 0,
      size: json['size'] ?? 0,
    );
  }
}

/// Cache priority levels
enum CachePriority { low, normal, high }

/// Cache statistics model
class CacheStatistics {
  final int hitCount;
  final int missCount;
  final double hitRate;
  final int evictionCount;
  final int memoryCacheSize;
  final int l1CacheSize;
  final int l2CacheSize;

  CacheStatistics({
    required this.hitCount,
    required this.missCount,
    required this.hitRate,
    required this.evictionCount,
    required this.memoryCacheSize,
    required this.l1CacheSize,
    required this.l2CacheSize,
  });
}
