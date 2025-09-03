import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'dart:ui';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Add haptic feedback for premium feel
    HapticFeedback.mediumImpact();

    // Simulate app initialization
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Reduced from 3 to 2 seconds

    if (mounted) {
      setState(() => _isLoading = false);

      // Navigate after animation completes
      await Future.delayed(const Duration(milliseconds: 500)); // Reduced delay
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/auth',
        ); // Skip onboarding, go directly to auth
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.cos(_rotationController.value * 2 * math.pi),
                      math.sin(_rotationController.value * 2 * math.pi),
                    ),
                    end: Alignment(
                      -math.cos(_rotationController.value * 2 * math.pi),
                      -math.sin(_rotationController.value * 2 * math.pi),
                    ),
                    colors: const [
                      Color(0xFF374151),
                      Color(0xFF4B5563),
                      Color(0xFF6B7280),
                      Color(0xFF64748B),
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              );
            },
          ),

          // Floating particles
          ...List.generate(15, (index) => _buildParticle(index)),

          // Glassmorphic overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.1);
                    return Transform.scale(
                      scale: scale,
                      child:
                          Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF9333EA),
                                      Color(0xFFEC4899),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF9333EA,
                                      ).withValues(alpha: 0.5),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.explore_rounded,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 1000.ms)
                              .scale(
                                begin: const Offset(0.5, 0.5),
                                end: const Offset(1, 1),
                                duration: 1000.ms,
                                curve: Curves.elasticOut,
                              ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // App name
                Text(
                      'SomethingToDo',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                    )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 1000.ms)
                    .slideY(
                      begin: 0.5,
                      end: 0,
                      duration: 1000.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 8),

                // Tagline
                Text(
                      'Discover Amazing Events',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 1000.ms)
                    .slideY(
                      begin: 0.5,
                      end: 0,
                      duration: 1000.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 60),

                // Loading indicator
                if (_isLoading)
                  Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 500.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                      )
                else
                  const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 50,
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),
              ],
            ),
          ),

          // Bottom text
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              'Made with ❤️ in Flutter',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ).animate().fadeIn(delay: 1500.ms, duration: 1000.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = math.Random(index);
    final size = random.nextDouble() * 4 + 2;
    final initialX = random.nextDouble();
    final initialY = random.nextDouble();

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = _particleController.value;
        final y = (initialY + progress) % 1.0;
        final opacity = math.sin(progress * math.pi * 2 + index) * 0.5 + 0.5;

        return Positioned(
          left: initialX * MediaQuery.of(context).size.width,
          top: y * MediaQuery.of(context).size.height,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: opacity * 0.6),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: opacity * 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
