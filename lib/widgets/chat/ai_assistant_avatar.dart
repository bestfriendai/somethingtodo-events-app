import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/unified_design_system.dart';

class AIAssistantAvatar extends StatefulWidget {
  final double size;
  final bool isThinking;
  final AvatarState state;
  final VoidCallback? onTap;

  const AIAssistantAvatar({
    super.key,
    this.size = 48,
    this.isThinking = false,
    this.state = AvatarState.idle,
    this.onTap,
  });

  @override
  State<AIAssistantAvatar> createState() => _AIAssistantAvatarState();
}

enum AvatarState { idle, thinking, success, error, happy, curious, excited }

class _AIAssistantAvatarState extends State<AIAssistantAvatar>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _expressionController;

  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _expressionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    if (widget.isThinking) {
      _startThinkingAnimation();
    }
  }

  @override
  void didUpdateWidget(AIAssistantAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isThinking != oldWidget.isThinking) {
      if (widget.isThinking) {
        _startThinkingAnimation();
      } else {
        _stopThinkingAnimation();
      }
    }

    if (widget.state != oldWidget.state) {
      _playStateAnimation();
    }
  }

  void _startThinkingAnimation() {
    _rotationController.repeat();
  }

  void _stopThinkingAnimation() {
    _rotationController.stop();
    _rotationController.reset();
  }

  void _playStateAnimation() {
    _expressionController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child:
          SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow effect
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: widget.size * 1.5,
                          height: widget.size * 1.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _getGlowColor().withValues(
                                  alpha: 0.3 * _glowAnimation.value,
                                ),
                                _getGlowColor().withValues(
                                  alpha: 0.1 * _glowAnimation.value,
                                ),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        );
                      },
                    ),

                    // Rotating rings (visible when thinking)
                    if (widget.isThinking) ...[
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: CustomPaint(
                              size: Size(widget.size * 1.3, widget.size * 1.3),
                              painter: _OrbitPainter(
                                color: UnifiedDesignSystem.primaryBrand
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: -_rotationAnimation.value * 0.5,
                            child: CustomPaint(
                              size: Size(widget.size * 1.2, widget.size * 1.2),
                              painter: _OrbitPainter(
                                color: UnifiedDesignSystem.secondaryBrand
                                    .withValues(alpha: 0.3),
                                strokeWidth: 1.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    // Main avatar
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: widget.isThinking
                              ? _pulseAnimation.value
                              : 1.0,
                          child: Container(
                            width: widget.size,
                            height: widget.size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _getGradientColors(),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getGlowColor().withValues(alpha: 0.5),
                                  blurRadius: widget.size * 0.3,
                                  spreadRadius: widget.size * 0.1,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Inner pattern
                                ClipOval(
                                  child: CustomPaint(
                                    size: Size(widget.size, widget.size),
                                    painter: _InnerPatternPainter(
                                      state: widget.state,
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                ),

                                // Face/Expression
                                _buildExpression(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Success/Error overlay animation
                    if (widget.state == AvatarState.success ||
                        widget.state == AvatarState.error)
                      AnimatedBuilder(
                        animation: _expressionController,
                        builder: (context, child) {
                          final scale = Curves.elasticOut.transform(
                            _expressionController.value,
                          );
                          return Transform.scale(
                            scale: scale,
                            child: Icon(
                              widget.state == AvatarState.success
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: widget.state == AvatarState.success
                                  ? UnifiedDesignSystem.successColor
                                  : UnifiedDesignSystem.errorColor,
                              size: widget.size * 0.4,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
              ),
    );
  }

  Widget _buildExpression() {
    final faceSize = widget.size * 0.5;

    switch (widget.state) {
      case AvatarState.happy:
        return CustomPaint(
          size: Size(faceSize, faceSize),
          painter: _ExpressionPainter(
            expression: Expression.happy,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        );
      case AvatarState.curious:
        return CustomPaint(
          size: Size(faceSize, faceSize),
          painter: _ExpressionPainter(
            expression: Expression.curious,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        );
      case AvatarState.excited:
        return CustomPaint(
          size: Size(faceSize, faceSize),
          painter: _ExpressionPainter(
            expression: Expression.excited,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        );
      case AvatarState.thinking:
        return _buildThinkingDots();
      default:
        return CustomPaint(
          size: Size(faceSize, faceSize),
          painter: _ExpressionPainter(
            expression: Expression.neutral,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        );
    }
  }

  Widget _buildThinkingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: widget.size * 0.08,
              height: widget.size * 0.08,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
              delay: Duration(milliseconds: index * 200),
            )
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: const Duration(milliseconds: 600),
            );
      }),
    );
  }

  List<Color> _getGradientColors() {
    switch (widget.state) {
      case AvatarState.success:
        return [
          UnifiedDesignSystem.successColor,
          UnifiedDesignSystem.successColor.withValues(alpha: 0.7),
        ];
      case AvatarState.error:
        return [
          UnifiedDesignSystem.errorColor,
          UnifiedDesignSystem.errorColor.withValues(alpha: 0.7),
        ];
      case AvatarState.happy:
      case AvatarState.excited:
        return [
          UnifiedDesignSystem.secondaryBrand,
          UnifiedDesignSystem.accentBrand,
        ];
      default:
        return [
          UnifiedDesignSystem.primaryBrand,
          UnifiedDesignSystem.primaryBrand.withValues(alpha: 0.7),
        ];
    }
  }

  Color _getGlowColor() {
    switch (widget.state) {
      case AvatarState.success:
        return UnifiedDesignSystem.successColor;
      case AvatarState.error:
        return UnifiedDesignSystem.errorColor;
      case AvatarState.happy:
      case AvatarState.excited:
        return UnifiedDesignSystem.accentBrand;
      default:
        return widget.isThinking
            ? UnifiedDesignSystem.secondaryBrand
            : UnifiedDesignSystem.primaryBrand;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _expressionController.dispose();
    super.dispose();
  }
}

class _OrbitPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _OrbitPainter({required this.color, this.strokeWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw orbital ring
    canvas.drawCircle(center, radius, paint);

    // Draw orbital dots
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InnerPatternPainter extends CustomPainter {
  final AvatarState state;
  final Color color;

  _InnerPatternPainter({required this.state, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw concentric circles or patterns based on state
    if (state == AvatarState.thinking) {
      for (int i = 1; i <= 3; i++) {
        canvas.drawCircle(
          center,
          size.width * (i * 0.15),
          paint..color = color.withValues(alpha: 0.3 / i),
        );
      }
    } else {
      // Draw a subtle grid pattern
      final step = size.width / 8;
      for (int i = 1; i < 8; i++) {
        canvas.drawLine(
          Offset(step * i, 0),
          Offset(step * i, size.height),
          paint..color = color.withValues(alpha: 0.1),
        );
        canvas.drawLine(
          Offset(0, step * i),
          Offset(size.width, step * i),
          paint..color = color.withValues(alpha: 0.1),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum Expression { neutral, happy, curious, excited }

class _ExpressionPainter extends CustomPainter {
  final Expression expression;
  final Color color;

  _ExpressionPainter({required this.expression, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final eyeY = center.dy - size.height * 0.1;
    final eyeSpacing = size.width * 0.2;

    switch (expression) {
      case Expression.happy:
        // Happy eyes (crescents)
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;

        final leftEyePath = Path()
          ..moveTo(center.dx - eyeSpacing - 5, eyeY)
          ..quadraticBezierTo(
            center.dx - eyeSpacing,
            eyeY + 5,
            center.dx - eyeSpacing + 5,
            eyeY,
          );
        canvas.drawPath(leftEyePath, paint);

        final rightEyePath = Path()
          ..moveTo(center.dx + eyeSpacing - 5, eyeY)
          ..quadraticBezierTo(
            center.dx + eyeSpacing,
            eyeY + 5,
            center.dx + eyeSpacing + 5,
            eyeY,
          );
        canvas.drawPath(rightEyePath, paint);

        // Happy mouth (smile)
        final smilePath = Path()
          ..moveTo(center.dx - size.width * 0.15, center.dy + size.height * 0.1)
          ..quadraticBezierTo(
            center.dx,
            center.dy + size.height * 0.25,
            center.dx + size.width * 0.15,
            center.dy + size.height * 0.1,
          );
        canvas.drawPath(smilePath, paint);
        break;

      case Expression.curious:
        // Curious eyes (one raised)
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(center.dx - eyeSpacing, eyeY), 3, paint);
        canvas.drawCircle(Offset(center.dx + eyeSpacing, eyeY - 3), 3, paint);

        // Curious mouth (small o)
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        canvas.drawCircle(
          Offset(center.dx, center.dy + size.height * 0.15),
          size.width * 0.05,
          paint,
        );
        break;

      case Expression.excited:
        // Star eyes
        paint.style = PaintingStyle.fill;
        _drawStar(canvas, Offset(center.dx - eyeSpacing, eyeY), 5, paint);
        _drawStar(canvas, Offset(center.dx + eyeSpacing, eyeY), 5, paint);

        // Excited mouth (wide smile)
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        final excitedPath = Path()
          ..moveTo(center.dx - size.width * 0.2, center.dy + size.height * 0.05)
          ..quadraticBezierTo(
            center.dx,
            center.dy + size.height * 0.3,
            center.dx + size.width * 0.2,
            center.dy + size.height * 0.05,
          );
        canvas.drawPath(excitedPath, paint);
        break;

      case Expression.neutral:
      default:
        // Neutral eyes (dots)
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(center.dx - eyeSpacing, eyeY), 3, paint);
        canvas.drawCircle(Offset(center.dx + eyeSpacing, eyeY), 3, paint);

        // Neutral mouth (line)
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        canvas.drawLine(
          Offset(center.dx - size.width * 0.1, center.dy + size.height * 0.15),
          Offset(center.dx + size.width * 0.1, center.dy + size.height * 0.15),
          paint,
        );
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      final innerAngle = angle + math.pi / 5;
      final innerX = center.dx + (radius * 0.5) * math.cos(innerAngle);
      final innerY = center.dy + (radius * 0.5) * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
