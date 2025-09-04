import 'package:flutter/foundation.dart';

/// Application configuration constants
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // App Information
  static const String appName = 'SomethingToDo';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Environment
  static const bool isProduction = kReleaseMode;
  static const bool isDevelopment = kDebugMode;

  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.somethingtodo.app',
  );

  // Firebase Configuration
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'somethingtodo-events',
  );

  // API Keys (should be set via environment variables)
  static const String rapidApiKey = String.fromEnvironment(
    'RAPIDAPI_KEY',
    defaultValue: '', // API keys are handled by Firebase Functions
  );
  static const String openAIApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '', // API keys should be set via environment variables
  );

  // Deep linking
  static const String appScheme = 'somethingtodo';
  static const String appHost = 'app.somethingtodo.com';

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Performance Configuration
  static const int maxConcurrentRequests = 5;
  static const Duration requestTimeout = Duration(seconds: 30);

  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const int animationDurationMs = 300;

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableOfflineMode = true;

  // Mapbox Configuration
  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: '',
  );

  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Development Configuration
  static const bool enableDebugMode = kDebugMode;
  static const bool enableLogging = kDebugMode;
  static const bool enableNetworkLogging = kDebugMode;

  // Security Configuration
  static const bool enableCertificatePinning = kReleaseMode;
  static const bool enableObfuscation = kReleaseMode;

  // Validation helpers
  static bool get hasValidRapidApiKey => rapidApiKey.isNotEmpty;
  static bool get hasValidOpenAIApiKey => openAIApiKey.isNotEmpty;
  static bool get hasValidMapboxToken => mapboxAccessToken.isNotEmpty;
  static bool get hasValidSupabaseConfig => 
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // Environment detection
  static bool get isConfigured => 
      hasValidRapidApiKey || hasValidOpenAIApiKey || hasValidMapboxToken;

  // Debug information
  static Map<String, dynamic> get debugInfo => {
    'appName': appName,
    'appVersion': appVersion,
    'buildNumber': buildNumber,
    'isProduction': isProduction,
    'isDevelopment': isDevelopment,
    'baseUrl': baseUrl,
    'hasValidRapidApiKey': hasValidRapidApiKey,
    'hasValidOpenAIApiKey': hasValidOpenAIApiKey,
    'hasValidMapboxToken': hasValidMapboxToken,
    'hasValidSupabaseConfig': hasValidSupabaseConfig,
    'isConfigured': isConfigured,
  };
}
