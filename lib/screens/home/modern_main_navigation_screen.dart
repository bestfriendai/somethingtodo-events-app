import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/modern/modern_bottom_nav.dart';
import '../../widgets/modern/modern_fab.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/cache_service.dart';
import '../../services/platform_interactions.dart';
import '../../services/delight_service.dart';
import '../../services/shake_detector.dart';
import '../../config/modern_theme.dart';
import 'modern_home_screen.dart';
import '../map/map_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/glass_profile_screen.dart';
import '../favorites/favorites_screen.dart';

class ModernMainNavigationScreen extends StatefulWidget {
  const ModernMainNavigationScreen({super.key});

  @override
  State<ModernMainNavigationScreen> createState() =>
      _ModernMainNavigationScreenState();
}

class _ModernMainNavigationScreenState extends State<ModernMainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _screens = [
      const ModernHomeScreen(),
      const MapScreen(),
      const ChatScreen(),
      const FavoritesScreen(),
      const GlassProfileScreen(),
    ];

    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
      _fabAnimationController.forward();

      // Initialize delight services
      DelightService.instance.initialize();
      ShakeDetector.instance.startListening(context);
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    ShakeDetector.instance.stopListening();
    super.dispose();
  }

  Future<void> _initializeProviders() async {
    try {
      print('Initializing providers...');
      // Initialize cache service first
      await CacheService.instance.initialize();

      final authProvider = context.read<AuthProvider>();
      final eventsProvider = context.read<EventsProvider>();
      final chatProvider = context.read<ChatProvider>();

      print('Auth status in home: ${authProvider.isAuthenticated}');
      if (authProvider.isAuthenticated) {
        final isDemoMode = authProvider.isDemoMode;
        print('Demo mode: $isDemoMode');

        // Initialize events provider with demo mode
        await eventsProvider.initialize(demoMode: isDemoMode);

        // Initialize chat provider with demo mode
        await chatProvider.initialize(
          authProvider.currentUser!.id,
          demoMode: isDemoMode,
        );

        // Set demo mode in Firestore service
        if (isDemoMode) {
          FirestoreService().setDemoMode(true);
        }
      }
    } catch (e) {
      print('Error initializing providers: $e');
    }
  }

  void _onNavTap(int index) {
    PlatformInteractions.lightImpact();

    // Add delightful tab switching celebration
    if (index != _currentIndex) {
      DelightService.instance.showMiniCelebration(context, _getTabEmoji(index));

      // Special celebration for favorites tab
      if (index == 3) {
        DelightService.instance.showHeartExplosion(
          context,
          const Offset(200, 300),
        );
      }

      // Chat tab gets a sparkle effect
      if (index == 2) {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          DelightService.instance.showSparkleEffect(
            context,
            Offset(
              position.dx + renderBox.size.width / 2,
              position.dy + renderBox.size.height - 100,
            ),
          );
        }
      }
    }

    setState(() {
      _currentIndex = index;
    });

    // Animate FAB based on screen
    if (index == 0) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  void _startNewChat() {
    PlatformInteractions.mediumImpact();

    // Celebration for starting a new chat
    DelightService.instance.showConfetti(
      context,
      customMessage: 'Ready to chat! Let\'s find you something amazing! 💬✨',
    );

    setState(() {
      _currentIndex = 2; // Switch to chat tab
    });
    // The chat screen will handle creating a new session
  }

  void _showSpeedDial() {
    PlatformInteractions.lightImpact();

    // Show sparkle effect when speed dial opens
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      DelightService.instance.showSparkleEffect(
        context,
        Offset(
          position.dx + renderBox.size.width / 2,
          position.dy + renderBox.size.height - 120,
        ),
      );
    }

    // TODO: Implement speed dial actions
  }

  String _getTabEmoji(int index) {
    switch (index) {
      case 0:
        return '🏠'; // Home
      case 1:
        return '🗺️'; // Map
      case 2:
        return '💬'; // Chat
      case 3:
        return '❤️'; // Favorites
      case 4:
        return '👤'; // Profile
      default:
        return '✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: const Color(
            0xFF0A0A0B,
          ), // Rich black like Arc Browser
          extendBody: true,
          body: Stack(
            children: [
              // Subtle background gradient for depth
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0A0A0B),
                      const Color(0xFF111111).withValues(alpha: 0.8),
                      const Color(0xFF0A0A0B),
                    ],
                  ),
                ),
              ),

              // Demo mode banner
              if (authProvider.isDemoMode) _buildDemoModeBanner(),

              // Main content with proper padding for banner
              Positioned.fill(
                top: authProvider.isDemoMode ? 50 : 0,
                child: IndexedStack(index: _currentIndex, children: _screens),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
          floatingActionButton: _buildFloatingActionButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildDemoModeBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: ModernTheme.warningGradient),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Demo Mode • Explore with sample data',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    PlatformInteractions.lightImpact();
                    DelightService.instance.showMiniCelebration(context, '💭');
                    showDialog(
                      context: context,
                      builder: (context) => _buildDemoInfoDialog(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoInfoDialog() {
    return AlertDialog(
      backgroundColor: ModernTheme.darkCardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: ModernTheme.warningGradient,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.explore_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Demo Mode',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Text(
        'You\'re exploring the app with sample data. All features work normally, but nothing is saved to the cloud.\n\n'
        '✨ What you can do:\n'
        '• Browse 20+ sample events\n'
        '• Search and filter events\n'
        '• Add/remove favorites locally\n'
        '• Chat with AI assistant\n'
        '• View event details and maps\n\n'
        '🚀 Create an account to save your data and access real events!',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Got it',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            DelightService.instance.showConfetti(
              context,
              customMessage:
                  'Welcome to the journey! Let\'s get you set up! 🚀',
            );
            Navigator.of(context).pop();
            context.read<AuthProvider>().signOut();
            Navigator.pushReplacementNamed(context, '/auth');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ModernTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Create Account'),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final unreadCount = chatProvider.getUnreadRecommendationCount();

        return ModernBottomNavigation(
          currentIndex: _currentIndex,
          unreadCount: unreadCount,
          onTap: _onNavTap,
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    // Show different FABs based on screen and user status
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        if (_currentIndex != 0) return const SizedBox.shrink();

        return Transform.scale(
          scale: _fabAnimationController.value,
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (!authProvider.isPremiumActive) {
                return ModernFloatingActionButton.extended(
                  onPressed: () {
                    PlatformInteractions.mediumImpact();
                    DelightService.instance.showConfetti(
                      context,
                      customMessage:
                          'Ready for premium features? Let\'s unlock the magic! ✨🎆',
                    );
                    Navigator.pushNamed(context, '/premium');
                  },
                  icon: Icons.star_rounded,
                  label: 'Upgrade',
                  gradient: ModernTheme.sunsetGradient,
                  tooltip: 'Upgrade to Premium',
                );
              }

              // Premium users get speed dial
              return ModernSpeedDial(
                gradient: ModernTheme.purpleGradient,
                tooltip: 'Quick Actions',
                onPressed: _showSpeedDial,
                actions: [
                  ModernSpeedDialAction(
                    icon: Icons.add_rounded,
                    label: 'Create Event',
                    gradient: ModernTheme.forestGradient,
                    onPressed: () {
                      PlatformInteractions.mediumImpact();
                      DelightService.instance.showConfetti(
                        context,
                        customMessage: 'Time to create something awesome! 🎉',
                      );
                      // TODO: Implement create event
                    },
                  ),
                  ModernSpeedDialAction(
                    icon: Icons.chat_rounded,
                    label: 'New Chat',
                    gradient: ModernTheme.neonGradient,
                    onPressed: _startNewChat,
                  ),
                  ModernSpeedDialAction(
                    icon: Icons.search_rounded,
                    label: 'Search',
                    gradient: ModernTheme.pinkGradient,
                    onPressed: () {
                      PlatformInteractions.lightImpact();
                      DelightService.instance.showMiniCelebration(
                        context,
                        '🔍',
                      );
                      Navigator.pushNamed(context, '/search');
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
