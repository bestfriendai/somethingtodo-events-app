// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserEvent _$UserEventFromJson(Map<String, dynamic> json) {
  return _UserEvent.fromJson(json);
}

/// @nodoc
mixin _$UserEvent {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get eventType => throw _privateConstructorUsedError;
  String get eventName => throw _privateConstructorUsedError;
  Map<String, dynamic>? get parameters => throw _privateConstructorUsedError;
  String? get sessionId => throw _privateConstructorUsedError;
  String? get screenName => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  /// Serializes this UserEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserEventCopyWith<UserEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserEventCopyWith<$Res> {
  factory $UserEventCopyWith(UserEvent value, $Res Function(UserEvent) then) =
      _$UserEventCopyWithImpl<$Res, UserEvent>;
  @useResult
  $Res call({
    String id,
    String userId,
    String eventType,
    String eventName,
    Map<String, dynamic>? parameters,
    String? sessionId,
    String? screenName,
    DateTime? timestamp,
  });
}

/// @nodoc
class _$UserEventCopyWithImpl<$Res, $Val extends UserEvent>
    implements $UserEventCopyWith<$Res> {
  _$UserEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? eventType = null,
    Object? eventName = null,
    Object? parameters = freezed,
    Object? sessionId = freezed,
    Object? screenName = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            eventType: null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                      as String,
            eventName: null == eventName
                ? _value.eventName
                : eventName // ignore: cast_nullable_to_non_nullable
                      as String,
            parameters: freezed == parameters
                ? _value.parameters
                : parameters // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            sessionId: freezed == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            screenName: freezed == screenName
                ? _value.screenName
                : screenName // ignore: cast_nullable_to_non_nullable
                      as String?,
            timestamp: freezed == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserEventImplCopyWith<$Res>
    implements $UserEventCopyWith<$Res> {
  factory _$$UserEventImplCopyWith(
    _$UserEventImpl value,
    $Res Function(_$UserEventImpl) then,
  ) = __$$UserEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String eventType,
    String eventName,
    Map<String, dynamic>? parameters,
    String? sessionId,
    String? screenName,
    DateTime? timestamp,
  });
}

/// @nodoc
class __$$UserEventImplCopyWithImpl<$Res>
    extends _$UserEventCopyWithImpl<$Res, _$UserEventImpl>
    implements _$$UserEventImplCopyWith<$Res> {
  __$$UserEventImplCopyWithImpl(
    _$UserEventImpl _value,
    $Res Function(_$UserEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? eventType = null,
    Object? eventName = null,
    Object? parameters = freezed,
    Object? sessionId = freezed,
    Object? screenName = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(
      _$UserEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        eventType: null == eventType
            ? _value.eventType
            : eventType // ignore: cast_nullable_to_non_nullable
                  as String,
        eventName: null == eventName
            ? _value.eventName
            : eventName // ignore: cast_nullable_to_non_nullable
                  as String,
        parameters: freezed == parameters
            ? _value._parameters
            : parameters // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        sessionId: freezed == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        screenName: freezed == screenName
            ? _value.screenName
            : screenName // ignore: cast_nullable_to_non_nullable
                  as String?,
        timestamp: freezed == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserEventImpl implements _UserEvent {
  const _$UserEventImpl({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.eventName,
    final Map<String, dynamic>? parameters,
    this.sessionId,
    this.screenName,
    this.timestamp,
  }) : _parameters = parameters;

  factory _$UserEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserEventImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String eventType;
  @override
  final String eventName;
  final Map<String, dynamic>? _parameters;
  @override
  Map<String, dynamic>? get parameters {
    final value = _parameters;
    if (value == null) return null;
    if (_parameters is EqualUnmodifiableMapView) return _parameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? sessionId;
  @override
  final String? screenName;
  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'UserEvent(id: $id, userId: $userId, eventType: $eventType, eventName: $eventName, parameters: $parameters, sessionId: $sessionId, screenName: $screenName, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.eventName, eventName) ||
                other.eventName == eventName) &&
            const DeepCollectionEquality().equals(
              other._parameters,
              _parameters,
            ) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.screenName, screenName) ||
                other.screenName == screenName) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    eventType,
    eventName,
    const DeepCollectionEquality().hash(_parameters),
    sessionId,
    screenName,
    timestamp,
  );

  /// Create a copy of UserEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserEventImplCopyWith<_$UserEventImpl> get copyWith =>
      __$$UserEventImplCopyWithImpl<_$UserEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserEventImplToJson(this);
  }
}

abstract class _UserEvent implements UserEvent {
  const factory _UserEvent({
    required final String id,
    required final String userId,
    required final String eventType,
    required final String eventName,
    final Map<String, dynamic>? parameters,
    final String? sessionId,
    final String? screenName,
    final DateTime? timestamp,
  }) = _$UserEventImpl;

  factory _UserEvent.fromJson(Map<String, dynamic> json) =
      _$UserEventImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get eventType;
  @override
  String get eventName;
  @override
  Map<String, dynamic>? get parameters;
  @override
  String? get sessionId;
  @override
  String? get screenName;
  @override
  DateTime? get timestamp;

  /// Create a copy of UserEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserEventImplCopyWith<_$UserEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionData _$SessionDataFromJson(Map<String, dynamic> json) {
  return _SessionData.fromJson(json);
}

/// @nodoc
mixin _$SessionData {
  String get sessionId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError; // in seconds
  int get screenViews => throw _privateConstructorUsedError;
  int get eventsViewed => throw _privateConstructorUsedError;
  int get searchQueries => throw _privateConstructorUsedError;
  int get chatMessages => throw _privateConstructorUsedError;
  List<String> get categoriesViewed => throw _privateConstructorUsedError;
  String? get lastScreenName => throw _privateConstructorUsedError;
  Map<String, dynamic>? get deviceInfo => throw _privateConstructorUsedError;

  /// Serializes this SessionData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionDataCopyWith<SessionData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionDataCopyWith<$Res> {
  factory $SessionDataCopyWith(
    SessionData value,
    $Res Function(SessionData) then,
  ) = _$SessionDataCopyWithImpl<$Res, SessionData>;
  @useResult
  $Res call({
    String sessionId,
    String userId,
    DateTime startTime,
    DateTime? endTime,
    int duration,
    int screenViews,
    int eventsViewed,
    int searchQueries,
    int chatMessages,
    List<String> categoriesViewed,
    String? lastScreenName,
    Map<String, dynamic>? deviceInfo,
  });
}

/// @nodoc
class _$SessionDataCopyWithImpl<$Res, $Val extends SessionData>
    implements $SessionDataCopyWith<$Res> {
  _$SessionDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? userId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? duration = null,
    Object? screenViews = null,
    Object? eventsViewed = null,
    Object? searchQueries = null,
    Object? chatMessages = null,
    Object? categoriesViewed = null,
    Object? lastScreenName = freezed,
    Object? deviceInfo = freezed,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            screenViews: null == screenViews
                ? _value.screenViews
                : screenViews // ignore: cast_nullable_to_non_nullable
                      as int,
            eventsViewed: null == eventsViewed
                ? _value.eventsViewed
                : eventsViewed // ignore: cast_nullable_to_non_nullable
                      as int,
            searchQueries: null == searchQueries
                ? _value.searchQueries
                : searchQueries // ignore: cast_nullable_to_non_nullable
                      as int,
            chatMessages: null == chatMessages
                ? _value.chatMessages
                : chatMessages // ignore: cast_nullable_to_non_nullable
                      as int,
            categoriesViewed: null == categoriesViewed
                ? _value.categoriesViewed
                : categoriesViewed // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            lastScreenName: freezed == lastScreenName
                ? _value.lastScreenName
                : lastScreenName // ignore: cast_nullable_to_non_nullable
                      as String?,
            deviceInfo: freezed == deviceInfo
                ? _value.deviceInfo
                : deviceInfo // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionDataImplCopyWith<$Res>
    implements $SessionDataCopyWith<$Res> {
  factory _$$SessionDataImplCopyWith(
    _$SessionDataImpl value,
    $Res Function(_$SessionDataImpl) then,
  ) = __$$SessionDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    String userId,
    DateTime startTime,
    DateTime? endTime,
    int duration,
    int screenViews,
    int eventsViewed,
    int searchQueries,
    int chatMessages,
    List<String> categoriesViewed,
    String? lastScreenName,
    Map<String, dynamic>? deviceInfo,
  });
}

/// @nodoc
class __$$SessionDataImplCopyWithImpl<$Res>
    extends _$SessionDataCopyWithImpl<$Res, _$SessionDataImpl>
    implements _$$SessionDataImplCopyWith<$Res> {
  __$$SessionDataImplCopyWithImpl(
    _$SessionDataImpl _value,
    $Res Function(_$SessionDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? userId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? duration = null,
    Object? screenViews = null,
    Object? eventsViewed = null,
    Object? searchQueries = null,
    Object? chatMessages = null,
    Object? categoriesViewed = null,
    Object? lastScreenName = freezed,
    Object? deviceInfo = freezed,
  }) {
    return _then(
      _$SessionDataImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        screenViews: null == screenViews
            ? _value.screenViews
            : screenViews // ignore: cast_nullable_to_non_nullable
                  as int,
        eventsViewed: null == eventsViewed
            ? _value.eventsViewed
            : eventsViewed // ignore: cast_nullable_to_non_nullable
                  as int,
        searchQueries: null == searchQueries
            ? _value.searchQueries
            : searchQueries // ignore: cast_nullable_to_non_nullable
                  as int,
        chatMessages: null == chatMessages
            ? _value.chatMessages
            : chatMessages // ignore: cast_nullable_to_non_nullable
                  as int,
        categoriesViewed: null == categoriesViewed
            ? _value._categoriesViewed
            : categoriesViewed // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        lastScreenName: freezed == lastScreenName
            ? _value.lastScreenName
            : lastScreenName // ignore: cast_nullable_to_non_nullable
                  as String?,
        deviceInfo: freezed == deviceInfo
            ? _value._deviceInfo
            : deviceInfo // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionDataImpl implements _SessionData {
  const _$SessionDataImpl({
    required this.sessionId,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.duration = 0,
    this.screenViews = 0,
    this.eventsViewed = 0,
    this.searchQueries = 0,
    this.chatMessages = 0,
    final List<String> categoriesViewed = const [],
    this.lastScreenName,
    final Map<String, dynamic>? deviceInfo,
  }) : _categoriesViewed = categoriesViewed,
       _deviceInfo = deviceInfo;

  factory _$SessionDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionDataImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String userId;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  @JsonKey()
  final int duration;
  // in seconds
  @override
  @JsonKey()
  final int screenViews;
  @override
  @JsonKey()
  final int eventsViewed;
  @override
  @JsonKey()
  final int searchQueries;
  @override
  @JsonKey()
  final int chatMessages;
  final List<String> _categoriesViewed;
  @override
  @JsonKey()
  List<String> get categoriesViewed {
    if (_categoriesViewed is EqualUnmodifiableListView)
      return _categoriesViewed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categoriesViewed);
  }

  @override
  final String? lastScreenName;
  final Map<String, dynamic>? _deviceInfo;
  @override
  Map<String, dynamic>? get deviceInfo {
    final value = _deviceInfo;
    if (value == null) return null;
    if (_deviceInfo is EqualUnmodifiableMapView) return _deviceInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SessionData(sessionId: $sessionId, userId: $userId, startTime: $startTime, endTime: $endTime, duration: $duration, screenViews: $screenViews, eventsViewed: $eventsViewed, searchQueries: $searchQueries, chatMessages: $chatMessages, categoriesViewed: $categoriesViewed, lastScreenName: $lastScreenName, deviceInfo: $deviceInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionDataImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.screenViews, screenViews) ||
                other.screenViews == screenViews) &&
            (identical(other.eventsViewed, eventsViewed) ||
                other.eventsViewed == eventsViewed) &&
            (identical(other.searchQueries, searchQueries) ||
                other.searchQueries == searchQueries) &&
            (identical(other.chatMessages, chatMessages) ||
                other.chatMessages == chatMessages) &&
            const DeepCollectionEquality().equals(
              other._categoriesViewed,
              _categoriesViewed,
            ) &&
            (identical(other.lastScreenName, lastScreenName) ||
                other.lastScreenName == lastScreenName) &&
            const DeepCollectionEquality().equals(
              other._deviceInfo,
              _deviceInfo,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    userId,
    startTime,
    endTime,
    duration,
    screenViews,
    eventsViewed,
    searchQueries,
    chatMessages,
    const DeepCollectionEquality().hash(_categoriesViewed),
    lastScreenName,
    const DeepCollectionEquality().hash(_deviceInfo),
  );

  /// Create a copy of SessionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionDataImplCopyWith<_$SessionDataImpl> get copyWith =>
      __$$SessionDataImplCopyWithImpl<_$SessionDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionDataImplToJson(this);
  }
}

abstract class _SessionData implements SessionData {
  const factory _SessionData({
    required final String sessionId,
    required final String userId,
    required final DateTime startTime,
    final DateTime? endTime,
    final int duration,
    final int screenViews,
    final int eventsViewed,
    final int searchQueries,
    final int chatMessages,
    final List<String> categoriesViewed,
    final String? lastScreenName,
    final Map<String, dynamic>? deviceInfo,
  }) = _$SessionDataImpl;

  factory _SessionData.fromJson(Map<String, dynamic> json) =
      _$SessionDataImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get userId;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  int get duration; // in seconds
  @override
  int get screenViews;
  @override
  int get eventsViewed;
  @override
  int get searchQueries;
  @override
  int get chatMessages;
  @override
  List<String> get categoriesViewed;
  @override
  String? get lastScreenName;
  @override
  Map<String, dynamic>? get deviceInfo;

  /// Create a copy of SessionData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionDataImplCopyWith<_$SessionDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventAnalytics _$EventAnalyticsFromJson(Map<String, dynamic> json) {
  return _EventAnalytics.fromJson(json);
}

/// @nodoc
mixin _$EventAnalytics {
  String get eventId => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  int get favorites => throw _privateConstructorUsedError;
  int get shares => throw _privateConstructorUsedError;
  int get ticketClicks => throw _privateConstructorUsedError;
  int get mapViews => throw _privateConstructorUsedError;
  int get chatMentions => throw _privateConstructorUsedError;
  double get averageViewDuration => throw _privateConstructorUsedError;
  Map<String, int> get viewsByCategory => throw _privateConstructorUsedError;
  Map<String, int> get viewsByLocation => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this EventAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventAnalyticsCopyWith<EventAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventAnalyticsCopyWith<$Res> {
  factory $EventAnalyticsCopyWith(
    EventAnalytics value,
    $Res Function(EventAnalytics) then,
  ) = _$EventAnalyticsCopyWithImpl<$Res, EventAnalytics>;
  @useResult
  $Res call({
    String eventId,
    int views,
    int favorites,
    int shares,
    int ticketClicks,
    int mapViews,
    int chatMentions,
    double averageViewDuration,
    Map<String, int> viewsByCategory,
    Map<String, int> viewsByLocation,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class _$EventAnalyticsCopyWithImpl<$Res, $Val extends EventAnalytics>
    implements $EventAnalyticsCopyWith<$Res> {
  _$EventAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? views = null,
    Object? favorites = null,
    Object? shares = null,
    Object? ticketClicks = null,
    Object? mapViews = null,
    Object? chatMentions = null,
    Object? averageViewDuration = null,
    Object? viewsByCategory = null,
    Object? viewsByLocation = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _value.copyWith(
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            views: null == views
                ? _value.views
                : views // ignore: cast_nullable_to_non_nullable
                      as int,
            favorites: null == favorites
                ? _value.favorites
                : favorites // ignore: cast_nullable_to_non_nullable
                      as int,
            shares: null == shares
                ? _value.shares
                : shares // ignore: cast_nullable_to_non_nullable
                      as int,
            ticketClicks: null == ticketClicks
                ? _value.ticketClicks
                : ticketClicks // ignore: cast_nullable_to_non_nullable
                      as int,
            mapViews: null == mapViews
                ? _value.mapViews
                : mapViews // ignore: cast_nullable_to_non_nullable
                      as int,
            chatMentions: null == chatMentions
                ? _value.chatMentions
                : chatMentions // ignore: cast_nullable_to_non_nullable
                      as int,
            averageViewDuration: null == averageViewDuration
                ? _value.averageViewDuration
                : averageViewDuration // ignore: cast_nullable_to_non_nullable
                      as double,
            viewsByCategory: null == viewsByCategory
                ? _value.viewsByCategory
                : viewsByCategory // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            viewsByLocation: null == viewsByLocation
                ? _value.viewsByLocation
                : viewsByLocation // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            lastUpdated: freezed == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventAnalyticsImplCopyWith<$Res>
    implements $EventAnalyticsCopyWith<$Res> {
  factory _$$EventAnalyticsImplCopyWith(
    _$EventAnalyticsImpl value,
    $Res Function(_$EventAnalyticsImpl) then,
  ) = __$$EventAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String eventId,
    int views,
    int favorites,
    int shares,
    int ticketClicks,
    int mapViews,
    int chatMentions,
    double averageViewDuration,
    Map<String, int> viewsByCategory,
    Map<String, int> viewsByLocation,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class __$$EventAnalyticsImplCopyWithImpl<$Res>
    extends _$EventAnalyticsCopyWithImpl<$Res, _$EventAnalyticsImpl>
    implements _$$EventAnalyticsImplCopyWith<$Res> {
  __$$EventAnalyticsImplCopyWithImpl(
    _$EventAnalyticsImpl _value,
    $Res Function(_$EventAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? views = null,
    Object? favorites = null,
    Object? shares = null,
    Object? ticketClicks = null,
    Object? mapViews = null,
    Object? chatMentions = null,
    Object? averageViewDuration = null,
    Object? viewsByCategory = null,
    Object? viewsByLocation = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _$EventAnalyticsImpl(
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        views: null == views
            ? _value.views
            : views // ignore: cast_nullable_to_non_nullable
                  as int,
        favorites: null == favorites
            ? _value.favorites
            : favorites // ignore: cast_nullable_to_non_nullable
                  as int,
        shares: null == shares
            ? _value.shares
            : shares // ignore: cast_nullable_to_non_nullable
                  as int,
        ticketClicks: null == ticketClicks
            ? _value.ticketClicks
            : ticketClicks // ignore: cast_nullable_to_non_nullable
                  as int,
        mapViews: null == mapViews
            ? _value.mapViews
            : mapViews // ignore: cast_nullable_to_non_nullable
                  as int,
        chatMentions: null == chatMentions
            ? _value.chatMentions
            : chatMentions // ignore: cast_nullable_to_non_nullable
                  as int,
        averageViewDuration: null == averageViewDuration
            ? _value.averageViewDuration
            : averageViewDuration // ignore: cast_nullable_to_non_nullable
                  as double,
        viewsByCategory: null == viewsByCategory
            ? _value._viewsByCategory
            : viewsByCategory // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        viewsByLocation: null == viewsByLocation
            ? _value._viewsByLocation
            : viewsByLocation // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        lastUpdated: freezed == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventAnalyticsImpl implements _EventAnalytics {
  const _$EventAnalyticsImpl({
    required this.eventId,
    this.views = 0,
    this.favorites = 0,
    this.shares = 0,
    this.ticketClicks = 0,
    this.mapViews = 0,
    this.chatMentions = 0,
    this.averageViewDuration = 0.0,
    final Map<String, int> viewsByCategory = const {},
    final Map<String, int> viewsByLocation = const {},
    this.lastUpdated,
  }) : _viewsByCategory = viewsByCategory,
       _viewsByLocation = viewsByLocation;

  factory _$EventAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventAnalyticsImplFromJson(json);

  @override
  final String eventId;
  @override
  @JsonKey()
  final int views;
  @override
  @JsonKey()
  final int favorites;
  @override
  @JsonKey()
  final int shares;
  @override
  @JsonKey()
  final int ticketClicks;
  @override
  @JsonKey()
  final int mapViews;
  @override
  @JsonKey()
  final int chatMentions;
  @override
  @JsonKey()
  final double averageViewDuration;
  final Map<String, int> _viewsByCategory;
  @override
  @JsonKey()
  Map<String, int> get viewsByCategory {
    if (_viewsByCategory is EqualUnmodifiableMapView) return _viewsByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_viewsByCategory);
  }

  final Map<String, int> _viewsByLocation;
  @override
  @JsonKey()
  Map<String, int> get viewsByLocation {
    if (_viewsByLocation is EqualUnmodifiableMapView) return _viewsByLocation;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_viewsByLocation);
  }

  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'EventAnalytics(eventId: $eventId, views: $views, favorites: $favorites, shares: $shares, ticketClicks: $ticketClicks, mapViews: $mapViews, chatMentions: $chatMentions, averageViewDuration: $averageViewDuration, viewsByCategory: $viewsByCategory, viewsByLocation: $viewsByLocation, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventAnalyticsImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.favorites, favorites) ||
                other.favorites == favorites) &&
            (identical(other.shares, shares) || other.shares == shares) &&
            (identical(other.ticketClicks, ticketClicks) ||
                other.ticketClicks == ticketClicks) &&
            (identical(other.mapViews, mapViews) ||
                other.mapViews == mapViews) &&
            (identical(other.chatMentions, chatMentions) ||
                other.chatMentions == chatMentions) &&
            (identical(other.averageViewDuration, averageViewDuration) ||
                other.averageViewDuration == averageViewDuration) &&
            const DeepCollectionEquality().equals(
              other._viewsByCategory,
              _viewsByCategory,
            ) &&
            const DeepCollectionEquality().equals(
              other._viewsByLocation,
              _viewsByLocation,
            ) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    eventId,
    views,
    favorites,
    shares,
    ticketClicks,
    mapViews,
    chatMentions,
    averageViewDuration,
    const DeepCollectionEquality().hash(_viewsByCategory),
    const DeepCollectionEquality().hash(_viewsByLocation),
    lastUpdated,
  );

  /// Create a copy of EventAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventAnalyticsImplCopyWith<_$EventAnalyticsImpl> get copyWith =>
      __$$EventAnalyticsImplCopyWithImpl<_$EventAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventAnalyticsImplToJson(this);
  }
}

abstract class _EventAnalytics implements EventAnalytics {
  const factory _EventAnalytics({
    required final String eventId,
    final int views,
    final int favorites,
    final int shares,
    final int ticketClicks,
    final int mapViews,
    final int chatMentions,
    final double averageViewDuration,
    final Map<String, int> viewsByCategory,
    final Map<String, int> viewsByLocation,
    final DateTime? lastUpdated,
  }) = _$EventAnalyticsImpl;

  factory _EventAnalytics.fromJson(Map<String, dynamic> json) =
      _$EventAnalyticsImpl.fromJson;

  @override
  String get eventId;
  @override
  int get views;
  @override
  int get favorites;
  @override
  int get shares;
  @override
  int get ticketClicks;
  @override
  int get mapViews;
  @override
  int get chatMentions;
  @override
  double get averageViewDuration;
  @override
  Map<String, int> get viewsByCategory;
  @override
  Map<String, int> get viewsByLocation;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of EventAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventAnalyticsImplCopyWith<_$EventAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchAnalytics _$SearchAnalyticsFromJson(Map<String, dynamic> json) {
  return _SearchAnalytics.fromJson(json);
}

/// @nodoc
mixin _$SearchAnalytics {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get query => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get resultCount => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  Map<String, dynamic>? get filters => throw _privateConstructorUsedError;
  int get clickedResults => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  /// Serializes this SearchAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchAnalyticsCopyWith<SearchAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchAnalyticsCopyWith<$Res> {
  factory $SearchAnalyticsCopyWith(
    SearchAnalytics value,
    $Res Function(SearchAnalytics) then,
  ) = _$SearchAnalyticsCopyWithImpl<$Res, SearchAnalytics>;
  @useResult
  $Res call({
    String id,
    String userId,
    String query,
    String category,
    int resultCount,
    String? location,
    Map<String, dynamic>? filters,
    int clickedResults,
    DateTime? timestamp,
  });
}

/// @nodoc
class _$SearchAnalyticsCopyWithImpl<$Res, $Val extends SearchAnalytics>
    implements $SearchAnalyticsCopyWith<$Res> {
  _$SearchAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? query = null,
    Object? category = null,
    Object? resultCount = null,
    Object? location = freezed,
    Object? filters = freezed,
    Object? clickedResults = null,
    Object? timestamp = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            resultCount: null == resultCount
                ? _value.resultCount
                : resultCount // ignore: cast_nullable_to_non_nullable
                      as int,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            filters: freezed == filters
                ? _value.filters
                : filters // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            clickedResults: null == clickedResults
                ? _value.clickedResults
                : clickedResults // ignore: cast_nullable_to_non_nullable
                      as int,
            timestamp: freezed == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchAnalyticsImplCopyWith<$Res>
    implements $SearchAnalyticsCopyWith<$Res> {
  factory _$$SearchAnalyticsImplCopyWith(
    _$SearchAnalyticsImpl value,
    $Res Function(_$SearchAnalyticsImpl) then,
  ) = __$$SearchAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String query,
    String category,
    int resultCount,
    String? location,
    Map<String, dynamic>? filters,
    int clickedResults,
    DateTime? timestamp,
  });
}

/// @nodoc
class __$$SearchAnalyticsImplCopyWithImpl<$Res>
    extends _$SearchAnalyticsCopyWithImpl<$Res, _$SearchAnalyticsImpl>
    implements _$$SearchAnalyticsImplCopyWith<$Res> {
  __$$SearchAnalyticsImplCopyWithImpl(
    _$SearchAnalyticsImpl _value,
    $Res Function(_$SearchAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? query = null,
    Object? category = null,
    Object? resultCount = null,
    Object? location = freezed,
    Object? filters = freezed,
    Object? clickedResults = null,
    Object? timestamp = freezed,
  }) {
    return _then(
      _$SearchAnalyticsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        resultCount: null == resultCount
            ? _value.resultCount
            : resultCount // ignore: cast_nullable_to_non_nullable
                  as int,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        filters: freezed == filters
            ? _value._filters
            : filters // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        clickedResults: null == clickedResults
            ? _value.clickedResults
            : clickedResults // ignore: cast_nullable_to_non_nullable
                  as int,
        timestamp: freezed == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchAnalyticsImpl implements _SearchAnalytics {
  const _$SearchAnalyticsImpl({
    required this.id,
    required this.userId,
    required this.query,
    required this.category,
    this.resultCount = 0,
    this.location,
    final Map<String, dynamic>? filters,
    this.clickedResults = 0,
    this.timestamp,
  }) : _filters = filters;

  factory _$SearchAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchAnalyticsImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String query;
  @override
  final String category;
  @override
  @JsonKey()
  final int resultCount;
  @override
  final String? location;
  final Map<String, dynamic>? _filters;
  @override
  Map<String, dynamic>? get filters {
    final value = _filters;
    if (value == null) return null;
    if (_filters is EqualUnmodifiableMapView) return _filters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final int clickedResults;
  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'SearchAnalytics(id: $id, userId: $userId, query: $query, category: $category, resultCount: $resultCount, location: $location, filters: $filters, clickedResults: $clickedResults, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchAnalyticsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.resultCount, resultCount) ||
                other.resultCount == resultCount) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._filters, _filters) &&
            (identical(other.clickedResults, clickedResults) ||
                other.clickedResults == clickedResults) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    query,
    category,
    resultCount,
    location,
    const DeepCollectionEquality().hash(_filters),
    clickedResults,
    timestamp,
  );

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchAnalyticsImplCopyWith<_$SearchAnalyticsImpl> get copyWith =>
      __$$SearchAnalyticsImplCopyWithImpl<_$SearchAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchAnalyticsImplToJson(this);
  }
}

abstract class _SearchAnalytics implements SearchAnalytics {
  const factory _SearchAnalytics({
    required final String id,
    required final String userId,
    required final String query,
    required final String category,
    final int resultCount,
    final String? location,
    final Map<String, dynamic>? filters,
    final int clickedResults,
    final DateTime? timestamp,
  }) = _$SearchAnalyticsImpl;

  factory _SearchAnalytics.fromJson(Map<String, dynamic> json) =
      _$SearchAnalyticsImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get query;
  @override
  String get category;
  @override
  int get resultCount;
  @override
  String? get location;
  @override
  Map<String, dynamic>? get filters;
  @override
  int get clickedResults;
  @override
  DateTime? get timestamp;

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchAnalyticsImplCopyWith<_$SearchAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
