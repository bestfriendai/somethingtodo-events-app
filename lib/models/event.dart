import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
class Event with _$Event {
  const factory Event({
    required String id,
    required String title,
    required String description,
    required String organizerName,
    String? organizerImageUrl,
    required EventVenue venue,
    required List<String> imageUrls,
    required EventCategory category,
    required EventPricing pricing,
    @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
    required DateTime startDateTime,
    @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
    required DateTime endDateTime,
    @Default([]) List<String> tags,
    @Default(0) int attendeeCount,
    @Default(0) int maxAttendees,
    @Default(0) int favoriteCount,
    @Default(EventStatus.active) EventStatus status,
    String? websiteUrl,
    String? ticketUrl,
    String? contactEmail,
    String? contactPhone,
    @Default(false) bool isFeatured,
    @Default(false) bool isPremium,
    @JsonKey(fromJson: _fromJsonTimestampNullable, toJson: _toJsonTimestamp)
    DateTime? createdAt,
    @JsonKey(fromJson: _fromJsonTimestampNullable, toJson: _toJsonTimestamp)
    DateTime? updatedAt,
    String? createdBy,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

@freezed
class EventVenue with _$EventVenue {
  const factory EventVenue({
    required String name,
    required String address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    required double latitude,
    required double longitude,
    String? description,
    String? imageUrl,
    String? websiteUrl,
    String? phoneNumber,
  }) = _EventVenue;

  factory EventVenue.fromJson(Map<String, dynamic> json) => 
      _$EventVenueFromJson(json);
}

@freezed
class EventPricing with _$EventPricing {
  const factory EventPricing({
    @Default(true) bool isFree,
    @Default(0.0) double price,
    @Default('USD') String currency,
    String? priceDescription,
    @Default([]) List<TicketTier> tiers,
  }) = _EventPricing;

  factory EventPricing.fromJson(Map<String, dynamic> json) => 
      _$EventPricingFromJson(json);
}

@freezed
class TicketTier with _$TicketTier {
  const factory TicketTier({
    required String name,
    required double price,
    String? description,
    @Default(0) int available,
    @Default(0) int sold,
  }) = _TicketTier;

  factory TicketTier.fromJson(Map<String, dynamic> json) => 
      _$TicketTierFromJson(json);
}

enum EventStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('active')
  active,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('completed')
  completed,
  @JsonValue('soldOut')
  soldOut,
}

enum EventCategory {
  @JsonValue('music')
  music,
  @JsonValue('food')
  food,
  @JsonValue('sports')
  sports,
  @JsonValue('arts')
  arts,
  @JsonValue('business')
  business,
  @JsonValue('education')
  education,
  @JsonValue('technology')
  technology,
  @JsonValue('health')
  health,
  @JsonValue('community')
  community,
  @JsonValue('other')
  other,
}

extension EventCategoryExtension on EventCategory {
  String get displayName {
    switch (this) {
      case EventCategory.music:
        return 'Music & Concerts';
      case EventCategory.food:
        return 'Food & Drink';
      case EventCategory.sports:
        return 'Sports & Fitness';
      case EventCategory.arts:
        return 'Arts & Culture';
      case EventCategory.business:
        return 'Business & Networking';
      case EventCategory.education:
        return 'Education & Learning';
      case EventCategory.technology:
        return 'Technology';
      case EventCategory.health:
        return 'Health & Wellness';
      case EventCategory.community:
        return 'Community';
      case EventCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case EventCategory.music:
        return '🎵';
      case EventCategory.food:
        return '🍽️';
      case EventCategory.sports:
        return '⚽';
      case EventCategory.arts:
        return '🎨';
      case EventCategory.business:
        return '💼';
      case EventCategory.education:
        return '📚';
      case EventCategory.technology:
        return '💻';
      case EventCategory.health:
        return '🏥';
      case EventCategory.community:
        return '👥';
      case EventCategory.other:
        return '📌';
    }
  }
}

// Helper functions for Firestore Timestamp conversion
DateTime _fromJsonTimestamp(dynamic timestamp) {
  if (timestamp == null) return DateTime.now();
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is String) return DateTime.parse(timestamp);
  return DateTime.now();
}

DateTime? _fromJsonTimestampNullable(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is String) return DateTime.parse(timestamp);
  return null;
}

dynamic _toJsonTimestamp(DateTime? dateTime) {
  if (dateTime == null) return null;
  return Timestamp.fromDate(dateTime);
}