import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/event.dart';
import '../../config/modern_theme.dart';
import '../../services/platform_interactions.dart';
import '../../services/cache_service.dart';
import '../../services/delight_service.dart';
import 'dart:math';

class SwipeableFeedCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const SwipeableFeedCard({
    super.key,
    required this.event,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<SwipeableFeedCard> createState() => _SwipeableFeedCardState();
}

class _SwipeableFeedCardState extends State<SwipeableFeedCard>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late AnimationController _shareAnimationController;
  late Animation<double> _likeScale;
  late Animation<double> _shareScale;

  bool _isLiked = false;
  bool _showLikeAnimation = false;
  bool _showShareAnimation = false;

  @override
  void initState() {
    super.initState();

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shareAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _likeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _shareScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shareAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _shareAnimationController.dispose();
    super.dispose();
  }

  void _loadFavoriteStatus() {
    final favorites = CacheService.instance.getCachedFavorites();
    setState(() {
      _isLiked = favorites.contains(widget.event.id);
    });
  }

  void _handleSwipeUp() {
    widget.onSwipeUp?.call();
  }

  void _handleSwipeDown() {
    widget.onSwipeDown?.call();
  }

  void _handleSwipeLeft() {
    _triggerShareAnimation();
    widget.onSwipeLeft?.call();
  }

  void _handleSwipeRight() {
    _triggerLikeAnimation();
    widget.onSwipeRight?.call();
  }

  void _triggerLikeAnimation() {
    setState(() {
      _showLikeAnimation = true;
      _isLiked = true;
    });

    // Enhanced haptic feedback
    PlatformInteractions.heavyImpact();

    // Show confetti celebration
    DelightService.instance.showConfetti(
      context,
      customMessage: [
        'You have amazing taste! ✨',
        'Great choice! Your friends will love this! 😍',
        'Added to favorites! You are on fire! 🔥',
        'Excellent pick! This is going to be epic! 🎉',
      ][Random().nextInt(4)],
    );

    // Heart explosion from button position
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final heartPosition = Offset(size.width - 40, size.height - 200);
      DelightService.instance.showHeartExplosion(context, heartPosition);
    }

    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showLikeAnimation = false;
          });
        }
      });
    });
  }

  void _triggerShareAnimation() {
    setState(() {
      _showShareAnimation = true;
    });

    // Enhanced share celebration
    PlatformInteractions.mediumImpact();

    DelightService.instance.showConfetti(
      context,
      customMessage: DelightService.instance.getRandomShareMessage(),
    );

    _shareAnimationController.forward().then((_) {
      _shareAnimationController.reverse();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showShareAnimation = false;
          });
        }
      });
    });
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      _triggerLikeAnimation();

      // Special double-tap celebration
      DelightService.instance.showConfetti(
        context,
        customMessage: 'Double-tap master! You know what you want! 💫',
      );

      widget.onDoubleTap?.call();
    } else {
      // Fun message for already liked events
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'You already love this! Great minds think alike! 🤩',
          ),
          backgroundColor: Colors.pink.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: _handleDoubleTap,
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond;
        const minVelocity = 300.0;

        if (velocity.distance < minVelocity) return;

        if (velocity.dy.abs() > velocity.dx.abs()) {
          // Vertical swipe
          if (velocity.dy > 0) {
            _handleSwipeDown();
          } else {
            _handleSwipeUp();
          }
        } else {
          // Horizontal swipe
          if (velocity.dx > 0) {
            _handleSwipeRight();
          } else {
            _handleSwipeLeft();
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            _buildBackground(),

            // Gradient overlay
            _buildGradientOverlay(),

            // Content overlay
            _buildContentOverlay(),

            // Time-based easter egg indicator
            _buildTimeBasedIndicator(),

            // Enhanced action animations with more sparkle
            if (_showLikeAnimation) _buildEnhancedLikeAnimation(),
            if (_showShareAnimation) _buildEnhancedShareAnimation(),

            // Random floating elements for visual interest
            ..._buildFloatingElements(),

            // Side actions
            _buildSideActions(),

            // Bottom info
            _buildBottomInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (widget.event.imageUrls.isNotEmpty) {
      return Hero(
        tag: 'feed-event-${widget.event.id}',
        child: CachedNetworkImage(
          imageUrl: widget.event.imageUrls.first,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ModernTheme.getCategoryGradient(
                  widget.event.category.name,
                ),
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ModernTheme.getCategoryGradient(
                  widget.event.category.name,
                ),
              ),
            ),
            child: const Center(
              child: Icon(Icons.event_rounded, color: Colors.white, size: 64),
            ),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ModernTheme.getCategoryGradient(widget.event.category.name),
          ),
        ),
      );
    }
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black45,
            Colors.black87,
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildContentOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onLongPress: () {
          DelightService.instance.triggerEasterEgg(context, 'long_press_event');
        },
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildTimeBasedIndicator() {
    final timeMessage = DelightService.instance.getTimeBasedMessage();

    if (timeMessage == null) return const SizedBox.shrink();

    return Positioned(
      top: 20,
      left: 20,
      child:
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.orange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  timeMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms)
              .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut)
              .then(delay: 3.seconds)
              .fadeOut(duration: 600.ms),
    );
  }

  Widget _buildEnhancedLikeAnimation() {
    return Center(
      child: AnimatedBuilder(
        animation: _likeScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _likeScale.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.pink.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.pink.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
                // Main heart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.pink.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.pink,
                    size: 80,
                  ),
                ),
                // Orbiting mini hearts
                ...List.generate(6, (index) {
                  final angle =
                      (index * 60.0) * (pi / 180.0) +
                      (_likeScale.value * 2 * pi);
                  return Transform.translate(
                    offset: Offset(
                      60 * cos(angle) * _likeScale.value,
                      60 * sin(angle) * _likeScale.value,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.pink.withValues(alpha: 0.7),
                      size: 16,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedShareAnimation() {
    return Center(
      child: AnimatedBuilder(
        animation: _shareScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _shareScale.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect
                Container(
                  width: 200 * _shareScale.value,
                  height: 200 * _shareScale.value,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
                // Main share icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.cyan.shade400],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                // Flying share icons
                ...List.generate(4, (index) {
                  final angle = (index * 90.0) * (pi / 180.0);
                  return Transform.translate(
                    offset: Offset(
                      80 * cos(angle) * _shareScale.value,
                      80 * sin(angle) * _shareScale.value,
                    ),
                    child: Transform.rotate(
                      angle: _shareScale.value * pi * 2,
                      child: Icon(
                        [
                          Icons.facebook,
                          Icons.telegram,
                          Icons.email,
                          Icons.link,
                        ][index],
                        color: Colors.blue.withValues(alpha: 0.8),
                        size: 24,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    final elements = <Widget>[];
    final random = Random();

    // Add some floating sparkles occasionally
    if (random.nextDouble() < 0.3) {
      for (int i = 0; i < 3; i++) {
        elements.add(
          Positioned(
            top: random.nextDouble() * 400,
            left: random.nextDouble() * 200,
            child:
                Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    )
                    .animate(delay: (i * 500).ms)
                    .fadeIn(duration: 1.seconds)
                    .scale(begin: const Offset(0.5, 0.5))
                    .moveY(begin: 20, end: -20, duration: 3.seconds)
                    .then()
                    .fadeOut(duration: 500.ms),
          ),
        );
      }
    }

    return elements;
  }

  Widget _buildSideActions() {
    return Positioned(
      right: 16,
      bottom: 120,
      child: Column(
        children: [
          // Enhanced Favorite button with extra delight
          _buildEnhancedActionButton(
            icon: _isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isLiked ? Colors.pink : Colors.white,
            label: '${widget.event.favoriteCount + (_isLiked ? 1 : 0)}',
            onTap: () {
              if (!_isLiked) {
                _triggerLikeAnimation();
              }
              _handleSwipeRight();
            },
            glowColor: Colors.pink,
            isActive: _isLiked,
          ),
          const SizedBox(height: 20),

          // Enhanced Share button
          _buildEnhancedActionButton(
            icon: Icons.share_rounded,
            color: Colors.white,
            label: 'Share',
            onTap: _handleSwipeLeft,
            glowColor: Colors.blue,
            isActive: false,
          ),
          const SizedBox(height: 20),

          // Enhanced Comments/Details button
          _buildEnhancedActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            color: Colors.white,
            label: 'Details',
            onTap: widget.onTap ?? () {},
            glowColor: Colors.purple,
            isActive: false,
          ),
          const SizedBox(height: 20),

          // Category indicator
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ModernTheme.getCategoryGradient(
                  widget.event.category.name,
                ),
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _getCategoryIcon(widget.event.category),
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    required Color glowColor,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        PlatformInteractions.lightImpact();
        onTap();
      },
      onLongPress: () {
        DelightService.instance.triggerEasterEgg(context, 'action_explorer');
      },
      child: Container(
        width: 50,
        height: 70,
        child: Column(
          children: [
            AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isActive
                        ? glowColor.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isActive
                          ? glowColor.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.2),
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: glowColor.withValues(alpha: 0.4),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(icon, color: color, size: 24),
                )
                .animate()
                .then(delay: Random().nextInt(3).seconds)
                .shimmer(
                  duration: 2.seconds,
                  color: glowColor.withValues(alpha: 0.3),
                ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? glowColor : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Keep the old method for backward compatibility
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return _buildEnhancedActionButton(
      icon: icon,
      color: color,
      label: label,
      onTap: onTap,
      glowColor: Colors.white,
      isActive: false,
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      left: 16,
      right: 80,
      bottom: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            widget.event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Organizer with avatar
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: ModernTheme.getCategoryGradient(
                      widget.event.category.name,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.event.organizerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Event metadata chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.calendar_today_rounded,
                text: DateFormat('MMM d').format(widget.event.startDateTime),
              ),
              _buildInfoChip(
                icon: Icons.access_time_rounded,
                text: DateFormat('h:mm a').format(widget.event.startDateTime),
              ),
              _buildInfoChip(
                icon: widget.event.pricing.isFree
                    ? Icons.celebration_rounded
                    : Icons.monetization_on_rounded,
                text: widget.event.pricing.isFree
                    ? 'FREE'
                    : '\$${widget.event.pricing.price.toStringAsFixed(0)}',
                color: widget.event.pricing.isFree
                    ? Colors.green
                    : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.event.venue.name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (color ?? Colors.white).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.music:
        return Icons.music_note_rounded;
      case EventCategory.food:
        return Icons.restaurant_rounded;
      case EventCategory.sports:
        return Icons.sports_soccer_rounded;
      case EventCategory.arts:
        return Icons.palette_rounded;
      case EventCategory.business:
        return Icons.business_center_rounded;
      case EventCategory.education:
        return Icons.school_rounded;
      case EventCategory.technology:
        return Icons.computer_rounded;
      case EventCategory.health:
        return Icons.local_hospital_rounded;
      case EventCategory.community:
        return Icons.group_rounded;
      default:
        return Icons.event_rounded;
    }
  }
}
