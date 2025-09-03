import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../config/modern_theme.dart';

class PremiumLoadingIndicator extends StatefulWidget {
  final double size;
  final List<Color>? colors;
  final String? message;
  final Duration duration;
  final LoadingStyle style;

  const PremiumLoadingIndicator({
    super.key,
    this.size = 50,
    this.colors,
    this.message,
    this.duration = const Duration(milliseconds: 1500),
    this.style = LoadingStyle.aurora,
  });

  @override
  State<PremiumLoadingIndicator> createState() =>
      _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<PremiumLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _colorController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _colorController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _controller.repeat();
    _colorController.repeat();
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _colorController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? ModernTheme.neonGradient;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: _buildLoadingIndicator(colors),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
                widget.message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(List<Color> colors) {
    switch (widget.style) {
      case LoadingStyle.aurora:
        return _buildAuroraLoader(colors);
      case LoadingStyle.pulse:
        return _buildPulseLoader(colors);
      case LoadingStyle.orbit:
        return _buildOrbitLoader(colors);
      case LoadingStyle.wave:
        return _buildWaveLoader(colors);
    }
  }

  Widget _buildAuroraLoader(List<Color> colors) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        _colorController,
        _scaleController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_scaleController.value * 0.1),
          child: CustomPaint(
            painter: AuroraLoadingPainter(
              progress: _controller.value,
              colorProgress: _colorController.value,
              colors: colors,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseLoader(List<Color> colors) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final scale = 1.0 + ((_scaleController.value + delay) % 1.0) * 0.5;
            final opacity = 1.0 - ((_scaleController.value + delay) % 1.0);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size / 2,
                height: widget.size / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: colors),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.first.withValues(alpha: opacity * 0.3),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildOrbitLoader(List<Color> colors) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Central orb
            Container(
              width: widget.size / 3,
              height: widget.size / 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [colors.first, colors.last]),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            // Orbiting particles
            ...List.generate(4, (index) {
              final angle =
                  (_controller.value * 2 * math.pi) + (index * math.pi / 2);
              final radius = widget.size / 3;

              return Transform.translate(
                offset: Offset(
                  radius * math.cos(angle),
                  radius * math.sin(angle),
                ),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[index % colors.length],
                    boxShadow: [
                      BoxShadow(
                        color: colors[index % colors.length].withValues(
                          alpha: 0.5,
                        ),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildWaveLoader(List<Color> colors) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final height =
                (math.sin((_controller.value * 2 * math.pi) - (index * 0.5)) +
                    1) /
                2 *
                widget.size *
                0.8;

            return Container(
              width: 4,
              height: height + 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [colors.first, colors.last],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class AuroraLoadingPainter extends CustomPainter {
  final double progress;
  final double colorProgress;
  final List<Color> colors;

  AuroraLoadingPainter({
    required this.progress,
    required this.colorProgress,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw aurora rings
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i * 0.3)) % 1.0;
      final ringRadius = radius * (0.3 + (ringProgress * 0.7));
      final opacity = 1.0 - ringProgress;

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            colors[i % colors.length].withValues(alpha: opacity * 0.7),
            colors[(i + 1) % colors.length].withValues(alpha: opacity * 0.3),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: ringRadius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(center, ringRadius, paint);
    }

    // Draw flowing particles
    for (int i = 0; i < 12; i++) {
      final particleAngle = (colorProgress * 2 * math.pi) + (i * math.pi / 6);
      final particleRadius = radius * 0.7;
      final particlePos = Offset(
        center.dx + particleRadius * math.cos(particleAngle),
        center.dy + particleRadius * math.sin(particleAngle),
      );

      final particlePaint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particlePos,
        2.0 + math.sin(progress * 4 * math.pi + i),
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PremiumSkeleton extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final List<Color>? shimmerColors;
  final Duration duration;

  const PremiumSkeleton({
    super.key,
    required this.child,
    required this.isLoading,
    this.shimmerColors,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<PremiumSkeleton> createState() => _PremiumSkeletonState();
}

class _PremiumSkeletonState extends State<PremiumSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PremiumSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .slideY(begin: 0.1, duration: 500.ms, curve: Curves.elasticOut);
    }

    final shimmerColors =
        widget.shimmerColors ??
        [
          ModernTheme.darkCardSurface,
          ModernTheme.darkCardSurface.withValues(alpha: 0.5),
          ModernTheme.darkCardSurface,
        ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 - _controller.value, 0.0),
              end: Alignment(1.0 + _controller.value, 0.0),
              colors: shimmerColors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

enum LoadingStyle { aurora, pulse, orbit, wave }
