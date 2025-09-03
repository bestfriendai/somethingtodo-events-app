import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'dart:ui';
import '../../config/modern_theme.dart';
import '../../services/delight_service.dart';
import '../../services/platform_interactions.dart';

class ModernFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? tooltip;
  final List<Color>? gradient;
  final double size;
  final bool isExpanded;
  final String? label;
  final IconData? icon;

  const ModernFloatingActionButton({
    super.key,
    this.onPressed,
    this.child,
    this.tooltip,
    this.gradient,
    this.size = 56,
    this.isExpanded = false,
    this.label,
    this.icon,
  });

  const ModernFloatingActionButton.extended({
    super.key,
    this.onPressed,
    this.tooltip,
    this.gradient,
    this.size = 56,
    required this.label,
    required this.icon,
  }) : isExpanded = true,
       child = null;

  @override
  State<ModernFloatingActionButton> createState() =>
      _ModernFloatingActionButtonState();
}

class _ModernFloatingActionButtonState extends State<ModernFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = widget.gradient ?? ModernTheme.purpleGradient;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _rotationAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                widget.isExpanded ? 28 : widget.size / 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.4),
                  blurRadius: 20 * _pulseAnimation.value,
                  spreadRadius: 2 * _pulseAnimation.value,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: gradient.last.withValues(alpha: 0.2),
                  blurRadius: 30 * _pulseAnimation.value,
                  spreadRadius: 5 * _pulseAnimation.value,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: GestureDetector(
              onTapDown: (_) => _handleTapDown(),
              onTapUp: (_) => _handleTapUp(),
              onTapCancel: _handleTapCancel,
              child: Container(
                width: widget.isExpanded ? null : widget.size,
                height: widget.size,
                padding: widget.isExpanded
                    ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                    : null,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(
                    widget.isExpanded ? 28 : widget.size / 2,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: widget.isExpanded
                    ? _buildExpandedContent()
                    : _buildRegularContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegularContent() {
    return Center(
      child: Transform.rotate(
        angle: _rotationAnimation.value * 3.14159,
        child:
            widget.child ??
            Icon(
              widget.icon ?? Icons.add_rounded,
              color: Colors.white,
              size: widget.size * 0.5,
            ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: _rotationAnimation.value * 3.14159,
          child: Icon(
            widget.icon ?? Icons.add_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(width: 12),
          Text(
            widget.label!,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: ModernTheme.primaryFont,
            ),
          ),
        ],
      ],
    );
  }
}

class ModernSpeedDial extends StatefulWidget {
  final List<ModernSpeedDialAction> actions;
  final Widget? child;
  final VoidCallback? onPressed;
  final List<Color>? gradient;
  final String? tooltip;

  const ModernSpeedDial({
    super.key,
    required this.actions,
    this.child,
    this.onPressed,
    this.gradient,
    this.tooltip,
  });

  @override
  State<ModernSpeedDial> createState() => _ModernSpeedDialState();
}

class _ModernSpeedDialState extends State<ModernSpeedDial>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isOpen = !_isOpen;
    });

    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Background overlay
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: Colors.black.withValues(alpha: _isOpen ? 0.3 : 0.0),
              ),
            ),
          ),
        // Speed dial actions
        ...widget.actions.asMap().entries.map((entry) {
          int index = entry.key;
          ModernSpeedDialAction action = entry.value;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offset = Offset(
                0,
                -((index + 1) * 70.0 * _scaleAnimation.value),
              );

              return Transform.translate(
                offset: offset,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Label
                        if (action.label != null && _isOpen)
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              action.label!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                        // Action button
                        GestureDetector(
                          onTap: () {
                            _toggle();
                            action.onPressed?.call();
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    action.gradient ??
                                    ModernTheme.oceanGradient,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (action.gradient ??
                                              ModernTheme.oceanGradient)
                                          .first
                                          .withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              action.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
        // Main FAB
        ModernFloatingActionButton(
          onPressed: _toggle,
          gradient: widget.gradient,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 3.14159 * 2,
                child: Icon(
                  _isOpen ? Icons.close_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ModernSpeedDialAction {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final List<Color>? gradient;
  final String? tooltip;

  const ModernSpeedDialAction({
    required this.icon,
    this.label,
    this.onPressed,
    this.gradient,
    this.tooltip,
  });
}

// Delightful FAB with Extra Personality
class DelightfulFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;
  final bool showSparkles;

  const DelightfulFAB({
    super.key,
    this.onPressed,
    this.icon = Icons.add_rounded,
    this.tooltip = 'Add Something Awesome',
    this.showSparkles = true,
  });

  @override
  State<DelightfulFAB> createState() => _DelightfulFABState();
}

class _DelightfulFABState extends State<DelightfulFAB>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _bounceController;
  late AnimationController _rotateController;

  int _tapCount = 0;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _sparkleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sparkleController.repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _bounceController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapCount++;

    setState(() => _isPressed = true);

    _bounceController.forward().then((_) {
      _bounceController.reverse();
      setState(() => _isPressed = false);
    });

    _rotateController.forward().then((_) {
      _rotateController.reset();
    });

    // Easter egg for multiple taps
    if (_tapCount >= 10) {
      DelightService.instance.triggerEasterEgg(context, 'fab_masher');
      _tapCount = 0;
    }

    // Show celebration
    DelightService.instance.showConfetti(
      context,
      customMessage: [
        'Boom! Let\'s make it happen! 💥',
        'Your creativity is showing! ✨',
        'Time to add some magic! 🪄',
        'Another brilliant idea incoming! 💡',
      ][Random().nextInt(4)],
    );

    PlatformInteractions.mediumImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sparkle background
        if (widget.showSparkles)
          AnimatedBuilder(
            animation: _sparkleController,
            builder: (context, child) {
              return CustomPaint(
                painter: FABSparklePainter(
                  progress: _sparkleController.value,
                  radius: 40,
                ),
                size: const Size(120, 120),
              );
            },
          ),
        // Main FAB
        AnimatedBuilder(
          animation: Listenable.merge([_bounceController, _rotateController]),
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + (_bounceController.value * 0.2),
              child: Transform.rotate(
                angle: _rotateController.value * pi * 2,
                child: FloatingActionButton(
                  onPressed: _handleTap,
                  tooltip: widget.tooltip,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.shade400,
                          Colors.blue.shade500,
                          Colors.teal.shade400,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.3),
                          blurRadius: _isPressed ? 30 : 20,
                          spreadRadius: _isPressed ? 8 : 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 28),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// FAB Sparkle Painter
class FABSparklePainter extends CustomPainter {
  final double progress;
  final double radius;

  FABSparklePainter({required this.progress, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (progress * 2 * pi);
      final sparkleDistance = radius + (10 * sin(progress * 4 * pi + i));
      final sparkleSize = 3 + (2 * sin(progress * 6 * pi + i * 0.7));

      final x = center.dx + (sparkleDistance * cos(angle));
      final y = center.dy + (sparkleDistance * sin(angle));

      // Use modern theme colors for sparkles
      final colorIndex = i % ModernTheme.auroraGradient.length;
      paint.color = ModernTheme.auroraGradient[colorIndex].withOpacity(
        0.5 + (0.4 * sin(progress * 2 * pi + i)),
      );

      // Draw sparkle
      canvas.drawCircle(Offset(x, y), sparkleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
