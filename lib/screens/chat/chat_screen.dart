import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/chat.dart';
import '../../models/event.dart';
import '../../config/theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../widgets/common/event_card.dart';
import '../events/event_details_screen.dart';

class ChatScreen extends StatefulWidget {
  final String? sessionId;

  const ChatScreen({super.key, this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  
  late AnimationController _typingAnimationController;
  late AnimationController _messageAnimationController;
  
  bool _isKeyboardVisible = false;
  ChatSession? _currentSession;
  
  final List<String> _quickActions = [
    '🎵 Music events near me',
    '🍽️ Food festivals',
    '🎨 Art exhibitions',
    '⚽ Sports events',
    '💼 Networking events',
    '📚 Workshops & classes',
  ];

  @override
  void initState() {
    super.initState();
    
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
    
    // Listen to keyboard visibility
    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus != _isKeyboardVisible) {
        setState(() {
          _isKeyboardVisible = _messageFocusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _messageAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final chatProvider = context.read<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.currentUser == null) return;
    
    if (widget.sessionId != null) {
      _currentSession = await chatProvider.getSession(widget.sessionId!);
    } else {
      // Create or get the current active session
      _currentSession = await chatProvider.createNewSession(
        userId: authProvider.currentUser!.id,
        type: ChatType.eventDiscovery,
        title: 'New Chat',
      );
    }
    
    if (_currentSession != null && _currentSession!.messages.isEmpty) {
      // Send welcome message
      await _sendWelcomeMessage();
    }
    
    setState(() {});
    _scrollToBottom();
  }

  Future<void> _sendWelcomeMessage() async {
    final chatProvider = context.read<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (_currentSession == null || authProvider.currentUser == null) return;
    
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _currentSession!.id,
      role: MessageRole.assistant,
      content: 'Hi ${authProvider.currentUser!.displayName?.split(' ').first ?? 'there'}! 👋\n\n'
                'I\'m your personal event discovery assistant. I can help you find amazing events based on your interests, location, and preferences.\n\n'
                'What kind of events are you looking for today?',
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
    );
    
    await chatProvider.addMessage(welcomeMessage);
  }

  Future<void> _sendMessage([String? predefinedMessage]) async {
    final message = predefinedMessage ?? _messageController.text.trim();
    if (message.isEmpty) return;
    
    final chatProvider = context.read<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (_currentSession == null || authProvider.currentUser == null) return;
    
    // Clear input if it's user typing
    if (predefinedMessage == null) {
      _messageController.clear();
    }
    
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _currentSession!.id,
      role: MessageRole.user,
      content: message,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    
    await chatProvider.addMessage(userMessage);
    
    // Scroll to bottom
    _scrollToBottom();
    
    // Generate AI response
    await _generateAIResponse(message);
  }

  Future<void> _generateAIResponse(String userMessage) async {
    final chatProvider = context.read<ChatProvider>();
    final eventsProvider = context.read<EventsProvider>();
    
    if (_currentSession == null) return;
    
    // Show typing indicator
    setState(() {});
    
    // Simulate AI thinking time
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Generate response based on user message
    String responseText = '';
    List<EventRecommendation> recommendations = [];
    
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('music') || lowerMessage.contains('🎵')) {
      responseText = 'Great choice! Here are some amazing music events I found for you:';
      final musicEvents = eventsProvider.getEventsByCategory(EventCategory.music);
      recommendations = musicEvents.take(3).map((event) => 
        EventRecommendation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          eventId: event.id,
          title: event.title,
          description: event.description,
          confidenceScore: 0.9,
          reasons: ['Based on your interest in music events'],
        )
      ).toList();
    } else if (lowerMessage.contains('food') || lowerMessage.contains('🍽️')) {
      responseText = 'Delicious! I\'ve found some fantastic food events for you:';
      final foodEvents = eventsProvider.getEventsByCategory(EventCategory.food);
      recommendations = foodEvents.take(3).map((event) => 
        EventRecommendation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          eventId: event.id,
          title: event.title,
          description: event.description,
          confidenceScore: 0.85,
          reasons: ['Perfect for food enthusiasts'],
        )
      ).toList();
    } else if (lowerMessage.contains('art') || lowerMessage.contains('🎨')) {
      responseText = 'Wonderful! Here are some inspiring art events:';
      final artEvents = eventsProvider.getEventsByCategory(EventCategory.arts);
      recommendations = artEvents.take(3).map((event) => 
        EventRecommendation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          eventId: event.id,
          title: event.title,
          description: event.description,
          confidenceScore: 0.88,
          reasons: ['Great for art and culture lovers'],
        )
      ).toList();
    } else if (lowerMessage.contains('sport') || lowerMessage.contains('⚽')) {
      responseText = 'Let\'s get active! Here are some exciting sports events:';
      final sportsEvents = eventsProvider.getEventsByCategory(EventCategory.sports);
      recommendations = sportsEvents.take(3).map((event) => 
        EventRecommendation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          eventId: event.id,
          title: event.title,
          description: event.description,
          confidenceScore: 0.92,
          reasons: ['Perfect for sports enthusiasts'],
        )
      ).toList();
    } else if (lowerMessage.contains('free') || lowerMessage.contains('budget')) {
      responseText = 'I understand budget is important! Here are some amazing free events:';
      final freeEvents = eventsProvider.events
          .where((event) => event.pricing.isFree)
          .toList();
      recommendations = freeEvents.take(3).map((event) => 
        EventRecommendation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          eventId: event.id,
          title: event.title,
          description: event.description,
          confidenceScore: 0.95,
          reasons: ['Free events that match your budget'],
        )
      ).toList();
    } else if (lowerMessage.contains('tonight') || lowerMessage.contains('today')) {
      responseText = 'Looking for something to do right now? Here are today\'s events:';
      final today = DateTime.now();
      final todayEvents = eventsProvider.events
          .where((event) => 
            event.startDateTime.year == today.year &&
            event.startDateTime.month == today.month &&
            event.startDateTime.day == today.day)
          .toList();
      recommendations = todayEvents.take(3).map((event) => 
        EventRecommendation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          eventId: event.id,
          title: event.title,
          description: event.description,
          confidenceScore: 1.0,
          reasons: ['Happening today!'],
        )
      ).toList();
    } else if (lowerMessage.contains('weekend') || lowerMessage.contains('saturday') || lowerMessage.contains('sunday')) {
      responseText = 'Weekend plans coming up! Here are some great weekend events:';
      final weekendEvents = eventsProvider.getEventsThisWeekend();
      recommendations = weekendEvents.take(3).map((event) => 
        EventRecommendation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          eventId: event.id,
          title: event.title,
          description: event.description,
          confidenceScore: 0.90,
          reasons: ['Perfect for your weekend'],
        )
      ).toList();
    } else {
      responseText = 'I\'d love to help you find the perfect events! Here are some popular events happening near you:';
      final popularEvents = eventsProvider.events
          .where((event) => event.attendeeCount > 50)
          .toList();
      recommendations = popularEvents.take(3).map((event) => 
        EventRecommendation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          eventId: event.id,
          title: event.title,
          description: event.description,
          confidenceScore: 0.8,
          reasons: ['Popular events in your area'],
        )
      ).toList();
    }
    
    if (recommendations.isEmpty) {
      responseText = 'I\'m still learning about events in your area! Here are some general recommendations:';
      recommendations = eventsProvider.events.take(3).map((event) => 
        EventRecommendation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          eventId: event.id,
          title: event.title,
          description: event.description,
          confidenceScore: 0.7,
          reasons: ['Based on popular events'],
        )
      ).toList();
    }
    
    // Add follow-up suggestions
    responseText += '\n\nWould you like me to:\n'
                   '• Filter by date range?\n'
                   '• Show only free events?\n'
                   '• Find events in a specific location?\n'
                   '• Get more details about any of these events?';
    
    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _currentSession!.id,
      role: MessageRole.assistant,
      content: responseText,
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      recommendations: recommendations.isNotEmpty ? recommendations : [],
    );
    
    await chatProvider.addMessage(aiMessage);
    
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildQuickActions(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Assistant'),
          Text(
            'Event Discovery',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return IconButton(
              onPressed: () => _showSessionsBottomSheet(),
              icon: Stack(
                children: [
                  const Icon(Icons.history),
                  if (chatProvider.sessions.length > 1)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (_currentSession == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final messages = _currentSession!.messages;
        
        if (messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length + (chatProvider.isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length && chatProvider.isTyping) {
              return _buildTypingIndicator();
            }
            
            final message = messages[index];
            return _buildMessageBubble(message, index);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.sender == MessageSender.user;
    final showAvatar = index == 0 || 
        (index > 0 && _currentSession!.messages[index - 1].sender != message.sender);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 16,
                ),
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? AppTheme.primaryColor 
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : null,
                    ),
                  ),
                ),
                
                // Event recommendations
                if (message.recommendations.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  ...message.recommendations.map((rec) => 
                    _buildRecommendationCard(rec)
                  ),
                ],
                
                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('h:mm a').format(message.timestamp ?? DateTime.now()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return CircleAvatar(
                  radius: 16,
                  backgroundImage: authProvider.currentUser?.photoUrl != null
                      ? NetworkImage(authProvider.currentUser!.photoUrl!)
                      : null,
                  child: authProvider.currentUser?.photoUrl == null
                      ? Text(
                          authProvider.currentUser?.displayName?.substring(0, 1) ?? 'U',
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                );
              },
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3);
  }

  Widget _buildRecommendationCard(EventRecommendation recommendation) {
    final eventsProvider = context.read<EventsProvider>();
    final event = eventsProvider.events.firstWhere(
      (e) => e.id == recommendation.eventId,
      orElse: () => eventsProvider.events.first, // fallback
    );
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: EventCard(
        event: event,
        compact: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypingDot(0),
                    const SizedBox(width: 4),
                    _buildTypingDot(1),
                    const SizedBox(width: 4),
                    _buildTypingDot(2),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    final delay = index * 0.2;
    final animation = Tween(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _typingAnimationController,
        curve: Interval(delay, delay + 0.4, curve: Curves.easeInOut),
      ),
    );
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    if (_isKeyboardVisible) return const SizedBox.shrink();
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _quickActions.length,
        itemBuilder: (context, index) {
          final action = _quickActions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                action,
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () => _sendMessage(action),
              backgroundColor: Theme.of(context).cardColor,
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.5);
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                decoration: InputDecoration(
                  hintText: 'Ask me about events...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _messageController,
              builder: (context, value, child) {
                return FloatingActionButton(
                  heroTag: 'chat_send_fab',
                  mini: true,
                  onPressed: value.text.trim().isNotEmpty ? () => _sendMessage() : null,
                  backgroundColor: value.text.trim().isNotEmpty 
                      ? AppTheme.primaryColor 
                      : Colors.grey[400],
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat History',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                
                if (chatProvider.sessions.isEmpty)
                  const Center(
                    child: Text('No chat history yet'),
                  )
                else
                  ...chatProvider.sessions.map((session) {
                    final lastMessage = session.messages.isNotEmpty 
                        ? session.messages.last 
                        : null;
                    
                    return ListTile(
                      title: Text(
                        session.title ?? 'Chat Session',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: lastMessage != null
                          ? Text(
                              lastMessage.content.length > 50
                                  ? '${lastMessage.content.substring(0, 50)}...'
                                  : lastMessage.content,
                            )
                          : null,
                      trailing: Text(
                        DateFormat('MMM dd').format(session.createdAt ?? DateTime.now()),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _currentSession = session;
                        });
                        _scrollToBottom();
                      },
                    );
                  }),
                
                const SizedBox(height: 16),
                
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _initializeChat();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Chat'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}