import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/modern_theme.dart';
import '../config/app_config.dart';
import '../core/constants/app_constants.dart';
import '../services/delight_service.dart';
import '../services/platform_interactions.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _breathingController;
  late AnimationController _auroraController;
  late AnimationController _morphController;
  final Random _random = Random();

  static const List<String> _loadingMessages = [
    'Warming up the party engines...',
    'Calibrating fun levels...',
    'Downloading good vibes...',
    'Initializing awesome mode...',
    'Loading maximum entertainment...',
    'Preparing epic discoveries...',
    'Gathering cosmic event energy...',
    'Activating adventure protocols...',
  ];

  String _currentMessage = 'Loading amazing events...';

  @override
  void initState() {
    super.initState();

    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _sparkleController.repeat();
    _breathingController.repeat(reverse: true);

    // Initialize delight service
    DelightService.instance.initialize();

    _startMessageRotation();
    _initializeApp();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _startMessageRotation() {
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted && timer.tick < _loadingMessages.length) {
        setState(() {
          _currentMessage =
              _loadingMessages[timer.tick % _loadingMessages.length];
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _initializeApp() async {
    // Add a shorter splash time for better UX
    await Future.delayed(Duration(milliseconds: AppConstants.slowAnimationMs * 3));

    if (mounted) {
      // Success haptic (only on mobile)
      if (!kIsWeb) {
        PlatformInteractions.lightImpact();
      }

      // Show completion celebration
      DelightService.instance.showConfetti(
        context,
        customMessage: 'Welcome to your next adventure! 🎉',
      );

      final authProvider = context.read<AuthProvider>();

      // Add a small delay for the celebration to show
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if user is authenticated
      if (authProvider.isAuthenticated) {
        // User is logged in, go to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Check if user has seen onboarding
        final hasSeenOnboarding = await _checkOnboardingStatus();
        if (hasSeenOnboarding) {
          Navigator.pushReplacementNamed(context, '/auth');
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      }
    }
  }

  Future<bool> _checkOnboardingStatus() async {
    // This would typically check SharedPreferences or Hive
    // For now, return false to always show onboarding
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? ModernTheme.darkBackground
          : ModernTheme.lightBackground,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // App Logo and Name
            Column(
              children: [
                // Enhanced Logo Container with sparkles
                Stack(
                      alignment: Alignment.center,
                      children: [
                        // Sparkle background
                        AnimatedBuilder(
                          animation: _sparkleController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: SparklePainter(
                                progress: _sparkleController.value,
                                sparkleCount: 20,
                              ),
                              size: const Size(200, 200),
                            );
                          },
                        ),
                        // Main logo with breathing effect
                        AnimatedBuilder(
                          animation: _breathingController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1 + (_breathingController.value * 0.1),
                              child: GestureDetector(
                                onLongPress: () {
                                  DelightService.instance.triggerEasterEgg(
                                    context,
                                    'logo',
                                  );
                                },
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: ModernTheme.purpleGradient,
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ModernTheme.primaryColor.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 25,
                                        offset: const Offset(0, 15),
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Main icon
                                      Icon(
                                        Icons.explore,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                      // Orbiting mini icons
                                      ...List.generate(3, (index) {
                                        final angle =
                                            (index * 120.0) * (pi / 180.0) +
                                            (_sparkleController.value * 2 * pi);
                                        return Transform.translate(
                                          offset: Offset(
                                            30 * cos(angle),
                                            30 * sin(angle),
                                          ),
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              [
                                                Icons.star,
                                                Icons.favorite,
                                                Icons.celebration,
                                              ][index],
                                              size: 14,
                                              color: ModernTheme.primaryColor,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                    .animate()
                    .scale(
                      duration: Duration(milliseconds: AppConstants.defaultAnimationMs + 500),
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 600.ms)
                    .then(delay: 1.seconds)
                    .shimmer(
                      duration: 2.seconds,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),

                const SizedBox(height: 24),

                // App Name
                Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : ModernTheme.lightOnSurface,
                          ),
                    )
.animate(delay: 300.ms)
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                // Enhanced Tagline with personality
                Column(
                      children: [
                        Text(
                          'Discover Events Near You',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: isDarkMode
                                    ? Colors.white70
                                    : ModernTheme.lightOnSurface.withValues(
                                        alpha: 0.7,
                                      ),
                              ),
                        ),
                        SizedBox(height: AppTheme.spaceSm),
                        Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.withValues(alpha: 0.8),
                                    Colors.orange.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Where memories begin ✨',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            .animate(delay: Duration(milliseconds: 1500))
                            .fadeIn(duration: AppTheme.animationSlow)
                            .scale(
                              begin: const Offset(0.5, 0.5),
                              curve: Curves.elasticOut,
                            )
                            .then()
                            .shimmer(duration: 3.seconds),
                      ],
                    )
.animate(delay: 600.ms)
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.3, end: 0),
              ],
            ),

            const Spacer(),

            // Loading Indicator
            Column(
              children: [
                SizedBox(
                      width: AppTheme.space2xl - 8,
                      height: AppTheme.space2xl - 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    )
                    .animate(delay: Duration(milliseconds: 1000))
                    .fadeIn(duration: Duration(milliseconds: AppConstants.defaultAnimationMs + 100))
                    .scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 24),

                // Dynamic loading message
                AnimatedSwitcher(
                      duration: Duration(milliseconds: AppConstants.defaultAnimationMs + 100),
                      child: Text(
                        _currentMessage,
                        key: ValueKey(_currentMessage),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? Colors.white60
                              : ModernTheme.lightOnSurface.withValues(
                                  alpha: 0.6,
                                ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    .animate(delay: Duration(milliseconds: 1200))
                    .fadeIn(duration: Duration(milliseconds: AppConstants.defaultAnimationMs + 100)),
              ],
            ),

            const SizedBox(height: 60),

            // Hidden easter egg area
            GestureDetector(
              onTap: () {
                DelightService.instance.triggerEasterEgg(
                  context,
                  'splash_secret',
                );
              },
              child: Container(
                width: 100,
                height: AppTheme.spaceLg - 4,
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Premium Aurora Painter for Splash Screen
class PremiumAuroraPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  PremiumAuroraPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create flowing aurora waves
    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress + (i * 0.3)) % 1.0;
      final path = Path();

      // Create wave shape
      for (double x = 0; x <= size.width; x += 5) {
        final normalizedX = x / size.width;
        final y =
            (size.height * 0.3) +
            (size.height *
                0.2 *
                sin(normalizedX * 4 * pi + waveProgress * 2 * pi)) +
            (size.height *
                0.1 *
                sin(normalizedX * 8 * pi + waveProgress * 4 * pi));

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      // Complete the shape
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      // Apply gradient
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors[i % colors.length].withValues(alpha: 0.1 * (1 - waveProgress)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Floating Particles Painter
class FloatingParticlesPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  FloatingParticlesPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate floating particles
    for (int i = 0; i < 20; i++) {
      final particleProgress = (progress + (i * 0.1)) % 1.0;
      final particleSize = 2 + (4 * sin(progress * 2 * pi + i));

      // Particle position using consistent randomization
      final seed = i * 1000; // Use index as seed
      final x =
          (sin(seed) * 0.5 + 0.5) * size.width +
          (30 * cos(particleProgress * 2 * pi));
      final y =
          (cos(seed * 1.5) * 0.5 + 0.5) * size.height +
          (20 * sin(particleProgress * 3 * pi));

      paint.color = colors[i % colors.length].withValues(
        alpha: 0.3 + 0.4 * sin(particleProgress * pi),
      );

      // Draw glowing particle
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced Sparkle Painter for Splash Screen
class SparklePainter extends CustomPainter {
  final double progress;
  final int sparkleCount;
  final Random _random = Random(42); // Fixed seed for consistent animation

  SparklePainter({required this.progress, this.sparkleCount = 15});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < sparkleCount; i++) {
      // Use consistent random values
      final angle = (i * 2 * pi / sparkleCount) + (progress * 2 * pi);
      final distance = 80 + (20 * sin(progress * 2 * pi + i));
      final sparkleSize = 2 + (3 * sin(progress * 4 * pi + i * 0.5));

      final x = center.dx + (distance * cos(angle));
      final y = center.dy + (distance * sin(angle));

      // Use modern theme colors
      final colorIndex = i % ModernTheme.auroraGradient.length;
      paint.color = ModernTheme.auroraGradient[colorIndex].withValues(
        alpha: 0.6 + 0.4 * sin(progress * 2 * pi + i),
      );

      // Draw enhanced sparkle with glow
      final glowPaint = Paint()
        ..color = paint.color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      // Glow effect
      canvas.drawCircle(Offset(x, y), sparkleSize * 2, glowPaint);

      // Main sparkle as a star shape
      final path = Path();
      for (int j = 0; j < 5; j++) {
        final starAngle = (j * 2 * pi / 5) - (pi / 2);
        final radius = j.isEven ? sparkleSize : sparkleSize * 0.5;
        final px = x + radius * cos(starAngle);
        final py = y + radius * sin(starAngle);

        if (j == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
