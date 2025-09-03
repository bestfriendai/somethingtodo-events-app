import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/modern_theme.dart';

class PremiumTextAnimator extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAnimationType animationType;
  final Duration duration;
  final Duration delay;
  final bool autoPlay;

  const PremiumTextAnimator({
    super.key,
    required this.text,
    this.style,
    this.animationType = TextAnimationType.typewriter,
    this.duration = const Duration(milliseconds: 2000),
    this.delay = Duration.zero,
    this.autoPlay = true,
  });

  @override
  State<PremiumTextAnimator> createState() => _PremiumTextAnimatorState();
}

class _PremiumTextAnimatorState extends State<PremiumTextAnimator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  String _displayText = '';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _characterCount = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _characterCount.addListener(() {
      if (mounted) {
        setState(() {
          _displayText = widget.text.substring(0, _characterCount.value);
        });
      }
    });

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

  void play() {
    _controller.forward();
  }

  void reset() {
    _controller.reset();
    setState(() {
      _displayText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.animationType) {
      case TextAnimationType.typewriter:
        return _buildTypewriterText();
      case TextAnimationType.fadeIn:
        return _buildFadeInText();
      case TextAnimationType.slideUp:
        return _buildSlideUpText();
      case TextAnimationType.glitch:
        return _buildGlitchText();
      case TextAnimationType.neon:
        return _buildNeonText();
    }
  }

  Widget _buildTypewriterText() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_displayText, style: widget.style),
            if (_controller.isAnimating)
              Container(
                    width: 2,
                    height: (widget.style?.fontSize ?? 16) + 2,
                    color: ModernTheme.primaryColor,
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .fadeIn(duration: 300.ms)
                  .then()
                  .fadeOut(duration: 300.ms),
          ],
        );
      },
    );
  }

  Widget _buildFadeInText() {
    return Text(widget.text, style: widget.style)
        .animate(delay: widget.delay)
        .fadeIn(duration: widget.duration, curve: Curves.easeOut)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut);
  }

  Widget _buildSlideUpText() {
    return Text(widget.text, style: widget.style)
        .animate(delay: widget.delay)
        .slideY(begin: 1, duration: widget.duration, curve: Curves.elasticOut)
        .fadeIn(
          duration: (widget.duration.inMilliseconds * 0.6).round().milliseconds,
        );
  }

  Widget _buildGlitchText() {
    return Text(widget.text, style: widget.style)
        .animate(
          delay: widget.delay,
          onPlay: (controller) => controller.repeat(),
        )
        .effect(duration: 100.ms, delay: 0.ms, curve: Curves.easeInOut)
        .then(delay: 2000.ms)
        .slideX(begin: 0.1, end: -0.1, duration: 50.ms)
        .then()
        .slideX(begin: -0.1, end: 0.1, duration: 50.ms)
        .then()
        .slideX(begin: 0.1, end: 0, duration: 50.ms);
  }

  Widget _buildNeonText() {
    return Stack(
          children: [
            // Glow layers
            ...List.generate(3, (index) {
              return Text(
                widget.text,
                style: widget.style?.copyWith(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = (index + 1) * 2.0
                    ..color = ModernTheme.primaryColor.withValues(
                      alpha: 0.3 / (index + 1),
                    ),
                ),
              );
            }),
            // Main text
            Text(
              widget.text,
              style: widget.style?.copyWith(
                color: Colors.white,
                shadows: [
                  Shadow(color: ModernTheme.primaryColor, blurRadius: 10),
                  Shadow(color: ModernTheme.secondaryColor, blurRadius: 20),
                ],
              ),
            ),
          ],
        )
        .animate(
          delay: widget.delay,
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .fadeIn(duration: widget.duration)
        .then()
        .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.5));
  }
}

class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String prefix;
  final String suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
    this.prefix = '',
    this.suffix = '',
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _previousValue = _animation.value;
      _animation = IntTween(begin: _previousValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      _controller.reset();
      _controller.forward();
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
      animation: _animation,
      builder: (context, child) {
        return Text(
              '${widget.prefix}${_animation.value}${widget.suffix}',
              style: widget.style,
            )
            .animate()
            .scale(
              begin: const Offset(1.2, 1.2),
              duration: 200.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 300.ms);
      },
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final TextStyle? style;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    super.key,
    required this.colors,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}

enum TextAnimationType { typewriter, fadeIn, slideUp, glitch, neon }
