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

  List<Event> _events = [];
  List<Event> _featuredEvents = [];
  List<Event> _nearbyEvents = [];
  List<Event> _favoriteEvents = [];
  List<Event> _searchResults = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreEvents = true;
  String? _error;
  DocumentSnapshot? _lastDocument;
  bool _useDemoData = false;
  bool _useRapidAPI = true; // Use RapidAPI by default

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
  
  EventCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  double get searchRadius => _searchRadius;
  bool? get isFreeFilter => _isFreeFilter;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;
  String get currentLocation => _currentLocation;

  // Initialize
  Future<void> initialize({bool demoMode = false}) async {
    _useDemoData = false; // Always use real data
    _useRapidAPI = true; // Always use RapidAPI

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
      if (!AppConfig.demoMode) {
        final position = await _locationService.getCurrentPosition();
        if (position != null) {
          setUserLocation(position.latitude, position.longitude);
        }
      }
    } catch (e) {
      print('Error getting current location: $e');
      // Continue with default location
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
      print('Loading real events from RapidAPI for location: $_currentLocation');
      
      // Check connectivity
      final isConnected = await CacheService.instance.isConnected;
      if (!isConnected) {
        // Load from cache if offline
        await _loadFromCache();
        _setLoading(false);
        return;
      }
      
      // Load trending events
      final trendingEvents = await _rapidAPIService.getTrendingEvents(
        location: _currentLocation,
        limit: 30,
      );
      
      if (trendingEvents.isNotEmpty) {
        _events = trendingEvents;
        _featuredEvents = trendingEvents.take(5).toList();
      } else {
        // Fallback to search if trending is empty
        final searchEvents = await _rapidAPIService.searchEvents(
          query: 'events',
          location: _currentLocation,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          limit: 30,
        );
        
        _events = searchEvents;
        _featuredEvents = searchEvents.take(5).toList();
      }
      
      // Cache the loaded events
      await CacheService.instance.cacheEvents(_events);
      await CacheService.instance.cacheFeaturedEvents(_featuredEvents);
      
      // Load nearby events if we have location
      if (_userLatitude != null && _userLongitude != null) {
        await loadNearbyEvents();
      }
      
      _hasMoreEvents = _events.length >= 30;
    } catch (e) {
      _setError('Failed to load events: $e');
      // Fallback to cached data or demo data
      if (await _loadFromCache()) {
        print('Loaded from cache due to API error');
      } else {
        await loadDemoEvents();
      }
    } finally {
      _setLoading(false);
    }
  }

  // Load Nearby Events
  Future<void> loadNearbyEvents() async {
    if (_userLatitude == null || _userLongitude == null) {
      print('Cannot load nearby events: location not set');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final nearby = await _rapidAPIService.getEventsNearLocation(
        latitude: _userLatitude!,
        longitude: _userLongitude!,
        radiusKm: _searchRadius,
        limit: 20,
      );

      _nearbyEvents = nearby;
      notifyListeners();
    } catch (e) {
      print('Failed to load nearby events: $e');
      _setError('Failed to load nearby events. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Search Events
  Future<void> searchEvents([String? query]) async {
    query ??= _searchQuery;
    if (query.isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    _searchQuery = query;
    _setLoading(true);
    _clearError();

    try {
      final results = await _rapidAPIService.searchEvents(
        query: query,
        location: _currentLocation,
        startDate: _startDateFilter,
        endDate: _endDateFilter,
        limit: 20,
      );

      _searchResults = results;
    } catch (e) {
      _setError('Search failed: $e');
      _searchResults = [];
    } finally {
      _setLoading(false);
    }
  }

  // Load Events by Category
  Future<void> loadEventsByCategory(EventCategory category) async {
    _selectedCategory = category;
    _setLoading(true);
    _clearError();

    try {
      if (_useRapidAPI && !_useDemoData) {
        final categoryMap = {
          EventCategory.music: 'music concerts',
          EventCategory.sports: 'sports',
          EventCategory.arts: 'arts exhibitions',
          EventCategory.food: 'food festivals',
          EventCategory.technology: 'tech conferences',
          EventCategory.business: 'business networking',
          EventCategory.education: 'education workshops',
          EventCategory.health: 'health wellness',
          EventCategory.community: 'community events',
        };
        
        final categoryQuery = categoryMap[category] ?? 'events';
        
        final categoryEvents = await _rapidAPIService.searchEvents(
          query: categoryQuery,
          location: _currentLocation,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          limit: 30,
        );
        
        _events = categoryEvents;
      } else {
        // Filter demo data
        final demo = await SampleEvents.getDemoEvents();
        _events = demo.where((event) => event.category == category).toList();
      }
    } catch (e) {
      _setError('Failed to load category events: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get Event Details
  Future<Event?> getEventDetails(String eventId) async {
    try {
      // First check if we have it locally
      Event? localEvent;
      try {
        localEvent = _events.firstWhere((event) => event.id == eventId);
      } catch (e) {
        try {
          localEvent = _searchResults.firstWhere((event) => event.id == eventId);
        } catch (e) {
          localEvent = null;
        }
      }
      
      if (localEvent != null) {
        return localEvent;
      }
      
      // Try to fetch from API
      if (_useRapidAPI && !_useDemoData) {
        return await _rapidAPIService.getEventDetails(eventId);
      }
      
      return null;
    } catch (e) {
      print('Failed to get event details: $e');
      return null;
    }
  }

  // Set Location (with optional coordinates)
  void setLocation(String location, [double? latitude, double? longitude]) {
    _currentLocation = location;
    if (latitude != null && longitude != null) {
      _userLatitude = latitude;
      _userLongitude = longitude;
    }
    notifyListeners();
    loadRealEvents(refresh: true);
  }

  // Set User Location
  void setUserLocation(double latitude, double longitude) {
    _userLatitude = latitude;
    _userLongitude = longitude;
    _currentLocation = '$latitude,$longitude'; // Update current location string
    notifyListeners();

    // Always load nearby events when location is set
    loadNearbyEvents();
  }

  // Clear Category Filter
  void clearCategoryFilter() {
    _selectedCategory = null;
    notifyListeners();
    loadRealEvents(refresh: true);
  }

  // Load Demo Events
  Future<void> loadDemoEvents() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      _events = await SampleEvents.getDemoEvents();
      _featuredEvents = await SampleEvents.getFeaturedEvents();
      _hasMoreEvents = false; // Demo has finite events
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
      final events = await _firestoreService.getEvents(
        limit: AppConfig.eventsPerPage,
        startAfter: _lastDocument,
        category: _selectedCategory,
        latitude: _userLatitude,
        longitude: _userLongitude,
        radius: _searchRadius,
        isFree: _isFreeFilter,
        startDate: _startDateFilter,
        endDate: _endDateFilter,
      );

      if (events.isEmpty) {
        _hasMoreEvents = false;
      } else {
        if (refresh) {
          _events = events;
        } else {
          _events.addAll(events);
        }
      }
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
        final moreEvents = await _rapidAPIService.searchEvents(
          query: _searchQuery.isNotEmpty ? _searchQuery : 'events',
          location: _currentLocation,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 60)),
          limit: 20,
        );
        
        // Filter out duplicates
        final existingIds = _events.map((e) => e.id).toSet();
        final newEvents = moreEvents.where((e) => !existingIds.contains(e.id)).toList();
        
        if (newEvents.isEmpty) {
          _hasMoreEvents = false;
        } else {
          _events.addAll(newEvents);
        }
      } catch (e) {
        _setError('Failed to load more events: $e');
      } finally {
        _isLoadingMore = false;
        notifyListeners();
      }
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final events = await _firestoreService.getEvents(
        limit: AppConfig.eventsPerPage,
        startAfter: _lastDocument,
        category: _selectedCategory,
        latitude: _userLatitude,
        longitude: _userLongitude,
        radius: _searchRadius,
        isFree: _isFreeFilter,
        startDate: _startDateFilter,
        endDate: _endDateFilter,
      );

      if (events.isEmpty) {
        _hasMoreEvents = false;
      } else {
        _events.addAll(events);
      }
    } catch (e) {
      _setError('Failed to load more events: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load Featured Events
  Future<void> loadFeaturedEvents() async {
    if (_useDemoData) {
      _featuredEvents = await SampleEvents.getFeaturedEvents();
      notifyListeners();
      return;
    }

    try {
      final events = await _firestoreService.getFeaturedEvents();
      _featuredEvents = events;
      notifyListeners();
    } catch (e) {
      print('Failed to load featured events: $e');
    }
  }

  // Load Favorite Events
  Future<void> loadFavoriteEvents(String userId) async {
    if (_useDemoData) {
      // In demo mode, favorites are stored locally
      _favoriteEvents = _events.where((event) => 
        event.favoriteCount > 0 // Use favoriteCount as proxy for favorites
      ).toList();
      notifyListeners();
      return;
    }

    try {
      final events = await _firestoreService.getUserFavoriteEvents(userId);
      _favoriteEvents = events;
      notifyListeners();
    } catch (e) {
      print('Failed to load favorite events: $e');
    }
  }

  // Toggle Favorite
  Future<void> toggleFavorite(Event event, String userId) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      final isFavorite = _favoriteEvents.any((e) => e.id == event.id);
      
      // Update favorites list
      if (!isFavorite) {
        _favoriteEvents.add(_events[index]);
        _events[index] = _events[index].copyWith(
          favoriteCount: _events[index].favoriteCount + 1,
        );
      } else {
        _favoriteEvents.removeWhere((e) => e.id == event.id);
        _events[index] = _events[index].copyWith(
          favoriteCount: _events[index].favoriteCount - 1,
        );
      }
      
      notifyListeners();
      
      // Save to backend if not in demo mode
      if (!_useDemoData) {
        try {
          if (!isFavorite) {
            await _firestoreService.addToFavorites(userId, event.id);
          } else {
            await _firestoreService.removeFromFavorites(userId, event.id);
          }
        } catch (e) {
          // Revert on error
          if (!isFavorite) {
            _favoriteEvents.removeWhere((e) => e.id == event.id);
            _events[index] = _events[index].copyWith(
              favoriteCount: _events[index].favoriteCount - 1,
            );
          } else {
            _favoriteEvents.add(_events[index]);
            _events[index] = _events[index].copyWith(
              favoriteCount: _events[index].favoriteCount + 1,
            );
          }
          notifyListeners();
          throw e;
        }
      }
    }
  }

  // Apply Filters
  void applyFilters({
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
    loadEvents(refresh: true);
  }

  // Clear Filters
  void clearFilters() {
    _selectedCategory = null;
    _isFreeFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _searchRadius = AppConfig.defaultSearchRadius;
    
    notifyListeners();
    loadEvents(refresh: true);
  }
  
  // Set Category
  void setCategory(EventCategory? category) {
    _selectedCategory = category;
    notifyListeners();
    if (category != null) {
      loadEventsByCategory(category);
    } else {
      loadEvents(refresh: true);
    }
  }
  
  // Get Events by Category (synchronous)
  List<Event> getEventsByCategory(EventCategory category) {
    return _events.where((event) => event.category == category).toList();
  }
  
  // Get Events This Weekend
  List<Event> getEventsThisWeekend() {
    final now = DateTime.now();
    final saturday = now.add(Duration(days: (6 - now.weekday) % 7));
    final sunday = saturday.add(const Duration(days: 1));
    final mondayMorning = sunday.add(const Duration(days: 1));
    
    return _events.where((event) {
      return event.startDateTime.isAfter(saturday) && 
             event.startDateTime.isBefore(mondayMorning);
    }).toList();
  }
  
  // Clear Search
  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    notifyListeners();
  }
  
  // Log Event View
  Future<void> logEventView(String eventId, String userId) async {
    // Log to analytics if needed
    print('Event viewed: $eventId by user: $userId');
  }
  
  // Log Event Share
  Future<void> logEventShare(String eventId, String userId) async {
    // Log to analytics if needed
    print('Event shared: $eventId by user: $userId');
  }

  // Helper methods
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
  }

  // Load from cache
  Future<bool> _loadFromCache() async {
    try {
      final cachedEvents = await CacheService.instance.getCachedEvents();
      final cachedFeatured = await CacheService.instance.getCachedFeaturedEvents();
      
      bool hasCache = false;
      
      if (cachedEvents != null && cachedEvents.isNotEmpty) {
        _events = cachedEvents;
        hasCache = true;
      }
      
      if (cachedFeatured != null && cachedFeatured.isNotEmpty) {
        _featuredEvents = cachedFeatured;
        hasCache = true;
      }
      
      if (hasCache) {
        notifyListeners();
      }
      
      return hasCache;
    } catch (e) {
      print('Error loading from cache: $e');
      return false;
    }
  }
  
  // Background refresh
  void _startBackgroundRefresh() {
    // Listen to connectivity changes
    CacheService.instance.connectivityStream.listen((isConnected) {
      if (isConnected && _events.isEmpty) {
        // Refresh when connection is restored
        loadRealEvents(refresh: true);
      }
    });
  }
  
  // Preload images for better performance
  void preloadEventImages() {
    final imageUrls = _events
        .expand((event) => event.imageUrls)
        .take(20) // Preload first 20 images
        .toList();
    
    CacheService.instance.preloadImages(imageUrls);
  }

  @override
  void dispose() {
    super.dispose();
  }
}