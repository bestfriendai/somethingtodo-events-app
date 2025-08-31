// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  DateTime? get premiumExpiresAt => throw _privateConstructorUsedError;
  List<String> get interests => throw _privateConstructorUsedError;
  List<String> get favoriteEventIds => throw _privateConstructorUsedError;
  UserPreferences? get preferences => throw _privateConstructorUsedError;
  UserLocation? get location => throw _privateConstructorUsedError;
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call(
      {String id,
      String email,
      String? displayName,
      String? photoUrl,
      String? phoneNumber,
      bool isPremium,
      DateTime? premiumExpiresAt,
      List<String> interests,
      List<String> favoriteEventIds,
      UserPreferences? preferences,
      UserLocation? location,
      DateTime? lastActiveAt,
      @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
      DateTime? createdAt,
      @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
      DateTime? updatedAt});

  $UserPreferencesCopyWith<$Res>? get preferences;
  $UserLocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? phoneNumber = freezed,
    Object? isPremium = null,
    Object? premiumExpiresAt = freezed,
    Object? interests = null,
    Object? favoriteEventIds = null,
    Object? preferences = freezed,
    Object? location = freezed,
    Object? lastActiveAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      premiumExpiresAt: freezed == premiumExpiresAt
          ? _value.premiumExpiresAt
          : premiumExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      interests: null == interests
          ? _value.interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteEventIds: null == favoriteEventIds
          ? _value.favoriteEventIds
          : favoriteEventIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as UserLocation?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesCopyWith<$Res>? get preferences {
    if (_value.preferences == null) {
      return null;
    }

    return $UserPreferencesCopyWith<$Res>(_value.preferences!, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserLocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $UserLocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
          _$AppUserImpl value, $Res Function(_$AppUserImpl) then) =
      __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String? displayName,
      String? photoUrl,
      String? phoneNumber,
      bool isPremium,
      DateTime? premiumExpiresAt,
      List<String> interests,
      List<String> favoriteEventIds,
      UserPreferences? preferences,
      UserLocation? location,
      DateTime? lastActiveAt,
      @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
      DateTime? createdAt,
      @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
      DateTime? updatedAt});

  @override
  $UserPreferencesCopyWith<$Res>? get preferences;
  @override
  $UserLocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
      _$AppUserImpl _value, $Res Function(_$AppUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? phoneNumber = freezed,
    Object? isPremium = null,
    Object? premiumExpiresAt = freezed,
    Object? interests = null,
    Object? favoriteEventIds = null,
    Object? preferences = freezed,
    Object? location = freezed,
    Object? lastActiveAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AppUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      premiumExpiresAt: freezed == premiumExpiresAt
          ? _value.premiumExpiresAt
          : premiumExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      interests: null == interests
          ? _value._interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteEventIds: null == favoriteEventIds
          ? _value._favoriteEventIds
          : favoriteEventIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as UserLocation?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppUserImpl implements _AppUser {
  const _$AppUserImpl(
      {required this.id,
      required this.email,
      this.displayName,
      this.photoUrl,
      this.phoneNumber,
      this.isPremium = false,
      this.premiumExpiresAt,
      final List<String> interests = const [],
      final List<String> favoriteEventIds = const [],
      this.preferences,
      this.location,
      this.lastActiveAt,
      @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
      this.createdAt,
      @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
      this.updatedAt})
      : _interests = interests,
        _favoriteEventIds = favoriteEventIds;

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? photoUrl;
  @override
  final String? phoneNumber;
  @override
  @JsonKey()
  final bool isPremium;
  @override
  final DateTime? premiumExpiresAt;
  final List<String> _interests;
  @override
  @JsonKey()
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  final List<String> _favoriteEventIds;
  @override
  @JsonKey()
  List<String> get favoriteEventIds {
    if (_favoriteEventIds is EqualUnmodifiableListView)
      return _favoriteEventIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteEventIds);
  }

  @override
  final UserPreferences? preferences;
  @override
  final UserLocation? location;
  @override
  final DateTime? lastActiveAt;
  @override
  @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
  final DateTime? createdAt;
  @override
  @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, isPremium: $isPremium, premiumExpiresAt: $premiumExpiresAt, interests: $interests, favoriteEventIds: $favoriteEventIds, preferences: $preferences, location: $location, lastActiveAt: $lastActiveAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.premiumExpiresAt, premiumExpiresAt) ||
                other.premiumExpiresAt == premiumExpiresAt) &&
            const DeepCollectionEquality()
                .equals(other._interests, _interests) &&
            const DeepCollectionEquality()
                .equals(other._favoriteEventIds, _favoriteEventIds) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      displayName,
      photoUrl,
      phoneNumber,
      isPremium,
      premiumExpiresAt,
      const DeepCollectionEquality().hash(_interests),
      const DeepCollectionEquality().hash(_favoriteEventIds),
      preferences,
      location,
      lastActiveAt,
      createdAt,
      updatedAt);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(
      this,
    );
  }
}

abstract class _AppUser implements AppUser {
  const factory _AppUser(
      {required final String id,
      required final String email,
      final String? displayName,
      final String? photoUrl,
      final String? phoneNumber,
      final bool isPremium,
      final DateTime? premiumExpiresAt,
      final List<String> interests,
      final List<String> favoriteEventIds,
      final UserPreferences? preferences,
      final UserLocation? location,
      final DateTime? lastActiveAt,
      @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
      final DateTime? createdAt,
      @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
      final DateTime? updatedAt}) = _$AppUserImpl;

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get displayName;
  @override
  String? get photoUrl;
  @override
  String? get phoneNumber;
  @override
  bool get isPremium;
  @override
  DateTime? get premiumExpiresAt;
  @override
  List<String> get interests;
  @override
  List<String> get favoriteEventIds;
  @override
  UserPreferences? get preferences;
  @override
  UserLocation? get location;
  @override
  DateTime? get lastActiveAt;
  @override
  @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
  DateTime? get createdAt;
  @override
  @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
  DateTime? get updatedAt;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  bool get locationEnabled => throw _privateConstructorUsedError;
  bool get marketingEmails => throw _privateConstructorUsedError;
  String get theme => throw _privateConstructorUsedError;
  double get maxDistance => throw _privateConstructorUsedError;
  List<String> get preferredCategories => throw _privateConstructorUsedError;
  String get pricePreference => throw _privateConstructorUsedError;

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
          UserPreferences value, $Res Function(UserPreferences) then) =
      _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call(
      {bool notificationsEnabled,
      bool locationEnabled,
      bool marketingEmails,
      String theme,
      double maxDistance,
      List<String> preferredCategories,
      String pricePreference});
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationsEnabled = null,
    Object? locationEnabled = null,
    Object? marketingEmails = null,
    Object? theme = null,
    Object? maxDistance = null,
    Object? preferredCategories = null,
    Object? pricePreference = null,
  }) {
    return _then(_value.copyWith(
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      locationEnabled: null == locationEnabled
          ? _value.locationEnabled
          : locationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      marketingEmails: null == marketingEmails
          ? _value.marketingEmails
          : marketingEmails // ignore: cast_nullable_to_non_nullable
              as bool,
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      maxDistance: null == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as double,
      preferredCategories: null == preferredCategories
          ? _value.preferredCategories
          : preferredCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pricePreference: null == pricePreference
          ? _value.pricePreference
          : pricePreference // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(_$UserPreferencesImpl value,
          $Res Function(_$UserPreferencesImpl) then) =
      __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool notificationsEnabled,
      bool locationEnabled,
      bool marketingEmails,
      String theme,
      double maxDistance,
      List<String> preferredCategories,
      String pricePreference});
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
      _$UserPreferencesImpl _value, $Res Function(_$UserPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationsEnabled = null,
    Object? locationEnabled = null,
    Object? marketingEmails = null,
    Object? theme = null,
    Object? maxDistance = null,
    Object? preferredCategories = null,
    Object? pricePreference = null,
  }) {
    return _then(_$UserPreferencesImpl(
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      locationEnabled: null == locationEnabled
          ? _value.locationEnabled
          : locationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      marketingEmails: null == marketingEmails
          ? _value.marketingEmails
          : marketingEmails // ignore: cast_nullable_to_non_nullable
              as bool,
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      maxDistance: null == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as double,
      preferredCategories: null == preferredCategories
          ? _value._preferredCategories
          : preferredCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pricePreference: null == pricePreference
          ? _value.pricePreference
          : pricePreference // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {this.notificationsEnabled = true,
      this.locationEnabled = true,
      this.marketingEmails = true,
      this.theme = 'light',
      this.maxDistance = 10.0,
      final List<String> preferredCategories = const [],
      this.pricePreference = 'any'})
      : _preferredCategories = preferredCategories;

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  @override
  @JsonKey()
  final bool notificationsEnabled;
  @override
  @JsonKey()
  final bool locationEnabled;
  @override
  @JsonKey()
  final bool marketingEmails;
  @override
  @JsonKey()
  final String theme;
  @override
  @JsonKey()
  final double maxDistance;
  final List<String> _preferredCategories;
  @override
  @JsonKey()
  List<String> get preferredCategories {
    if (_preferredCategories is EqualUnmodifiableListView)
      return _preferredCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredCategories);
  }

  @override
  @JsonKey()
  final String pricePreference;

  @override
  String toString() {
    return 'UserPreferences(notificationsEnabled: $notificationsEnabled, locationEnabled: $locationEnabled, marketingEmails: $marketingEmails, theme: $theme, maxDistance: $maxDistance, preferredCategories: $preferredCategories, pricePreference: $pricePreference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.locationEnabled, locationEnabled) ||
                other.locationEnabled == locationEnabled) &&
            (identical(other.marketingEmails, marketingEmails) ||
                other.marketingEmails == marketingEmails) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.maxDistance, maxDistance) ||
                other.maxDistance == maxDistance) &&
            const DeepCollectionEquality()
                .equals(other._preferredCategories, _preferredCategories) &&
            (identical(other.pricePreference, pricePreference) ||
                other.pricePreference == pricePreference));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      notificationsEnabled,
      locationEnabled,
      marketingEmails,
      theme,
      maxDistance,
      const DeepCollectionEquality().hash(_preferredCategories),
      pricePreference);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(
      this,
    );
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences(
      {final bool notificationsEnabled,
      final bool locationEnabled,
      final bool marketingEmails,
      final String theme,
      final double maxDistance,
      final List<String> preferredCategories,
      final String pricePreference}) = _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  bool get notificationsEnabled;
  @override
  bool get locationEnabled;
  @override
  bool get marketingEmails;
  @override
  String get theme;
  @override
  double get maxDistance;
  @override
  List<String> get preferredCategories;
  @override
  String get pricePreference;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserLocation _$UserLocationFromJson(Map<String, dynamic> json) {
  return _UserLocation.fromJson(json);
}

/// @nodoc
mixin _$UserLocation {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this UserLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserLocationCopyWith<UserLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserLocationCopyWith<$Res> {
  factory $UserLocationCopyWith(
          UserLocation value, $Res Function(UserLocation) then) =
      _$UserLocationCopyWithImpl<$Res, UserLocation>;
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      String? address,
      String? city,
      String? state,
      String? country,
      DateTime? lastUpdated});
}

/// @nodoc
class _$UserLocationCopyWithImpl<$Res, $Val extends UserLocation>
    implements $UserLocationCopyWith<$Res> {
  _$UserLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? country = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
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
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserLocationImplCopyWith<$Res>
    implements $UserLocationCopyWith<$Res> {
  factory _$$UserLocationImplCopyWith(
          _$UserLocationImpl value, $Res Function(_$UserLocationImpl) then) =
      __$$UserLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      String? address,
      String? city,
      String? state,
      String? country,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$UserLocationImplCopyWithImpl<$Res>
    extends _$UserLocationCopyWithImpl<$Res, _$UserLocationImpl>
    implements _$$UserLocationImplCopyWith<$Res> {
  __$$UserLocationImplCopyWithImpl(
      _$UserLocationImpl _value, $Res Function(_$UserLocationImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? country = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$UserLocationImpl(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
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
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserLocationImpl implements _UserLocation {
  const _$UserLocationImpl(
      {required this.latitude,
      required this.longitude,
      this.address,
      this.city,
      this.state,
      this.country,
      this.lastUpdated});

  factory _$UserLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserLocationImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? address;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? country;
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'UserLocation(latitude: $latitude, longitude: $longitude, address: $address, city: $city, state: $state, country: $country, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserLocationImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, address,
      city, state, country, lastUpdated);

  /// Create a copy of UserLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserLocationImplCopyWith<_$UserLocationImpl> get copyWith =>
      __$$UserLocationImplCopyWithImpl<_$UserLocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserLocationImplToJson(
      this,
    );
  }
}

abstract class _UserLocation implements UserLocation {
  const factory _UserLocation(
      {required final double latitude,
      required final double longitude,
      final String? address,
      final String? city,
      final String? state,
      final String? country,
      final DateTime? lastUpdated}) = _$UserLocationImpl;

  factory _UserLocation.fromJson(Map<String, dynamic> json) =
      _$UserLocationImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get address;
  @override
  String? get city;
  @override
  String? get state;
  @override
  String? get country;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of UserLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserLocationImplCopyWith<_$UserLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
