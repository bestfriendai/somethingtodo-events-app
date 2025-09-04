import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:math' as math;

class GlassOnboardingScreen extends StatefulWidget {
  const GlassOnboardingScreen({super.key});

  @override
  State<GlassOnboardingScreen> createState() => _GlassOnboardingScreenState();
}

class _GlassOnboardingScreenState extends State<GlassOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _backgroundController;
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Discover Amazing Events',
      description:
          'Find the best events happening around you with our smart AI-powered recommendations.',
      icon: Icons.explore,
      gradientColors: [Colors.purple, Colors.blue],
    ),
    OnboardingPage(
      title: 'Never Miss Out',
      description:
          'Get personalized notifications about events you\'ll love and never miss great experiences.',
      icon: Icons.notifications_active,
      gradientColors: [Colors.blue, Colors.cyan],
    ),
    OnboardingPage(
      title: 'Connect & Share',
      description:
          'Share your favorite events with friends and discover what\'s happening in your community.',
      icon: Icons.group,
      gradientColors: [Colors.cyan, Colors.teal],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _orb1Controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _orb2Controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _orb3Controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _completeOnboarding() {
    Navigator.pushReplacementNamed(context, '/auth');
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.black, Colors.grey.shade900, Colors.black],
                    stops: [
                      0.0,
                      math.sin(_backgroundController.value * math.pi) * 0.5 +
                          0.5,
                      1.0,
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating orbs
          ..._buildFloatingOrbs(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _skipOnboarding,
                        child: GlassmorphicContainer(
                          width: 80,
                          height: 40,
                          borderRadius: 20,
                          blur: 20,
                          alignment: Alignment.center,
                          border: 1,
                          linearGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                          borderGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.3),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return _buildOnboardingPage(page, index);
                    },
                  ),
                ),

                // Page indicator and navigation
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: GlassmorphicContainer(
                              width: _currentPage == index ? 32 : 8,
                              height: 8,
                              borderRadius: 4,
                              blur: 10,
                              alignment: Alignment.center,
                              border: 0,
                              linearGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _currentPage == index
                                    ? [
                                        _pages[_currentPage].gradientColors[0]
                                            .withValues(alpha: 0.6),
                                        _pages[_currentPage].gradientColors[1]
                                            .withValues(alpha: 0.3),
                                      ]
                                    : [
                                        Colors.white.withValues(alpha: 0.2),
                                        Colors.white.withValues(alpha: 0.1),
                                      ],
                              ),
                              borderGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 32),

                      // Navigation buttons
                      Row(
                        children: [
                          if (_currentPage > 0)
                            Expanded(
                              child: GestureDetector(
                                onTap: _previousPage,
                                child: GlassmorphicContainer(
                                  width: double.infinity,
                                  height: 56,
                                  borderRadius: 28,
                                  blur: 20,
                                  alignment: Alignment.center,
                                  border: 1.5,
                                  linearGradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.1),
                                      Colors.white.withValues(alpha: 0.05),
                                    ],
                                  ),
                                  borderGradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.5),
                                      Colors.white.withValues(alpha: 0.2),
                                    ],
                                  ),
                                  child: const Text(
                                    'Previous',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),

                          const SizedBox(width: 16),

                          Expanded(
                            child: GestureDetector(
                              onTap: _nextPage,
                              child: GlassmorphicContainer(
                                width: double.infinity,
                                height: 56,
                                borderRadius: 28,
                                blur: 20,
                                alignment: Alignment.center,
                                border: 2,
                                linearGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _pages[_currentPage].gradientColors[0]
                                        .withValues(alpha: 0.3),
                                    _pages[_currentPage].gradientColors[1]
                                        .withValues(alpha: 0.2),
                                  ],
                                ),
                                borderGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _pages[_currentPage].gradientColors[0]
                                        .withValues(alpha: 0.8),
                                    _pages[_currentPage].gradientColors[1]
                                        .withValues(alpha: 0.4),
                                  ],
                                ),
                                child: Text(
                                  _currentPage == _pages.length - 1
                                      ? 'Get Started'
                                      : 'Next',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingOrbs() {
    return [
      AnimatedBuilder(
        animation: _orb1Controller,
        builder: (context, child) {
          return Positioned(
            top: 100 + 50 * math.sin(_orb1Controller.value * 2 * math.pi),
            left: 50 + 30 * math.cos(_orb1Controller.value * 2 * math.pi),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.withValues(alpha: 0.3),
                    Colors.purple.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _orb2Controller,
        builder: (context, child) {
          return Positioned(
            bottom: 150 + 40 * math.sin(_orb2Controller.value * 2 * math.pi),
            right: 30 + 50 * math.cos(_orb2Controller.value * 2 * math.pi),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.2),
                    Colors.blue.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _orb3Controller,
        builder: (context, child) {
          return Positioned(
            top:
                MediaQuery.of(context).size.height / 2 +
                60 * math.sin(_orb3Controller.value * 2 * math.pi),
            right: 100 + 40 * math.cos(_orb3Controller.value * 2 * math.pi),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.cyan.withValues(alpha: 0.25),
                    Colors.cyan.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildOnboardingPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glass icon container
          GlassmorphicContainer(
                width: 180,
                height: 180,
                borderRadius: 90,
                blur: 30,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    page.gradientColors[0].withValues(alpha: 0.2),
                    page.gradientColors[1].withValues(alpha: 0.1),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    page.gradientColors[0].withValues(alpha: 0.5),
                    page.gradientColors[1].withValues(alpha: 0.2),
                  ],
                ),
                child: Icon(
                  page.icon,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .shimmer(duration: 2000.ms, delay: 600.ms),

          const SizedBox(height: 48),

          // Title
          Text(
                page.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.3, curve: Curves.easeOutCubic),

          const SizedBox(height: 20),

          // Description in glass container
          GlassmorphicContainer(
                width: double.infinity,
                height: 100,
                borderRadius: 20,
                blur: 20,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Text(
                  page.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              .animate()
              .fadeIn(duration: 1000.ms, delay: 200.ms)
              .slideY(begin: 0.3, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}
