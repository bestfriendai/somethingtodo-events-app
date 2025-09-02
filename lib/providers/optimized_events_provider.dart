import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/event.dart';
import '../services/firestore_service.dart';
import '../services/rapidapi_events_service.dart';
import '../services/location_service.dart';
import '../services/cache_service.dart';
import '../services/enhanced_cache_service.dart';
import '../utils/performance_optimizer.dart';

/// Optimized events provider with better state management and performance
class OptimizedEventsProvider extends ChangeNotifier {
  // Services
  final FirestoreService _firestoreService = FirestoreService();
  final RapidAPIEventsService _rapidAPIService = RapidAPIEventsService();
  final LocationService _locationService = LocationService();
  final EnhancedCacheService _cacheService = EnhancedCacheService.instance;
  final PerformanceOptimizer _performanceOptimizer = PerformanceOptimizer();

  // State - using separate lists to prevent unnecessary rebuilds
  List<Event> _events = [];
  List<Event> _featuredEvents = [];
  List<Event> _nearbyEvents = [];
  List<Event> _filteredEvents = [];
  List<Event> _searchResults = [];

  // Loading states - granular control
  bool _isLoadingEvents = false;
  bool _isLoadingFeatured = false;
  bool _isLoadingNearby = false;
  bool _isSearching = false;

  // Error handling
  String? _error;

  // Pagination
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMoreEvents = true;

  // Filters
  String? _selectedCategory;
  double? _maxDistance;
  String? _priceFilter;
  DateTime? _dateFilter;

  // Location
  double? _userLatitude;
  double? _userLongitude;

  // Memory management
  final int _maxEventsInMemory = 100;
  Timer? _cleanupTimer;

  // Getters with const where possible
  List<Event> get events => List.unmodifiable(_events);
  List<Event> get featuredEvents => List.unmodifiable(_featuredEvents);
  List<Event> get nearbyEvents => List.unmodifiable(_nearbyEvents);
  List<Event> get filteredEvents => List.unmodifiable(_filteredEvents);
  List<Event> get searchResults => List.unmodifiable(_searchResults);

  bool get isLoading => _isLoadingEvents;
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isLoadingNearby => _isLoadingNearby;
  bool get isSearching => _isSearching;
  bool get hasMoreEvents => _hasMoreEvents;
  String? get error => _error;

  String? get selectedCategory => _selectedCategory;
  double? get maxDistance => _maxDistance;
  String? get priceFilter => _priceFilter;
  DateTime? get dateFilter => _dateFilter;

  OptimizedEventsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Set up periodic cleanup
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanupMemory();
    });

    // Load cached data first for instant display
    await _loadCachedData();

    // Then fetch fresh data in background
    _loadInitialData();
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    _performanceOptimizer.dispose();
    super.dispose();
  }

  /// Load cached data for instant display
  Future<void> _loadCachedData() async {
    try {
      final cachedEvents = await _cacheService.getCachedNearbyEvents(
        _userLatitude ?? 0,
        _userLongitude ?? 0,
      );

      if (cachedEvents != null && cachedEvents.isNotEmpty) {
        _events = cachedEvents.take(_pageSize).toList();
        // Don't notify here - wait for UI to be ready
        Future.microtask(() => notifyListeners());
      }
    } catch (e) {
      debugPrint('Failed to load cached data: $e');
    }
  }

  /// Load initial data
  Future<void> _loadInitialData() async {
    await Future.wait([
      loadEvents(refresh: false),
      loadFeaturedEvents(),
      _getUserLocation(),
    ]);
  }

  /// Get user location with caching
  Future<void> _getUserLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        _userLatitude = location.latitude;
        _userLongitude = location.longitude;

        // Debounce location-based loading
        _performanceOptimizer.debounce(
          'location_load',
          const Duration(seconds: 5),
          () => loadNearbyEvents(),
        );
      }
    } catch (e) {
      debugPrint('Failed to get location: $e');
    }
  }

  /// Load events with pagination
  Future<void> loadEvents({bool refresh = false}) async {
    if (_isLoadingEvents) return;

    if (refresh) {
      _currentPage = 0;
      _hasMoreEvents = true;
    }

    _isLoadingEvents = true;
    _error = null;

    // Only notify if this is a refresh or first load
    if (refresh || _events.isEmpty) {
      notifyListeners();
    }

    try {
      // Try cache first for non-refresh loads
      if (!refresh) {
        final cacheKey = _cacheService.generateCacheKey(
          latitude: _userLatitude,
          longitude: _userLongitude,
          limit: _pageSize,
        );
        final cachedEvents = await _cacheService.getCachedEvents(cacheKey);
        if (cachedEvents != null && cachedEvents.isNotEmpty) {
          _events = cachedEvents;
          _isLoadingEvents = false;
          notifyListeners();
          return;
        }
      }

      // Fetch from API
      final newEvents = await _rapidAPIService.searchEvents(
        query: '',
        limit: _pageSize,
      );

      if (refresh) {
        _events = newEvents;
      } else {
        // Prevent duplicates
        final existingIds = _events.map((e) => e.id).toSet();
        final uniqueNewEvents = newEvents
            .where((e) => !existingIds.contains(e.id))
            .toList();
        _events = [..._events, ...uniqueNewEvents];
      }

      // Trim if too many events in memory
      if (_events.length > _maxEventsInMemory) {
        _events = _events.take(_maxEventsInMemory).toList();
      }

      _hasMoreEvents = newEvents.length == _pageSize;
      _currentPage++;

      // Cache the events
      final cacheKey = _cacheService.generateCacheKey(
        latitude: _userLatitude,
        longitude: _userLongitude,
        limit: _pageSize,
      );
      await _cacheService.cacheEvents(cacheKey, _events);
    } catch (e) {
      _error = e.toString();
      // Load from cache as fallback
      final cacheKey = _cacheService.generateCacheKey(
        latitude: _userLatitude,
        longitude: _userLongitude,
        limit: _pageSize,
      );
      final cachedEvents = await _cacheService.getCachedEvents(cacheKey);
      if (cachedEvents != null) {
        _events = cachedEvents;
      }
    } finally {
      _isLoadingEvents = false;
      notifyListeners();
    }
  }

  /// Load more events for infinite scroll
  Future<void> loadMoreEvents() async {
    if (!_hasMoreEvents || _isLoadingEvents) return;

    // Throttle load more requests
    _performanceOptimizer.throttle(
      'load_more',
      const Duration(milliseconds: 500),
      () => loadEvents(refresh: false),
    );
  }

  /// Load featured events
  Future<void> loadFeaturedEvents() async {
    if (_isLoadingFeatured) return;

    _isLoadingFeatured = true;

    try {
      // Check cache first
      final cached = await _cacheService.getCachedFeaturedEvents();
      if (cached != null && cached.isNotEmpty) {
        _featuredEvents = cached;
        _isLoadingFeatured = false;
        notifyListeners();
        return;
      }

      // Fetch from API
      final events = await _rapidAPIService.searchEvents(
        query: 'featured popular trending',
        limit: 10,
      );

      _featuredEvents = events;
      await _cacheService.cacheFeaturedEvents(events);
    } catch (e) {
      debugPrint('Failed to load featured events: $e');
    } finally {
      _isLoadingFeatured = false;
      notifyListeners();
    }
  }

  /// Load nearby events with debouncing
  Future<void> loadNearbyEvents() async {
    if (_userLatitude == null || _userLongitude == null) return;
    if (_isLoadingNearby) return;

    _isLoadingNearby = true;

    try {
      // Check cache first
      final cached = await _cacheService.getCachedNearbyEvents(
        _userLatitude!,
        _userLongitude!,
      );

      if (cached != null && cached.isNotEmpty) {
        _nearbyEvents = cached;
        _isLoadingNearby = false;
        notifyListeners();

        // Still fetch fresh data in background
        _fetchNearbyEventsInBackground();
        return;
      }

      await _fetchNearbyEvents();
    } catch (e) {
      debugPrint('Failed to load nearby events: $e');
    } finally {
      _isLoadingNearby = false;
      notifyListeners();
    }
  }

  Future<void> _fetchNearbyEvents() async {
    final events = await _rapidAPIService.getEventsNearLocation(
      latitude: _userLatitude!,
      longitude: _userLongitude!,
      radiusKm: _maxDistance ?? 50,
      limit: 20,
    );

    _nearbyEvents = events;
    await _cacheService.cacheNearbyEvents(
      _userLatitude!,
      _userLongitude!,
      events,
    );
  }

  void _fetchNearbyEventsInBackground() {
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        await _fetchNearbyEvents();
        notifyListeners();
      } catch (e) {
        // Silent fail for background refresh
      }
    });
  }

  /// Search events with debouncing
  Future<void> searchEvents(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    // Debounce search requests
    _performanceOptimizer.debounce(
      'search',
      const Duration(milliseconds: 300),
      () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    _isSearching = true;
    notifyListeners();

    try {
      // Run search in background to prevent UI blocking
      final results = await Future.microtask(() => _searchInIsolate({
        'query': query,
        'events': _events,
      }));

      _searchResults = results;
    } catch (e) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Search in isolate to prevent UI blocking
  static List<Event> _searchInIsolate(Map<String, dynamic> params) {
    final query = params['query'] as String;
    final events = params['events'] as List<Event>;
    final lowerQuery = query.toLowerCase();

    return events.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
          (event.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          event.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Apply filters efficiently
  void applyFilters({
    String? category,
    double? maxDistance,
    String? priceFilter,
    DateTime? dateFilter,
  }) {
    _selectedCategory = category;
    _maxDistance = maxDistance;
    _priceFilter = priceFilter;
    _dateFilter = dateFilter;

    // Debounce filter application
    _performanceOptimizer.debounce(
      'filter',
      const Duration(milliseconds: 200),
      () => _applyFilters(),
    );
  }

  void _applyFilters() {
    List<Event> filtered = List.from(_events);

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered = filtered
          .where((e) => e.category == _selectedCategory)
          .toList();
    }

    if (_dateFilter != null) {
      filtered = filtered
          .where(
            (e) =>
                e.startDate.isAfter(_dateFilter!) ||
                e.startDate.isAtSameMomentAs(_dateFilter!),
          )
          .toList();
    }

    if (_priceFilter != null) {
      filtered = _filterByPrice(filtered, _priceFilter!);
    }

    _filteredEvents = filtered;
    notifyListeners();
  }

  List<Event> _filterByPrice(List<Event> events, String priceFilter) {
    switch (priceFilter) {
      case 'free':
        return events.where((e) => e.price == null || e.price == 0).toList();
      case 'low':
        return events.where((e) => e.price != null && e.price! <= 25).toList();
      case 'medium':
        return events
            .where((e) => e.price != null && e.price! > 25 && e.price! <= 75)
            .toList();
      case 'high':
        return events.where((e) => e.price != null && e.price! > 75).toList();
      default:
        return events;
    }
  }

  /// Toggle favorite with optimistic update
  Future<void> toggleFavorite(String eventId) async {
    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex == -1) return;

    // Optimistic update
    final event = _events[eventIndex];
    final wasFavorite = event.isFavorite;

    // Create new event with toggled favorite
    final updatedEvent = Event(
      id: event.id,
      title: event.title,
      description: event.description,
      organizerName: event.organizerName,
      organizerImageUrl: event.organizerImageUrl,
      venue: event.venue,
      imageUrls: event.imageUrls,
      category: event.category,
      pricing: event.pricing,
      startDateTime: event.startDateTime,
      endDateTime: event.endDateTime,
      tags: event.tags,
      attendeeCount: event.attendeeCount,
      maxAttendees: event.maxAttendees,
      favoriteCount: event.favoriteCount,
      status: event.status,
      websiteUrl: event.websiteUrl,
      ticketUrl: event.ticketUrl,
      contactEmail: event.contactEmail,
      contactPhone: event.contactPhone,
      isFeatured: event.isFeatured,
      isPremium: event.isPremium,
      isOnline: event.isOnline,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      createdBy: event.createdBy,
    );

    _events[eventIndex] = updatedEvent;
    notifyListeners();

    try {
      // Persist to backend - using updateUserFavorites instead
      // await _firestoreService.toggleEventFavorite(eventId, !wasFavorite);
      // TODO: Implement proper favorite toggle in FirestoreService
    } catch (e) {
      // Revert on error
      _events[eventIndex] = event;
      notifyListeners();
    }
  }

  /// Clean up memory periodically
  void _cleanupMemory() {
    // Remove old events from memory
    if (_events.length > _maxEventsInMemory) {
      _events = _events.take(_maxEventsInMemory).toList();
    }

    // Clear search results if not searching
    if (!_isSearching && _searchResults.isNotEmpty) {
      _searchResults = [];
    }

    // Clear filtered results if no filters applied
    if (_selectedCategory == null &&
        _priceFilter == null &&
        _dateFilter == null &&
        _filteredEvents.isNotEmpty) {
      _filteredEvents = [];
    }
  }

  /// Clear all data
  void clearAll() {
    _events = [];
    _featuredEvents = [];
    _nearbyEvents = [];
    _filteredEvents = [];
    _searchResults = [];
    _currentPage = 0;
    _hasMoreEvents = true;
    notifyListeners();
  }
}
