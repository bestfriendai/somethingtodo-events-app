import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'analytics.freezed.dart';
part 'analytics.g.dart';

@freezed
class UserEvent with _$UserEvent {
  const factory UserEvent({
    required String id,
    required String userId,
    required String eventType,
    required String eventName,
    Map<String, dynamic>? parameters,
    String? sessionId,
    String? screenName,
    @JsonKey(fromJson: _fromJsonTimestampNullable, toJson: _toJsonTimestamp)
    DateTime? timestamp,
  }) = _UserEvent;

  factory UserEvent.fromJson(Map<String, dynamic> json) => 
      _$UserEventFromJson(json);
}

@freezed
class SessionData with _$SessionData {
  const factory SessionData({
    required String sessionId,
    required String userId,
    @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
    required DateTime startTime,
    @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
    DateTime? endTime,
    @Default(0) int duration, // in seconds
    @Default(0) int screenViews,
    @Default(0) int eventsViewed,
    @Default(0) int searchQueries,
    @Default(0) int chatMessages,
    @Default([]) List<String> categoriesViewed,
    String? lastScreenName,
    Map<String, dynamic>? deviceInfo,
  }) = _SessionData;

  factory SessionData.fromJson(Map<String, dynamic> json) => 
      _$SessionDataFromJson(json);
}

@freezed
class EventAnalytics with _$EventAnalytics {
  const factory EventAnalytics({
    required String eventId,
    @Default(0) int views,
    @Default(0) int favorites,
    @Default(0) int shares,
    @Default(0) int ticketClicks,
    @Default(0) int mapViews,
    @Default(0) int chatMentions,
    @Default(0.0) double averageViewDuration,
    @Default({}) Map<String, int> viewsByCategory,
    @Default({}) Map<String, int> viewsByLocation,
    @JsonKey(fromJson: _fromJsonTimestampNullable, toJson: _toJsonTimestamp)
    DateTime? lastUpdated,
  }) = _EventAnalytics;

  factory EventAnalytics.fromJson(Map<String, dynamic> json) => 
      _$EventAnalyticsFromJson(json);
}

@freezed
class SearchAnalytics with _$SearchAnalytics {
  const factory SearchAnalytics({
    required String id,
    required String userId,
    required String query,
    required String category,
    @Default(0) int resultCount,
    String? location,
    Map<String, dynamic>? filters,
    @Default(0) int clickedResults,
    @JsonKey(fromJson: _fromJsonTimestampNullable, toJson: _toJsonTimestamp)
    DateTime? timestamp,
  }) = _SearchAnalytics;

  factory SearchAnalytics.fromJson(Map<String, dynamic> json) => 
      _$SearchAnalyticsFromJson(json);
}

// Common event types for analytics
class AnalyticsEvents {
  static const String appOpen = 'app_open';
  static const String screenView = 'screen_view';
  static const String eventView = 'event_view';
  static const String eventFavorite = 'event_favorite';
  static const String eventShare = 'event_share';
  static const String search = 'search';
  static const String chatStart = 'chat_start';
  static const String chatMessage = 'chat_message';
  static const String mapView = 'map_view';
  static const String filterApply = 'filter_apply';
  static const String ticketClick = 'ticket_click';
  static const String premiumUpgrade = 'premium_upgrade';
  static const String userSignUp = 'user_sign_up';
  static const String userLogin = 'user_login';
  static const String locationPermission = 'location_permission';
  static const String notificationPermission = 'notification_permission';
}

// Common screen names
class ScreenNames {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String home = 'home';
  static const String map = 'map';
  static const String eventDetails = 'event_details';
  static const String chat = 'chat';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String premium = 'premium';
  static const String favorites = 'favorites';
  static const String search = 'search';
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