import '../models/event.dart';
import '../services/rapidapi_events_service.dart';
import '../services/logging_service.dart';

class SampleEvents {
  static final RapidAPIEventsService _rapidApiService = RapidAPIEventsService();
  static List<Event>? _cachedEvents;
  static DateTime? _lastFetchTime;
  static const Duration _cacheExpiry = Duration(hours: 2);

  /// Get real events from RapidAPI only
  static Future<List<Event>> getDemoEvents() async {
    // Check cache first
    if (_cachedEvents != null && _lastFetchTime != null) {
      final cacheAge = DateTime.now().difference(_lastFetchTime!);
      if (cacheAge < _cacheExpiry) {
        return _cachedEvents!;
      }
    }

    // Fetch real events from RapidAPI
    final realEvents = await _fetchRealEvents();

    // Remove duplicates
    final uniqueEvents = _removeDuplicateEvents(realEvents);

    // Cache the results
    _cachedEvents = uniqueEvents;
    _lastFetchTime = DateTime.now();

    return uniqueEvents;
  }

  /// Fetch real events from multiple RapidAPI endpoints
  static Future<List<Event>> _fetchRealEvents() async {
    final List<Event> allEvents = [];

    try {
      // Fetch trending events
      final trendingEvents = await _rapidApiService.getTrendingEvents(
        location: 'San Francisco, CA',
        limit: 15,
      );
      allEvents.addAll(trendingEvents);

      // Fetch music events
      final musicEvents = await _rapidApiService.searchEvents(
        query: 'music concert festival',
        location: 'Los Angeles, CA',
        limit: 10,
      );
      allEvents.addAll(musicEvents);

      // Fetch food events
      final foodEvents = await _rapidApiService.searchEvents(
        query: 'food festival restaurant',
        location: 'San Diego, CA',
        limit: 8,
      );
      allEvents.addAll(foodEvents);

      // Fetch sports events
      final sportsEvents = await _rapidApiService.searchEvents(
        query: 'sports game tournament',
        location: 'Seattle, WA',
        limit: 8,
      );
      allEvents.addAll(sportsEvents);

      // Fetch arts events
      final artsEvents = await _rapidApiService.searchEvents(
        query: 'art exhibition gallery',
        location: 'Portland, OR',
        limit: 6,
      );
      allEvents.addAll(artsEvents);

      // Fetch tech events
      final techEvents = await _rapidApiService.searchEvents(
        query: 'technology conference workshop',
        location: 'San Jose, CA',
        limit: 6,
      );
      allEvents.addAll(techEvents);

      // Remove duplicates based on title similarity
      final uniqueEvents = _removeDuplicateEvents(allEvents);

      // Enhance events with additional demo data
      final enhancedEvents = _enhanceEventsWithDemoData(uniqueEvents);

      return enhancedEvents.take(50).toList();
    } catch (e) {
      LoggingService.error(
        'Error fetching real events',
        tag: 'SampleEvents',
        error: e,
      );
      return [];
    }
  }

  /// Remove duplicate events based on title similarity
  static List<Event> _removeDuplicateEvents(List<Event> events) {
    final Map<String, Event> uniqueEvents = {};

    for (final event in events) {
      final normalizedTitle = event.title.toLowerCase().trim();
      if (!uniqueEvents.containsKey(normalizedTitle)) {
        uniqueEvents[normalizedTitle] = event;
      }
    }

    return uniqueEvents.values.toList();
  }

  /// Enhance events with additional demo data
  static List<Event> _enhanceEventsWithDemoData(List<Event> events) {
    return events.map((event) {
      // Add some demo-specific enhancements
      return event.copyWith(
        // You can add additional demo data here if needed
        // For now, just return the event as-is
      );
    }).toList();
  }

  // Helper methods for filtering real events
  static Future<List<Event>> getFeaturedEvents() async {
    final events = await getDemoEvents();
    return events.where((event) => event.isFeatured).toList();
  }

  static Future<List<Event>> getEventsByCategory(EventCategory category) async {
    final events = await getDemoEvents();
    return events.where((event) => event.category == category).toList();
  }

  static Future<List<Event>> getFreeEvents() async {
    final events = await getDemoEvents();
    return events.where((event) => event.pricing.isFree).toList();
  }

  static Future<List<Event>> getTodaysEvents() async {
    final events = await getDemoEvents();
    final today = DateTime.now();
    return events.where((event) {
      return event.startDateTime.year == today.year &&
          event.startDateTime.month == today.month &&
          event.startDateTime.day == today.day;
    }).toList();
  }

  static Future<List<Event>> getWeekendEvents() async {
    final events = await getDemoEvents();
    return events.where((event) {
      final weekday = event.startDateTime.weekday;
      return weekday == DateTime.saturday || weekday == DateTime.sunday;
    }).toList();
  }

  static Future<List<Event>> getUpcomingEvents() async {
    final events = await getDemoEvents();
    final now = DateTime.now();
    return events.where((event) => event.startDateTime.isAfter(now)).toList();
  }

  static Future<List<Event>> searchEvents(String query) async {
    final events = await getDemoEvents();
    final lowercaseQuery = query.toLowerCase();
    return events.where((event) {
      return event.title.toLowerCase().contains(lowercaseQuery) ||
          event.description.toLowerCase().contains(lowercaseQuery) ||
          event.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
          (event.venue.city?.toLowerCase() ?? '').contains(lowercaseQuery);
    }).toList();
  }

  /// Clear cached events to force refresh
  static void clearCache() {
    _cachedEvents = null;
    _lastFetchTime = null;
  }

  /// Get cache status
  static bool get hasCachedEvents => _cachedEvents != null;
  static DateTime? get lastFetchTime => _lastFetchTime;
}
