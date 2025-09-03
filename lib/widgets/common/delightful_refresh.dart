import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../services/delight_service.dart';
import '../../services/platform_interactions.dart';
import '../../config/modern_theme.dart';
import 'dart:math';

class DelightfulRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshMessage;
  final bool showFunMessages;

  const DelightfulRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshMessage,
    this.showFunMessages = true,
  });

  @override
  State<DelightfulRefresh> createState() => _DelightfulRefreshState();
}

class _DelightfulRefreshState extends State<DelightfulRefresh>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  final Random _random = Random();

  static const List<String> _refreshMessages = [
    'Summoning fresh events from the universe...',
    'Shaking the event tree for new adventures...',
    'Consulting our crystal ball for epic activities...',
    'Asking the fun police for their latest recommendations...',
    'Downloading more excitement from the cloud...',
    'Refreshing your social possibilities...',
    'Loading maximum fun levels...',
    'Gathering intel on the coolest happenings...',
    'Brewing up some fresh weekend plans...',
    'Updating your adventure algorithms...',
  ];

  static const List<String> _completedMessages = [
    'Boom! Fresh events have landed!',
    'Mission accomplished! New fun incoming!',
    'Success! Your social calendar just got an upgrade!',
    'Ta-da! More amazing events discovered!',
    'Jackpot! Fresh adventures await!',
    'Victory! The fun has been doubled!',
    'Epic win! New events unlocked!',
    'Nailed it! Your options just multiplied!',
  ];

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Start sparkle animation
    _sparkleController.repeat();

    if (widget.showFunMessages) {
      // Show refreshing message with premium styling
      final message =
          widget.refreshMessage ??
          _refreshMessages[_random.nextInt(_refreshMessages.length)];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ModernTheme.primaryColor,
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: ModernTheme.darkCardSurface.withValues(alpha: 0.95),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Enhanced haptic feedback
    PlatformInteractions.mediumImpact();

    try {
      await widget.onRefresh();

      // Stop sparkle animation
      _sparkleController.stop();

      // Success haptic
      PlatformInteractions.lightImpact();

      // Success celebration with premium effects
      if (widget.showFunMessages) {
        final completedMessage =
            _completedMessages[_random.nextInt(_completedMessages.length)];

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            DelightService.instance.showConfetti(
              context,
              customMessage: completedMessage,
            );
          }
        });
      }
    } catch (e) {
      _sparkleController.stop();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LiquidPullToRefresh(
          onRefresh: _handleRefresh,
          color: Colors.transparent,
          backgroundColor: ModernTheme.primaryColor,
          height: 120,
          animSpeedFactor: 2.5,
          showChildOpacityTransition: true,
          springAnimationDurationInMilliseconds: 300,
          child: widget.child,
        ),
        // Aurora effect overlay
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: AuroraRefreshPainter(
                    progress: _sparkleController.value,
                    colors: ModernTheme.auroraGradient,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Aurora Refresh Painter for premium pull-to-refresh
class AuroraRefreshPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  AuroraRefreshPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    // Create aurora waves during refresh
    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress + (i * 0.3)) % 1.0;
      final waveHeight = size.height * 0.15 * waveProgress;

      final path = Path();
      path.moveTo(0, 0);

      for (double x = 0; x <= size.width; x += 5) {
        final y =
            waveHeight * sin((x / size.width * 2 * pi) + (progress * 4 * pi));
        path.lineTo(x, y);
      }

      path.lineTo(size.width, 0);
      path.close();

      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors[i % colors.length].withValues(alpha: 0.1 * (1 - waveProgress)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, waveHeight));

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Premium Custom Refresh Indicator
class PremiumRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final RefreshStyle style;

  const PremiumRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.style = RefreshStyle.aurora,
  });

  @override
  State<PremiumRefreshIndicator> createState() =>
      _PremiumRefreshIndicatorState();
}

class _PremiumRefreshIndicatorState extends State<PremiumRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _refreshController.forward();
    _glowController.repeat();

    PlatformInteractions.mediumImpact();

    try {
      await widget.onRefresh();

      // Success feedback
      PlatformInteractions.lightImpact();
      DelightService.instance.showConfetti(
        context,
        customMessage: 'Refreshed with premium sparkles! ✨',
      );
    } finally {
      _refreshController.reset();
      _glowController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case RefreshStyle.aurora:
        return _buildAuroraRefresh();
      case RefreshStyle.cosmic:
        return _buildCosmicRefresh();
      case RefreshStyle.liquid:
        return _buildLiquidRefresh();
    }
  }

  Widget _buildAuroraRefresh() {
    return DelightfulRefresh(
      onRefresh: _handleRefresh,
      child: widget.child,
      showFunMessages: true,
    );
  }

  Widget _buildCosmicRefresh() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      displacement: 100,
      strokeWidth: 4,
      backgroundColor: ModernTheme.darkCardSurface,
      color: ModernTheme.primaryColor,
      child: widget.child,
    );
  }

  Widget _buildLiquidRefresh() {
    return LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      color: ModernTheme.primaryColor.withValues(alpha: 0.1),
      backgroundColor: ModernTheme.primaryColor,
      height: 150,
      animSpeedFactor: 3,
      springAnimationDurationInMilliseconds: 250,
      child: widget.child,
    );
  }
}

enum RefreshStyle { aurora, cosmic, liquid }
