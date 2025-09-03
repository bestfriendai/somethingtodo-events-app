import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../services/firestore_service.dart';
import '../services/rapidapi_events_service.dart';
import '../services/cache_service.dart';
import '../services/performance_service.dart';
import '../config/app_config.dart';

/// Optimized Events Provider with performance improvements
///
/// Key optimizations:
/// - Lazy loading with pagination
/// - Memory-efficient state management
/// - Debounced search
/// - Smart caching strategies
/// - Automatic cleanup of unused data
class OptimizedEventsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final RapidAPIEventsService _rapidAPIService = RapidAPIEventsService();

  // Pagination and lazy loading
  static const int _pageSize = 20;
  static const int _maxEventsInMemory = 100;

  // Event lists with memory management
  List<Event> _events = [];
  List<Event> _featuredEvents = [];
  List<Event> _nearbyEvents = [];
  final Map<String, Event> _eventCache = {}; // Quick lookup cache

  // Search with debouncing
  List<Event> _searchResults = [];
  Timer? _searchDebounce;
  String _lastSearchQuery = '';

  // Loading states
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreEvents = true;
  String? _error;

  // Pagination
  int _currentPage = 0;
  DocumentSnapshot? _lastDocument;

  // Filter state
  EventCategory? _selectedCategory;
  double _searchRadius = AppConfig.defaultSearchRadius;
  double? _userLatitude;
  double? _userLongitude;

  // Memory management
  Timer? _cleanupTimer;
  final Set<String> _viewedEventIds = {};

  // Getters with defensive copying for immutability
  List<Event> get events => List.unmodifiable(_events);
  List<Event> get featuredEvents => List.unmodifiable(_featuredEvents);
  List<Event> get nearbyEvents => List.unmodifiable(_nearbyEvents);
  List<Event> get searchResults => List.unmodifiable(_searchResults);

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreEvents => _hasMoreEvents;
  String? get error => _error;

  EventCategory? get selectedCategory => _selectedCategory;
  double get searchRadius => _searchRadius;

  /// Initialize provider with optimizations
  Future<void> initialize() async {
    // Start performance tracking
    PerformanceService.instance.startOperation('events_init');

    try {
      // Initialize cache service
      await CacheService.instance.initialize();

      // Load cached data first for instant UI
      await _loadCachedData();

      // Start periodic cleanup
      _startPeriodicCleanup();

      // Load fresh data in background
      _loadFreshData();
    } finally {
      PerformanceService.instance.endOperation('events_init');
    }
  }

  /// Load cached data for instant display
  Future<void> _loadCachedData() async {
    try {
      final cachedEvents = await CacheService.instance.getCachedEvents();
      final cachedFeatured = await CacheService.instance
          .getCachedFeaturedEvents();

      if (cachedEvents != null && cachedEvents.isNotEmpty) {
        _events = cachedEvents.take(_maxEventsInMemory).toList();
        _updateEventCache(_events);
      }

      if (cachedFeatured != null && cachedFeatured.isNotEmpty) {
        _featuredEvents = cachedFeatured;
      }

      if (_events.isNotEmpty || _featuredEvents.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  /// Load fresh data in background
  Future<void> _loadFreshData() async {
    if (_isLoading) return;

    try {
      // Check connectivity first
      final isConnected = await CacheService.instance.isConnected;
      if (!isConnected) return;

      await loadEvents(refresh: true);
    } catch (e) {
      debugPrint('Error loading fresh data: $e');
    }
  }

  /// Load events with pagination
  Future<void> loadEvents({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 0;
      _lastDocument = null;
      _hasMoreEvents = true;
      _events.clear();
      _eventCache.clear();
    }

    _setLoading(true);
    PerformanceService.instance.startOperation('load_events');

    try {
      final isConnected = await CacheService.instance.isConnected;

      if (!isConnected) {
        // Use cached data when offline
        await _loadCachedData();
        return;
      }

      // Load from API with pagination
      final newEvents = await _loadEventsPage();

      if (refresh) {
        _events = newEvents;
      } else {
        // Append new events, avoiding duplicates
        for (final event in newEvents) {
          if (!_eventCache.containsKey(event.id)) {
            _events.add(event);
          }
        }
      }

      // Update cache
      _updateEventCache(newEvents);

      // Trim events list if too large
      _trimEventsIfNeeded();

      // Cache for offline use
      if (_currentPage == 0) {
        await CacheService.instance.cacheEvents(_events);
      }

      _currentPage++;
      _hasMoreEvents = newEvents.length >= _pageSize;

      notifyListeners();
    } catch (e) {
      _setError('Failed to load events: $e');
    } finally {
      _setLoading(false);
      PerformanceService.instance.endOperation('load_events');
    }
  }

  /// Load a single page of events
  Future<List<Event>> _loadEventsPage() async {
    try {
      // Use cached API response if available
      final cacheKey = 'events_page_$_currentPage';
      final cachedResponse = await CacheService.instance.getCachedApiResponse(
        cacheKey,
      );

      if (cachedResponse != null) {
        return (cachedResponse as List).map((e) => Event.fromJson(e)).toList();
      }

      // Load from API
      final events = await _rapidAPIService.searchEvents(
        query: 'events',
        location: 'San Francisco, CA',
        limit: _pageSize,
      );

      // Cache the response
      await CacheService.instance.cacheApiResponse(cacheKey, {
        'events': events.map((e) => e.toJson()).toList(),
        'count': events.length,
      });

      return events;
    } catch (e) {
      debugPrint('Error loading events page: $e');
      return [];
    }
  }

  /// Load more events (pagination)
  Future<void> loadMoreEvents() async {
    if (_isLoadingMore || !_hasMoreEvents) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      await loadEvents(refresh: false);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Search events with debouncing
  Future<void> searchEvents(String query) async {
    // Cancel previous search
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      _searchResults.clear();
      _lastSearchQuery = '';
      notifyListeners();
      return;
    }

    // Debounce search to avoid excessive API calls
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (query == _lastSearchQuery) return;

      _lastSearchQuery = query;
      PerformanceService.instance.startOperation('search_events');

      try {
        // First search in local cache
        final localResults = _searchInCache(query);

        if (localResults.isNotEmpty) {
          _searchResults = localResults;
          notifyListeners();
        }

        // Then search via API
        final isConnected = await CacheService.instance.isConnected;
        if (isConnected) {
          final apiResults = await _rapidAPIService.searchEvents(
            query: query,
            location: 'San Francisco, CA',
            limit: 30,
          );

          _searchResults = apiResults;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Search error: $e');
      } finally {
        PerformanceService.instance.endOperation('search_events');
      }
    });
  }

  /// Search in local cache
  List<Event> _searchInCache(String query) {
    final lowercaseQuery = query.toLowerCase();

    return _eventCache.values
        .where((event) {
          return event.title.toLowerCase().contains(lowercaseQuery) ||
              event.description.toLowerCase().contains(lowercaseQuery) ||
              event.venue.name.toLowerCase().contains(lowercaseQuery);
        })
        .take(20)
        .toList();
  }

  /// Load nearby events
  Future<void> loadNearbyEvents() async {
    if (_userLatitude == null || _userLongitude == null) return;

    PerformanceService.instance.startOperation('load_nearby');

    try {
      final isConnected = await CacheService.instance.isConnected;
      if (!isConnected) {
        // Use cached nearby events
        _nearbyEvents = _events.take(10).toList();
        notifyListeners();
        return;
      }

      final events = await _rapidAPIService.getEventsNearLocation(
        latitude: _userLatitude!,
        longitude: _userLongitude!,
        radiusKm: _searchRadius,
        limit: 30,
      );

      _nearbyEvents = events;
      _updateEventCache(events);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading nearby events: $e');
    } finally {
      PerformanceService.instance.endOperation('load_nearby');
    }
  }

  /// Set user location
  void setUserLocation(double latitude, double longitude) {
    _userLatitude = latitude;
    _userLongitude = longitude;
    loadNearbyEvents();
  }

  /// Get event by ID with caching
  Event? getEventById(String eventId) {
    // Mark as viewed for memory management
    _viewedEventIds.add(eventId);

    return _eventCache[eventId];
  }

  /// Update event cache
  void _updateEventCache(List<Event> events) {
    for (final event in events) {
      _eventCache[event.id] = event;
    }
  }

  /// Trim events list if too large to prevent memory issues
  void _trimEventsIfNeeded() {
    if (_events.length > _maxEventsInMemory) {
      // Keep only the most recent events
      final recentEvents = _events
          .skip(_events.length - _maxEventsInMemory)
          .toList();

      // Keep viewed events in cache
      final viewedEvents = _events
          .where((e) => _viewedEventIds.contains(e.id))
          .toList();

      _events = {...recentEvents, ...viewedEvents}.toList();

      // Clean up cache
      final keepIds = _events.map((e) => e.id).toSet();
      _eventCache.removeWhere((key, value) => !keepIds.contains(key));
    }
  }

  /// Start periodic cleanup to prevent memory leaks
  void _startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _performCleanup();
    });
  }

  /// Perform memory cleanup
  void _performCleanup() {
    // Clear old viewed event IDs
    if (_viewedEventIds.length > 100) {
      _viewedEventIds.clear();
    }

    // Trim events if needed
    _trimEventsIfNeeded();

    // Clear old search results
    if (_searchResults.length > 50) {
      _searchResults = _searchResults.take(30).toList();
    }

    // Trigger garbage collection hint
    if (kDebugMode) {
      debugPrint('Performing events provider cleanup');
    }
  }

  /// Set filters
  void setFilters({EventCategory? category, double? radius}) {
    _selectedCategory = category;
    if (radius != null) _searchRadius = radius;

    // Reload with new filters
    loadEvents(refresh: true);
  }

  /// Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _searchRadius = AppConfig.defaultSearchRadius;
    notifyListeners();
  }

  /// Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _cleanupTimer?.cancel();
    _events.clear();
    _eventCache.clear();
    _searchResults.clear();
    _viewedEventIds.clear();
    super.dispose();
  }
}
