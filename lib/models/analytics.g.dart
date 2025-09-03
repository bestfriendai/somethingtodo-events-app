// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserEventImpl _$$UserEventImplFromJson(Map<String, dynamic> json) =>
    _$UserEventImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      eventType: json['eventType'] as String,
      eventName: json['eventName'] as String,
      parameters: json['parameters'] as Map<String, dynamic>?,
      sessionId: json['sessionId'] as String?,
      screenName: json['screenName'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$UserEventImplToJson(_$UserEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'eventType': instance.eventType,
      'eventName': instance.eventName,
      'parameters': instance.parameters,
      'sessionId': instance.sessionId,
      'screenName': instance.screenName,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

_$SessionDataImpl _$$SessionDataImplFromJson(Map<String, dynamic> json) =>
    _$SessionDataImpl(
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      screenViews: (json['screenViews'] as num?)?.toInt() ?? 0,
      eventsViewed: (json['eventsViewed'] as num?)?.toInt() ?? 0,
      searchQueries: (json['searchQueries'] as num?)?.toInt() ?? 0,
      chatMessages: (json['chatMessages'] as num?)?.toInt() ?? 0,
      categoriesViewed: (json['categoriesViewed'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastScreenName: json['lastScreenName'] as String?,
      deviceInfo: json['deviceInfo'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SessionDataImplToJson(_$SessionDataImpl instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'userId': instance.userId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'duration': instance.duration,
      'screenViews': instance.screenViews,
      'eventsViewed': instance.eventsViewed,
      'searchQueries': instance.searchQueries,
      'chatMessages': instance.chatMessages,
      'categoriesViewed': instance.categoriesViewed,
      'lastScreenName': instance.lastScreenName,
      'deviceInfo': instance.deviceInfo,
    };

_$EventAnalyticsImpl _$$EventAnalyticsImplFromJson(Map<String, dynamic> json) =>
    _$EventAnalyticsImpl(
      eventId: json['eventId'] as String,
      views: (json['views'] as num?)?.toInt() ?? 0,
      favorites: (json['favorites'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      ticketClicks: (json['ticketClicks'] as num?)?.toInt() ?? 0,
      mapViews: (json['mapViews'] as num?)?.toInt() ?? 0,
      chatMentions: (json['chatMentions'] as num?)?.toInt() ?? 0,
      averageViewDuration:
          (json['averageViewDuration'] as num?)?.toDouble() ?? 0.0,
      viewsByCategory: (json['viewsByCategory'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      viewsByLocation: (json['viewsByLocation'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$EventAnalyticsImplToJson(
        _$EventAnalyticsImpl instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'views': instance.views,
      'favorites': instance.favorites,
      'shares': instance.shares,
      'ticketClicks': instance.ticketClicks,
      'mapViews': instance.mapViews,
      'chatMentions': instance.chatMentions,
      'averageViewDuration': instance.averageViewDuration,
      'viewsByCategory': instance.viewsByCategory,
      'viewsByLocation': instance.viewsByLocation,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

_$SearchAnalyticsImpl _$$SearchAnalyticsImplFromJson(
        Map<String, dynamic> json) =>
    _$SearchAnalyticsImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      query: json['query'] as String,
      category: json['category'] as String,
      resultCount: (json['resultCount'] as num?)?.toInt() ?? 0,
      location: json['location'] as String?,
      filters: json['filters'] as Map<String, dynamic>?,
      clickedResults: (json['clickedResults'] as num?)?.toInt() ?? 0,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$SearchAnalyticsImplToJson(
        _$SearchAnalyticsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'query': instance.query,
      'category': instance.category,
      'resultCount': instance.resultCount,
      'location': instance.location,
      'filters': instance.filters,
      'clickedResults': instance.clickedResults,
      'timestamp': instance.timestamp?.toIso8601String(),
    };
