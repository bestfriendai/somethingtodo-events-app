import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/modern_theme.dart';

class ModernBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int? unreadCount;

  const ModernBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount,
  });

  @override
  State<ModernBottomNavigation> createState() => _ModernBottomNavigationState();
}

class _ModernBottomNavigationState extends State<ModernBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    
    _animations = _controllers
        .map((controller) => Tween<double>(begin: 1.0, end: 0.8).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  void didUpdateWidget(ModernBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Add micro-animation when tab changes
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[widget.currentIndex].forward().then((_) {
        _controllers[widget.currentIndex].reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 65,
              decoration: ModernTheme.floatingNavDecoration(isDark: isDark),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) => _buildNavItem(index)),
                ),
              ),
            ),
          ),
        ),
      ),
    )
    .animate()
    .slideY(begin: 1, duration: 800.ms, curve: Curves.elasticOut)
    .fadeIn(duration: 600.ms);
  }

  Widget _buildNavItem(int index) {
    final isSelected = widget.currentIndex == index;
    final navItems = _getNavItems();
    final item = navItems[index];
    
    return GestureDetector(
      onTapDown: (_) {
        _controllers[index].forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _controllers[index].reverse();
        widget.onTap(index);
      },
      onTapCancel: () => _controllers[index].reverse(),
      child: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _animations[index].value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Modern floating icon with glassmorphic effect
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: item.gradient ?? ModernTheme.neonGradient,
                                )
                              : null,
                          color: !isSelected 
                              ? Colors.white.withValues(alpha: 0.05)
                              : null,
                          border: Border.all(
                            color: isSelected 
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.transparent,
                            width: 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: (item.gradient?[0] ?? ModernTheme.primaryColor)
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ] : null,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            key: ValueKey(isSelected),
                            color: isSelected 
                                ? Colors.white 
                                : Colors.white.withValues(alpha: 0.6),
                            size: 22,
                          ),
                        ),
                      ),
                      // Pulsing glow effect when selected
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                colors: item.gradient ?? ModernTheme.neonGradient,
                              ),
                            ),
                            child: CustomPaint(
                              painter: PulsePainter(
                                animation: _controllers[index],
                                color: item.gradient?[0] ?? ModernTheme.primaryColor,
                              ),
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.2, 1.2),
                            duration: 2000.ms,
                            curve: Curves.easeInOut,
                          )
                          .fadeIn(duration: 1000.ms)
                          .then()
                          .fadeOut(duration: 1000.ms),
                        ),
                      // Notification badge for chat with modern styling
                      if (index == 2 && (widget.unreadCount ?? 0) > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF3B30), Color(0xFFFF6B35)],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF3B30).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 22,
                              minHeight: 22,
                            ),
                            child: Text(
                              '${widget.unreadCount! > 9 ? '9+' : widget.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                            duration: 1000.ms,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .scale(
                            begin: const Offset(1.1, 1.1),
                            end: const Offset(1, 1),
                            duration: 1000.ms,
                            curve: Curves.easeInOut,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Modern label with better typography
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: isSelected ? 12 : 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6),
                      fontFamily: ModernTheme.primaryFont,
                      letterSpacing: 0.5,
                    ),
                    child: Text(item.label),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<_NavItem> _getNavItems() {
    return [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
        gradient: ModernTheme.purpleGradient, // Electric Purple
      ),
      _NavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: 'Explore',
        gradient: ModernTheme.oceanGradient, // Cyber Blue
      ),
      _NavItem(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome_rounded,
        label: 'AI Chat',
        gradient: ModernTheme.neonGradient, // Blue to Purple
      ),
      _NavItem(
        icon: Icons.favorite_border_rounded,
        activeIcon: Icons.favorite_rounded,
        label: 'Saved',
        gradient: ModernTheme.pinkGradient, // Neon Pink
      ),
      _NavItem(
        icon: Icons.account_circle_outlined,
        activeIcon: Icons.account_circle_rounded,
        label: 'Profile',
        gradient: ModernTheme.sunsetGradient, // Orange Sunset
      ),
    ];
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final List<Color>? gradient;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.gradient,
  });
}

// Modern Pulse Painter for active nav items
class PulsePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  
  PulsePainter({required this.animation, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * progress;
    
    canvas.drawCircle(center, radius, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Navigation Sparkle Painter for ambient effects
class NavSparklePainter extends CustomPainter {
  final double progress;
  final Color color;
  
  NavSparklePainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4 * sin(progress * pi))
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (progress * 2 * pi);
      final distance = 25 + (8 * sin(progress * 3 * pi + i));
      final sparkleSize = 2 + (1.5 * sin(progress * 4 * pi + i));
      
      final x = center.dx + (distance * cos(angle));
      final y = center.dy + (distance * sin(angle));
      
      // Create star shape instead of circle
      _drawStar(canvas, Offset(x, y), sparkleSize, paint);
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const numPoints = 5;
    final angleStep = pi / numPoints;
    
    for (int i = 0; i < numPoints * 2; i++) {
      final angle = i * angleStep;
      final radius = i.isEven ? size : size * 0.5;
      final x = center.dx + radius * cos(angle - pi / 2);
      final y = center.dy + radius * sin(angle - pi / 2);
      
      if (i == 0) {
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