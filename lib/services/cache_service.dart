import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/event.dart';

class CacheService {
  static const String _eventsBoxName = 'events_cache';
  static const String _imagesBoxName = 'images_cache';
  static const String _userPreferencesBoxName = 'user_preferences';
  static const Duration _cacheTimeout = Duration(hours: 24);

  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();

  CacheService._();

  Box<dynamic>? _eventsBox;
  Box<dynamic>? _imagesBox;
  Box<dynamic>? _preferencesBox;

  // Initialize cache service
  Future<void> initialize() async {
    try {
      _eventsBox = await Hive.openBox(_eventsBoxName);
      _imagesBox = await Hive.openBox(_imagesBoxName);
      _preferencesBox = await Hive.openBox(_userPreferencesBoxName);
    } catch (e) {
      print('Cache initialization error: $e');
    }
  }

  // Connectivity management
  Future<bool> get isConnected async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
           connectivityResult.contains(ConnectivityResult.wifi) ||
           connectivityResult.contains(ConnectivityResult.ethernet);
  }

  Stream<bool> get connectivityStream {
    return Connectivity().onConnectivityChanged.map((results) {
      return results.contains(ConnectivityResult.mobile) ||
             results.contains(ConnectivityResult.wifi) ||
             results.contains(ConnectivityResult.ethernet);
    });
  }

  // Events caching
  Future<void> cacheEvents(List<Event> events) async {
    if (_eventsBox == null) return;

    try {
      final cacheData = {
        'events': events.map((e) => e.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await _eventsBox!.put('all_events', cacheData);
    } catch (e) {
      print('Error caching events: $e');
    }
  }

  Future<List<Event>?> getCachedEvents() async {
    if (_eventsBox == null) return null;

    try {
      final cacheData = _eventsBox!.get('all_events');
      if (cacheData == null) return null;

      final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
      if (DateTime.now().difference(timestamp) > _cacheTimeout) {
        await _eventsBox!.delete('all_events');
        return null;
      }

      final eventsJson = List<Map<String, dynamic>>.from(cacheData['events']);
      return eventsJson.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print('Error retrieving cached events: $e');
      return null;
    }
  }

  Future<void> cacheFeaturedEvents(List<Event> events) async {
    if (_eventsBox == null) return;

    try {
      final cacheData = {
        'events': events.map((e) => e.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await _eventsBox!.put('featured_events', cacheData);
    } catch (e) {
      print('Error caching featured events: $e');
    }
  }

  Future<List<Event>?> getCachedFeaturedEvents() async {
    if (_eventsBox == null) return null;

    try {
      final cacheData = _eventsBox!.get('featured_events');
      if (cacheData == null) return null;

      final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
      if (DateTime.now().difference(timestamp) > _cacheTimeout) {
        await _eventsBox!.delete('featured_events');
        return null;
      }

      final eventsJson = List<Map<String, dynamic>>.from(cacheData['events']);
      return eventsJson.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print('Error retrieving cached featured events: $e');
      return null;
    }
  }

  // Single event caching
  Future<void> cacheEvent(Event event) async {
    if (_eventsBox == null) return;

    try {
      final cacheData = {
        'event': event.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await _eventsBox!.put('event_${event.id}', cacheData);
    } catch (e) {
      print('Error caching event: $e');
    }
  }

  Future<Event?> getCachedEvent(String eventId) async {
    if (_eventsBox == null) return null;

    try {
      final cacheData = _eventsBox!.get('event_$eventId');
      if (cacheData == null) return null;

      final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
      if (DateTime.now().difference(timestamp) > _cacheTimeout) {
        await _eventsBox!.delete('event_$eventId');
        return null;
      }

      return Event.fromJson(Map<String, dynamic>.from(cacheData['event']));
    } catch (e) {
      print('Error retrieving cached event: $e');
      return null;
    }
  }

  // Image caching with Flutter Cache Manager
  Future<File?> getCachedImage(String url) async {
    try {
      final fileInfo = await DefaultCacheManager().getFileFromCache(url);
      return fileInfo?.file;
    } catch (e) {
      print('Error getting cached image: $e');
      return null;
    }
  }

  Future<void> preloadImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        DefaultCacheManager().downloadFile(url);
      } catch (e) {
        print('Error preloading image $url: $e');
      }
    }
  }

  // User preferences caching
  Future<void> cacheUserPreference(String key, dynamic value) async {
    if (_preferencesBox == null) return;

    try {
      await _preferencesBox!.put(key, value);
    } catch (e) {
      print('Error caching user preference: $e');
    }
  }

  T? getCachedUserPreference<T>(String key) {
    if (_preferencesBox == null) return null;

    try {
      return _preferencesBox!.get(key) as T?;
    } catch (e) {
      print('Error retrieving user preference: $e');
      return null;
    }
  }

  // Favorites caching (offline support)
  Future<void> cacheFavoriteEvent(String eventId) async {
    if (_preferencesBox == null) return;

    try {
      List<String> favorites = getCachedFavorites();
      if (!favorites.contains(eventId)) {
        favorites.add(eventId);
        await _preferencesBox!.put('favorite_events', favorites);
      }
    } catch (e) {
      print('Error caching favorite event: $e');
    }
  }

  Future<void> removeFavoriteEvent(String eventId) async {
    if (_preferencesBox == null) return;

    try {
      List<String> favorites = getCachedFavorites();
      favorites.remove(eventId);
      await _preferencesBox!.put('favorite_events', favorites);
    } catch (e) {
      print('Error removing favorite event: $e');
    }
  }

  List<String> getCachedFavorites() {
    if (_preferencesBox == null) return [];

    try {
      final favorites = _preferencesBox!.get('favorite_events');
      if (favorites == null) return [];
      return List<String>.from(favorites);
    } catch (e) {
      print('Error retrieving cached favorites: $e');
      return [];
    }
  }

  // Search history caching
  Future<void> addSearchQuery(String query) async {
    if (_preferencesBox == null || query.trim().isEmpty) return;

    try {
      List<String> searchHistory = getSearchHistory();
      searchHistory.remove(query); // Remove if already exists
      searchHistory.insert(0, query); // Add to beginning

      // Keep only last 20 searches
      if (searchHistory.length > 20) {
        searchHistory = searchHistory.take(20).toList();
      }

      await _preferencesBox!.put('search_history', searchHistory);
    } catch (e) {
      print('Error adding search query: $e');
    }
  }

  List<String> getSearchHistory() {
    if (_preferencesBox == null) return [];

    try {
      final history = _preferencesBox!.get('search_history');
      if (history == null) return [];
      return List<String>.from(history);
    } catch (e) {
      print('Error retrieving search history: $e');
      return [];
    }
  }

  Future<void> clearSearchHistory() async {
    if (_preferencesBox == null) return;

    try {
      await _preferencesBox!.delete('search_history');
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  // Cache cleanup
  Future<void> clearExpiredCache() async {
    try {
      // Clear expired events
      if (_eventsBox != null) {
        final keys = _eventsBox!.keys.toList();
        for (final key in keys) {
          final data = _eventsBox!.get(key);
          if (data is Map && data.containsKey('timestamp')) {
            final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
            if (DateTime.now().difference(timestamp) > _cacheTimeout) {
              await _eventsBox!.delete(key);
            }
          }
        }
      }

      // Clear expired images
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      print('Error clearing expired cache: $e');
    }
  }

  Future<void> clearAllCache() async {
    try {
      await _eventsBox?.clear();
      await _imagesBox?.clear();
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }

  // Cache size management
  Future<int> getCacheSize() async {
    try {
      int size = 0;
      
      // Calculate Hive boxes size (approximate)
      if (_eventsBox != null) {
        size += _eventsBox!.length * 1000; // Rough estimate
      }
      if (_preferencesBox != null) {
        size += _preferencesBox!.length * 100;
      }

      return size;
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0;
    }
  }

  // Background sync for when connection is restored
  Future<void> syncPendingActions() async {
    final connected = await isConnected;
    if (!connected) return;

    // Implement sync logic for any pending actions
    // (like favorites that were added/removed while offline)
    print('Syncing pending actions...');
  }

  // Dispose
  Future<void> dispose() async {
    await _eventsBox?.close();
    await _imagesBox?.close();
    await _preferencesBox?.close();
  }
}