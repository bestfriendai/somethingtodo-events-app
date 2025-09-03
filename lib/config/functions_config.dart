import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import '../firebase_options.dart';
import 'app_config.dart';

/// Central configuration for Firebase Functions base URLs.
class FunctionsConfig {
  FunctionsConfig._();

  /// Resolve the Firebase project ID for the current platform
  static String get projectId {
    if (kIsWeb) return DefaultFirebaseOptions.web.projectId;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return DefaultFirebaseOptions.android.projectId;
      case TargetPlatform.iOS:
        return DefaultFirebaseOptions.ios.projectId;
      default:
        // Fallback to web projectId for other targets if needed
        return DefaultFirebaseOptions.web.projectId;
    }
  }

  /// Base URL for Functions (emulator vs deployed)
  static String get baseUrl {
    if (AppConfig.useFunctionsEmulator) {
      final host = (kIsWeb ? 'localhost' : '10.0.2.2');
      // For iOS simulator, localhost works; for Android emulator, use 10.0.2.2
      final platformHost = defaultTargetPlatform == TargetPlatform.iOS ? 'localhost' : host;
      return 'http://$platformHost:${AppConfig.functionsEmulatorPort}/$projectId/${AppConfig.functionsRegion}/api';
    }
    return 'https://${AppConfig.functionsRegion}-$projectId.cloudfunctions.net/api';
  }
}

