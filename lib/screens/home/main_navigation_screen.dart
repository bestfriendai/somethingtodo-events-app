import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui';
import '../../widgets/glass_bottom_nav.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/firestore_service.dart';
import '../../config/theme.dart';
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
      final isDemoMode = authProvider.isDemoMode;

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
              // Demo mode banner
              if (authProvider.isDemoMode) _buildDemoModeBanner(),

              // Main content
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

  Widget _buildDemoModeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.explore, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Demo Mode - Explore with sample data',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _buildDemoInfoDialog(),
                );
              },
              child: const Text(
                'Info',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoInfoDialog() {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.explore, color: AppTheme.warningColor),
          SizedBox(width: 8),
          Text('Demo Mode'),
        ],
      ),
      content: const Text(
        'You\'re using the app in demo mode with sample data. All features work normally, but no data is saved to the cloud.\n\n'
        'Features available:\n'
        '• Browse 20+ sample events\n'
        '• Search and filter events\n'
        '• Add/remove favorites (locally)\n'
        '• Chat with AI assistant\n'
        '• View event details and maps\n\n'
        'Create an account to save your data and access real events!',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<AuthProvider>().signOut();
            Navigator.pushReplacementNamed(context, '/auth');
          },
          child: const Text('Create Account'),
        ),
      ],
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
                  color: Colors.amber.withOpacity(0.3),
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
                      Colors.amber.withOpacity(0.3),
                      Colors.orange.withOpacity(0.2),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.withOpacity(0.8),
                      Colors.orange.withOpacity(0.4),
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
                color: Colors.purple.withOpacity(0.3),
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
                    Colors.purple.withOpacity(0.3),
                    Colors.blue.withOpacity(0.2),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.8),
                    Colors.blue.withOpacity(0.4),
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
