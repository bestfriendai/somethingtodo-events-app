import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../config/unified_design_system.dart';
import '../../config/app_config.dart';
import '../../models/chat.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/ai_assistant_avatar.dart';

class PremiumChatScreen extends ConsumerStatefulWidget {
  final String? sessionId;

  const PremiumChatScreen({super.key, this.sessionId});

  @override
  ConsumerState<PremiumChatScreen> createState() => _PremiumChatScreenState();
}

class _PremiumChatScreenState extends ConsumerState<PremiumChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _typingAnimationController;
  late AnimationController _sendButtonAnimationController;
  late AnimationController _emojiAnimationController;

  bool _showEmojiPanel = false;
  bool _isRecording = false;
  ChatMessage? _replyToMessage;
  bool _showScrollToBottom = false;
  final bool _isTyping = false;
  String? _replyToMessageId; // Reserved for future reply feature
  final List<String> _selectedImages = []; // Reserved for image sharing
  final Map<String, List<String>> _messageReactions = {}; // Reserved for message reactions

  final List<String> _quickReplies = [
    "Show me events nearby",
    "What's happening this weekend?",
    "Find family-friendly activities",
    "Suggest something romantic",
    "I'm looking for live music",
    "Show me free events",
  ];

  final List<String> _reactionEmojis = ['❤️', '👍', '😂', '😮', '😢', '🔥'];

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _sendButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _emojiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scrollController.addListener(_scrollListener);
    _messageController.addListener(_onTextChanged);

    // Load initial messages if session exists
    if (widget.sessionId != null) {
      Future.microtask(() => _loadChatSession());
    }
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final showButton = _scrollController.offset > 200;
      if (showButton != _showScrollToBottom) {
        setState(() => _showScrollToBottom = showButton);
      }
    }
  }

  void _onTextChanged() {
    final hasText = _messageController.text.isNotEmpty;
    if (hasText) {
      _sendButtonAnimationController.forward();
    } else {
      _sendButtonAnimationController.reverse();
    }
  }

  Future<void> _loadChatSession() async {
    // Load chat session implementation
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty && _selectedImages.isEmpty) {
      return;
    }

    final message = _messageController.text.trim();
    _messageController.clear();
    _selectedImages.clear();
    _replyToMessage = null;
    _replyToMessageId = null;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Send message implementation
    ref
        .read(chatProvider.notifier)
        .sendMessage(sessionId: widget.sessionId ?? '', content: message);

    _scrollToBottom();
  }

  void _showReactionPicker(String messageId) {
    HapticFeedback.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 120,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _reactionEmojis.map((emoji) {
              return GestureDetector(
                onTap: () {
                  _addReaction(messageId, emoji);
                  Navigator.pop(context);
                },
                child:
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Text(emoji, style: const TextStyle(fontSize: 32)),
                    ).animate().scale(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.elasticOut,
                    ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _addReaction(String messageId, String emoji) {
    setState(() {
      _messageReactions[messageId] ??= [];
      if (!_messageReactions[messageId]!.contains(emoji)) {
        _messageReactions[messageId]!.add(emoji);
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              UnifiedDesignSystem.primaryBrand.withValues(alpha: 0.1),
              Colors.black,
              UnifiedDesignSystem.accentBrand.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme),
              Expanded(
                child: Stack(
                  children: [
                    _buildMessagesList(theme, chatState),
                    if (_showScrollToBottom) _buildScrollToBottomButton(),
                  ],
                ),
              ),
              if (_replyToMessage != null) _buildReplyPreview(theme),
              if (_quickReplies.isNotEmpty && chatState.messages.isEmpty)
                _buildQuickReplies(theme),
              _buildInputArea(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
      borderRadius: 0,
      blur: 20,
      alignment: Alignment.center,
      border: 0,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.02),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.05),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            AIAssistantAvatar(size: 40, isThinking: _isTyping),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Assistant',
                    style: UnifiedDesignSystem.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isTyping)
                    Row(
                      children: [
                        Text(
                          'Thinking',
                          style: UnifiedDesignSystem.bodySmall.copyWith(
                            color: UnifiedDesignSystem.secondaryBrand,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildTypingIndicator(),
                      ],
                    )
                  else
                    Text(
                      'Always here to help',
                      style: UnifiedDesignSystem.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _typingAnimationController,
          builder: (context, child) {
            final double offset =
                math.sin(
                  (_typingAnimationController.value * 2 * math.pi) +
                      (index * math.pi / 3),
                ) *
                2;
            return Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: UnifiedDesignSystem.secondaryBrand,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildMessagesList(ThemeData theme, ChatState chatState) {
    final messages = chatState.messages ?? [];

    if (messages.isEmpty && !chatState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AIAssistantAvatar(size: 100, isThinking: false)
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 600))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 24),
            Text(
              'Hi! I\'m your event assistant',
              style: UnifiedDesignSystem.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
            const SizedBox(height: 8),
            Text(
              'Ask me about events, activities, or things to do!',
              style: UnifiedDesignSystem.bodyLarge.copyWith(
                color: Colors.white70,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final showDate = _shouldShowDate(messages, messages.length - 1 - index);

        return Column(
          children: [
            if (showDate)
              _buildDateSeparator(message.timestamp ?? DateTime.now()),
            _buildMessage(message, theme),
          ],
        );
      },
    );
  }

  bool _shouldShowDate(List<ChatMessage> messages, int index) {
    if (index == 0) return true;

    final current = messages[index].timestamp ?? DateTime.now();
    final previous = messages[index - 1].timestamp ?? DateTime.now();

    return current.day != previous.day ||
        current.month != previous.month ||
        current.year != previous.year;
  }

  Widget _buildDateSeparator(DateTime date) {
    final isToday =
        DateFormat.yMd().format(date) ==
        DateFormat.yMd().format(DateTime.now());
    final dateText = isToday ? 'Today' : DateFormat.MMMEd().format(date);

    return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  dateText,
                  style: UnifiedDesignSystem.bodySmall.copyWith(
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildMessage(ChatMessage message, ThemeData theme) {
    final isUser = message.role == MessageRole.user;
    final reactions = _messageReactions[message.id] ?? [];

    return Slidable(
      key: ValueKey(message.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _setReplyTo(message),
            backgroundColor: Colors.blue.withValues(alpha: 0.3),
            foregroundColor: Colors.white,
            icon: Icons.reply,
            label: 'Reply',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: () => _showReactionPicker(message.id),
        child: Container(
          margin: EdgeInsets.only(
            top: 4,
            bottom: reactions.isNotEmpty ? 16 : 4,
            left: isUser ? 48 : 0,
            right: isUser ? 0 : 48,
          ),
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: isUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isUser) ...[
                    AIAssistantAvatar(size: 32, isThinking: false),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child:
                        GlassmorphicContainer(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: 20,
                              blur: 20,
                              alignment: Alignment.center,
                              border: 1,
                              linearGradient: LinearGradient(
                                colors: isUser
                                    ? [
                                        UnifiedDesignSystem.primaryBrand
                                            .withValues(alpha: 0.3),
                                        UnifiedDesignSystem.primaryBrand
                                            .withValues(alpha: 0.1),
                                      ]
                                    : [
                                        Colors.white.withValues(alpha: 0.1),
                                        Colors.white.withValues(alpha: 0.05),
                                      ],
                              ),
                              borderGradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (message.type == MessageType.text)
                                      Text(
                                        message.content,
                                        style: UnifiedDesignSystem.bodyLarge
                                            .copyWith(color: Colors.white),
                                      )
                                    else if (message.type == MessageType.image)
                                      _buildImageMessage(message)
                                    else if (message.type == MessageType.event)
                                      _buildEventCard(message)
                                    else if (message.type ==
                                        MessageType.location)
                                      _buildLocationMessage(message),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          DateFormat.jm().format(
                                            message.timestamp ?? DateTime.now(),
                                          ),
                                          style: UnifiedDesignSystem.bodySmall
                                              .copyWith(
                                                color: Colors.white54,
                                                fontSize: 11,
                                              ),
                                        ),
                                        if (isUser) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.done_all,
                                            size: 14,
                                            color: UnifiedDesignSystem
                                                .secondaryBrand,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 300))
                            .slideX(
                              begin: isUser ? 0.1 : -0.1,
                              end: 0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            ),
                  ),
                ],
              ),
              if (reactions.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(
                    top: 4,
                    left: isUser ? 0 : 40,
                    right: isUser ? 0 : 0,
                  ),
                  child: Wrap(
                    spacing: 4,
                    children: reactions.map((emoji) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ).animate().scale(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.elasticOut,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageMessage(ChatMessage message) {
    return GestureDetector(
      onTap: () => _showImageViewer(message.metadata?['imageUrl']),
      child: Hero(
        tag: 'image_${message.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: message.metadata?['imageUrl'] ?? '',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.white10,
              highlightColor: Colors.white24,
              child: Container(width: 200, height: 200, color: Colors.white10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(ChatMessage message) {
    // This would integrate with your existing event card widget
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.metadata?['eventTitle'] ?? 'Event',
            style: UnifiedDesignSystem.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message.metadata?['eventDescription'] ?? '',
            style: UnifiedDesignSystem.bodySmall.copyWith(
              color: Colors.white70,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: UnifiedDesignSystem.secondaryBrand,
              ),
              const SizedBox(width: 4),
              Text(
                message.metadata?['eventDate'] ?? '',
                style: UnifiedDesignSystem.bodySmall.copyWith(
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(ChatMessage message) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(
            'https://maps.googleapis.com/maps/api/staticmap?center=${message.metadata?['lat']},${message.metadata?['lng']}&zoom=15&size=400x300&key=${AppConfig.googleMapsApiKey}',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
          ),
        ),
        padding: const EdgeInsets.all(12),
        alignment: Alignment.bottomLeft,
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: UnifiedDesignSystem.accentBrand,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                message.metadata?['address'] ?? '',
                style: UnifiedDesignSystem.bodySmall.copyWith(
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReplies(ThemeData theme) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickReplies.length,
        itemBuilder: (context, index) {
          return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _messageController.text = _quickReplies[index];
                      _sendMessage();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: UnifiedDesignSystem.primaryBrand.withValues(
                            alpha: 0.5,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _quickReplies[index],
                        style: UnifiedDesignSystem.bodySmall.copyWith(
                          color: UnifiedDesignSystem.primaryBrand,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: index * 50),
                duration: const Duration(milliseconds: 300),
              )
              .slideX(
                begin: 0.2,
                end: 0,
                delay: Duration(milliseconds: index * 50),
                duration: const Duration(milliseconds: 300),
              );
        },
      ),
    );
  }

  Widget _buildReplyPreview(ThemeData theme) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 40,
                decoration: BoxDecoration(
                  color: UnifiedDesignSystem.primaryBrand,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Replying to',
                      style: UnifiedDesignSystem.bodySmall.copyWith(
                        color: UnifiedDesignSystem.primaryBrand,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _replyToMessage!.content,
                      style: UnifiedDesignSystem.bodySmall.copyWith(
                        color: Colors.white60,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                onPressed: () {
                  setState(() {
                    _replyToMessage = null;
                    _replyToMessageId = null;
                  });
                },
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 200))
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildInputArea(ThemeData theme) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
      borderRadius: 0,
      blur: 20,
      alignment: Alignment.center,
      border: 0,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.05),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.1),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: UnifiedDesignSystem.primaryBrand,
                ),
                onPressed: _showAttachmentOptions,
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: UnifiedDesignSystem.bodyLarge.copyWith(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ask about events...',
                            hintStyle: UnifiedDesignSystem.bodyLarge.copyWith(
                              color: Colors.white38,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() => _showEmojiPanel = !_showEmojiPanel);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _sendButtonAnimationController,
      builder: (context, child) {
        final hasContent =
            _messageController.text.isNotEmpty || _selectedImages.isNotEmpty;

        return GestureDetector(
          onTap: hasContent ? _sendMessage : _startVoiceRecording,
          onLongPress: _startVoiceRecording,
          onLongPressEnd: (_) => _stopVoiceRecording(),
          child:
              AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: hasContent
                          ? LinearGradient(
                              colors: [
                                UnifiedDesignSystem.primaryBrand,
                                UnifiedDesignSystem.primaryBrand.withValues(
                                  alpha: 0.7,
                                ),
                              ],
                            )
                          : null,
                      color: hasContent
                          ? null
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      hasContent
                          ? Icons.send_rounded
                          : (_isRecording ? Icons.mic : Icons.mic_none),
                      color: hasContent || _isRecording
                          ? Colors.white
                          : Colors.white54,
                      size: 24,
                    ),
                  )
                  .animate(target: _isRecording ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: const Duration(milliseconds: 300),
                  )
                  .shimmer(
                    duration: const Duration(seconds: 1),
                    color: UnifiedDesignSystem.accentBrand.withValues(
                      alpha: 0.3,
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildScrollToBottomButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: _showScrollToBottom ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: GlassmorphicContainer(
          width: 44,
          height: 44,
          borderRadius: 22,
          blur: 20,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.3),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            onPressed: _scrollToBottom,
          ),
        ),
      ),
    );
  }

  void _setReplyTo(ChatMessage message) {
    setState(() {
      _replyToMessage = message;
      _replyToMessageId = message.id;
    });
    _focusNode.requestFocus();
    HapticFeedback.lightImpact();
  }

  void _showAttachmentOptions() {
    HapticFeedback.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            _buildAttachmentOption(
              icon: Icons.image,
              label: 'Photo',
              color: UnifiedDesignSystem.primaryBrand,
              onTap: () => _pickImage(),
            ),
            _buildAttachmentOption(
              icon: Icons.location_on,
              label: 'Location',
              color: UnifiedDesignSystem.accentBrand,
              onTap: () => _shareLocation(),
            ),
            _buildAttachmentOption(
              icon: Icons.event,
              label: 'Event',
              color: UnifiedDesignSystem.secondaryBrand,
              onTap: () => _shareEvent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: UnifiedDesignSystem.bodyLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageViewer(String? imageUrl) {
    if (imageUrl == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoView(
                imageProvider: CachedNetworkImageProvider(imageUrl),
                heroAttributes: PhotoViewHeroAttributes(tag: 'image_viewer'),
              ),
              SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startVoiceRecording() {
    setState(() => _isRecording = true);
    HapticFeedback.heavyImpact();
    // Implement voice recording
  }

  void _stopVoiceRecording() {
    setState(() => _isRecording = false);
    HapticFeedback.lightImpact();
    // Stop recording and send
  }

  void _pickImage() {
    // Implement image picker
  }

  void _shareLocation() {
    // Implement location sharing
  }

  void _shareEvent() {
    // Implement event sharing
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _sendButtonAnimationController.dispose();
    _emojiAnimationController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
