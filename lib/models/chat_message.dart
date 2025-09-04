import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageSender { user, ai, system }

class ChatMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime? timestamp;
  final List<EventRecommendation> recommendations;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    this.timestamp,
    this.recommendations = const [],
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      sender: MessageSender.values.firstWhere(
        (e) => e.toString().split('.').last == json['sender'],
        orElse: () => MessageSender.system,
      ),
      timestamp: json['timestamp'] != null 
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((r) => EventRecommendation.fromJson(r))
              .toList() ??
          [],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.toString().split('.').last,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    List<EventRecommendation>? recommendations,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      recommendations: recommendations ?? this.recommendations,
      metadata: metadata ?? this.metadata,
    );
  }
}

class EventRecommendation {
  final String eventId;
  final String title;
  final String description;
  final String? imageUrl;
  final double? price;
  final DateTime? date;
  final String? location;

  EventRecommendation({
    required this.eventId,
    required this.title,
    required this.description,
    this.imageUrl,
    this.price,
    this.date,
    this.location,
  });

  factory EventRecommendation.fromJson(Map<String, dynamic> json) {
    return EventRecommendation(
      eventId: json['eventId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      price: json['price']?.toDouble(),
      date: json['date'] != null 
          ? (json['date'] as Timestamp).toDate()
          : null,
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'location': location,
    };
  }
}

class ChatSession {
  final String id;
  final String userId;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? title;

  ChatSession({
    required this.id,
    required this.userId,
    required this.messages,
    required this.createdAt,
    this.lastMessageAt,
    this.title,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastMessageAt: json['lastMessageAt'] != null
          ? (json['lastMessageAt'] as Timestamp).toDate()
          : null,
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': lastMessageAt != null 
          ? Timestamp.fromDate(lastMessageAt!) 
          : null,
      'title': title,
    };
  }

  ChatSession copyWith({
    String? id,
    String? userId,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? title,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      title: title ?? this.title,
    );
  }
}
