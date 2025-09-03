/// API Configuration for the SomethingToDo app
///
/// IMPORTANT: RapidAPI keys must never be shipped in the client. All traffic is
/// routed through Firebase Functions (see FunctionsConfig).
class ApiConfig {
  // Deprecated: client-side RapidAPI access (kept for backward compatibility)
  static const String rapidApiKey = 'YOUR_RAPIDAPI_KEY_HERE';

  // Demo mode still supported when backend is unavailable
  static const bool useDemoMode = false;

  // Deprecated: RapidAPI host/base (no longer used directly by the app)
  static const String rapidApiHost = 'real-time-events-search.p.rapidapi.com';
  static const String rapidApiBaseUrl =
      'https://real-time-events-search.p.rapidapi.com';

  /// Treat RapidAPI as not configured on client to prevent direct calls
  static bool get isApiConfigured => false;

  /// Deprecated API key getter
  static String get apiKey {
    // Always return empty to avoid accidental client-side usage
    return '';
  }
}
