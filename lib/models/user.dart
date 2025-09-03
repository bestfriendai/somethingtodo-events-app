import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    @Default(false) bool isPremium,
    DateTime? premiumExpiresAt,
    @Default([]) List<String> interests,
    @Default([]) List<String> favoriteEventIds,
    UserPreferences? preferences,
    UserLocation? location,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(true) bool notificationsEnabled,
    @Default(true) bool locationEnabled,
    @Default(true) bool marketingEmails,
    @Default('light') String theme,
    @Default(10.0) double maxDistance,
    @Default([]) List<String> preferredCategories,
    @Default('any') String pricePreference, // 'free', 'paid', 'any'
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

@freezed
class UserLocation with _$UserLocation {
  const factory UserLocation({
    required double latitude,
    required double longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    DateTime? lastUpdated,
  }) = _UserLocation;

  factory UserLocation.fromJson(Map<String, dynamic> json) =>
      _$UserLocationFromJson(json);
}
