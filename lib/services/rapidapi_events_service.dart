import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/event.dart';

class RapidAPIEventsService {
  static const String _baseUrl = 'https://real-time-events-search.p.rapidapi.com';
  static const String _apiKey = '92bc1b4fc7mshacea9f118bf7a3fp1b5a6cjsnd2287a72fcb9';
  static const String _apiHost = 'real-time-events-search.p.rapidapi.com';
  
  final Dio _dio;
  
  RapidAPIEventsService() : _dio = Dio() {
    _dio.options.headers = {
      'x-rapidapi-key': _apiKey,
      'x-rapidapi-host': _apiHost,
    };
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }
  
  /// Search for events based on query and location
  Future<List<Event>> searchEvents({
    required String query,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'query': query,
        if (location != null) 'location': location,
        if (startDate != null) 'start': startDate.toIso8601String(),
        if (endDate != null) 'end': endDate.toIso8601String(),
        'limit': limit.toString(),
      };
      
      final response = await _dio.get(
        '/search-events',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => _parseEventFromAPI(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }
  
  /// Get events near a specific location
  Future<List<Event>> getEventsNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/events-near-location',
        queryParameters: {
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'radius': radiusKm.toString(),
          'limit': limit.toString(),
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => _parseEventFromAPI(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting events near location: $e');
      return [];
    }
  }
  
  /// Get trending events
  Future<List<Event>> getTrendingEvents({
    String? location,
    int limit = 20,
  }) async {
    try {
      print('Calling RapidAPI trending-events endpoint...');
      final queryParams = {
        if (location != null) 'location': location,
        'limit': limit.toString(),
      };
      
      print('Request params: $queryParams');
      // Use search endpoint as trending endpoint doesn't exist
      final response = await _dio.get(
        '/search-events',
        queryParameters: {
          'query': 'events trending music concert sports',
          ...queryParams,
        },
      );
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        print('Response data: ${data.toString().substring(0, 200 < data.toString().length ? 200 : data.toString().length)}...');
        if (data['data'] != null && data['data'] is List) {
          final events = (data['data'] as List)
              .map((json) => _parseEventFromAPI(json))
              .toList();
          print('Parsed ${events.length} events from API');
          return events;
        }
      }
      print('No events found in response');
      return [];
    } catch (e) {
      print('Error getting trending events: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }
  
  /// Get event details by ID
  Future<Event?> getEventDetails(String eventId) async {
    try {
      final response = await _dio.get(
        '/event-details',
        queryParameters: {
          'event_id': eventId,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return _parseEventFromAPI(response.data['data'] ?? response.data);
      }
      return null;
    } catch (e) {
      print('Error getting event details: $e');
      return null;
    }
  }
  
  /// Get events by category
  Future<List<Event>> getEventsByCategory({
    required String category,
    String? location,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'category': category,
        if (location != null) 'location': location,
        'limit': limit.toString(),
      };
      
      final response = await _dio.get(
        '/events-by-category',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => _parseEventFromAPI(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting events by category: $e');
      return [];
    }
  }
  
  /// Parse event from API response  
  Event _parseEventFromAPI(Map<String, dynamic> json) {
    // Extract basic information
    final String id = json['event_id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    final String title = json['name'] ?? 'Untitled Event';
    final String description = json['description'] ?? '';
    
    // Parse dates
    DateTime startDateTime = DateTime.now();
    DateTime? endDateTime;
    
    if (json['start_time'] != null) {
      try {
        startDateTime = DateTime.parse(json['start_time']);
      } catch (e) {
        if (json['date'] != null) {
          try {
            startDateTime = DateTime.parse(json['date']);
          } catch (e) {
            // Keep default
          }
        }
      }
    }
    
    if (json['end_time'] != null) {
      try {
        endDateTime = DateTime.parse(json['end_time']);
      } catch (e) {
        // Optional field
      }
    }
    
    // Parse venue
    final venue = _parseVenueFromAPI(json);
    
    // Parse category
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
    
    // Parse pricing
    EventPricing pricing;
    if (json['price'] != null) {
      final priceData = json['price'];
      if (priceData is Map) {
        pricing = EventPricing(
          isFree: priceData['is_free'] ?? false,
          price: (priceData['min'] ?? priceData['amount'] ?? 0).toDouble(),
          currency: priceData['currency'] ?? 'USD',
          priceDescription: priceData['description'],
        );
      } else if (priceData is num) {
        pricing = EventPricing(
          isFree: priceData == 0,
          price: priceData.toDouble(),
          currency: 'USD',
        );
      } else {
        pricing = const EventPricing(isFree: true, price: 0, currency: 'USD');
      }
    } else {
      pricing = const EventPricing(isFree: true, price: 0, currency: 'USD');
    }
    
    // Parse images
    List<String> imageUrls = [];
    if (json['thumbnail'] != null) {
      imageUrls.add(json['thumbnail']);
    } else if (json['image'] != null) {
      imageUrls.add(json['image']);
    } else if (json['images'] != null && json['images'] is List) {
      imageUrls = List<String>.from(json['images']);
    }
    
    // Default image if none provided
    if (imageUrls.isEmpty) {
      imageUrls.add('https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800');
    }
    
    // Parse organizer
    final organizerName = json['publisher'] ?? json['organizer_name'] ?? 'Event Organizer';
    final organizerImageUrl = json['publisher_favicon'] ?? json['organizer_image'];
    
    // Parse tags
    List<String> tags = [];
    if (json['tags'] != null && json['tags'] is List) {
      tags = List<String>.from(json['tags']);
    } else if (json['keywords'] != null && json['keywords'] is List) {
      tags = List<String>.from(json['keywords']);
    }
    
    return Event(
      id: id,
      title: title,
      description: description,
      organizerName: organizerName,
      organizerImageUrl: organizerImageUrl,
      venue: venue,
      imageUrls: imageUrls,
      category: category,
      pricing: pricing,
      startDateTime: startDateTime,
      endDateTime: endDateTime ?? startDateTime.add(const Duration(hours: 2)),
      tags: tags,
      attendeeCount: json['attendee_count'] ?? json['interested_count'] ?? 0,
      maxAttendees: json['max_attendees'] ?? json['capacity'] ?? 0,
      favoriteCount: json['favorite_count'] ?? 0,
      status: EventStatus.active,
      websiteUrl: json['link'] ?? json['website'],
      ticketUrl: json['link'] ?? json['ticket_url'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      isFeatured: json['is_featured'] ?? json['is_trending'] ?? false,
      isPremium: json['is_premium'] ?? false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'rapidapi',
    );
  }
  
  /// Parse venue from API response
  EventVenue _parseVenueFromAPI(Map<String, dynamic> json) {
    // Try to extract venue data from various possible locations in the JSON
    Map<String, dynamic>? venueData = json['venue'] ?? json['location'];
    
    String name = 'Unknown Venue';
    String? address;
    String? city;
    String? state;
    String? country;
    String? postalCode;
    double? latitude;
    double? longitude;
    
    if (venueData != null && venueData is Map) {
      name = venueData['name'] ?? name;
      address = venueData['street'] ?? venueData['full_address'] ?? venueData['address'];
      city = venueData['city'] ?? city;
      state = venueData['state'] ?? state;
      country = venueData['country'] ?? country;
      postalCode = venueData['zipcode'] ?? venueData['postal_code'];
      latitude = venueData['latitude'] is num ? venueData['latitude'].toDouble() : latitude;
      longitude = venueData['longitude'] is num ? venueData['longitude'].toDouble() : longitude;
    } else {
      // Try to extract from flat structure
      // Sometimes venue info is inline
      name = 'Event Location';
      city = 'San Francisco';
      state = 'CA';
      country = 'USA';
      
      if (json['coordinates'] != null) {
        latitude = json['coordinates']['lat'] ?? json['coordinates']['latitude'];
        longitude = json['coordinates']['lng'] ?? json['coordinates']['longitude'];
      } else {
        latitude = json['latitude'] ?? json['lat'];
        longitude = json['longitude'] ?? json['lng'] ?? json['lon'];
      }
    }
    
    // Build full address
    String fullAddress = '';
    if (address != null) fullAddress = address;
    if (city != null) {
      if (fullAddress.isNotEmpty) fullAddress += ', ';
      fullAddress += city;
    }
    if (state != null) {
      if (fullAddress.isNotEmpty) fullAddress += ', ';
      fullAddress += state;
    }
    if (country != null) {
      if (fullAddress.isNotEmpty) fullAddress += ', ';
      fullAddress += country;
    }
    
    // Default coordinates if not provided (San Francisco)
    latitude ??= 37.7749;
    longitude ??= -122.4194;
    
    return EventVenue(
      name: name,
      address: address ?? 'Address not available',
      city: city ?? 'San Francisco',
      state: state ?? 'CA',
      country: country ?? 'USA',
      zipCode: postalCode ?? '',
      latitude: latitude,
      longitude: longitude,
      description: venueData?['description'],
      imageUrl: venueData?['image_url'] ?? venueData?['photo'],
      websiteUrl: venueData?['website'] ?? venueData?['url'],
      phoneNumber: venueData?['phone'] ?? venueData?['contact'],
    );
  }
}