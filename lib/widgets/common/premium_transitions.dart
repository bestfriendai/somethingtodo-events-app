import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class PremiumPageTransition {
  static PageRouteBuilder slideTransition({
    required Widget child,
    required RouteSettings settings,
    SlideDirection direction = SlideDirection.right,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset beginOffset;
        switch (direction) {
          case SlideDirection.left:
            beginOffset = const Offset(-1.0, 0.0);
            break;
          case SlideDirection.right:
            beginOffset = const Offset(1.0, 0.0);
            break;
          case SlideDirection.up:
            beginOffset = const Offset(0.0, -1.0);
            break;
          case SlideDirection.down:
            beginOffset = const Offset(0.0, 1.0);
            break;
        }
        
        final slideAnimation = animation.drive(
          Tween(begin: beginOffset, end: Offset.zero).chain(
            CurveTween(curve: curve),
          ),
        );
        
        final fadeAnimation = animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.easeIn),
          ),
        );
        
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
  
  static PageRouteBuilder scaleTransition({
    required Widget child,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.elasticOut,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = animation.drive(
          Tween(begin: 0.8, end: 1.0).chain(
            CurveTween(curve: curve),
          ),
        );
        
        final fadeAnimation = animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.easeOut),
          ),
        );
        
        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
  
  static PageRouteBuilder morphTransition({
    required Widget child,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
                  CurveTween(curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
                ),
              ),
              child: child,
            ),
            SlideTransition(
              position: secondaryAnimation.drive(
                Tween(begin: Offset.zero, end: const Offset(0, -1)).chain(
                  CurveTween(curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
                ),
              ),
              child: Container(), // Previous page placeholder
            ),
          ],
        );
      },
    );
  }
}

class PremiumHeroTransition extends StatelessWidget {
  final String tag;
  final Widget child;
  final Duration transitionDuration;
  
  const PremiumHeroTransition({
    super.key,
    required this.tag,
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 400),
  });
  
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      flightShuttleBuilder: (context, animation, direction, fromContext, toContext) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (0.1 * math.sin(animation.value * math.pi)),
              child: child,
            );
          },
          child: Material(
            color: Colors.transparent,
            child: direction == HeroFlightDirection.push ? toContext.widget : fromContext.widget,
          ),
        );
      },
      child: child,
    );
  }
}

class PremiumSlideTransition extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Curve curve;
  final bool autoPlay;
  final Duration delay;
  
  const PremiumSlideTransition({
    super.key,
    required this.child,
    this.direction = SlideDirection.up,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.autoPlay = true,
    this.delay = Duration.zero,
  });
  
  @override
  State<PremiumSlideTransition> createState() => _PremiumSlideTransitionState();
}

class _PremiumSlideTransitionState extends State<PremiumSlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    Offset beginOffset;
    switch (widget.direction) {
      case SlideDirection.left:
        beginOffset = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(1.0, 0.0);
        break;
      case SlideDirection.up:
        beginOffset = const Offset(0.0, 1.0);
        break;
      case SlideDirection.down:
        beginOffset = const Offset(0.0, -1.0);
        break;
    }
    
    _animation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    if (widget.autoPlay) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

class StaggeredAnimationList extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Curve curve;
  final Axis scrollDirection;
  
  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.scrollDirection = Axis.vertical,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return child
            .animate(
              delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
            )
            .slideY(
              begin: scrollDirection == Axis.vertical ? 0.3 : 0,
              duration: itemDuration,
              curve: curve,
            )
            .slideX(
              begin: scrollDirection == Axis.horizontal ? 0.3 : 0,
              duration: itemDuration,
              curve: curve,
            )
            .fadeIn(
              duration: Duration(
                milliseconds: (itemDuration.inMilliseconds * 0.8).round(),
              ),
            );
      }).toList(),
    );
  }
}

class ParallaxContainer extends StatefulWidget {
  final Widget child;
  final double parallaxFactor;
  final ScrollController? scrollController;
  
  const ParallaxContainer({
    super.key,
    required this.child,
    this.parallaxFactor = 0.5,
    this.scrollController,
  });
  
  @override
  State<ParallaxContainer> createState() => _ParallaxContainerState();
}

class _ParallaxContainerState extends State<ParallaxContainer> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_updateScrollOffset);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollOffset);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
  
  void _updateScrollOffset() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, _scrollOffset * widget.parallaxFactor),
      child: widget.child,
    );
  }
}

class FloatingActionTransition extends StatefulWidget {
  final Widget child;
  final bool visible;
  final Duration duration;
  
  const FloatingActionTransition({
    super.key,
    required this.child,
    required this.visible,
    this.duration = const Duration(milliseconds: 300),
  });
  
  @override
  State<FloatingActionTransition> createState() => _FloatingActionTransitionState();
}

class _FloatingActionTransitionState extends State<FloatingActionTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    if (widget.visible) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(FloatingActionTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * math.pi,
            child: widget.child,
          ),
        );
      },
    );
  }
}

enum SlideDirection {
  left,
  right,
  up,
  down,
}