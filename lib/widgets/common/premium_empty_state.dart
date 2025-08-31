import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../config/modern_theme.dart';
import 'premium_button.dart';
import 'premium_text_animator.dart';

class PremiumEmptyState extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? lottieAsset;
  final String? actionText;
  final VoidCallback? onAction;
  final EmptyStateType type;
  final List<Color>? customColors;
  final bool showFloatingElements;
  
  const PremiumEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.lottieAsset,
    this.actionText,
    this.onAction,
    this.type = EmptyStateType.general,
    this.customColors,
    this.showFloatingElements = true,
  });
  
  @override
  State<PremiumEmptyState> createState() => _PremiumEmptyStateState();
}

class _PremiumEmptyStateState extends State<PremiumEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  
  @override
  void initState() {
    super.initState();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _floatingController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _particleController.repeat();
  }
  
  @override
  void dispose() {
    _floatingController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = widget.customColors ?? _getColorsForType(widget.type);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration area
            _buildIllustration(colors),
            
            const SizedBox(height: 32),
            
            // Title
            PremiumTextAnimator(
              text: widget.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              animationType: TextAnimationType.fadeIn,
              delay: const Duration(milliseconds: 300),
            ),
            
            const SizedBox(height: 16),
            
            // Subtitle
            PremiumTextAnimator(
              text: widget.subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
              animationType: TextAnimationType.slideUp,
              delay: const Duration(milliseconds: 500),
            ),
            
            if (widget.actionText != null && widget.onAction != null) ..[
              const SizedBox(height: 32),
              PremiumButton(
                text: widget.actionText!,
                onPressed: widget.onAction,
                gradient: colors,
                width: 200,
              )
              .animate(delay: 700.ms)
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildIllustration(List<Color> colors) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Floating particles
          if (widget.showFloatingElements)
            ...List.generate(8, (index) {
              return AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  final angle = (index * 45.0) * (math.pi / 180) + 
                      (_particleController.value * 2 * math.pi);
                  final radius = 80 + (20 * math.sin(_particleController.value * 2 * math.pi + index));
                  
                  return Transform.translate(
                    offset: Offset(
                      radius * math.cos(angle),
                      radius * math.sin(angle),
                    ),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            colors[index % colors.length].withOpacity(0.8),
                            colors[(index + 1) % colors.length].withOpacity(0.4),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors[index % colors.length].withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          
          // Main icon with glow
          AnimatedBuilder(
            animation: Listenable.merge([_floatingController, _glowController]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  10 * math.sin(_floatingController.value * math.pi),
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: colors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.first.withOpacity(0.4 + (0.2 * _glowController.value)),
                        blurRadius: 20 + (10 * _glowController.value),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon ?? _getIconForType(widget.type),
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          // Ripple effect
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(200, 200),
                painter: RippleEffectPainter(
                  progress: _glowController.value,
                  color: colors.first.withOpacity(0.2),
                ),
              );
            },
          ),
        ],
      ),
    )
    .animate(delay: 100.ms)
    .fadeIn(duration: 800.ms)
    .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut);
  }
  
  List<Color> _getColorsForType(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.noData:
        return ModernTheme.oceanGradient;
      case EmptyStateType.noResults:
        return ModernTheme.purpleGradient;
      case EmptyStateType.offline:
        return [Colors.grey.shade600, Colors.grey.shade800];
      case EmptyStateType.error:
        return [ModernTheme.errorColor, Colors.red.shade700];
      case EmptyStateType.noFavorites:
        return ModernTheme.pinkGradient;
      case EmptyStateType.noNotifications:
        return ModernTheme.sunsetGradient;
      case EmptyStateType.general:
      default:
        return ModernTheme.neonGradient;
    }
  }
  
  IconData _getIconForType(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.noData:
        return Icons.inventory_2_outlined;
      case EmptyStateType.noResults:
        return Icons.search_off;
      case EmptyStateType.offline:
        return Icons.wifi_off;
      case EmptyStateType.error:
        return Icons.error_outline;
      case EmptyStateType.noFavorites:
        return Icons.favorite_border;
      case EmptyStateType.noNotifications:
        return Icons.notifications_none;
      case EmptyStateType.general:
      default:
        return Icons.explore_off;
    }
  }
}

class RippleEffectPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  RippleEffectPainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    
    for (int i = 0; i < 3; i++) {
      final rippleProgress = (progress - (i * 0.3)).clamp(0.0, 1.0);
      final radius = maxRadius * rippleProgress;
      final opacity = 1.0 - rippleProgress;
      
      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      if (rippleProgress > 0) {
        canvas.drawCircle(center, radius, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FloatingElementsWidget extends StatefulWidget {
  final int elementCount;
  final List<Color> colors;
  final double radius;
  
  const FloatingElementsWidget({
    super.key,
    this.elementCount = 6,
    required this.colors,
    this.radius = 100,
  });
  
  @override
  State<FloatingElementsWidget> createState() => _FloatingElementsWidgetState();
}

class _FloatingElementsWidgetState extends State<FloatingElementsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _controller.repeat();
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
        return SizedBox(
          width: widget.radius * 2,
          height: widget.radius * 2,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(widget.elementCount, (index) {
              final angle = (index * (2 * math.pi / widget.elementCount)) + 
                  (_controller.value * 2 * math.pi);
              final elementRadius = widget.radius * (0.8 + 0.2 * math.sin(_controller.value * 3 * math.pi + index));
              
              return Transform.translate(
                offset: Offset(
                  elementRadius * math.cos(angle),
                  elementRadius * math.sin(angle),
                ),
                child: Container(
                  width: 8 + (4 * math.sin(_controller.value * 4 * math.pi + index)),
                  height: 8 + (4 * math.sin(_controller.value * 4 * math.pi + index)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.colors[index % widget.colors.length],
                    boxShadow: [
                      BoxShadow(
                        color: widget.colors[index % widget.colors.length].withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class PremiumErrorState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onRetry;
  final bool showContactSupport;
  
  const PremiumErrorState({
    super.key,
    this.title = 'Oops! Something went wrong',
    this.subtitle = 'We encountered an unexpected error. Please try again.',
    this.actionText = 'Try Again',
    this.onRetry,
    this.showContactSupport = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return PremiumEmptyState(
      title: title,
      subtitle: subtitle,
      icon: Icons.error_outline,
      actionText: actionText,
      onAction: onRetry,
      type: EmptyStateType.error,
    );
  }
}

enum EmptyStateType {
  general,
  noData,
  noResults,
  offline,
  error,
  noFavorites,
  noNotifications,
}