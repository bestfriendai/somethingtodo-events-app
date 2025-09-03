import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/demo_data_service.dart';
import 'auth_provider.dart';

class DemoModeProvider extends ChangeNotifier {
  final AuthProvider? _authProvider;
  final Random _random = Random();

  // Demo state
  bool _isDemoModeActive = false;
  bool _showDemoIndicators = true;
  bool _simulateRealTimeUpdates = true;

  // Demo data
  List<DemoUser> _demoUsers = [];
  List<ActivityFeedItem> _activityFeed = [];
  List<DemoNotification> _notifications = [];
  final Map<String, List<EventInteractionData>> _eventInteractions = {};

  // Real-time simulation
  Timer? _activitySimulationTimer;
  Timer? _notificationTimer;
  Timer? _interactionTimer;

  // Demo analytics
  int _demoSessionDuration = 0;
  int _eventsViewed = 0;
  int _interactionsSimulated = 0;
  DateTime? _demoStartTime;

  DemoModeProvider({AuthProvider? authProvider})
    : _authProvider = authProvider {
    if (_authProvider != null) {
      _authProvider.addListener(_onAuthStateChanged);
    }
    _initializeDemoData();
  }

  // Getters
  bool get isDemoModeActive => _isDemoModeActive;
  bool get showDemoIndicators => _showDemoIndicators;
  bool get simulateRealTimeUpdates => _simulateRealTimeUpdates;
  List<DemoUser> get demoUsers => _demoUsers;
  List<ActivityFeedItem> get activityFeed => _activityFeed;
  List<DemoNotification> get notifications => _notifications;
  int get demoSessionDuration => _demoSessionDuration;
  int get eventsViewed => _eventsViewed;
  int get interactionsSimulated => _interactionsSimulated;
  DateTime? get demoStartTime => _demoStartTime;

  // Demo mode management
  void enableDemoMode({
    bool showIndicators = true,
    bool simulateUpdates = true,
  }) {
    _isDemoModeActive = true;
    _showDemoIndicators = showIndicators;
    _simulateRealTimeUpdates = simulateUpdates;
    _demoStartTime = DateTime.now();

    _initializeDemoData();

    if (_simulateRealTimeUpdates) {
      _startRealTimeSimulation();
    }

    notifyListeners();
  }

  void disableDemoMode() {
    _isDemoModeActive = false;
    _stopRealTimeSimulation();
    _resetDemoAnalytics();
    notifyListeners();
  }

  void toggleDemoIndicators() {
    _showDemoIndicators = !_showDemoIndicators;
    notifyListeners();
  }

  void toggleRealTimeSimulation() {
    _simulateRealTimeUpdates = !_simulateRealTimeUpdates;

    if (_simulateRealTimeUpdates && _isDemoModeActive) {
      _startRealTimeSimulation();
    } else {
      _stopRealTimeSimulation();
    }

    notifyListeners();
  }

  // Demo data initialization
  void _initializeDemoData() {
    _demoUsers = DemoDataService.getDemoUsers();
    _activityFeed = DemoDataService.generateActivityFeed();
    _notifications = DemoDataService.generateDemoNotifications();
    _generateEventInteractions();
  }

  void _generateEventInteractions() {
    _eventInteractions.clear();

    // Generate interactions for demo events (demo_1 to demo_7)
    for (int i = 1; i <= 7; i++) {
      final eventId = 'demo_$i';
      final interactions = <EventInteractionData>[];

      // Generate interactions from random demo users
      final numInteractions =
          _random.nextInt(5) + 2; // 2-6 interactions per event
      final selectedUsers = _demoUsers.toList()..shuffle(_random);

      for (int j = 0; j < numInteractions && j < selectedUsers.length; j++) {
        final interaction = DemoDataService.simulateEventInteraction(
          eventId,
          selectedUsers[j],
        );
        interactions.add(interaction);
      }

      _eventInteractions[eventId] = interactions;
    }
  }

  // Real-time simulation
  void _startRealTimeSimulation() {
    _stopRealTimeSimulation(); // Clear any existing timers

    // Simulate new activity every 30-60 seconds
    _activitySimulationTimer = Timer.periodic(
      Duration(seconds: 30 + _random.nextInt(30)),
      (_) => _simulateNewActivity(),
    );

    // Simulate new notifications every 2-5 minutes
    _notificationTimer = Timer.periodic(
      Duration(minutes: 2 + _random.nextInt(3)),
      (_) => _simulateNewNotification(),
    );

    // Simulate event interactions every 1-3 minutes
    _interactionTimer = Timer.periodic(
      Duration(minutes: 1 + _random.nextInt(2)),
      (_) => _simulateEventInteraction(),
    );
  }

  void _stopRealTimeSimulation() {
    _activitySimulationTimer?.cancel();
    _notificationTimer?.cancel();
    _interactionTimer?.cancel();
  }

  void _simulateNewActivity() {
    if (!_isDemoModeActive || !_simulateRealTimeUpdates) return;

    final user = _demoUsers[_random.nextInt(_demoUsers.length)];
    final activityType =
        ActivityType.values[_random.nextInt(ActivityType.values.length)];

    final newActivity = ActivityFeedItem(
      id: 'activity_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      userName: user.name,
      userImageUrl: user.profileImageUrl,
      activityType: activityType,
      timestamp: DateTime.now(),
      content: _generateActivityContent(activityType, user),
      eventId: _random.nextBool() ? 'demo_${_random.nextInt(7) + 1}' : null,
    );

    _activityFeed.insert(0, newActivity);

    // Keep only the latest 50 activities
    if (_activityFeed.length > 50) {
      _activityFeed = _activityFeed.take(50).toList();
    }

    _interactionsSimulated++;
    notifyListeners();
  }

  void _simulateNewNotification() {
    if (!_isDemoModeActive || !_simulateRealTimeUpdates) return;

    final notificationMessages = [
      'New event matches your interests!',
      'Someone you follow is attending an event nearby',
      'Price drop on a favorited event',
      'Event starting soon - don\'t miss out!',
      'New photos shared from an event you attended',
      'Weather update for your upcoming event',
    ];

    final newNotification = DemoNotification(
      id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
      title: 'SomethingToDo',
      message:
          notificationMessages[_random.nextInt(notificationMessages.length)],
      timestamp: DateTime.now(),
      isRead: false,
      type: NotificationType
          .values[_random.nextInt(NotificationType.values.length)],
    );

    _notifications.insert(0, newNotification);

    // Keep only the latest 20 notifications
    if (_notifications.length > 20) {
      _notifications = _notifications.take(20).toList();
    }

    notifyListeners();
  }

  void _simulateEventInteraction() {
    if (!_isDemoModeActive || !_simulateRealTimeUpdates) return;

    final eventId = 'demo_${_random.nextInt(7) + 1}';
    final user = _demoUsers[_random.nextInt(_demoUsers.length)];

    final interaction = DemoDataService.simulateEventInteraction(eventId, user);

    _eventInteractions[eventId] ??= [];
    _eventInteractions[eventId]!.add(interaction);

    // Keep only the latest 10 interactions per event
    if (_eventInteractions[eventId]!.length > 10) {
      _eventInteractions[eventId] = _eventInteractions[eventId]!
          .take(10)
          .toList();
    }

    _interactionsSimulated++;
    notifyListeners();
  }

  String _generateActivityContent(ActivityType type, DemoUser user) {
    switch (type) {
      case ActivityType.eventAttended:
        return 'just attended an amazing event!';
      case ActivityType.eventCreated:
        return 'created a new event you might like';
      case ActivityType.eventFavorited:
        return 'favorited an upcoming event';
      case ActivityType.userFollowed:
        return 'started following new organizers';
      case ActivityType.commentPosted:
        return 'shared thoughts on an event';
      case ActivityType.photoShared:
        return 'shared photos from a recent event';
    }
  }

  // Demo analytics and tracking
  void trackEventView(String eventId) {
    if (_isDemoModeActive) {
      _eventsViewed++;
    }
  }

  void _resetDemoAnalytics() {
    _demoSessionDuration = 0;
    _eventsViewed = 0;
    _interactionsSimulated = 0;
    _demoStartTime = null;
  }

  // Event interaction helpers
  List<EventInteractionData> getEventInteractions(String eventId) {
    return _eventInteractions[eventId] ?? [];
  }

  int getEventAttendeeCount(String eventId) {
    final interactions = _eventInteractions[eventId] ?? [];
    return interactions.length; // Simplified for now
  }

  void _onAuthStateChanged() {
    // Handle auth state changes if needed
    if (_authProvider != null &&
        !_authProvider.isAuthenticated &&
        _isDemoModeActive) {
      // Could auto-disable demo mode if user logs out
    }
  }

  @override
  void dispose() {
    _stopRealTimeSimulation();
    _authProvider?.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
