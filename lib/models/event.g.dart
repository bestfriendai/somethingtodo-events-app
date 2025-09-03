// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  organizerName: json['organizerName'] as String,
  organizerImageUrl: json['organizerImageUrl'] as String?,
  venue: EventVenue.fromJson(json['venue'] as Map<String, dynamic>),
  imageUrls: (json['imageUrls'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  category: $enumDecode(_$EventCategoryEnumMap, json['category']),
  pricing: EventPricing.fromJson(json['pricing'] as Map<String, dynamic>),
  startDateTime: DateTime.parse(json['startDateTime'] as String),
  endDateTime: DateTime.parse(json['endDateTime'] as String),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  attendeeCount: (json['attendeeCount'] as num?)?.toInt() ?? 0,
  maxAttendees: (json['maxAttendees'] as num?)?.toInt() ?? 0,
  favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
  status:
      $enumDecodeNullable(_$EventStatusEnumMap, json['status']) ??
      EventStatus.active,
  websiteUrl: json['websiteUrl'] as String?,
  ticketUrl: json['ticketUrl'] as String?,
  contactEmail: json['contactEmail'] as String?,
  contactPhone: json['contactPhone'] as String?,
  isFeatured: json['isFeatured'] as bool? ?? false,
  isPremium: json['isPremium'] as bool? ?? false,
  isOnline: json['isOnline'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  createdBy: json['createdBy'] as String?,
);

Map<String, dynamic> _$$EventImplToJson(_$EventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'organizerName': instance.organizerName,
      'organizerImageUrl': instance.organizerImageUrl,
      'venue': instance.venue,
      'imageUrls': instance.imageUrls,
      'category': _$EventCategoryEnumMap[instance.category]!,
      'pricing': instance.pricing,
      'startDateTime': instance.startDateTime.toIso8601String(),
      'endDateTime': instance.endDateTime.toIso8601String(),
      'tags': instance.tags,
      'attendeeCount': instance.attendeeCount,
      'maxAttendees': instance.maxAttendees,
      'favoriteCount': instance.favoriteCount,
      'status': _$EventStatusEnumMap[instance.status]!,
      'websiteUrl': instance.websiteUrl,
      'ticketUrl': instance.ticketUrl,
      'contactEmail': instance.contactEmail,
      'contactPhone': instance.contactPhone,
      'isFeatured': instance.isFeatured,
      'isPremium': instance.isPremium,
      'isOnline': instance.isOnline,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'createdBy': instance.createdBy,
    };

const _$EventCategoryEnumMap = {
  EventCategory.music: 'music',
  EventCategory.food: 'food',
  EventCategory.sports: 'sports',
  EventCategory.arts: 'arts',
  EventCategory.business: 'business',
  EventCategory.education: 'education',
  EventCategory.technology: 'technology',
  EventCategory.health: 'health',
  EventCategory.community: 'community',
  EventCategory.other: 'other',
};

const _$EventStatusEnumMap = {
  EventStatus.draft: 'draft',
  EventStatus.active: 'active',
  EventStatus.cancelled: 'cancelled',
  EventStatus.completed: 'completed',
  EventStatus.soldOut: 'soldOut',
};

_$EventVenueImpl _$$EventVenueImplFromJson(Map<String, dynamic> json) =>
    _$EventVenueImpl(
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      zipCode: json['zipCode'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );

Map<String, dynamic> _$$EventVenueImplToJson(_$EventVenueImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'zipCode': instance.zipCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'websiteUrl': instance.websiteUrl,
      'phoneNumber': instance.phoneNumber,
    };

_$EventPricingImpl _$$EventPricingImplFromJson(Map<String, dynamic> json) =>
    _$EventPricingImpl(
      isFree: json['isFree'] as bool? ?? true,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      priceDescription: json['priceDescription'] as String?,
      tiers:
          (json['tiers'] as List<dynamic>?)
              ?.map((e) => TicketTier.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EventPricingImplToJson(_$EventPricingImpl instance) =>
    <String, dynamic>{
      'isFree': instance.isFree,
      'price': instance.price,
      'currency': instance.currency,
      'priceDescription': instance.priceDescription,
      'tiers': instance.tiers,
    };

_$TicketTierImpl _$$TicketTierImplFromJson(Map<String, dynamic> json) =>
    _$TicketTierImpl(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      available: (json['available'] as num?)?.toInt() ?? 0,
      sold: (json['sold'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TicketTierImplToJson(_$TicketTierImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'available': instance.available,
      'sold': instance.sold,
    };
