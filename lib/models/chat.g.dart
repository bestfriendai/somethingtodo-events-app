// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatSessionImpl _$$ChatSessionImplFromJson(Map<String, dynamic> json) =>
    _$ChatSessionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      type:
          $enumDecodeNullable(_$ChatTypeEnumMap, json['type']) ??
          ChatType.eventDiscovery,
      status:
          $enumDecodeNullable(_$ChatStatusEnumMap, json['status']) ??
          ChatStatus.active,
      context: json['context'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ChatSessionImplToJson(_$ChatSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'messages': instance.messages,
      'type': _$ChatTypeEnumMap[instance.type]!,
      'status': _$ChatStatusEnumMap[instance.status]!,
      'context': instance.context,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ChatTypeEnumMap = {
  ChatType.eventDiscovery: 'eventDiscovery',
  ChatType.eventPlanning: 'eventPlanning',
  ChatType.generalSupport: 'generalSupport',
};

const _$ChatStatusEnumMap = {
  ChatStatus.active: 'active',
  ChatStatus.archived: 'archived',
  ChatStatus.deleted: 'deleted',
};

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      role: $enumDecode(_$MessageRoleEnumMap, json['role']),
      content: json['content'] as String,
      type:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      sender:
          $enumDecodeNullable(_$MessageSenderEnumMap, json['sender']) ??
          MessageSender.user,
      metadata: json['metadata'] as Map<String, dynamic>?,
      actions:
          (json['actions'] as List<dynamic>?)
              ?.map((e) => MessageAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map(
                (e) => EventRecommendation.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'sender': _$MessageSenderEnumMap[instance.sender]!,
      'metadata': instance.metadata,
      'actions': instance.actions,
      'recommendations': instance.recommendations,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
  MessageRole.system: 'system',
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.event: 'event',
  MessageType.location: 'location',
  MessageType.image: 'image',
  MessageType.action: 'action',
};

const _$MessageSenderEnumMap = {
  MessageSender.user: 'user',
  MessageSender.assistant: 'assistant',
  MessageSender.system: 'system',
};

_$MessageActionImpl _$$MessageActionImplFromJson(Map<String, dynamic> json) =>
    _$MessageActionImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      type: $enumDecode(_$ActionTypeEnumMap, json['type']),
      payload: json['payload'] as Map<String, dynamic>?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$MessageActionImplToJson(_$MessageActionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'type': _$ActionTypeEnumMap[instance.type]!,
      'payload': instance.payload,
      'isCompleted': instance.isCompleted,
    };

const _$ActionTypeEnumMap = {
  ActionType.viewEvent: 'viewEvent',
  ActionType.saveEvent: 'saveEvent',
  ActionType.shareEvent: 'shareEvent',
  ActionType.filterEvents: 'filterEvents',
  ActionType.showOnMap: 'showOnMap',
  ActionType.buyTicket: 'buyTicket',
};

_$ChatRecommendationImpl _$$ChatRecommendationImplFromJson(
  Map<String, dynamic> json,
) => _$ChatRecommendationImpl(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  reason: json['reason'] as String,
  confidenceScore: (json['confidenceScore'] as num).toDouble(),
  matchingCriteria:
      (json['matchingCriteria'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(_$RecommendationStatusEnumMap, json['status']) ??
      RecommendationStatus.pending,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$ChatRecommendationImplToJson(
  _$ChatRecommendationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'reason': instance.reason,
  'confidenceScore': instance.confidenceScore,
  'matchingCriteria': instance.matchingCriteria,
  'status': _$RecommendationStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$RecommendationStatusEnumMap = {
  RecommendationStatus.pending: 'pending',
  RecommendationStatus.accepted: 'accepted',
  RecommendationStatus.rejected: 'rejected',
  RecommendationStatus.viewed: 'viewed',
};

_$EventRecommendationImpl _$$EventRecommendationImplFromJson(
  Map<String, dynamic> json,
) => _$EventRecommendationImpl(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
  reasons:
      (json['reasons'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  status:
      $enumDecodeNullable(_$RecommendationStatusEnumMap, json['status']) ??
      RecommendationStatus.pending,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$EventRecommendationImplToJson(
  _$EventRecommendationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'title': instance.title,
  'description': instance.description,
  'confidenceScore': instance.confidenceScore,
  'reasons': instance.reasons,
  'status': _$RecommendationStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt?.toIso8601String(),
};
