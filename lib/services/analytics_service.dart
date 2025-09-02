import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();
  
  AnalyticsService._();
  
  late FirebaseAnalytics _analytics;
  late FirebasePerformance _performance;
  late FirebaseCrashlytics _crashlytics;
  
  Future<void> initialize() async {
    _analytics = FirebaseAnalytics.instance;
    _performance = FirebasePerformance.instance;
    _crashlytics = FirebaseCrashlytics.instance;
  }
  
  // Screen tracking
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
      parameters: parameters?.map((key, value) => MapEntry(key, value as Object)),
    );
  }
  
  // Event tracking
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await instance._analytics.logEvent(
      name: name,
      parameters: parameters?.map((key, value) => MapEntry(key, value as Object)),
    );
  }
  
  // User properties
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
  
  // User ID
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }
  
  // Custom events
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }
  
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }
  
  Future<void> logPurchase({
    required double value,
    required String currency,
    String? transactionId,
    List<AnalyticsEventItem>? items,
  }) async {
    await _analytics.logPurchase(
      value: value,
      currency: currency,
      transactionId: transactionId,
      items: items,
    );
  }
  
  static Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await instance._analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }
  
  static Future<void> logSearch(String searchTerm) async {
    await instance._analytics.logSearch(searchTerm: searchTerm);
  }
  
  Future<void> logSelectContent({
    required String contentType,
    required String itemId,
  }) async {
    await _analytics.logSelectContent(
      contentType: contentType,
      itemId: itemId,
    );
  }
  
  // Performance monitoring
  Future<T> trackPerformance<T>({
    required String traceName,
    required Future<T> Function() operation,
    Map<String, String>? attributes,
    Map<String, int>? metrics,
  }) async {
    final Trace trace = _performance.newTrace(traceName);
    
    // Add attributes
    attributes?.forEach((key, value) {
      trace.putAttribute(key, value);
    });
    
    // Add metrics
    metrics?.forEach((key, value) {
      trace.setMetric(key, value);
    });
    
    await trace.start();
    
    try {
      final result = await operation();
      await trace.stop();
      return result;
    } catch (e) {
      trace.putAttribute('error', e.toString());
      await trace.stop();
      rethrow;
    }
  }
  
  // Error tracking
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, String>? information,
  }) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      information: information?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
    );
  }
  
  // Custom crash logs
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
  
  // Set custom keys for crash reports
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }
}