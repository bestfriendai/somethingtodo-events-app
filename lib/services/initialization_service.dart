import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import 'notification_service.dart';
import 'cache_service.dart';
import 'analytics_service.dart';

class InitializationService {
  static bool _isInitialized = false;

  static Future<void> initializeCoreServices() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase
      await _initializeFirebase();

      // Initialize local storage
      await _initializeLocalStorage();

      // Initialize services
      await _initializeServices();

      // Load remote config
      await _loadRemoteConfig();

      _isInitialized = true;
    } catch (e) {
      print('Initialization error: $e');
      throw InitializationException('Failed to initialize app: $e');
    }
  }

  static Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Initialize Performance Monitoring
    FirebasePerformance performance = FirebasePerformance.instance;
    await performance.setPerformanceCollectionEnabled(true);

    // Initialize Analytics
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(true);
  }

  static Future<void> _initializeLocalStorage() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox('settings');
    await Hive.openBox('cache');
    await Hive.openBox('user_data');

    // Initialize SharedPreferences
    await SharedPreferences.getInstance();
  }

  static Future<void> _initializeServices() async {
    // Initialize notification service
    await NotificationService.instance.initialize();

    // Initialize location service
    // LocationService doesn't have an initialize method, it's ready to use

    // Initialize cache service
    await CacheService.instance.initialize();

    // Initialize analytics service
    await AnalyticsService.instance.initialize();
  }

  static Future<void> _loadRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await remoteConfig.setDefaults({
      'enable_new_features': false,
      'maintenance_mode': false,
      'min_app_version': '1.0.0',
      'api_base_url': 'https://api.somethingtodo.app',
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Failed to fetch remote config: $e');
    }
  }
}

class InitializationException implements Exception {
  final String message;
  InitializationException(this.message);

  @override
  String toString() => message;
}
