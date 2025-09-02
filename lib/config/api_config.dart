/// API Configuration for the SomethingToDo app
/// 
/// IMPORTANT: For production, use environment variables or secure key management.
/// Never commit real API keys to version control.
class ApiConfig {
  // For development/testing only - Replace with your actual API key
  // Get your free API key from: https://rapidapi.com/real-time-events-search/api/real-time-events-search
  static const String rapidApiKey = 'YOUR_RAPIDAPI_KEY_HERE';
  
  // Set to true to use demo data instead of real API calls
  static const bool useDemoMode = true;
  
  // API endpoints
  static const String rapidApiHost = 'real-time-events-search.p.rapidapi.com';
  static const String rapidApiBaseUrl = 'https://real-time-events-search.p.rapidapi.com';
  
  /// Check if API is configured
  static bool get isApiConfigured => rapidApiKey != 'YOUR_RAPIDAPI_KEY_HERE' && rapidApiKey.isNotEmpty;
  
  /// Get the API key (with fallback to environment variable)
  static String get apiKey {
    // Try environment variable first
    const envKey = String.fromEnvironment('RAPIDAPI_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;
    
    // Fall back to hardcoded key for development
    if (rapidApiKey != 'YOUR_RAPIDAPI_KEY_HERE') return rapidApiKey;
    
    // Return empty if not configured
    return '';
  }
}