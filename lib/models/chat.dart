import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
class ChatSession with _$ChatSession {
  const factory ChatSession({
    required String id,
    required String userId,
    required String title,
    @Default([]) List<ChatMessage> messages,
    @Default(ChatType.eventDiscovery) ChatType type,
    @Default(ChatStatus.active) ChatStatus status,
    Map<String, dynamic>? context,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChatSession;

  factory ChatSession.fromJson(Map<String, dynamic> json) => 
      _$ChatSessionFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String sessionId,
    required MessageRole role,
    required String content,
    @Default(MessageType.text) MessageType type,
    @Default(MessageSender.user) MessageSender sender,
    Map<String, dynamic>? metadata,
    @Default([]) List<MessageAction> actions,
    @Default([]) List<EventRecommendation> recommendations,
    DateTime? timestamp,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => 
      _$ChatMessageFromJson(json);
}

@freezed
class MessageAction with _$MessageAction {
  const factory MessageAction({
    required String id,
    required String label,
    required ActionType type,
    Map<String, dynamic>? payload,
    @Default(false) bool isCompleted,
  }) = _MessageAction;

  factory MessageAction.fromJson(Map<String, dynamic> json) => 
      _$MessageActionFromJson(json);
}

@freezed
class ChatRecommendation with _$ChatRecommendation {
  const factory ChatRecommendation({
    required String id,
    required String eventId,
    required String reason,
    required double confidenceScore,
    @Default([]) List<String> matchingCriteria,
    @Default(RecommendationStatus.pending) RecommendationStatus status,
    DateTime? createdAt,
  }) = _ChatRecommendation;

  factory ChatRecommendation.fromJson(Map<String, dynamic> json) => 
      _$ChatRecommendationFromJson(json);
}

enum ChatType {
  @JsonValue('eventDiscovery')
  eventDiscovery,
  @JsonValue('eventPlanning')
  eventPlanning,
  @JsonValue('generalSupport')
  generalSupport,
}

enum ChatStatus {
  @JsonValue('active')
  active,
  @JsonValue('archived')
  archived,
  @JsonValue('deleted')
  deleted,
}

enum MessageRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('system')
  system,
}

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('event')
  event,
  @JsonValue('location')
  location,
  @JsonValue('image')
  image,
  @JsonValue('action')
  action,
}

enum ActionType {
  @JsonValue('viewEvent')
  viewEvent,
  @JsonValue('saveEvent')
  saveEvent,
  @JsonValue('shareEvent')
  shareEvent,
  @JsonValue('filterEvents')
  filterEvents,
  @JsonValue('showOnMap')
  showOnMap,
  @JsonValue('buyTicket')
  buyTicket,
}

@freezed
class EventRecommendation with _$EventRecommendation {
  const factory EventRecommendation({
    required String id,
    required String eventId,
    required String title,
    required String description,
    @Default(0.0) double confidenceScore,
    @Default([]) List<String> reasons,
    @Default(RecommendationStatus.pending) RecommendationStatus status,
    DateTime? createdAt,
  }) = _EventRecommendation;

  factory EventRecommendation.fromJson(Map<String, dynamic> json) => 
      _$EventRecommendationFromJson(json);
}

enum MessageSender {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('system')
  system,
}

enum RecommendationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
  @JsonValue('viewed')
  viewed,
}

