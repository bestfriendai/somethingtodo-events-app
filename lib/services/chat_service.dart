import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:uuid/uuid.dart';
import '../models/chat.dart';
import '../models/analytics.dart';
import '../config/app_config.dart';
import '../data/sample_chat_responses.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final Dio _dio = Dio();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final Uuid _uuid = const Uuid();

  // Collections
  CollectionReference get _chatSessionsCollection =>
      _firestore.collection('chatSessions');
  CollectionReference get _messagesCollection =>
      _firestore.collection('messages');
  CollectionReference get _recommendationsCollection =>
      _firestore.collection('recommendations');

  // Initialize chat service
  Future<void> initialize() async {
    if (!AppConfig.demoMode) {
      _dio.options.baseUrl = 'https://api.openai.com/v1/';
      _dio.options.headers = {
        'Authorization': 'Bearer ${AppConfig.openAIApiKey}',
        'Content-Type': 'application/json',
      };
      _dio.options.connectTimeout = const Duration(
        seconds: AppConfig.chatTimeoutSeconds,
      );
    }
  }

  // Chat Session Management
  Future<ChatSession> createChatSession({
    required String userId,
    required ChatType type,
    String? title,
    Map<String, dynamic>? context,
  }) async {
    try {
      final session = ChatSession(
        id: _uuid.v4(),
        userId: userId,
        title: title ?? _generateSessionTitle(type),
        type: type,
        context: context,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (!AppConfig.demoMode) {
        await _chatSessionsCollection.doc(session.id).set(session.toJson());

        await _analytics.logEvent(
          name: AnalyticsEvents.chatStart,
          parameters: {
            'user_id': userId,
            'chat_type': type.name,
            'session_id': session.id,
          },
        );
      }

      return session;
    } catch (e) {
      throw Exception('Failed to create chat session: $e');
    }
  }

  Future<List<ChatSession>> getUserChatSessions(String userId) async {
    try {
      // In demo mode, return empty list or mock sessions
      if (AppConfig.demoMode) {
        return [];
      }

      final querySnapshot = await _chatSessionsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: ChatStatus.active.name)
          .orderBy('updatedAt', descending: true)
          .limit(AppConfig.maxChatHistory)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => ChatSession.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      // In case of permission errors or other issues, return empty list
      print('Failed to get chat sessions: $e');
      return [];
    }
  }

  Future<ChatSession?> getChatSession(String sessionId) async {
    try {
      final doc = await _chatSessionsCollection.doc(sessionId).get();
      if (doc.exists) {
        return ChatSession.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get chat session: $e');
    }
  }

  Future<void> updateChatSession(ChatSession session) async {
    try {
      await _chatSessionsCollection
          .doc(session.id)
          .update(session.copyWith(updatedAt: DateTime.now()).toJson());
    } catch (e) {
      throw Exception('Failed to update chat session: $e');
    }
  }

  Future<void> deleteChatSession(String sessionId) async {
    try {
      // Mark as deleted instead of actually deleting
      await _chatSessionsCollection.doc(sessionId).update({
        'status': ChatStatus.deleted.name,
        'updatedAt': Timestamp.now(),
      });

      // Also delete all messages in the session
      final messagesQuery = await _messagesCollection
          .where('sessionId', isEqualTo: sessionId)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete chat session: $e');
    }
  }

  // Message Management
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String content,
    required MessageRole role,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final message = ChatMessage(
        id: _uuid.v4(),
        sessionId: sessionId,
        role: role,
        content: content,
        type: type,
        metadata: metadata,
        timestamp: DateTime.now(),
      );

      if (!AppConfig.demoMode) {
        await _messagesCollection.doc(message.id).set(message.toJson());

        // Update session's last updated time
        await _chatSessionsCollection.doc(sessionId).update({
          'updatedAt': Timestamp.now(),
        });

        if (role == MessageRole.user) {
          await _analytics.logEvent(
            name: AnalyticsEvents.chatMessage,
            parameters: {'session_id': sessionId, 'message_type': type.name},
          );
        }
      }

      return message;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<List<ChatMessage>> getSessionMessages(String sessionId) async {
    try {
      final querySnapshot = await _messagesCollection
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('timestamp')
          .get();

      return querySnapshot.docs
          .map(
            (doc) => ChatMessage.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get session messages: $e');
    }
  }

  Stream<List<ChatMessage>> getSessionMessagesStream(String sessionId) {
    return _messagesCollection
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    ChatMessage.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }

  // AI Chat Integration
  Future<ChatMessage> sendMessageToAI({
    required String sessionId,
    required String userMessage,
    required ChatType chatType,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Save user message
      await sendMessage(
        sessionId: sessionId,
        content: userMessage,
        role: MessageRole.user,
      );

      ChatMessage aiResponse;

      if (AppConfig.demoMode) {
        // Use demo response
        aiResponse = ChatMessage(
          id: _uuid.v4(),
          sessionId: sessionId,
          role: MessageRole.assistant,
          content: SampleChatResponses.getResponse(userMessage),
          timestamp: DateTime.now(),
        );
      } else {
        // Get conversation history
        final messages = await getSessionMessages(sessionId);

        // Generate AI response
        aiResponse = await _generateAIResponse(
          messages: messages,
          chatType: chatType,
          context: context,
        );
      }

      // Save AI response
      final responseMessage = await sendMessage(
        sessionId: sessionId,
        content: aiResponse.content,
        role: MessageRole.assistant,
        type: aiResponse.type,
        metadata: aiResponse.metadata,
      );

      // Process any actions in the response
      if (aiResponse.actions.isNotEmpty) {
        await _processMessageActions(sessionId, aiResponse.actions);
      }

      return responseMessage;
    } catch (e) {
      throw Exception('Failed to send message to AI: $e');
    }
  }

  Future<ChatMessage> _generateAIResponse({
    required List<ChatMessage> messages,
    required ChatType chatType,
    Map<String, dynamic>? context,
  }) async {
    try {
      final systemPrompt = _getSystemPrompt(chatType, context);
      final conversationMessages = _formatMessagesForAPI(messages);

      final response = await _dio.post(
        'chat/completions',
        data: {
          'model': 'gpt-4-turbo-preview',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...conversationMessages,
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
          'functions': _getChatFunctions(chatType),
          'function_call': 'auto',
        },
      );

      final responseData = response.data;
      final choice = responseData['choices'][0];
      final message = choice['message'];

      if (message.containsKey('function_call')) {
        return await _processFunctionCall(message['function_call']);
      } else {
        return ChatMessage(
          id: _uuid.v4(),
          sessionId: '',
          role: MessageRole.assistant,
          content:
              message['content'] ??
              'I apologize, but I encountered an error processing your request.',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      return ChatMessage(
        id: _uuid.v4(),
        sessionId: '',
        role: MessageRole.assistant,
        content:
            'I apologize, but I\'m having trouble connecting right now. Please try again in a moment.',
        timestamp: DateTime.now(),
      );
    }
  }

  String _getSystemPrompt(ChatType chatType, Map<String, dynamic>? context) {
    switch (chatType) {
      case ChatType.eventDiscovery:
        return '''
You are an AI assistant helping users discover events in their area. You can:
- Search for events based on user preferences
- Recommend events based on their interests
- Provide event details and help with planning
- Answer questions about venues, pricing, and logistics

Be helpful, friendly, and focus on finding the perfect events for the user's needs.
${context != null ? 'User context: ${json.encode(context)}' : ''}
        ''';

      case ChatType.eventPlanning:
        return '''
You are an AI assistant helping users plan their event attendance. You can:
- Help create event itineraries
- Suggest nearby restaurants and activities
- Provide transportation advice
- Help coordinate with friends

Be practical and organized in your suggestions.
${context != null ? 'User context: ${json.encode(context)}' : ''}
        ''';

      case ChatType.generalSupport:
        return '''
You are a helpful AI assistant for the SomethingToDo app. You can:
- Help users navigate the app
- Answer questions about features
- Assist with account issues
- Provide general support

Be patient and helpful, and guide users to the right resources.
${context != null ? 'User context: ${json.encode(context)}' : ''}
        ''';
    }
  }

  List<Map<String, dynamic>> _formatMessagesForAPI(List<ChatMessage> messages) {
    return messages
        .where((msg) => msg.role != MessageRole.system)
        .map((msg) => {'role': msg.role.name, 'content': msg.content})
        .toList();
  }

  List<Map<String, dynamic>> _getChatFunctions(ChatType chatType) {
    switch (chatType) {
      case ChatType.eventDiscovery:
        return [
          {
            'name': 'search_events',
            'description': 'Search for events based on criteria',
            'parameters': {
              'type': 'object',
              'properties': {
                'query': {'type': 'string', 'description': 'Search query'},
                'category': {'type': 'string', 'description': 'Event category'},
                'location': {'type': 'string', 'description': 'Location'},
                'date_range': {'type': 'string', 'description': 'Date range'},
                'price_range': {
                  'type': 'string',
                  'description': 'Price preference',
                },
              },
            },
          },
          {
            'name': 'recommend_events',
            'description': 'Get personalized event recommendations',
            'parameters': {
              'type': 'object',
              'properties': {
                'interests': {
                  'type': 'array',
                  'items': {'type': 'string'},
                  'description': 'User interests',
                },
                'location': {'type': 'string', 'description': 'User location'},
              },
            },
          },
        ];
      default:
        return [];
    }
  }

  Future<ChatMessage> _processFunctionCall(
    Map<String, dynamic> functionCall,
  ) async {
    final functionName = functionCall['name'];
    final arguments = json.decode(functionCall['arguments']);

    switch (functionName) {
      case 'search_events':
        return await _handleSearchEvents(arguments);
      case 'recommend_events':
        return await _handleRecommendEvents(arguments);
      default:
        return ChatMessage(
          id: _uuid.v4(),
          sessionId: '',
          role: MessageRole.assistant,
          content: 'I encountered an error processing your request.',
          timestamp: DateTime.now(),
        );
    }
  }

  Future<ChatMessage> _handleSearchEvents(Map<String, dynamic> args) async {
    // This would integrate with FirestoreService to search events
    // For now, return a mock response
    return ChatMessage(
      id: _uuid.v4(),
      sessionId: '',
      role: MessageRole.assistant,
      content:
          'I found several events matching your criteria. Let me show you the best options.',
      type: MessageType.event,
      actions: [
        MessageAction(
          id: _uuid.v4(),
          label: 'View Events',
          type: ActionType.filterEvents,
          payload: args,
        ),
      ],
      timestamp: DateTime.now(),
    );
  }

  Future<ChatMessage> _handleRecommendEvents(Map<String, dynamic> args) async {
    // This would generate personalized recommendations
    return ChatMessage(
      id: _uuid.v4(),
      sessionId: '',
      role: MessageRole.assistant,
      content:
          'Based on your interests, I have some great event recommendations for you!',
      type: MessageType.event,
      timestamp: DateTime.now(),
    );
  }

  Future<void> _processMessageActions(
    String sessionId,
    List<MessageAction> actions,
  ) async {
    // Process any automated actions that should happen after a message
    for (final action in actions) {
      switch (action.type) {
        case ActionType.saveEvent:
          // Auto-save recommended events
          break;
        case ActionType.filterEvents:
          // Apply search filters
          break;
        default:
          break;
      }
    }
  }

  String _generateSessionTitle(ChatType type) {
    switch (type) {
      case ChatType.eventDiscovery:
        return 'Event Discovery';
      case ChatType.eventPlanning:
        return 'Event Planning';
      case ChatType.generalSupport:
        return 'General Support';
    }
  }

  // Recommendations
  Future<List<ChatRecommendation>> getRecommendations(String userId) async {
    try {
      final querySnapshot = await _recommendationsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: RecommendationStatus.pending.name)
          .orderBy('confidenceScore', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                ChatRecommendation.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }

  Future<void> updateRecommendationStatus(
    String recommendationId,
    RecommendationStatus status,
  ) async {
    try {
      await _recommendationsCollection.doc(recommendationId).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update recommendation status: $e');
    }
  }
}
