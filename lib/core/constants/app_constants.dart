/// Application-wide constants and configuration values
class AppConstants {
  AppConstants._();

  // ============================================================================
  // APP INFO
  // ============================================================================

  static const String appName = 'SomethingToDo';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Discover amazing events near you';

  // ============================================================================
  // API CONFIGURATION
  // ============================================================================

  static const String baseUrl = 'https://api.somethingtodo.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // ============================================================================
  // CACHE CONFIGURATION
  // ============================================================================

  static const String cacheBoxName = 'app_cache';
  static const Duration cacheValidDuration = Duration(hours: 1);
  static const int maxCacheSize = 100; // MB

  // ============================================================================
  // PAGINATION
  // ============================================================================

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ============================================================================
  // UI CONSTRAINTS
  // ============================================================================

  static const double minTouchTargetSize = 44.0;
  static const double maxContentWidth = 600.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1200.0;

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  static const int defaultAnimationMs = 300;
  static const int quickAnimationMs = 150;
  static const int slowAnimationMs = 600;

  // ============================================================================
  // VALIDATION RULES
  // ============================================================================

  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // ============================================================================
  // STORAGE KEYS
  // ============================================================================

  static const String themeKey = 'theme_mode';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';
  static const String languageKey = 'app_language';

  // ============================================================================
  // REGEX PATTERNS
  // ============================================================================

  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static final RegExp phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');

  // ============================================================================
  // ERROR MESSAGES
  // ============================================================================

  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String serverError = 'Server error. Please try again later.';

  // ============================================================================
  // ROUTE NAMES
  // ============================================================================

  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String authRoute = '/auth';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String eventDetailsRoute = '/event/:id';

  // ============================================================================
  // ASSET PATHS
  // ============================================================================

  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String animationsPath = 'assets/animations/';

  // ============================================================================
  // DATE FORMATS
  // ============================================================================

  static const String shortDateFormat = 'MMM d';
  static const String longDateFormat = 'MMMM d, yyyy';
  static const String timeFormat = 'h:mm a';
  static const String dateTimeFormat = 'MMM d, yyyy • h:mm a';
}
