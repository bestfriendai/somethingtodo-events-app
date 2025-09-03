// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Event _$EventFromJson(Map<String, dynamic> json) {
  return _Event.fromJson(json);
}

/// @nodoc
mixin _$Event {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get organizerName => throw _privateConstructorUsedError;
  String? get organizerImageUrl => throw _privateConstructorUsedError;
  EventVenue get venue => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  EventCategory get category => throw _privateConstructorUsedError;
  EventPricing get pricing => throw _privateConstructorUsedError;
  DateTime get startDateTime => throw _privateConstructorUsedError;
  DateTime get endDateTime => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  int get attendeeCount => throw _privateConstructorUsedError;
  int get maxAttendees => throw _privateConstructorUsedError;
  int get favoriteCount => throw _privateConstructorUsedError;
  EventStatus get status => throw _privateConstructorUsedError;
  String? get websiteUrl => throw _privateConstructorUsedError;
  String? get ticketUrl => throw _privateConstructorUsedError;
  String? get contactEmail => throw _privateConstructorUsedError;
  String? get contactPhone => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCopyWith<Event> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res, Event>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String organizerName,
      String? organizerImageUrl,
      EventVenue venue,
      List<String> imageUrls,
      EventCategory category,
      EventPricing pricing,
      DateTime startDateTime,
      DateTime endDateTime,
      List<String> tags,
      int attendeeCount,
      int maxAttendees,
      int favoriteCount,
      EventStatus status,
      String? websiteUrl,
      String? ticketUrl,
      String? contactEmail,
      String? contactPhone,
      bool isFeatured,
      bool isPremium,
      bool isOnline,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? createdBy});

  $EventVenueCopyWith<$Res> get venue;
  $EventPricingCopyWith<$Res> get pricing;
}

/// @nodoc
class _$EventCopyWithImpl<$Res, $Val extends Event>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? organizerName = null,
    Object? organizerImageUrl = freezed,
    Object? venue = null,
    Object? imageUrls = null,
    Object? category = null,
    Object? pricing = null,
    Object? startDateTime = null,
    Object? endDateTime = null,
    Object? tags = null,
    Object? attendeeCount = null,
    Object? maxAttendees = null,
    Object? favoriteCount = null,
    Object? status = null,
    Object? websiteUrl = freezed,
    Object? ticketUrl = freezed,
    Object? contactEmail = freezed,
    Object? contactPhone = freezed,
    Object? isFeatured = null,
    Object? isPremium = null,
    Object? isOnline = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      organizerName: null == organizerName
          ? _value.organizerName
          : organizerName // ignore: cast_nullable_to_non_nullable
              as String,
      organizerImageUrl: freezed == organizerImageUrl
          ? _value.organizerImageUrl
          : organizerImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      venue: null == venue
          ? _value.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as EventVenue,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as EventCategory,
      pricing: null == pricing
          ? _value.pricing
          : pricing // ignore: cast_nullable_to_non_nullable
              as EventPricing,
      startDateTime: null == startDateTime
          ? _value.startDateTime
          : startDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDateTime: null == endDateTime
          ? _value.endDateTime
          : endDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      attendeeCount: null == attendeeCount
          ? _value.attendeeCount
          : attendeeCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxAttendees: null == maxAttendees
          ? _value.maxAttendees
          : maxAttendees // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteCount: null == favoriteCount
          ? _value.favoriteCount
          : favoriteCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      ticketUrl: freezed == ticketUrl
          ? _value.ticketUrl
          : ticketUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EventVenueCopyWith<$Res> get venue {
    return $EventVenueCopyWith<$Res>(_value.venue, (value) {
      return _then(_value.copyWith(venue: value) as $Val);
    });
  }

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EventPricingCopyWith<$Res> get pricing {
    return $EventPricingCopyWith<$Res>(_value.pricing, (value) {
      return _then(_value.copyWith(pricing: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EventImplCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$$EventImplCopyWith(
          _$EventImpl value, $Res Function(_$EventImpl) then) =
      __$$EventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String organizerName,
      String? organizerImageUrl,
      EventVenue venue,
      List<String> imageUrls,
      EventCategory category,
      EventPricing pricing,
      DateTime startDateTime,
      DateTime endDateTime,
      List<String> tags,
      int attendeeCount,
      int maxAttendees,
      int favoriteCount,
      EventStatus status,
      String? websiteUrl,
      String? ticketUrl,
      String? contactEmail,
      String? contactPhone,
      bool isFeatured,
      bool isPremium,
      bool isOnline,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? createdBy});

  @override
  $EventVenueCopyWith<$Res> get venue;
  @override
  $EventPricingCopyWith<$Res> get pricing;
}

/// @nodoc
class __$$EventImplCopyWithImpl<$Res>
    extends _$EventCopyWithImpl<$Res, _$EventImpl>
    implements _$$EventImplCopyWith<$Res> {
  __$$EventImplCopyWithImpl(
      _$EventImpl _value, $Res Function(_$EventImpl) _then)
      : super(_value, _then);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? organizerName = null,
    Object? organizerImageUrl = freezed,
    Object? venue = null,
    Object? imageUrls = null,
    Object? category = null,
    Object? pricing = null,
    Object? startDateTime = null,
    Object? endDateTime = null,
    Object? tags = null,
    Object? attendeeCount = null,
    Object? maxAttendees = null,
    Object? favoriteCount = null,
    Object? status = null,
    Object? websiteUrl = freezed,
    Object? ticketUrl = freezed,
    Object? contactEmail = freezed,
    Object? contactPhone = freezed,
    Object? isFeatured = null,
    Object? isPremium = null,
    Object? isOnline = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
  }) {
    return _then(_$EventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      organizerName: null == organizerName
          ? _value.organizerName
          : organizerName // ignore: cast_nullable_to_non_nullable
              as String,
      organizerImageUrl: freezed == organizerImageUrl
          ? _value.organizerImageUrl
          : organizerImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      venue: null == venue
          ? _value.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as EventVenue,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as EventCategory,
      pricing: null == pricing
          ? _value.pricing
          : pricing // ignore: cast_nullable_to_non_nullable
              as EventPricing,
      startDateTime: null == startDateTime
          ? _value.startDateTime
          : startDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDateTime: null == endDateTime
          ? _value.endDateTime
          : endDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      attendeeCount: null == attendeeCount
          ? _value.attendeeCount
          : attendeeCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxAttendees: null == maxAttendees
          ? _value.maxAttendees
          : maxAttendees // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteCount: null == favoriteCount
          ? _value.favoriteCount
          : favoriteCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      ticketUrl: freezed == ticketUrl
          ? _value.ticketUrl
          : ticketUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventImpl implements _Event {
  const _$EventImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.organizerName,
      this.organizerImageUrl,
      required this.venue,
      required final List<String> imageUrls,
      required this.category,
      required this.pricing,
      required this.startDateTime,
      required this.endDateTime,
      final List<String> tags = const [],
      this.attendeeCount = 0,
      this.maxAttendees = 0,
      this.favoriteCount = 0,
      this.status = EventStatus.active,
      this.websiteUrl,
      this.ticketUrl,
      this.contactEmail,
      this.contactPhone,
      this.isFeatured = false,
      this.isPremium = false,
      this.isOnline = false,
      this.createdAt,
      this.updatedAt,
      this.createdBy})
      : _imageUrls = imageUrls,
        _tags = tags;

  factory _$EventImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String organizerName;
  @override
  final String? organizerImageUrl;
  @override
  final EventVenue venue;
  final List<String> _imageUrls;
  @override
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  final EventCategory category;
  @override
  final EventPricing pricing;
  @override
  final DateTime startDateTime;
  @override
  final DateTime endDateTime;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final int attendeeCount;
  @override
  @JsonKey()
  final int maxAttendees;
  @override
  @JsonKey()
  final int favoriteCount;
  @override
  @JsonKey()
  final EventStatus status;
  @override
  final String? websiteUrl;
  @override
  final String? ticketUrl;
  @override
  final String? contactEmail;
  @override
  final String? contactPhone;
  @override
  @JsonKey()
  final bool isFeatured;
  @override
  @JsonKey()
  final bool isPremium;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? createdBy;

  @override
  String toString() {
    return 'Event(id: $id, title: $title, description: $description, organizerName: $organizerName, organizerImageUrl: $organizerImageUrl, venue: $venue, imageUrls: $imageUrls, category: $category, pricing: $pricing, startDateTime: $startDateTime, endDateTime: $endDateTime, tags: $tags, attendeeCount: $attendeeCount, maxAttendees: $maxAttendees, favoriteCount: $favoriteCount, status: $status, websiteUrl: $websiteUrl, ticketUrl: $ticketUrl, contactEmail: $contactEmail, contactPhone: $contactPhone, isFeatured: $isFeatured, isPremium: $isPremium, isOnline: $isOnline, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.organizerName, organizerName) ||
                other.organizerName == organizerName) &&
            (identical(other.organizerImageUrl, organizerImageUrl) ||
                other.organizerImageUrl == organizerImageUrl) &&
            (identical(other.venue, venue) || other.venue == venue) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.pricing, pricing) || other.pricing == pricing) &&
            (identical(other.startDateTime, startDateTime) ||
                other.startDateTime == startDateTime) &&
            (identical(other.endDateTime, endDateTime) ||
                other.endDateTime == endDateTime) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.attendeeCount, attendeeCount) ||
                other.attendeeCount == attendeeCount) &&
            (identical(other.maxAttendees, maxAttendees) ||
                other.maxAttendees == maxAttendees) &&
            (identical(other.favoriteCount, favoriteCount) ||
                other.favoriteCount == favoriteCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            (identical(other.ticketUrl, ticketUrl) ||
                other.ticketUrl == ticketUrl) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        organizerName,
        organizerImageUrl,
        venue,
        const DeepCollectionEquality().hash(_imageUrls),
        category,
        pricing,
        startDateTime,
        endDateTime,
        const DeepCollectionEquality().hash(_tags),
        attendeeCount,
        maxAttendees,
        favoriteCount,
        status,
        websiteUrl,
        ticketUrl,
        contactEmail,
        contactPhone,
        isFeatured,
        isPremium,
        isOnline,
        createdAt,
        updatedAt,
        createdBy
      ]);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      __$$EventImplCopyWithImpl<_$EventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventImplToJson(
      this,
    );
  }
}

abstract class _Event implements Event {
  const factory _Event(
      {required final String id,
      required final String title,
      required final String description,
      required final String organizerName,
      final String? organizerImageUrl,
      required final EventVenue venue,
      required final List<String> imageUrls,
      required final EventCategory category,
      required final EventPricing pricing,
      required final DateTime startDateTime,
      required final DateTime endDateTime,
      final List<String> tags,
      final int attendeeCount,
      final int maxAttendees,
      final int favoriteCount,
      final EventStatus status,
      final String? websiteUrl,
      final String? ticketUrl,
      final String? contactEmail,
      final String? contactPhone,
      final bool isFeatured,
      final bool isPremium,
      final bool isOnline,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final String? createdBy}) = _$EventImpl;

  factory _Event.fromJson(Map<String, dynamic> json) = _$EventImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get organizerName;
  @override
  String? get organizerImageUrl;
  @override
  EventVenue get venue;
  @override
  List<String> get imageUrls;
  @override
  EventCategory get category;
  @override
  EventPricing get pricing;
  @override
  DateTime get startDateTime;
  @override
  DateTime get endDateTime;
  @override
  List<String> get tags;
  @override
  int get attendeeCount;
  @override
  int get maxAttendees;
  @override
  int get favoriteCount;
  @override
  EventStatus get status;
  @override
  String? get websiteUrl;
  @override
  String? get ticketUrl;
  @override
  String? get contactEmail;
  @override
  String? get contactPhone;
  @override
  bool get isFeatured;
  @override
  bool get isPremium;
  @override
  bool get isOnline;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get createdBy;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventVenue _$EventVenueFromJson(Map<String, dynamic> json) {
  return _EventVenue.fromJson(json);
}

/// @nodoc
mixin _$EventVenue {
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get zipCode => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get websiteUrl => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;

  /// Serializes this EventVenue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventVenue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventVenueCopyWith<EventVenue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventVenueCopyWith<$Res> {
  factory $EventVenueCopyWith(
          EventVenue value, $Res Function(EventVenue) then) =
      _$EventVenueCopyWithImpl<$Res, EventVenue>;
  @useResult
  $Res call(
      {String name,
      String address,
      String? city,
      String? state,
      String? country,
      String? zipCode,
      double latitude,
      double longitude,
      String? description,
      String? imageUrl,
      String? websiteUrl,
      String? phoneNumber});
}

/// @nodoc
class _$EventVenueCopyWithImpl<$Res, $Val extends EventVenue>
    implements $EventVenueCopyWith<$Res> {
  _$EventVenueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventVenue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? city = freezed,
    Object? state = freezed,
    Object? country = freezed,
    Object? zipCode = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? websiteUrl = freezed,
    Object? phoneNumber = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      zipCode: freezed == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventVenueImplCopyWith<$Res>
    implements $EventVenueCopyWith<$Res> {
  factory _$$EventVenueImplCopyWith(
          _$EventVenueImpl value, $Res Function(_$EventVenueImpl) then) =
      __$$EventVenueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String address,
      String? city,
      String? state,
      String? country,
      String? zipCode,
      double latitude,
      double longitude,
      String? description,
      String? imageUrl,
      String? websiteUrl,
      String? phoneNumber});
}

/// @nodoc
class __$$EventVenueImplCopyWithImpl<$Res>
    extends _$EventVenueCopyWithImpl<$Res, _$EventVenueImpl>
    implements _$$EventVenueImplCopyWith<$Res> {
  __$$EventVenueImplCopyWithImpl(
      _$EventVenueImpl _value, $Res Function(_$EventVenueImpl) _then)
      : super(_value, _then);

  /// Create a copy of EventVenue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? city = freezed,
    Object? state = freezed,
    Object? country = freezed,
    Object? zipCode = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? websiteUrl = freezed,
    Object? phoneNumber = freezed,
  }) {
    return _then(_$EventVenueImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      zipCode: freezed == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventVenueImpl implements _EventVenue {
  const _$EventVenueImpl(
      {required this.name,
      required this.address,
      this.city,
      this.state,
      this.country,
      this.zipCode,
      required this.latitude,
      required this.longitude,
      this.description,
      this.imageUrl,
      this.websiteUrl,
      this.phoneNumber});

  factory _$EventVenueImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventVenueImplFromJson(json);

  @override
  final String name;
  @override
  final String address;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? country;
  @override
  final String? zipCode;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? description;
  @override
  final String? imageUrl;
  @override
  final String? websiteUrl;
  @override
  final String? phoneNumber;

  @override
  String toString() {
    return 'EventVenue(name: $name, address: $address, city: $city, state: $state, country: $country, zipCode: $zipCode, latitude: $latitude, longitude: $longitude, description: $description, imageUrl: $imageUrl, websiteUrl: $websiteUrl, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventVenueImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      address,
      city,
      state,
      country,
      zipCode,
      latitude,
      longitude,
      description,
      imageUrl,
      websiteUrl,
      phoneNumber);

  /// Create a copy of EventVenue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventVenueImplCopyWith<_$EventVenueImpl> get copyWith =>
      __$$EventVenueImplCopyWithImpl<_$EventVenueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventVenueImplToJson(
      this,
    );
  }
}

abstract class _EventVenue implements EventVenue {
  const factory _EventVenue(
      {required final String name,
      required final String address,
      final String? city,
      final String? state,
      final String? country,
      final String? zipCode,
      required final double latitude,
      required final double longitude,
      final String? description,
      final String? imageUrl,
      final String? websiteUrl,
      final String? phoneNumber}) = _$EventVenueImpl;

  factory _EventVenue.fromJson(Map<String, dynamic> json) =
      _$EventVenueImpl.fromJson;

  @override
  String get name;
  @override
  String get address;
  @override
  String? get city;
  @override
  String? get state;
  @override
  String? get country;
  @override
  String? get zipCode;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  String? get websiteUrl;
  @override
  String? get phoneNumber;

  /// Create a copy of EventVenue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventVenueImplCopyWith<_$EventVenueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventPricing _$EventPricingFromJson(Map<String, dynamic> json) {
  return _EventPricing.fromJson(json);
}

/// @nodoc
mixin _$EventPricing {
  bool get isFree => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String? get priceDescription => throw _privateConstructorUsedError;
  List<TicketTier> get tiers => throw _privateConstructorUsedError;

  /// Serializes this EventPricing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventPricing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventPricingCopyWith<EventPricing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventPricingCopyWith<$Res> {
  factory $EventPricingCopyWith(
          EventPricing value, $Res Function(EventPricing) then) =
      _$EventPricingCopyWithImpl<$Res, EventPricing>;
  @useResult
  $Res call(
      {bool isFree,
      double price,
      String currency,
      String? priceDescription,
      List<TicketTier> tiers});
}

/// @nodoc
class _$EventPricingCopyWithImpl<$Res, $Val extends EventPricing>
    implements $EventPricingCopyWith<$Res> {
  _$EventPricingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventPricing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isFree = null,
    Object? price = null,
    Object? currency = null,
    Object? priceDescription = freezed,
    Object? tiers = null,
  }) {
    return _then(_value.copyWith(
      isFree: null == isFree
          ? _value.isFree
          : isFree // ignore: cast_nullable_to_non_nullable
              as bool,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      priceDescription: freezed == priceDescription
          ? _value.priceDescription
          : priceDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      tiers: null == tiers
          ? _value.tiers
          : tiers // ignore: cast_nullable_to_non_nullable
              as List<TicketTier>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventPricingImplCopyWith<$Res>
    implements $EventPricingCopyWith<$Res> {
  factory _$$EventPricingImplCopyWith(
          _$EventPricingImpl value, $Res Function(_$EventPricingImpl) then) =
      __$$EventPricingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isFree,
      double price,
      String currency,
      String? priceDescription,
      List<TicketTier> tiers});
}

/// @nodoc
class __$$EventPricingImplCopyWithImpl<$Res>
    extends _$EventPricingCopyWithImpl<$Res, _$EventPricingImpl>
    implements _$$EventPricingImplCopyWith<$Res> {
  __$$EventPricingImplCopyWithImpl(
      _$EventPricingImpl _value, $Res Function(_$EventPricingImpl) _then)
      : super(_value, _then);

  /// Create a copy of EventPricing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isFree = null,
    Object? price = null,
    Object? currency = null,
    Object? priceDescription = freezed,
    Object? tiers = null,
  }) {
    return _then(_$EventPricingImpl(
      isFree: null == isFree
          ? _value.isFree
          : isFree // ignore: cast_nullable_to_non_nullable
              as bool,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      priceDescription: freezed == priceDescription
          ? _value.priceDescription
          : priceDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      tiers: null == tiers
          ? _value._tiers
          : tiers // ignore: cast_nullable_to_non_nullable
              as List<TicketTier>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventPricingImpl implements _EventPricing {
  const _$EventPricingImpl(
      {this.isFree = true,
      this.price = 0.0,
      this.currency = 'USD',
      this.priceDescription,
      final List<TicketTier> tiers = const []})
      : _tiers = tiers;

  factory _$EventPricingImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventPricingImplFromJson(json);

  @override
  @JsonKey()
  final bool isFree;
  @override
  @JsonKey()
  final double price;
  @override
  @JsonKey()
  final String currency;
  @override
  final String? priceDescription;
  final List<TicketTier> _tiers;
  @override
  @JsonKey()
  List<TicketTier> get tiers {
    if (_tiers is EqualUnmodifiableListView) return _tiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tiers);
  }

  @override
  String toString() {
    return 'EventPricing(isFree: $isFree, price: $price, currency: $currency, priceDescription: $priceDescription, tiers: $tiers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventPricingImpl &&
            (identical(other.isFree, isFree) || other.isFree == isFree) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.priceDescription, priceDescription) ||
                other.priceDescription == priceDescription) &&
            const DeepCollectionEquality().equals(other._tiers, _tiers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isFree, price, currency,
      priceDescription, const DeepCollectionEquality().hash(_tiers));

  /// Create a copy of EventPricing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventPricingImplCopyWith<_$EventPricingImpl> get copyWith =>
      __$$EventPricingImplCopyWithImpl<_$EventPricingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventPricingImplToJson(
      this,
    );
  }
}

abstract class _EventPricing implements EventPricing {
  const factory _EventPricing(
      {final bool isFree,
      final double price,
      final String currency,
      final String? priceDescription,
      final List<TicketTier> tiers}) = _$EventPricingImpl;

  factory _EventPricing.fromJson(Map<String, dynamic> json) =
      _$EventPricingImpl.fromJson;

  @override
  bool get isFree;
  @override
  double get price;
  @override
  String get currency;
  @override
  String? get priceDescription;
  @override
  List<TicketTier> get tiers;

  /// Create a copy of EventPricing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventPricingImplCopyWith<_$EventPricingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TicketTier _$TicketTierFromJson(Map<String, dynamic> json) {
  return _TicketTier.fromJson(json);
}

/// @nodoc
mixin _$TicketTier {
  String get name => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get available => throw _privateConstructorUsedError;
  int get sold => throw _privateConstructorUsedError;

  /// Serializes this TicketTier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TicketTier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TicketTierCopyWith<TicketTier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TicketTierCopyWith<$Res> {
  factory $TicketTierCopyWith(
          TicketTier value, $Res Function(TicketTier) then) =
      _$TicketTierCopyWithImpl<$Res, TicketTier>;
  @useResult
  $Res call(
      {String name,
      double price,
      String? description,
      int available,
      int sold});
}

/// @nodoc
class _$TicketTierCopyWithImpl<$Res, $Val extends TicketTier>
    implements $TicketTierCopyWith<$Res> {
  _$TicketTierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TicketTier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? description = freezed,
    Object? available = null,
    Object? sold = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      sold: null == sold
          ? _value.sold
          : sold // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TicketTierImplCopyWith<$Res>
    implements $TicketTierCopyWith<$Res> {
  factory _$$TicketTierImplCopyWith(
          _$TicketTierImpl value, $Res Function(_$TicketTierImpl) then) =
      __$$TicketTierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      double price,
      String? description,
      int available,
      int sold});
}

/// @nodoc
class __$$TicketTierImplCopyWithImpl<$Res>
    extends _$TicketTierCopyWithImpl<$Res, _$TicketTierImpl>
    implements _$$TicketTierImplCopyWith<$Res> {
  __$$TicketTierImplCopyWithImpl(
      _$TicketTierImpl _value, $Res Function(_$TicketTierImpl) _then)
      : super(_value, _then);

  /// Create a copy of TicketTier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? description = freezed,
    Object? available = null,
    Object? sold = null,
  }) {
    return _then(_$TicketTierImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      sold: null == sold
          ? _value.sold
          : sold // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TicketTierImpl implements _TicketTier {
  const _$TicketTierImpl(
      {required this.name,
      required this.price,
      this.description,
      this.available = 0,
      this.sold = 0});

  factory _$TicketTierImpl.fromJson(Map<String, dynamic> json) =>
      _$$TicketTierImplFromJson(json);

  @override
  final String name;
  @override
  final double price;
  @override
  final String? description;
  @override
  @JsonKey()
  final int available;
  @override
  @JsonKey()
  final int sold;

  @override
  String toString() {
    return 'TicketTier(name: $name, price: $price, description: $description, available: $available, sold: $sold)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TicketTierImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.available, available) ||
                other.available == available) &&
            (identical(other.sold, sold) || other.sold == sold));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, price, description, available, sold);

  /// Create a copy of TicketTier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TicketTierImplCopyWith<_$TicketTierImpl> get copyWith =>
      __$$TicketTierImplCopyWithImpl<_$TicketTierImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TicketTierImplToJson(
      this,
    );
  }
}

abstract class _TicketTier implements TicketTier {
  const factory _TicketTier(
      {required final String name,
      required final double price,
      final String? description,
      final int available,
      final int sold}) = _$TicketTierImpl;

  factory _TicketTier.fromJson(Map<String, dynamic> json) =
      _$TicketTierImpl.fromJson;

  @override
  String get name;
  @override
  double get price;
  @override
  String? get description;
  @override
  int get available;
  @override
  int get sold;

  /// Create a copy of TicketTier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TicketTierImplCopyWith<_$TicketTierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
