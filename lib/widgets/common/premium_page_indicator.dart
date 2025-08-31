import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../config/modern_theme.dart';

class PremiumPageIndicator extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final PageController? pageController;
  final Function(int)? onPageTapped;
  final PageIndicatorStyle style;
  final List<Color>? colors;
  final double size;
  final double spacing;
  final Duration animationDuration;
  
  const PremiumPageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.pageController,
    this.onPageTapped,
    this.style = PageIndicatorStyle.morphing,
    this.colors,
    this.size = 8,
    this.spacing = 12,
    this.animationDuration = const Duration(milliseconds: 300),
  });
  
  @override
  State<PremiumPageIndicator> createState() => _PremiumPageIndicatorState();
}

class _PremiumPageIndicatorState extends State<PremiumPageIndicator>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  
  @override
  void initState() {
    super.initState();
    
    _morphController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _glowController.repeat(reverse: true);
  }
  
  @override
  void didUpdateWidget(PremiumPageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _morphController.forward(from: 0);
      _scaleController.forward().then((_) => _scaleController.reverse());
    }
  }
  
  @override
  void dispose() {
    _morphController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? ModernTheme.primaryGradient;
    
    switch (widget.style) {
      case PageIndicatorStyle.morphing:
        return _buildMorphingIndicator(colors);
      case PageIndicatorStyle.scaling:
        return _buildScalingIndicator(colors);
      case PageIndicatorStyle.sliding:
        return _buildSlidingIndicator(colors);
      case PageIndicatorStyle.liquid:
        return _buildLiquidIndicator(colors);
      case PageIndicatorStyle.orbital:
        return _buildOrbitalIndicator(colors);
    }
  }
  
  Widget _buildMorphingIndicator(List<Color> colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.totalPages, (index) {
        final isActive = index == widget.currentPage;
        
        return GestureDetector(
          onTap: () => widget.onPageTapped?.call(index),
          child: AnimatedBuilder(
            animation: Listenable.merge([_morphController, _scaleController, _glowController]),
            builder: (context, child) {
              final scale = isActive ? 1.0 + (_scaleController.value * 0.2) : 1.0;
              final width = isActive ? widget.size * 3 : widget.size;
              final glow = isActive ? _glowController.value * 0.3 : 0.0;
              
              return Container(
                margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                child: Transform.scale(
                  scale: scale,
                  child: AnimatedContainer(
                    duration: widget.animationDuration,
                    curve: Curves.easeOutCubic,
                    width: width,
                    height: widget.size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.size / 2),
                      gradient: isActive
                          ? LinearGradient(colors: colors)
                          : null,
                      color: !isActive
                          ? colors.first.withOpacity(0.3)
                          : null,
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: colors.first.withOpacity(0.4 + glow),
                          blurRadius: 8 + (glow * 10),
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                  ),
                ),
              );
            },
          ),
        )
        .animate(delay: Duration(milliseconds: index * 50))
        .slideX(begin: 0.5, duration: 400.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 300.ms);
      }),
    );
  }
  
  Widget _buildScalingIndicator(List<Color> colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.totalPages, (index) {
        final isActive = index == widget.currentPage;
        
        return GestureDetector(
          onTap: () => widget.onPageTapped?.call(index),
          child: AnimatedBuilder(
            animation: _scaleController,
            builder: (context, child) {
              final scale = isActive 
                  ? 1.5 + (_scaleController.value * 0.3)
                  : 1.0;
              
              return Container(
                margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive
                          ? LinearGradient(colors: colors)
                          : null,
                      color: !isActive
                          ? colors.first.withOpacity(0.3)
                          : null,
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: colors.first.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ] : null,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
  
  Widget _buildSlidingIndicator(List<Color> colors) {
    return SizedBox(
      height: widget.size,
      child: Stack(
        children: [
          // Background dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.totalPages, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.first.withOpacity(0.2),
                ),
              );
            }),
          ),
          // Sliding active indicator
          AnimatedPositioned(
            duration: widget.animationDuration,
            curve: Curves.easeOutCubic,
            left: widget.currentPage * (widget.size + widget.spacing),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: colors),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            )
            .animate()
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut)
            .then()
            .shimmer(duration: 1.seconds),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLiquidIndicator(List<Color> colors) {
    return AnimatedBuilder(
      animation: _morphController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(
            (widget.totalPages * widget.size) + ((widget.totalPages - 1) * widget.spacing),
            widget.size,
          ),
          painter: LiquidIndicatorPainter(
            totalPages: widget.totalPages,
            currentPage: widget.currentPage,
            colors: colors,
            size: widget.size,
            spacing: widget.spacing,
            animation: _morphController.value,
          ),
        );
      },
    );
  }
  
  Widget _buildOrbitalIndicator(List<Color> colors) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return SizedBox(
          width: widget.size * 4,
          height: widget.size * 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Central indicator
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: colors),
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withOpacity(0.3 + (_glowController.value * 0.3)),
                      blurRadius: 8 + (_glowController.value * 8),
                    ),
                  ],
                ),
              ),
              // Orbiting dots
              ...List.generate(widget.totalPages, (index) {
                final angle = (index * 2 * math.pi / widget.totalPages) + 
                             (_glowController.value * 2 * math.pi);
                final radius = widget.size * 1.5;
                final isActive = index == widget.currentPage;
                
                return Transform.translate(
                  offset: Offset(
                    radius * math.cos(angle),
                    radius * math.sin(angle),
                  ),
                  child: Container(
                    width: widget.size * (isActive ? 0.8 : 0.5),
                    height: widget.size * (isActive ? 0.8 : 0.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Colors.white
                          : colors.first.withOpacity(0.5),
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ] : null,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class LiquidIndicatorPainter extends CustomPainter {
  final int totalPages;
  final int currentPage;
  final List<Color> colors;
  final double size;
  final double spacing;
  final double animation;
  
  LiquidIndicatorPainter({
    required this.totalPages,
    required this.currentPage,
    required this.colors,
    required this.size,
    required this.spacing,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Draw background dots
    for (int i = 0; i < totalPages; i++) {
      final x = (i * (size + spacing)) + (size / 2);
      final y = size / 2;
      
      paint.color = colors.first.withOpacity(0.2);
      canvas.drawCircle(Offset(x, y), size / 2, paint);
    }
    
    // Draw active liquid blob
    final activeX = (currentPage * (size + spacing)) + (size / 2);
    final activeY = size / 2;
    
    paint.shader = LinearGradient(colors: colors).createShader(
      Rect.fromCircle(center: Offset(activeX, activeY), radius: size / 2),
    );
    
    // Create liquid morphing effect
    final path = Path();
    final radius = (size / 2) * (1 + animation * 0.2);
    
    // Add wavy edges for liquid effect
    for (double angle = 0; angle < 2 * math.pi; angle += 0.1) {
      final waveRadius = radius + (2 * math.sin(angle * 4 + animation * 4 * math.pi));
      final x = activeX + waveRadius * math.cos(angle);
      final y = activeY + waveRadius * math.sin(angle);
      
      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PremiumProgressBar extends StatefulWidget {
  final double progress;
  final double height;
  final List<Color>? colors;
  final Duration animationDuration;
  final bool showPercentage;
  final String? label;
  final ProgressBarStyle style;
  
  const PremiumProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.colors,
    this.animationDuration = const Duration(milliseconds: 800),
    this.showPercentage = false,
    this.label,
    this.style = ProgressBarStyle.gradient,
  });
  
  @override
  State<PremiumProgressBar> createState() => _PremiumProgressBarState();
}

class _PremiumProgressBarState extends State<PremiumProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(PremiumProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      
      _controller.forward(from: 0);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? ModernTheme.primaryGradient;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ..[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return _buildProgressBar(colors, _animation.value);
                },
              ),
            ),
            if (widget.showPercentage) ..[
              const SizedBox(width: 12),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Text(
                    '${(_animation.value * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.first,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
  
  Widget _buildProgressBar(List<Color> colors, double progress) {
    switch (widget.style) {
      case ProgressBarStyle.gradient:
        return _buildGradientBar(colors, progress);
      case ProgressBarStyle.neon:
        return _buildNeonBar(colors, progress);
      case ProgressBarStyle.liquid:
        return _buildLiquidBar(colors, progress);
    }
  }
  
  Widget _buildGradientBar(List<Color> colors, double progress) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.height / 2),
        color: colors.first.withOpacity(0.1),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                gradient: LinearGradient(colors: colors),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNeonBar(List<Color> colors, double progress) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.height / 2),
        color: ModernTheme.darkCardSurface,
        border: Border.all(
          color: colors.first.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                gradient: LinearGradient(colors: colors),
                boxShadow: [
                  BoxShadow(
                    color: colors.first,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLiquidBar(List<Color> colors, double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.height / 2),
      child: Container(
        height: widget.height,
        color: colors.first.withOpacity(0.1),
        child: FractionallySizedBox(
          widthFactor: progress,
          child: CustomPaint(
            painter: LiquidProgressPainter(
              colors: colors,
              animation: _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}

class LiquidProgressPainter extends CustomPainter {
  final List<Color> colors;
  final double animation;
  
  LiquidProgressPainter({
    required this.colors,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(colors: colors).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    
    final path = Path();
    
    // Create liquid wave effect
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 + 
               (size.height * 0.1 * math.sin((x / size.width * 4 * math.pi) + 
                                            (animation * 4 * math.pi)));
      
      if (x == 0) {
        path.moveTo(x, size.height);
        path.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

enum PageIndicatorStyle {
  morphing,
  scaling,
  sliding,
  liquid,
  orbital,
}

enum ProgressBarStyle {
  gradient,
  neon,
  liquid,
}