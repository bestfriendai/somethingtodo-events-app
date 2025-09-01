import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/event.dart';

class RapidAPIEventsService {
  late final Dio _dio;

  RapidAPIEventsService() {
    _dio = Dio();
    _dio.options.baseUrl = 'https://real-time-events-search.p.rapidapi.com';
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers['x-rapidapi-key'] = AppConfig.rapidApiKey;
    _dio.options.headers['x-rapidapi-host'] = 'real-time-events-search.p.rapidapi.com';
  }

  Future<List<Event>> searchEvents({
    required String query,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/search-events',
        queryParameters: {
          'query': query,
          if (location != null) 'location': location,
          if (startDate != null) 'start': startDate.toIso8601String(),
          if (endDate != null) 'end': endDate.toIso8601String(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => _parseEventFromAPI(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Event>> getEventsNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/search-events',
        queryParameters: {
          'query': 'events',
          'location': '$latitude,$longitude',
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          final events = (data['data'] as List)
              .map((e) => _parseEventFromAPI(Map<String, dynamic>.from(e as Map)))
              .toList();
          return events;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Event>> getTrendingEvents({
    String? location,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/search-events',
        queryParameters: {
          'query': 'trending events music concert sports',
          if (location != null) 'location': location,
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => _parseEventFromAPI(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Event?> getEventDetails(String eventId) async {
    try {
      final response = await _dio.get(
        '/event-details',
        queryParameters: {
          'event_id': eventId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          return _parseEventFromAPI(Map<String, dynamic>.from(data['data'] as Map));
        }
        if (data is Map) return _parseEventFromAPI(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Event>> getEventsByCategory({
    required String category,
    String? location,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/search-events',
        queryParameters: {
          'query': '$category events',
          if (location != null) 'location': location,
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => _parseEventFromAPI(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Event _parseEventFromAPI(Map<String, dynamic> json) {
    final String id = json['event_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    final String title = (json['name'] ?? json['title'] ?? 'Untitled Event').toString();
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
      address: (venueJson['full_address'] ?? venueJson['address'] ?? '').toString(),
      city: (venueJson['city'] ?? '').toString(),
      state: (venueJson['state'] ?? '').toString(),
      country: (venueJson['country'] ?? '').toString(),
      latitude: venueJson['latitude'] is num ? (venueJson['latitude'] as num).toDouble() : 0.0,
      longitude: venueJson['longitude'] is num ? (venueJson['longitude'] as num).toDouble() : 0.0,
    );

    EventCategory category = EventCategory.other;
    final categoryString = (json['category'] ?? json['type'] ?? '').toString().toLowerCase();

    if (categoryString.contains('music') || categoryString.contains('concert')) {
      category = EventCategory.music;
    } else if (categoryString.contains('sport')) {
      category = EventCategory.sports;
    } else if (categoryString.contains('art') || categoryString.contains('exhibit')) {
      category = EventCategory.arts;
    } else if (categoryString.contains('food') || categoryString.contains('restaurant')) {
      category = EventCategory.food;
    } else if (categoryString.contains('tech') || categoryString.contains('conference')) {
      category = EventCategory.technology;
    } else if (categoryString.contains('business') || categoryString.contains('network')) {
      category = EventCategory.business;
    } else if (categoryString.contains('education') || categoryString.contains('workshop')) {
      category = EventCategory.education;
    } else if (categoryString.contains('health') || categoryString.contains('wellness')) {
      category = EventCategory.health;
    } else if (categoryString.contains('community') || categoryString.contains('social')) {
      category = EventCategory.community;
    }

    final pricing = const EventPricing(isFree: true, price: 0, currency: 'USD');

    List<String> imageUrls = [];
    if (json['thumbnail'] != null) {
      imageUrls.add(json['thumbnail'].toString());
    }
    if (imageUrls.isEmpty) {
      imageUrls.add('https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800');
    }

    final organizerName = (json['publisher'] ?? json['organizer_name'] ?? 'Event Organizer').toString();

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
}