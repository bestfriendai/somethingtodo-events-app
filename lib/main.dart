import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/events_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'services/performance_service.dart';
import 'services/cache_service.dart';
import 'screens/splash/animated_splash_screen.dart';
import 'screens/onboarding/glass_onboarding_screen.dart';
import 'screens/auth/glass_auth_screen.dart';
import 'screens/home/modern_main_navigation_screen.dart';
import 'screens/events/event_details_screen.dart';
import 'screens/events/event_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/profile/glass_profile_screen.dart';
import 'screens/settings/glass_settings_screen.dart';
import 'screens/premium/premium_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/feed/vertical_feed_screen.dart';
import 'screens/settings/theme_settings_screen.dart';
import 'screens/search/enhanced_search_screen.dart';
import 'services/navigation_service.dart';
import 'utils/app_debugger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Crashlytics (only on mobile platforms)
  if (AppConfig.crashReportingEnabled && !kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize cache service
  await CacheService.instance.initialize();

  // Initialize performance service
  PerformanceService.instance.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Optimize system UI for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Enable edge-to-edge on Android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const SomethingToDoApp());
}

class SomethingToDoApp extends StatelessWidget {
  const SomethingToDoApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, child) {
          // Schedule theme update after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final brightness = MediaQuery.platformBrightnessOf(context);
            themeProvider.updateSystemTheme(brightness);
          });

          return DebugOverlay(
            child: MaterialApp(
              title: AppConfig.appName,
              debugShowCheckedModeBanner: false,
              theme: themeProvider.currentTheme,
              themeMode: themeProvider.useSystemTheme
                  ? ThemeMode.system
                  : (themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light),
              navigatorKey: NavigationService.navigatorKey,
              navigatorObservers: [observer],
              home: const AnimatedSplashScreen(),
              routes: _buildRoutes(),
              onGenerateRoute: _generateRoute,
            ),
          );
        },
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/splash': (context) => const AnimatedSplashScreen(),
      '/onboarding': (context) => const GlassOnboardingScreen(),
      '/auth': (context) => const GlassAuthScreen(),
      '/home': (context) => const ModernMainNavigationScreen(),
      '/profile': (context) => const GlassProfileScreen(),
      '/settings': (context) => const GlassSettingsScreen(),
      '/theme-settings': (context) => const ThemeSettingsScreen(),
      '/premium': (context) => const PremiumScreen(),
      '/events': (context) => const EventListScreen(),
      '/map': (context) => const MapScreen(),
      '/favorites': (context) => const FavoritesScreen(),
      '/search': (context) => const SearchScreen(),
      '/enhanced-search': (context) => const EnhancedSearchScreen(),
      '/notifications': (context) => const NotificationsScreen(),
      '/feed': (context) => const VerticalFeedScreen(),
    };
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    // Handle dynamic routes with parameters
    final uri = Uri.parse(settings.name ?? '');

    if (uri.pathSegments.isEmpty) return null;

    switch (uri.pathSegments.first) {
      case 'event':
        if (uri.pathSegments.length > 1) {
          final eventId = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => EventDetailsScreen(eventId: eventId),
            settings: settings,
          );
        }
        break;
      case 'chat':
        if (uri.pathSegments.length > 1) {
          final sessionId = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => ChatScreen(sessionId: sessionId),
            settings: settings,
          );
        }
        break;
    }

    return null;
  }
}

// All screens are now implemented in separate files and imported above
