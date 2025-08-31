// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      premiumExpiresAt: json['premiumExpiresAt'] == null
          ? null
          : DateTime.parse(json['premiumExpiresAt'] as String),
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      favoriteEventIds: (json['favoriteEventIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferences: json['preferences'] == null
          ? null
          : UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>),
      location: json['location'] == null
          ? null
          : UserLocation.fromJson(json['location'] as Map<String, dynamic>),
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      createdAt: _fromJsonTimestamp(json['createdAt']),
      updatedAt: _fromJsonTimestamp(json['updatedAt']),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'phoneNumber': instance.phoneNumber,
      'isPremium': instance.isPremium,
      'premiumExpiresAt': instance.premiumExpiresAt?.toIso8601String(),
      'interests': instance.interests,
      'favoriteEventIds': instance.favoriteEventIds,
      'preferences': instance.preferences,
      'location': instance.location,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'createdAt': _toJsonTimestamp(instance.createdAt),
      'updatedAt': _toJsonTimestamp(instance.updatedAt),
    };

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesImpl(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      locationEnabled: json['locationEnabled'] as bool? ?? true,
      marketingEmails: json['marketingEmails'] as bool? ?? true,
      theme: json['theme'] as String? ?? 'light',
      maxDistance: (json['maxDistance'] as num?)?.toDouble() ?? 10.0,
      preferredCategories: (json['preferredCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      pricePreference: json['pricePreference'] as String? ?? 'any',
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'locationEnabled': instance.locationEnabled,
      'marketingEmails': instance.marketingEmails,
      'theme': instance.theme,
      'maxDistance': instance.maxDistance,
      'preferredCategories': instance.preferredCategories,
      'pricePreference': instance.pricePreference,
    };

_$UserLocationImpl _$$UserLocationImplFromJson(Map<String, dynamic> json) =>
    _$UserLocationImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$UserLocationImplToJson(_$UserLocationImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
