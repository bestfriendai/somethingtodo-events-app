import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SwipeDirection { up, down, left, right }

typedef SwipeCallback =
    void Function(SwipeDirection direction, double velocity);

class GestureService {
  static const double _minSwipeVelocity = 300.0;
  static const double _minSwipeDistance = 50.0;

  static void handleSwipeGesture({
    required DragEndDetails details,
    required SwipeCallback onSwipe,
    double? customMinVelocity,
    double? customMinDistance,
  }) {
    final velocity = details.velocity.pixelsPerSecond;
    final minVelocity = customMinVelocity ?? _minSwipeVelocity;
    final minDistance = customMinDistance ?? _minSwipeDistance;

    // Check if the swipe was fast enough
    if (velocity.distance < minVelocity) return;

    // Determine the primary direction
    if (velocity.dx.abs() > velocity.dy.abs()) {
      // Horizontal swipe
      if (velocity.dx.abs() > minDistance) {
        if (velocity.dx > 0) {
          HapticFeedback.lightImpact();
          onSwipe(SwipeDirection.right, velocity.dx);
        } else {
          HapticFeedback.lightImpact();
          onSwipe(SwipeDirection.left, velocity.dx.abs());
        }
      }
    } else {
      // Vertical swipe
      if (velocity.dy.abs() > minDistance) {
        if (velocity.dy > 0) {
          HapticFeedback.lightImpact();
          onSwipe(SwipeDirection.down, velocity.dy);
        } else {
          HapticFeedback.lightImpact();
          onSwipe(SwipeDirection.up, velocity.dy.abs());
        }
      }
    }
  }

  static Widget buildSwipeDetector({
    required Widget child,
    required SwipeCallback onSwipe,
    bool enableVerticalSwipe = true,
    bool enableHorizontalSwipe = true,
    double? customMinVelocity,
    double? customMinDistance,
  }) {
    return GestureDetector(
      onPanEnd: (details) {
        if (!enableVerticalSwipe && !enableHorizontalSwipe) return;

        final velocity = details.velocity.pixelsPerSecond;
        final minVelocity = customMinVelocity ?? _minSwipeVelocity;
        final minDistance = customMinDistance ?? _minSwipeDistance;

        if (velocity.distance < minVelocity) return;

        if (enableHorizontalSwipe && velocity.dx.abs() > velocity.dy.abs()) {
          if (velocity.dx.abs() > minDistance) {
            if (velocity.dx > 0) {
              onSwipe(SwipeDirection.right, velocity.dx);
            } else {
              onSwipe(SwipeDirection.left, velocity.dx.abs());
            }
          }
        } else if (enableVerticalSwipe && velocity.dy.abs() > minDistance) {
          if (velocity.dy > 0) {
            onSwipe(SwipeDirection.down, velocity.dy);
          } else {
            onSwipe(SwipeDirection.up, velocity.dy.abs());
          }
        }
      },
      child: child,
    );
  }
}

class SwipeableEventCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final VoidCallback? onTap;
  final Color leftActionColor;
  final Color rightActionColor;
  final IconData leftActionIcon;
  final IconData rightActionIcon;
  final String leftActionLabel;
  final String rightActionLabel;

  const SwipeableEventCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onTap,
    this.leftActionColor = Colors.pink,
    this.rightActionColor = Colors.blue,
    this.leftActionIcon = Icons.favorite_rounded,
    this.rightActionIcon = Icons.share_rounded,
    this.leftActionLabel = 'Like',
    this.rightActionLabel = 'Share',
  });

  @override
  State<SwipeableEventCard> createState() => _SwipeableEventCardState();
}

class _SwipeableEventCardState extends State<SwipeableEventCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  double _dragDistance = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragDistance = 0.0;
    });
    _scaleController.forward();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDistance += details.delta.dx;
    });

    // Update slide animation based on drag
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(_dragDistance / 300, 0),
    ).animate(_slideController);

    _slideController.value = (_dragDistance.abs() / 100).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final threshold = 100.0;

    setState(() {
      _isDragging = false;
    });
    _scaleController.reverse();

    if (_dragDistance.abs() > threshold || velocity.dx.abs() > 500) {
      // Trigger action based on swipe direction
      if (_dragDistance > 0) {
        // Swipe right
        HapticFeedback.heavyImpact();
        widget.onSwipeRight?.call();
      } else {
        // Swipe left
        HapticFeedback.heavyImpact();
        widget.onSwipeLeft?.call();
      }
    }

    // Reset position
    _slideController.reverse().then((_) {
      setState(() {
        _dragDistance = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      child: Stack(
        children: [
          // Background actions
          Positioned.fill(
            child: Row(
              children: [
                // Left action (swipe right to reveal)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.leftActionColor.withValues(alpha: 0.8),
                          widget.leftActionColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.leftActionIcon,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.leftActionLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Right action (swipe left to reveal)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.rightActionColor,
                          widget.rightActionColor.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.rightActionIcon,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.rightActionLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
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
          // Main content
          AnimatedBuilder(
            animation: Listenable.merge([_slideAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.translate(
                  offset: Offset(_dragDistance, 0),
                  child: widget.child,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
