import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/event.dart';
import '../services/firestore_service.dart';
import '../services/rapidapi_events_service.dart';
import '../services/cache_service.dart';
import '../services/location_service.dart';
import '../config/app_config.dart';
import '../data/sample_events.dart';

class EventsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final RapidAPIEventsService _rapidAPIService = RapidAPIEventsService();
  final LocationService _locationService = LocationService();

  // Event lists
  List<Event> _events = [];
  List<Event> _featuredEvents = [];
  List<Event> _nearbyEvents = [];
  final List<Event> _favoriteEvents = [];
  List<Event> _searchResults = [];

  // Loading states
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreEvents = true;
  String? _error;

  // Pagination
  DocumentSnapshot? _lastDocument;

  // Configuration
  bool _useDemoData = false;
  bool _useRapidAPI = true;

  // Filter state
  EventCategory? _selectedCategory;
  String _searchQuery = '';
  double? _userLatitude;
  double? _userLongitude;
  double _searchRadius = AppConfig.defaultSearchRadius;
  bool? _isFreeFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String _currentLocation = 'San Francisco, CA';

  // Getters
  List<Event> get events => _events;
  List<Event> get featuredEvents => _featuredEvents;
  List<Event> get nearbyEvents => _nearbyEvents;
  List<Event> get favoriteEvents => _favoriteEvents;
  List<Event> get searchResults => _searchResults;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreEvents => _hasMoreEvents;
  String? get error => _error;

  // Filter getters
  EventCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  double get searchRadius => _searchRadius;
  bool? get isFreeFilter => _isFreeFilter;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;
  String get currentLocation => _currentLocation;

  // Initialize
  Future<void> initialize({bool demoMode = false}) async {
    _useDemoData = demoMode;
    _useRapidAPI = !demoMode;

    // Initialize cache service
    await CacheService.instance.initialize();

    // Try to load from cache first for better perceived performance
    await _loadFromCache();

    // Always load real events
    await loadRealEvents();

    // Start background refresh
    _startBackgroundRefresh();

    // Load initial events
    await _loadInitialEvents();
  }

  Future<void> _loadInitialEvents() async {
    try {
      // Always try to get user's location first
      await _getCurrentLocation();
      if (_userLatitude != null && _userLongitude != null) {
        await loadNearbyEvents();
      } else {
        await loadRealEvents();
      }
    } catch (e) {
      print('Error loading initial events: $e');
      // Try to load real events anyway
      try {
        await loadRealEvents();
      } catch (e2) {
        print('Error loading real events: $e2');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        setUserLocation(position.latitude, position.longitude);
      } else {
        // Use default location if position is null
        setUserLocation(37.7749, -122.4194); // San Francisco
      }
    } catch (e) {
      print('Error getting current location: $e');
      // Use default location
      setUserLocation(37.7749, -122.4194); // San Francisco
    }
  }

  // Set User Location
  void setUserLocation(double latitude, double longitude) {
    _userLatitude = latitude;
    _userLongitude = longitude;
    LoggingService.info(
      'User location set to $latitude, $longitude',
      tag: 'EventsProvider',
    );
    LoggingService.info(
      'Loading nearby events for location $latitude, $longitude',
      tag: 'EventsProvider',
    );
    loadNearbyEvents();
  }

  // Load Nearby Events
  Future<void> loadNearbyEvents() async {
    if (_userLatitude == null || _userLongitude == null) {
      print('EventsProvider: Cannot load nearby events: location not set');
      return;
    }

    print(
      'EventsProvider: Loading nearby events for $_userLatitude, $_userLongitude',
    );
    _setLoading(true);
    _clearError();

    try {
      final events = await _rapidAPIService.getEventsNearLocation(
        latitude: _userLatitude!,
        longitude: _userLongitude!,
        radiusKm: _searchRadius,
        limit: 50,
      );

      _nearbyEvents = events;
      print('EventsProvider: Loaded ${events.length} nearby events');
      notifyListeners();
    } catch (e) {
      print('EventsProvider: Failed to load nearby events: $e');
      _setError('Failed to load nearby events: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load Real Events from RapidAPI
  Future<void> loadRealEvents({bool refresh = false}) async {
    if (refresh) {
      _events.clear();
      _hasMoreEvents = true;
    }

    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      print('Loading real events from RapidAPI');

      // Check connectivity
      final isConnected = await CacheService.instance.isConnected;
      if (!isConnected) {
        // Load from cache if offline
        await _loadFromCache();
        _setLoading(false);
        return;
      }

      // Load trending events first
      final trendingEvents = await _rapidAPIService.getTrendingEvents(
        location: _currentLocation,
        limit: 50,
      );

      if (trendingEvents.isNotEmpty) {
        _events = trendingEvents;
        _featuredEvents = trendingEvents.take(5).toList();
        print('Loaded ${trendingEvents.length} trending events');
      } else {
        // Fallback to general search
        final searchEvents = await _rapidAPIService.searchEvents(
          query: 'events',
          location: _currentLocation,
          limit: 50,
        );

        _events = searchEvents;
        _featuredEvents = searchEvents.take(5).toList();
        print('Loaded ${searchEvents.length} search events');
      }

      // Cache the loaded events
      await CacheService.instance.cacheEvents(_events);
      await CacheService.instance.cacheFeaturedEvents(_featuredEvents);

      _hasMoreEvents = _events.length >= 50;
      print('Total events loaded: ${_events.length}');
    } catch (e) {
      print('Failed to load real events: $e');
      _setError('Failed to load events: $e');
      // Fallback to cached data
      if (await _loadFromCache()) {
        print('Loaded from cache due to API error');
      } else {
        // Create some demo events as last resort
        _events = await _createDemoEvents();
        _featuredEvents = _events.take(5).toList();
      }
    } finally {
      _setLoading(false);
    }
  }

  // Load Demo Events
  Future<void> loadDemoEvents() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate network delay
      _events = await SampleEvents.getEvents();
      _featuredEvents = await SampleEvents.getFeaturedEvents();
      _hasMoreEvents = false;
      print('Loaded ${_events.length} demo events');
    } catch (e) {
      _setError('Failed to load demo events: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load Events (Legacy - for Firebase)
  Future<void> loadEvents({bool refresh = false}) async {
    if (_useDemoData) {
      await loadDemoEvents();
      return;
    }

    if (_useRapidAPI) {
      await loadRealEvents(refresh: refresh);
      return;
    }

    if (refresh) {
      _events.clear();
      _lastDocument = null;
      _hasMoreEvents = true;
    }

    if (_isLoading || !_hasMoreEvents) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _firestoreService.getEvents(
        lastDocument: _lastDocument,
        limit: AppConfig.eventsPerPage,
        category: _selectedCategory,
      );

      if (refresh) {
        _events = result.events;
      } else {
        _events.addAll(result.events);
      }

      _lastDocument = result.lastDocument;
      _hasMoreEvents = result.events.length == AppConfig.eventsPerPage;

      print('Loaded ${result.events.length} events from Firestore');
    } catch (e) {
      _setError('Failed to load events: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreEvents() async {
    if (_isLoadingMore || !_hasMoreEvents) return;

    if (_useRapidAPI && !_useDemoData) {
      // For RapidAPI, we load more by extending the search
      _isLoadingMore = true;
      notifyListeners();

      try {
        // Use the enhanced method to get maximum events
        final moreEvents = await _rapidAPIService.getMaximumEvents(
          query: _searchQuery.isNotEmpty ? _searchQuery : 'events',
          location: _currentLocation,
          maxEvents: 100,
        );

        // Filter out events we already have
        final newEvents = moreEvents
            .where(
              (event) => !_events.any((existing) => existing.id == event.id),
            )
            .toList();

        _events.addAll(newEvents);
        _hasMoreEvents = newEvents.isNotEmpty;

        print('Loaded ${newEvents.length} more events via enhanced method');
      } catch (e) {
        print('Failed to load more events: $e');
      } finally {
        _isLoadingMore = false;
        notifyListeners();
      }
      return;
    }

    // Original Firebase implementation
    await loadEvents();
  }

  // Load Featured Events
  Future<void> loadFeaturedEvents() async {
    if (_useDemoData) {
      _featuredEvents = await SampleEvents.getFeaturedEvents();
      notifyListeners();
      return;
    }

    try {
      _featuredEvents = _events.take(5).toList();
      notifyListeners();
    } catch (e) {
      print('Failed to load featured events: $e');
    }
  }

  // Load Favorite Events
  Future<void> loadFavoriteEvents(String userId) async {
    if (_useDemoData) {
      // In demo mode, favorites are stored locally
      _favoriteEvents.clear();
      _favoriteEvents.addAll(
        _events
            .where(
              (event) =>
                  event.favoriteCount >
                  0, // Use favoriteCount as proxy for favorites
            )
            .toList(),
      );
      notifyListeners();
      return;
    }

    try {
      final favoriteEvents = await _firestoreService.getFavoriteEvents(userId);
      _favoriteEvents.clear();
      _favoriteEvents.addAll(favoriteEvents);
      notifyListeners();
    } catch (e) {
      print('Failed to load favorite events: $e');
    }
  }

  // Search Events
  Future<void> searchEvents([String? query]) async {
    final searchQuery = query ?? _searchQuery;
    if (searchQuery.isEmpty) {
      _searchResults = _events;
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      if (_useRapidAPI && !_useDemoData) {
        final results = await _rapidAPIService.searchEvents(
          query: searchQuery,
          location: _currentLocation,
          limit: 50,
        );
        _searchResults = results;
      } else {
        // Local search for demo data or cached events
        _searchResults = _events.where((event) {
          return event.title.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              event.description.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              event.location.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }

      _searchQuery = searchQuery;
      print(
        'Search completed: ${_searchResults.length} results for "$searchQuery"',
      );
    } catch (e) {
      print('Search failed: $e');
      _setError('Search failed: $e');
      // Fallback to local search
      _searchResults = _events.where((event) {
        return event.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            event.description.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            event.location.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    } finally {
      _setLoading(false);
    }
  }

  // Toggle Favorite
  Future<void> toggleFavorite(String eventId, String userId) async {
    try {
      if (_useDemoData) {
        // In demo mode, just update the local state
        final eventIndex = _events.indexWhere((event) => event.id == eventId);
        if (eventIndex != -1) {
          final event = _events[eventIndex];
          final isFavorited = _favoriteEvents.any((fav) => fav.id == eventId);

          if (isFavorited) {
            _favoriteEvents.removeWhere((fav) => fav.id == eventId);
            _events[eventIndex] = event.copyWith(
              favoriteCount: event.favoriteCount > 0
                  ? event.favoriteCount - 1
                  : 0,
            );
          } else {
            _favoriteEvents.add(event);
            _events[eventIndex] = event.copyWith(
              favoriteCount: event.favoriteCount + 1,
            );
          }
          notifyListeners();
        }
        return;
      }

      await _firestoreService.toggleFavorite(eventId, userId);

      // Update local state
      final eventIndex = _events.indexWhere((event) => event.id == eventId);
      if (eventIndex != -1) {
        final event = _events[eventIndex];
        final isFavorited = _favoriteEvents.any((fav) => fav.id == eventId);

        if (isFavorited) {
          _favoriteEvents.removeWhere((fav) => fav.id == eventId);
          _events[eventIndex] = event.copyWith(
            favoriteCount: event.favoriteCount > 0
                ? event.favoriteCount - 1
                : 0,
          );
        } else {
          _favoriteEvents.add(event);
          _events[eventIndex] = event.copyWith(
            favoriteCount: event.favoriteCount + 1,
          );
        }
        notifyListeners();
      }
    } catch (e) {
      print('Failed to toggle favorite: $e');
    }
  }

  // Filter Methods
  void setFilters({
    EventCategory? category,
    bool? isFree,
    DateTime? startDate,
    DateTime? endDate,
    double? radius,
  }) {
    _selectedCategory = category;
    _isFreeFilter = isFree;
    _startDateFilter = startDate;
    _endDateFilter = endDate;
    if (radius != null) _searchRadius = radius;

    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _isFreeFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _searchRadius = AppConfig.defaultSearchRadius;

    notifyListeners();
  }

  void setCategory(EventCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Get Events by Category
  List<Event> getEventsByCategory(EventCategory category) {
    return _events.where((event) => event.category == category).toList();
  }

  // Get Filtered Events
  List<Event> getFilteredEvents() {
    return _events.where((event) {
      if (_selectedCategory != null && event.category != _selectedCategory)
        return false;
      if (_isFreeFilter == true && event.price > 0) return false;
      if (_isFreeFilter == false && event.price == 0) return false;
      return true;
    }).toList();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    notifyListeners();
  }

  // Helper Methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> _loadFromCache() async {
    try {
      final cachedEvents = await CacheService.instance.getCachedEvents();
      final cachedFeatured = await CacheService.instance
          .getCachedFeaturedEvents();

      if (cachedEvents?.isNotEmpty == true) {
        _events = cachedEvents!;
        if (cachedFeatured?.isNotEmpty == true) {
          _featuredEvents = cachedFeatured!;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Failed to load from cache: $e');
    }
    return false;
  }

  void _startBackgroundRefresh() {
    // Check connectivity and refresh if needed
    Connectivity().onConnectivityChanged.listen((result) async {
      final isConnected = result != ConnectivityResult.none;
      if (isConnected && _events.isEmpty) {
        await loadRealEvents();
      }
    });
  }

  // Preload event images for better performance
  void preloadEventImages() {
    final imageUrls = _events
        .where((event) => event.imageUrl.isNotEmpty)
        .map((event) => event.imageUrl)
        .take(10) // Preload first 10 images
        .toList();

    // This would be implemented with proper image preloading
    print('Preloading ${imageUrls.length} event images');
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Create demo events as fallback
  Future<List<Event>> _createDemoEvents() async {
    return await SampleEvents.getEvents();
  }
}
