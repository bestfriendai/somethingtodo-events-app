import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../data/sample_chat_responses.dart';

// Create a StateNotifier for better state management with Riverpod
class ChatState {
  final List<ChatSession> sessions;
  final ChatSession? currentSession;
  final List<ChatMessage> messages;
  final List<ChatRecommendation> recommendations;
  final bool isLoading;
  final bool isSendingMessage;
  final bool isTyping;
  final String? error;
  final bool isDemoMode;

  ChatState({
    this.sessions = const [],
    this.currentSession,
    this.messages = const [],
    this.recommendations = const [],
    this.isLoading = false,
    this.isSendingMessage = false,
    this.isTyping = false,
    this.error,
    this.isDemoMode = false,
  });

  ChatState copyWith({
    List<ChatSession>? sessions,
    ChatSession? currentSession,
    List<ChatMessage>? messages,
    List<ChatRecommendation>? recommendations,
    bool? isLoading,
    bool? isSendingMessage,
    bool? isTyping,
    String? error,
    bool? isDemoMode,
  }) {
    return ChatState(
      sessions: sessions ?? this.sessions,
      currentSession: currentSession ?? this.currentSession,
      messages: messages ?? this.messages,
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      isTyping: isTyping ?? this.isTyping,
      error: error,
      isDemoMode: isDemoMode ?? this.isDemoMode,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService = ChatService();

  ChatNotifier() : super(ChatState());

  // Expose the same interface methods
  Future<void> sendMessage({
    required String sessionId,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    if (state.currentSession == null) {
      state = state.copyWith(error: 'No active chat session');
      return;
    }

    state = state.copyWith(isSendingMessage: true, error: null);

    try {
      // Add user message to UI immediately for better UX
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: state.currentSession!.id,
        role: MessageRole.user,
        content: content,
        metadata: metadata,
        timestamp: DateTime.now(),
      );
      
      final updatedMessages = [...state.messages, userMessage];
      state = state.copyWith(messages: updatedMessages);

      if (state.isDemoMode) {
        // Simulate typing delay
        state = state.copyWith(isTyping: true);
        await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
        state = state.copyWith(isTyping: false);
        
        // Generate demo response
        final demoResponse = SampleChatResponses.getResponse(content);
        final assistantMessage = ChatMessage(
          id: '${DateTime.now().millisecondsSinceEpoch + 1}',
          sessionId: state.currentSession!.id,
          role: MessageRole.assistant,
          content: demoResponse,
          timestamp: DateTime.now(),
        );
        
        final finalMessages = [...state.messages, assistantMessage];
        state = state.copyWith(messages: finalMessages);
      } else {
        // Send message to AI and get response
        await _chatService.sendMessageToAI(
          sessionId: state.currentSession!.id,
          userMessage: content,
          chatType: state.currentSession!.type,
          context: metadata,
        );

        // Reload messages from server
        final updatedMessages = await _chatService.getSessionMessages(sessionId);
        state = state.copyWith(messages: updatedMessages);
      }

      // Update session in list
      final sessionIndex = state.sessions.indexWhere((s) => s.id == state.currentSession!.id);
      if (sessionIndex != -1) {
        final updatedSessions = [...state.sessions];
        updatedSessions[sessionIndex] = updatedSessions[sessionIndex].copyWith(
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(sessions: updatedSessions);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to send message: $e');
      // Remove the optimistically added message on error
      if (state.messages.isNotEmpty) {
        final revertedMessages = state.messages.sublist(0, state.messages.length - 1);
        state = state.copyWith(messages: revertedMessages);
      }
    } finally {
      state = state.copyWith(isSendingMessage: false);
    }
  }

  void setTyping(bool typing) {
    state = state.copyWith(isTyping: typing);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Riverpod provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

// Keep the old ChangeNotifier for backward compatibility
class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  List<ChatMessage> _currentMessages = [];
  List<ChatRecommendation> _recommendations = [];

  bool _isLoading = false;
  bool _isSendingMessage = false;
  bool _isTyping = false;
  String? _error;
  bool _isDemoMode = false;

  // Getters
  List<ChatSession> get sessions => _sessions;
  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get currentMessages => _currentMessages;
  List<ChatRecommendation> get recommendations => _recommendations;
  
  bool get isLoading => _isLoading;
  bool get isSendingMessage => _isSendingMessage;
  bool get isTyping => _isTyping;
  String? get error => _error;

  // Initialize
  Future<void> initialize(String userId, {bool demoMode = false}) async {
    _isDemoMode = demoMode;
    
    if (_isDemoMode) {
      await _initializeDemoChat(userId);
    } else {
      await _chatService.initialize();
      await loadUserSessions(userId);
      await loadRecommendations(userId);
    }
  }

  // Initialize demo chat with sample data
  Future<void> _initializeDemoChat(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
    
    // Create a sample chat session
    _currentSession = ChatSession(
      id: 'demo_session_1',
      userId: userId,
      type: ChatType.eventDiscovery,
      title: 'Event Discovery',
      messages: [
        ChatMessage(
          id: 'demo_msg_1',
          sessionId: 'demo_session_1',
          role: MessageRole.assistant,
          content: 'Hello! I\'m your personal event assistant. I can help you find amazing events in your area. What are you looking for today?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    );
    
    _sessions = [_currentSession!];
    _currentMessages = List.from(_currentSession!.messages);
    
    // Add some sample recommendations
    _recommendations = [
      ChatRecommendation(
        id: 'demo_rec_1',
        eventId: 'demo_1',
        reason: 'Based on your interest in music events',
        confidenceScore: 0.85,
        matchingCriteria: ['music', 'outdoor'],
        status: RecommendationStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ChatRecommendation(
        id: 'demo_rec_2',
        eventId: 'demo_3',
        reason: 'Free event happening this weekend',
        confidenceScore: 0.72,
        matchingCriteria: ['free', 'food'],
        status: RecommendationStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
    
    notifyListeners();
  }

  // Session Management
  Future<void> loadUserSessions(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _sessions = await _chatService.getUserChatSessions(userId);
    } catch (e) {
      _setError('Failed to load chat sessions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<ChatSession> createNewSession({
    required String userId,
    required ChatType type,
    String? title,
    Map<String, dynamic>? context,
  }) async {
    _clearError();

    try {
      ChatSession session;
      
      if (_isDemoMode) {
        // Create demo session
        final sessionId = 'demo_session_${DateTime.now().millisecondsSinceEpoch}';
        session = ChatSession(
          id: sessionId,
          userId: userId,
          type: type,
          title: title ?? 'New ${type.name} chat',
          messages: [],
          context: context,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        session = await _chatService.createChatSession(
          userId: userId,
          type: type,
          title: title,
          context: context,
        );
      }

      _sessions.insert(0, session);
      _currentSession = session;
      _currentMessages = [];
      notifyListeners();

      return session;
    } catch (e) {
      _setError('Failed to create chat session: $e');
      rethrow;
    }
  }

  // Get session by ID
  Future<ChatSession?> getSession(String sessionId) async {
    try {
      return await _chatService.getChatSession(sessionId);
    } catch (e) {
      _setError('Failed to get session: $e');
      return null;
    }
  }

  Future<void> selectSession(String sessionId) async {
    _setLoading(true);
    _clearError();

    try {
      final session = await _chatService.getChatSession(sessionId);
      if (session != null) {
        _currentSession = session;
        await loadSessionMessages(sessionId);
      } else {
        _setError('Session not found');
      }
    } catch (e) {
      _setError('Failed to select session: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteSession(String sessionId) async {
    _clearError();

    try {
      await _chatService.deleteChatSession(sessionId);
      
      _sessions.removeWhere((session) => session.id == sessionId);
      
      if (_currentSession?.id == sessionId) {
        _currentSession = null;
        _currentMessages = [];
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete session: $e');
    }
  }

  Future<void> updateSessionTitle(String sessionId, String newTitle) async {
    try {
      final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex != -1) {
        final updatedSession = _sessions[sessionIndex].copyWith(title: newTitle);
        await _chatService.updateChatSession(updatedSession);
        
        _sessions[sessionIndex] = updatedSession;
        if (_currentSession?.id == sessionId) {
          _currentSession = updatedSession;
        }
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update session title: $e');
    }
  }

  // Message Management
  Future<void> loadSessionMessages(String sessionId) async {
    try {
      _currentMessages = await _chatService.getSessionMessages(sessionId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load messages: $e');
    }
  }

  Future<void> sendMessage({
    required String content,
    Map<String, dynamic>? context,
  }) async {
    if (_currentSession == null) {
      _setError('No active chat session');
      return;
    }

    _isSendingMessage = true;
    _clearError();

    try {
      // Add user message to UI immediately for better UX
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: _currentSession!.id,
        role: MessageRole.user,
        content: content,
        timestamp: DateTime.now(),
      );
      
      _currentMessages.add(userMessage);
      notifyListeners();

      if (_isDemoMode) {
        // Simulate typing delay
        setTyping(true);
        await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
        setTyping(false);
        
        // Generate demo response
        final demoResponse = SampleChatResponses.getResponse(content);
        final assistantMessage = ChatMessage(
          id: '${DateTime.now().millisecondsSinceEpoch + 1}',
          sessionId: _currentSession!.id,
          role: MessageRole.assistant,
          content: demoResponse,
          timestamp: DateTime.now(),
        );
        
        _currentMessages.add(assistantMessage);
      } else {
        // Send message to AI and get response
        await _chatService.sendMessageToAI(
          sessionId: _currentSession!.id,
          userMessage: content,
          chatType: _currentSession!.type,
          context: context,
        );

        // Update messages with actual IDs from server
        await loadSessionMessages(_currentSession!.id);
      }

      // Update session in list
      final sessionIndex = _sessions.indexWhere((s) => s.id == _currentSession!.id);
      if (sessionIndex != -1) {
        _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      _setError('Failed to send message: $e');
      // Remove the optimistically added message on error
      _currentMessages.removeLast();
      notifyListeners();
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  // Add message directly (for system messages, etc.)
  Future<void> addMessage(ChatMessage message) async {
    if (_currentSession == null) return;
    
    try {
      _currentMessages.add(message);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add message: $e');
    }
  }

  // Set typing indicator
  void setTyping(bool typing) {
    if (_isTyping != typing) {
      _isTyping = typing;
      notifyListeners();
    }
  }

  Future<void> sendQuickReply(String reply) async {
    await sendMessage(content: reply);
  }

  // Message Streams for real-time updates
  void subscribeToMessages(String sessionId) {
    _chatService.getSessionMessagesStream(sessionId).listen(
      (messages) {
        if (_currentSession?.id == sessionId) {
          _currentMessages = messages;
          notifyListeners();
        }
      },
      onError: (error) {
        _setError('Message stream error: $error');
      },
    );
  }

  void unsubscribeFromMessages() {
    // Implementation would depend on how the stream subscription is managed
  }

  // Recommendations
  Future<void> loadRecommendations(String userId) async {
    try {
      _recommendations = await _chatService.getRecommendations(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recommendations: $e');
    }
  }

  Future<void> acceptRecommendation(String recommendationId) async {
    try {
      await _chatService.updateRecommendationStatus(
        recommendationId,
        RecommendationStatus.accepted,
      );

      final index = _recommendations.indexWhere((r) => r.id == recommendationId);
      if (index != -1) {
        _recommendations[index] = _recommendations[index].copyWith(
          status: RecommendationStatus.accepted,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to accept recommendation: $e');
    }
  }

  Future<void> rejectRecommendation(String recommendationId) async {
    try {
      await _chatService.updateRecommendationStatus(
        recommendationId,
        RecommendationStatus.rejected,
      );

      final index = _recommendations.indexWhere((r) => r.id == recommendationId);
      if (index != -1) {
        _recommendations[index] = _recommendations[index].copyWith(
          status: RecommendationStatus.rejected,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to reject recommendation: $e');
    }
  }

  Future<void> markRecommendationViewed(String recommendationId) async {
    try {
      await _chatService.updateRecommendationStatus(
        recommendationId,
        RecommendationStatus.viewed,
      );

      final index = _recommendations.indexWhere((r) => r.id == recommendationId);
      if (index != -1) {
        _recommendations[index] = _recommendations[index].copyWith(
          status: RecommendationStatus.viewed,
        );
        notifyListeners();
      }
    } catch (e) {
      // Silently handle error for viewed status
      debugPrint('Failed to mark recommendation as viewed: $e');
    }
  }

  // Quick Actions
  List<String> getQuickReplies() {
    if (_currentSession == null) return [];

    switch (_currentSession!.type) {
      case ChatType.eventDiscovery:
        return [
          'Find events near me',
          'What\'s happening this weekend?',
          'Show me music events',
          'Find free events',
          'Events tonight',
        ];
      case ChatType.eventPlanning:
        return [
          'Help me plan my day',
          'Find nearby restaurants',
          'Transportation options',
          'What should I do before/after?',
        ];
      case ChatType.generalSupport:
        return [
          'How do I save events?',
          'How to get directions?',
          'Account settings',
          'Report an issue',
        ];
    }
  }

  List<String> getSuggestedQuestions() {
    if (_currentSession == null) return [];

    // Generate context-aware suggestions based on conversation history
    final lastMessage = _currentMessages.isNotEmpty ? _currentMessages.last : null;
    
    if (lastMessage?.role == MessageRole.assistant) {
      return [
        'Tell me more',
        'Show me similar events',
        'What else can you recommend?',
        'Help me find something different',
      ];
    }

    return getQuickReplies();
  }

  // Helper Methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Utility Methods
  bool hasActiveSession() => _currentSession != null;

  String getSessionPreview(ChatSession session) {
    if (session.messages.isEmpty) {
      return 'New ${session.type.name} conversation';
    }
    
    final lastMessage = session.messages.last;
    return lastMessage.content.length > 50
        ? '${lastMessage.content.substring(0, 50)}...'
        : lastMessage.content;
  }

  DateTime? getSessionLastActivity(ChatSession session) {
    if (session.messages.isEmpty) return session.createdAt;
    return session.messages.last.timestamp;
  }

  int getUnreadRecommendationCount() {
    return _recommendations
        .where((r) => r.status == RecommendationStatus.pending)
        .length;
  }

  List<ChatRecommendation> getPendingRecommendations() {
    return _recommendations
        .where((r) => r.status == RecommendationStatus.pending)
        .toList();
  }

  // Session context helpers
  void updateSessionContext(Map<String, dynamic> context) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        context: {...?_currentSession!.context, ...context},
      );
      notifyListeners();
    }
  }

  Map<String, dynamic>? getCurrentSessionContext() {
    return _currentSession?.context;
  }
}