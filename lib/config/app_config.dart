class AppConfig {
  static const String appName = 'SomethingToDo';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const String stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  
   // Backend / Cloud Functions Configuration
   static const String functionsRegion = String.fromEnvironment('FUNCTIONS_REGION', defaultValue: 'us-central1');
   static const bool useFunctionsEmulator = bool.fromEnvironment('USE_FUNCTIONS_EMULATOR', defaultValue: true); // Enable for development
   static const int functionsEmulatorPort = int.fromEnvironment('FUNCTIONS_EMULATOR_PORT', defaultValue: 5001);

   // API Keys (these should be set via environment variables in production)
   static const String rapidApiKey = String.fromEnvironment('RAPIDAPI_KEY', defaultValue: '92bc1b4fc7mshacea9f118bf7a3fp1b5a6cjsnd2287a72fcb9');
   static const String openAIApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: 'demo-key');
  
  // Deep linking
  static const String appScheme = 'somethingtodo';
  static const String universalLinkDomain = 'somethingtodo.app';
  
  // Chat Configuration
  static const int maxChatHistory = 50;
  static const int chatTimeoutSeconds = 30;
  
  // Event Configuration
  static const int eventsPerPage = 20;
  static const double defaultSearchRadius = 50.0; // kilometers
  static const int maxImageUploads = 5;
  
  // Premium Configuration
  static const String premiumProductId = 'premium_monthly';
  static const String premiumAnnualProductId = 'premium_annual';
  
  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100; // MB
  
  // Location Configuration
  static const double locationAccuracy = 100.0; // meters
  static const Duration locationUpdateInterval = Duration(minutes: 5);
  
  // Push Notification Topics
  static const String generalTopic = 'general';
  static const String eventsNearbyTopic = 'events_nearby';
  static const String favoriteCategoriesTopic = 'favorite_categories';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxEventTitleLength = 100;
  static const int maxEventDescriptionLength = 1000;
  
  // Analytics
  static const bool analyticsEnabled = true;
  static const bool crashReportingEnabled = true;
  
   // Environment specific configurations
   static bool get isProduction => const bool.fromEnvironment('PRODUCTION', defaultValue: false);
   static bool get isDevelopment => !isProduction;
   static const bool demoMode = false; // Always use real data
  
  // URLs
  static const String termsOfServiceUrl = 'https://somethingtodo.app/terms';
  static const String privacyPolicyUrl = 'https://somethingtodo.app/privacy';
  static const String supportUrl = 'https://somethingtodo.app/support';
  static const String websiteUrl = 'https://somethingtodo.app';
}