import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PremiumEventCard extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final double price;
  final String distance;
  final DateTime dateTime;
  final List<String> attendeeAvatars;
  final int totalAttendees;
  final bool isPremium;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const PremiumEventCard({
    Key? key,
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.distance,
    required this.dateTime,
    this.attendeeAvatars = const [],
    this.totalAttendees = 0,
    this.isPremium = false,
    this.isLiked = false,
    this.isSaved = false,
    this.onTap,
    this.onLike,
    this.onShare,
    this.onSave,
  }) : super(key: key);

  @override
  State<PremiumEventCard> createState() => _PremiumEventCardState();
}

class _PremiumEventCardState extends State<PremiumEventCard>
    with TickerProviderStateMixin {
  late AnimationController _tiltController;
  late AnimationController _glowController;
  late AnimationController _likeController;
  late AnimationController _saveController;
  late ConfettiController _confettiController;

  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isPressed = false;
  bool _showRipple = false;

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _saveController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _tiltController.dispose();
    _glowController.dispose();
    _likeController.dispose();
    _saveController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _tiltController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _tiltController.reverse();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _tiltX = (details.localPosition.dy - 150) / 150;
      _tiltY = (details.localPosition.dx - 175) / 175;
      _tiltX = _tiltX.clamp(-0.15, 0.15);
      _tiltY = _tiltY.clamp(-0.15, 0.15);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  void _handleLike() {
    _likeController.forward().then((_) {
      _likeController.reverse();
    });
    _confettiController.play();
    HapticFeedback.mediumImpact();
    widget.onLike?.call();
  }

  void _handleSave() {
    _saveController.forward().then((_) {
      _saveController.reverse();
    });
    HapticFeedback.lightImpact();
    widget.onSave?.call();
  }

  void _handleShare() {
    setState(() => _showRipple = true);
    HapticFeedback.selectionClick();
    widget.onShare?.call();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showRipple = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: () => setState(() => _isPressed = false),
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTap: widget.onTap,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_tiltX)
          ..rotateY(_tiltY)
          ..scale(_isPressed ? 0.98 : 1.0),
        child: Container(
          height: 380,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Stack(
            children: [
              // Glow effect for premium events
              if (widget.isPremium)
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withValues(
                              alpha: 0.3 * _glowController.value,
                            ),
                            blurRadius: 20 + 10 * _glowController.value,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    );
                  },
                ),

              // Main card with glassmorphism
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image with parallax effect
                        SizedBox(
                          height: 200,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Parallax image
                              Transform.translate(
                                offset: Offset(_tiltY * 20, _tiltX * 20),
                                child: Transform.scale(
                                  scale: 1.1,
                                  child: CachedNetworkImage(
                                    imageUrl: widget.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ),
                                ),
                              ),

                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                              ),

                              // Category badge with gradient
                              Positioned(
                                top: 16,
                                left: 16,
                                child:
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getCategoryColor(widget.category),
                                            _getCategoryColor(
                                              widget.category,
                                            ).withValues(alpha: 0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        widget.category.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ).animate().fadeIn().slideX(
                                      begin: -0.5,
                                      duration: 600.ms,
                                      curve: Curves.easeOut,
                                    ),
                              ),

                              // Distance indicator with pulse
                              Positioned(
                                top: 16,
                                right: 16,
                                child:
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                                Icons.location_on,
                                                color: Colors.white,
                                                size: 14,
                                              )
                                              .animate(
                                                onPlay: (controller) =>
                                                    controller.repeat(),
                                              )
                                              .scale(
                                                begin: const Offset(1, 1),
                                                end: const Offset(1.2, 1.2),
                                                duration: 1.seconds,
                                              )
                                              .then()
                                              .scale(
                                                begin: const Offset(1.2, 1.2),
                                                end: const Offset(1, 1),
                                                duration: 1.seconds,
                                              ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.distance,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).animate().fadeIn().slideX(
                                      begin: 0.5,
                                      duration: 600.ms,
                                      curve: Curves.easeOut,
                                    ),
                              ),

                              // Price tag with shimmer
                              if (widget.price > 0)
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: widget.isPremium
                                      ? Shimmer.fromColors(
                                          baseColor: Colors.amber,
                                          highlightColor: Colors.yellow[100]!,
                                          child: _buildPriceTag(),
                                        )
                                      : _buildPriceTag(),
                                ),
                            ],
                          ),
                        ),

                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ).animate().fadeIn(delay: 200.ms),

                                const SizedBox(height: 8),

                                Text(
                                  widget.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ).animate().fadeIn(delay: 300.ms),

                                const Spacer(),

                                // Bottom row with actions and attendees
                                Row(
                                  children: [
                                    // Attendee avatars
                                    if (widget.attendeeAvatars.isNotEmpty)
                                      Expanded(child: _buildAttendeeAvatars()),

                                    // Action buttons
                                    Row(
                                      children: [
                                        // Like button with confetti
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: _handleLike,
                                              icon: AnimatedBuilder(
                                                animation: _likeController,
                                                builder: (context, child) {
                                                  return Transform.scale(
                                                    scale:
                                                        1.0 +
                                                        _likeController.value *
                                                            0.3,
                                                    child: Icon(
                                                      widget.isLiked
                                                          ? Icons.favorite
                                                          : Icons
                                                                .favorite_border,
                                                      color: widget.isLiked
                                                          ? Colors.red
                                                          : Colors.white,
                                                      size: 24,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            ConfettiWidget(
                                              confettiController:
                                                  _confettiController,
                                              blastDirection: -math.pi / 2,
                                              emissionFrequency: 0.05,
                                              numberOfParticles: 10,
                                              maxBlastForce: 5,
                                              minBlastForce: 1,
                                              gravity: 0.3,
                                              particleDrag: 0.05,
                                              colors: const [
                                                Colors.red,
                                                Colors.pink,
                                                Colors.orange,
                                                Colors.yellow,
                                              ],
                                            ),
                                          ],
                                        ),

                                        // Share button with ripple
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (_showRipple)
                                              Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                    ),
                                                  )
                                                  .animate()
                                                  .scale(
                                                    begin: const Offset(0, 0),
                                                    end: const Offset(2, 2),
                                                    duration: 600.ms,
                                                  )
                                                  .fadeOut(),
                                            IconButton(
                                              onPressed: _handleShare,
                                              icon: const Icon(
                                                Icons.share,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Save button with bookmark animation
                                        IconButton(
                                          onPressed: _handleSave,
                                          icon: AnimatedBuilder(
                                            animation: _saveController,
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle:
                                                    _saveController.value *
                                                    math.pi *
                                                    2,
                                                child: Icon(
                                                  widget.isSaved
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border,
                                                  color: widget.isSaved
                                                      ? Colors.amber
                                                      : Colors.white,
                                                  size: 24,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isPremium
              ? [Colors.amber, Colors.orange]
              : [Colors.green, Colors.teal],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.price == 0 ? 'FREE' : '\$${widget.price.toStringAsFixed(0)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAttendeeAvatars() {
    return SizedBox(
      height: 32,
      child: Stack(
        children: [
          ...widget.attendeeAvatars.take(3).toList().asMap().entries.map((
            entry,
          ) {
            return Positioned(
              left: entry.key * 20.0,
              child:
                  Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(entry.value),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 100 * entry.key))
                      .slideX(
                        begin: -0.5,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),
            );
          }),
          if (widget.totalAttendees > 3)
            Positioned(
              left: 60,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.6),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+${widget.totalAttendees - 3}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Return black for all categories to match the black theme
    return Colors.black;
  }
}
