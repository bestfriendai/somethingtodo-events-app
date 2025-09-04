import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'platform_interactions.dart';
import 'navigation_service.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();

      _isInitialized = true;
      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  Future<void> _requestPermissions() async {
    // Request notification permissions
    final notificationSettings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Request additional permissions
    await Permission.notification.request();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is opened from terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Get initial message if app was opened from a notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');

    // Show in-app notification with custom UI
    _showInAppNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    _handleNotificationPayload(message.data.toString());
  }

  void _handleNotificationPayload(String payload) {
    try {
      // Parse payload and navigate accordingly
      print('Handling notification payload: $payload');

      // Example navigation based on payload
      if (payload.contains('event_id')) {
        final eventId = _extractEventId(payload);
        if (eventId != null) {
          NavigationService.pushNamed('/event/$eventId');
        }
      } else if (payload.contains('feed')) {
        NavigationService.pushNamed('/feed');
      }
    } catch (e) {
      print('Error handling notification payload: $e');
    }
  }

  String? _extractEventId(String payload) {
    // Extract event ID from payload
    final regex = RegExp(r'event_id.*?([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(payload);
    return match?.group(1);
  }

  // Show custom in-app notification
  void _showInAppNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    PlatformInteractions.showToast(
      context: context,
      message: '$title: $body',
      icon: Icons.notifications_active,
      duration: const Duration(seconds: 4),
    );
  }

  // Event-specific notifications
  Future<void> notifyEventLiked({
    required String eventTitle,
    required String userName,
  }) async {
    showInstantNotification(
      title: 'Event Liked!',
      body: '$userName liked "$eventTitle"',
      channelId: 'social_notifications',
      channelName: 'Social Notifications',
    );
  }

  Future<void> notifyEventShared({required String eventTitle}) async {
    showInstantNotification(
      title: 'Event Shared!',
      body: 'You shared "$eventTitle"',
      channelId: 'social_notifications',
      channelName: 'Social Notifications',
    );
  }

  // Show immediate notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    String? channelId,
    String? channelName,
  }) async {
    try {
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId ?? 'instant_notifications',
            channelName ?? 'Instant Notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF6366F1),
          ),
          iOS: const DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      print('Error showing instant notification: $e');
    }
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');

  // Handle background message
  if (message.notification != null) {
    print('Background notification: ${message.notification!.title}');
  }
}
