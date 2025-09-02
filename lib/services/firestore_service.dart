import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/event.dart';
import '../models/analytics.dart';
import '../config/app_config.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _useDemoData = false;

  // Set demo mode (deprecated - always use real data)
  void setDemoMode(bool demoMode) {
    _useDemoData = false; // Always use real data
  }

  // Collections
  CollectionReference get _eventsCollection => _firestore.collection('events');
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _analyticsCollection => _firestore.collection('analytics');

  // Event CRUD Operations
  Future<String> createEvent(Event event) async {
    try {
      final docRef = await _eventsCollection.add(event.toJson());
      
      // Update the event with its ID
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<Event?> getEvent(String eventId) async {
    try {
      final doc = await _eventsCollection.doc(eventId).get();
      if (doc.exists) {
        return Event.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      await _eventsCollection
          .doc(event.id)
          .update(event.copyWith(updatedAt: DateTime.now()).toJson());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Event Queries
  Future<List<Event>> getEvents({
    int limit = AppConfig.eventsPerPage,
    DocumentSnapshot? startAfter,
    EventCategory? category,
    String? searchQuery,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isFree,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _eventsCollection
          .where('status', isEqualTo: EventStatus.active.name)
          .orderBy('startDateTime');

      // Apply filters
      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      if (isFree != null) {
        query = query.where('pricing.isFree', isEqualTo: isFree);
      }

      if (startDate != null) {
        query = query.where('startDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('endDateTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();
      List<Event> events = querySnapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Apply location-based filtering if coordinates provided
      if (latitude != null && longitude != null && radius != null) {
        events = _filterEventsByDistance(
          events,
          latitude,
          longitude,
          radius,
        );
      }

      // Apply text search if query provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        events = _filterEventsBySearch(events, searchQuery);
      }

      return events;
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  Future<List<Event>> getFeaturedEvents({int limit = 10}) async {
    try {
      final querySnapshot = await _eventsCollection
          .where('isFeatured', isEqualTo: true)
          .where('status', isEqualTo: EventStatus.active.name)
          .orderBy('startDateTime')
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get featured events: $e');
    }
  }

  Future<List<Event>> getEventsNearby({
    required double latitude,
    required double longitude,
    double radius = AppConfig.defaultSearchRadius,
    int limit = AppConfig.eventsPerPage,
  }) async {
    try {
      // Get all active events first (Firestore doesn't support geospatial queries directly)
      final querySnapshot = await _eventsCollection
          .where('status', isEqualTo: EventStatus.active.name)
          .limit(limit * 3) // Get more to filter by distance
          .get();

      List<Event> events = querySnapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by distance
      events = _filterEventsByDistance(events, latitude, longitude, radius);

      // Sort by distance and limit results
      events = events.take(limit).toList();

      return events;
    } catch (e) {
      throw Exception('Failed to get nearby events: $e');
    }
  }

  Future<List<Event>> getUserFavoriteEvents(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      final favoriteIds = List<String>.from(userData['favoriteEventIds'] ?? []);

      if (favoriteIds.isEmpty) return [];

      // Firestore 'in' queries are limited to 10 items
      List<Event> allEvents = [];
      for (int i = 0; i < favoriteIds.length; i += 10) {
        final chunk = favoriteIds.skip(i).take(10).toList();
        final querySnapshot = await _eventsCollection
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        final events = querySnapshot.docs
            .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        allEvents.addAll(events);
      }

      return allEvents;
    } catch (e) {
      throw Exception('Failed to get favorite events: $e');
    }
  }

  // Search Events
  Future<List<Event>> searchEvents({
    required String query,
    EventCategory? category,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isFree,
    int limit = AppConfig.eventsPerPage,
  }) async {
    try {
      // Log search analytics
      await _analytics.logEvent(
        name: AnalyticsEvents.search,
        parameters: {
          'search_term': query,
          'category': category?.name ?? '',
          'location_provided': latitude != null && longitude != null,
        },
      );

      // Get events with basic filters
      final events = await getEvents(
        category: category,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        isFree: isFree,
        limit: limit * 2, // Get more to ensure we have enough after text filtering
      );

      // Apply text search
      return _filterEventsBySearch(events, query).take(limit).toList();
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  // Favorites Management
  Future<void> addToFavorites(String userId, String eventId) async {
    try {
      await _usersCollection.doc(userId).update({
        'favoriteEventIds': FieldValue.arrayUnion([eventId]),
        'updatedAt': Timestamp.now(),
      });

      // Update event favorite count
      await _eventsCollection.doc(eventId).update({
        'favoriteCount': FieldValue.increment(1),
      });

      // Log analytics
      await _analytics.logEvent(
        name: AnalyticsEvents.eventFavorite,
        parameters: {
          'user_id': userId,
          'event_id': eventId,
          'action': 'add',
        },
      );
    } catch (e) {
      throw Exception('Failed to add event to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String userId, String eventId) async {
    try {
      await _usersCollection.doc(userId).update({
        'favoriteEventIds': FieldValue.arrayRemove([eventId]),
        'updatedAt': Timestamp.now(),
      });

      // Update event favorite count
      await _eventsCollection.doc(eventId).update({
        'favoriteCount': FieldValue.increment(-1),
      });

      // Log analytics
      await _analytics.logEvent(
        name: AnalyticsEvents.eventFavorite,
        parameters: {
          'user_id': userId,
          'event_id': eventId,
          'action': 'remove',
        },
      );
    } catch (e) {
      throw Exception('Failed to remove event from favorites: $e');
    }
  }

  // Check if event is favorited by user
  Future<bool> isEventFavorited(String userId, String eventId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      final favoriteIds = List<String>.from(userData['favoriteEventIds'] ?? []);
      
      return favoriteIds.contains(eventId);
    } catch (e) {
      return false;
    }
  }

  // Analytics
  Future<void> logEventView(String userId, String eventId) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.eventView,
        parameters: {
          'user_id': userId,
          'event_id': eventId,
        },
      );

      // Update event analytics
      await _eventsCollection.doc(eventId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      // Log analytics errors silently
      print('Failed to log event view: $e');
    }
  }

  Future<void> logEventShare(String userId, String eventId, String method) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEvents.eventShare,
        parameters: {
          'user_id': userId,
          'event_id': eventId,
          'method': method,
        },
      );

      // Update event analytics
      await _eventsCollection.doc(eventId).update({
        'shareCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Failed to log event share: $e');
    }
  }

  // Helper Methods
  List<Event> _filterEventsByDistance(
    List<Event> events,
    double latitude,
    double longitude,
    double radiusKm,
  ) {
    return events.where((event) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        event.venue.latitude,
        event.venue.longitude,
      );
      return distance <= radiusKm;
    }).toList()
      ..sort((a, b) {
        final distanceA = _calculateDistance(
          latitude, longitude,
          a.venue.latitude, a.venue.longitude,
        );
        final distanceB = _calculateDistance(
          latitude, longitude,
          b.venue.latitude, b.venue.longitude,
        );
        return distanceA.compareTo(distanceB);
      });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * 
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  List<Event> _filterEventsBySearch(List<Event> events, String query) {
    final lowercaseQuery = query.toLowerCase();
    return events.where((event) {
      return event.title.toLowerCase().contains(lowercaseQuery) ||
             event.description.toLowerCase().contains(lowercaseQuery) ||
             event.venue.name.toLowerCase().contains(lowercaseQuery) ||
             event.organizerName.toLowerCase().contains(lowercaseQuery) ||
             event.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Batch Operations
  Future<void> batchUpdateEvents(List<Event> events) async {
    try {
      final batch = _firestore.batch();
      
      for (final event in events) {
        final docRef = _eventsCollection.doc(event.id);
        batch.update(docRef, event.toJson());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update events: $e');
    }
  }

  // Real-time Streams
  Stream<List<Event>> getEventsStream({
    EventCategory? category,
    int limit = AppConfig.eventsPerPage,
  }) {
    Query query = _eventsCollection
        .where('status', isEqualTo: EventStatus.active.name)
        .orderBy('startDateTime')
        .limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<Event?> getEventStream(String eventId) {
    return _eventsCollection.doc(eventId).snapshots().map((doc) {
      if (doc.exists) {
        return Event.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}