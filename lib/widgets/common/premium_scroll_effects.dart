import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../config/modern_theme.dart';

class PremiumScrollEffects extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;
  final bool enableParallax;
  final bool enableFadeIn;
  final bool enableScale;
  final bool enableBlur;
  final double parallaxFactor;
  final Duration animationDuration;
  
  const PremiumScrollEffects({
    super.key,
    required this.child,
    this.controller,
    this.enableParallax = true,
    this.enableFadeIn = true,
    this.enableScale = false,
    this.enableBlur = false,
    this.parallaxFactor = 0.3,
    this.animationDuration = const Duration(milliseconds: 600),
  });
  
  @override
  State<PremiumScrollEffects> createState() => _PremiumScrollEffectsState();
}

class _PremiumScrollEffectsState extends State<PremiumScrollEffects>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  double _scrollOffset = 0.0;
  bool _isVisible = false;
  
  @override
  void initState() {
    super.initState();
    
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    // Start animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
    _checkVisibility();
  }
  
  void _checkVisibility() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final isNowVisible = position.dy < screenHeight && 
                        position.dy + size.height > 0;
    
    if (isNowVisible && !_isVisible) {
      _isVisible = true;
      if (widget.enableFadeIn) _fadeController.forward();
      if (widget.enableScale) _scaleController.forward();
    } else if (!isNowVisible && _isVisible) {
      _isVisible = false;
      if (widget.enableFadeIn) _fadeController.reverse();
      if (widget.enableScale) _scaleController.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    
    // Apply parallax effect
    if (widget.enableParallax) {
      child = Transform.translate(
        offset: Offset(0, _scrollOffset * widget.parallaxFactor),
        child: child,
      );
    }
    
    // Apply scale effect
    if (widget.enableScale) {
      child = AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * _scaleController.value),
            child: child,
          );
        },
        child: child,
      );
    }
    
    // Apply fade effect
    if (widget.enableFadeIn) {
      child = AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeController.value,
            child: child,
          );
        },
        child: child,
      );
    }
    
    return child;
  }
}

class ScrollRevealList extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Curve curve;
  final ScrollController? controller;
  final RevealDirection direction;
  
  const ScrollRevealList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.controller,
    this.direction = RevealDirection.up,
  });
  
  @override
  State<ScrollRevealList> createState() => _ScrollRevealListState();
}

class _ScrollRevealListState extends State<ScrollRevealList> {
  late ScrollController _scrollController;
  final List<bool> _visibilityStates = [];
  final List<GlobalKey> _itemKeys = [];
  
  @override
  void initState() {
    super.initState();
    
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_checkVisibility);
    
    // Initialize states
    for (int i = 0; i < widget.children.length; i++) {
      _visibilityStates.add(false);
      _itemKeys.add(GlobalKey());
    }
    
    // Check initial visibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_checkVisibility);
    }
    super.dispose();
  }
  
  void _checkVisibility() {
    final screenHeight = MediaQuery.of(context).size.height;
    
    for (int i = 0; i < _itemKeys.length; i++) {
      final RenderBox? renderBox = _itemKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;
      
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      
      final isVisible = position.dy < screenHeight * 0.8 && 
                       position.dy + size.height > screenHeight * 0.2;
      
      if (isVisible && !_visibilityStates[i]) {
        setState(() {
          _visibilityStates[i] = true;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return Container(
          key: _itemKeys[index],
          child: _visibilityStates[index]
              ? child
                  .animate(
                    delay: Duration(
                      milliseconds: widget.staggerDelay.inMilliseconds * index,
                    ),
                  )
                  .slideY(
                    begin: widget.direction == RevealDirection.up ? 0.3 : -0.3,
                    duration: widget.itemDuration,
                    curve: widget.curve,
                  )
                  .fadeIn(
                    duration: Duration(
                      milliseconds: (widget.itemDuration.inMilliseconds * 0.8).round(),
                    ),
                  )
              : Opacity(
                  opacity: 0,
                  child: child,
                ),
        );
      }).toList(),
    );
  }
}

class FloatingScrollButton extends StatefulWidget {
  final ScrollController controller;
  final IconData icon;
  final VoidCallback? onPressed;
  final double showOffset;
  final Duration animationDuration;
  final List<Color>? colors;
  
  const FloatingScrollButton({
    super.key,
    required this.controller,
    this.icon = Icons.keyboard_arrow_up,
    this.onPressed,
    this.showOffset = 200,
    this.animationDuration = const Duration(milliseconds: 300),
    this.colors,
  });
  
  @override
  State<FloatingScrollButton> createState() => _FloatingScrollButtonState();
}

class _FloatingScrollButtonState extends State<FloatingScrollButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isVisible = false;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
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
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    widget.controller.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    final shouldShow = widget.controller.offset > widget.showOffset;
    
    if (shouldShow && !_isVisible) {
      setState(() => _isVisible = true);
      _controller.forward();
    } else if (!shouldShow && _isVisible) {
      setState(() => _isVisible = false);
      _controller.reverse();
    }
  }
  
  void _scrollToTop() {
    widget.controller.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? ModernTheme.primaryGradient;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * math.pi,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: widget.onPressed ?? _scrollToTop,
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ParallaxBackground extends StatefulWidget {
  final Widget child;
  final String? imageAsset;
  final Color? color;
  final List<Color>? gradient;
  final double parallaxFactor;
  final ScrollController? controller;
  
  const ParallaxBackground({
    super.key,
    required this.child,
    this.imageAsset,
    this.color,
    this.gradient,
    this.parallaxFactor = 0.5,
    this.controller,
  });
  
  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> {
  late ScrollController _controller;
  double _scrollOffset = 0.0;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onScroll);
    }
    super.dispose();
  }
  
  void _onScroll() {
    setState(() {
      _scrollOffset = _controller.offset;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Parallax background
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(0, _scrollOffset * widget.parallaxFactor),
            child: Container(
              decoration: BoxDecoration(
                color: widget.color,
                gradient: widget.gradient != null
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: widget.gradient!,
                      )
                    : null,
                image: widget.imageAsset != null
                    ? DecorationImage(
                        image: AssetImage(widget.imageAsset!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class StickyHeader extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;
  final double offset;
  final Duration animationDuration;
  
  const StickyHeader({
    super.key,
    required this.child,
    this.controller,
    this.offset = 100,
    this.animationDuration = const Duration(milliseconds: 200),
  });
  
  @override
  State<StickyHeader> createState() => _StickyHeaderState();
}

class _StickyHeaderState extends State<StickyHeader>
    with SingleTickerProviderStateMixin {
  late ScrollController _controller;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;
  bool _isSticky = false;
  
  @override
  void initState() {
    super.initState();
    
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onScroll);
    }
    _animationController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    final shouldStick = _controller.offset > widget.offset;
    
    if (shouldStick && !_isSticky) {
      setState(() => _isSticky = true);
      _animationController.forward();
    } else if (!shouldStick && _isSticky) {
      setState(() => _isSticky = false);
      _animationController.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

enum RevealDirection {
  up,
  down,
  left,
  right,
}