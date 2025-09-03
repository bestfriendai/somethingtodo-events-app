import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui';
import '../../widgets/glass_bottom_nav.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/chat_provider.dart';

import 'glass_home_screen.dart';
import '../map/map_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/glass_profile_screen.dart';
import '../favorites/favorites_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const GlassHomeScreen(),
      const MapScreen(),
      const ChatScreen(),
      const FavoritesScreen(),
      const GlassProfileScreen(),
    ];

    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    final authProvider = context.read<AuthProvider>();
    final eventsProvider = context.read<EventsProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (authProvider.isAuthenticated) {
      // Always initialize with real API data for all users (including guests)
      await eventsProvider.initialize(demoMode: false);

      // Initialize chat provider with real API data
      await chatProvider.initialize(
        authProvider.currentUser!.id,
        demoMode: false,
      );

      // Start location-based event loading after initialization
      // Always load nearby events for all users
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          eventsProvider.loadNearbyEvents();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          extendBody: true,
          body: Column(
            children: [
              // Main content - All users get real API data
              Expanded(
                child: IndexedStack(index: _currentIndex, children: _screens),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
          floatingActionButton: _currentIndex == 0
              ? _buildFloatingActionButton()
              : null,
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final unreadCount = chatProvider.getUnreadRecommendationCount();

        return GlassBottomNavigation(
          currentIndex: _currentIndex,
          unreadCount: unreadCount,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isPremiumActive) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GlassmorphicContainer(
                  width: 140,
                  height: 56,
                  borderRadius: 30,
                  blur: 20,
                  alignment: Alignment.center,
                  border: 2,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.withValues(alpha: 0.3),
                      Colors.orange.withValues(alpha: 0.2),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.withValues(alpha: 0.8),
                      Colors.orange.withValues(alpha: 0.4),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/premium'),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Upgrade',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: GlassmorphicContainer(
                width: 60,
                height: 60,
                borderRadius: 30,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withValues(alpha: 0.3),
                    Colors.blue.withValues(alpha: 0.2),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withValues(alpha: 0.8),
                    Colors.blue.withValues(alpha: 0.4),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _startNewChat,
                    borderRadius: BorderRadius.circular(30),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _startNewChat() {
    // Navigate to chat screen and create new session
    setState(() {
      _currentIndex = 2; // Switch to chat tab
    });

    // The chat screen will handle creating a new session
  }
}

// All screens are now implemented in separate files and imported above
