import 'dart:math';
import '../models/event.dart';
import '../models/user.dart';

class DemoDataService {
  static final Random _random = Random();
  static List<DemoUser>? _cachedUsers;
  static Map<String, List<String>>? _cachedInteractions;

  /// Generate realistic demo user profiles
  static List<DemoUser> getDemoUsers() {
    if (_cachedUsers != null) {
      return _cachedUsers!;
    }

    _cachedUsers = [
      DemoUser(
        id: 'demo_user_1',
        name: 'Sarah Chen',
        email: 'sarah.chen@email.com',
        profileImageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face',
        bio: 'Tech enthusiast and music lover. Always looking for the next great concert or innovation conference.',
        location: 'San Francisco, CA',
        interests: ['technology', 'music', 'innovation', 'networking'],
        preferredCategories: [EventCategory.technology, EventCategory.music],
        joinedDate: DateTime.now().subtract(const Duration(days: 365)),
        eventsAttended: 47,
        eventsCreated: 3,
        followers: 234,
        following: 189,
        isVerified: true,
        activityLevel: ActivityLevel.high,
        personalityTraits: {
          'adventurous': 0.8,
          'social': 0.9,
          'tech_savvy': 0.95,
          'budget_conscious': 0.3,
        },
      ),
      
      DemoUser(
        id: 'demo_user_2',
        name: 'Marcus Rodriguez',
        email: 'marcus.r@email.com',
        profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
        bio: 'Foodie and sports fan. Love discovering new restaurants and cheering for my favorite teams.',
        location: 'Los Angeles, CA',
        interests: ['food', 'sports', 'restaurants', 'local events'],
        preferredCategories: [EventCategory.food, EventCategory.sports],
        joinedDate: DateTime.now().subtract(const Duration(days: 180)),
        eventsAttended: 23,
        eventsCreated: 1,
        followers: 89,
        following: 156,
        isVerified: false,
        activityLevel: ActivityLevel.medium,
        personalityTraits: {
          'adventurous': 0.6,
          'social': 0.7,
          'tech_savvy': 0.4,
          'budget_conscious': 0.6,
        },
      ),
      
      DemoUser(
        id: 'demo_user_3',
        name: 'Emma Thompson',
        email: 'emma.thompson@email.com',
        profileImageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
        bio: 'Art curator and culture enthusiast. Passionate about supporting local artists and creative communities.',
        location: 'Portland, OR',
        interests: ['arts', 'culture', 'exhibitions', 'community'],
        preferredCategories: [EventCategory.arts, EventCategory.community],
        joinedDate: DateTime.now().subtract(const Duration(days: 420)),
        eventsAttended: 67,
        eventsCreated: 8,
        followers: 445,
        following: 234,
        isVerified: true,
        activityLevel: ActivityLevel.high,
        personalityTraits: {
          'adventurous': 0.7,
          'social': 0.8,
          'tech_savvy': 0.6,
          'budget_conscious': 0.4,
        },
      ),
      
      DemoUser(
        id: 'demo_user_4',
        name: 'David Kim',
        email: 'david.kim@email.com',
        profileImageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
        bio: 'Fitness enthusiast and outdoor adventurer. Always up for a challenge and meeting new people.',
        location: 'Seattle, WA',
        interests: ['fitness', 'outdoor', 'sports', 'health'],
        preferredCategories: [EventCategory.sports, EventCategory.health],
        joinedDate: DateTime.now().subtract(const Duration(days: 90)),
        eventsAttended: 15,
        eventsCreated: 0,
        followers: 67,
        following: 89,
        isVerified: false,
        activityLevel: ActivityLevel.medium,
        personalityTraits: {
          'adventurous': 0.9,
          'social': 0.6,
          'tech_savvy': 0.5,
          'budget_conscious': 0.7,
        },
      ),
      
      DemoUser(
        id: 'demo_user_5',
        name: 'Lisa Wang',
        email: 'lisa.wang@email.com',
        profileImageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop&crop=face',
        bio: 'Business professional and networking expert. Love connecting people and discovering new opportunities.',
        location: 'San Jose, CA',
        interests: ['business', 'networking', 'professional development', 'startups'],
        preferredCategories: [EventCategory.business, EventCategory.technology],
        joinedDate: DateTime.now().subtract(const Duration(days: 300)),
        eventsAttended: 89,
        eventsCreated: 12,
        followers: 567,
        following: 345,
        isVerified: true,
        activityLevel: ActivityLevel.high,
        personalityTraits: {
          'adventurous': 0.5,
          'social': 0.95,
          'tech_savvy': 0.8,
          'budget_conscious': 0.2,
        },
      ),
    ];

    return _cachedUsers!;
  }

  /// Generate realistic user interactions and comments
  static Map<String, List<String>> getDemoInteractions() {
    if (_cachedInteractions != null) {
      return _cachedInteractions!;
    }

    _cachedInteractions = {
      'demo_1': [ // Summer Jazz Festival
        'Can\'t wait for this! The lineup looks amazing 🎷',
        'Been to this venue before, the acoustics are incredible',
        'Anyone know if there will be food trucks?',
        'Perfect way to spend a summer evening!',
        'The VIP tickets are worth it for the better view',
      ],
      'demo_2': [ // Rock the Night Concert
        'These bands are going to be EPIC! 🤘',
        'Got my tickets! Who else is going?',
        'The Music Hall has such great energy for rock shows',
        'This is going to be loud and amazing!',
        'Perfect date night activity',
      ],
      'demo_3': [ // Street Food Festival
        'Free entry is the best! More money for food 😋',
        'The Korean BBQ truck is a must-try',
        'Great family event, kids will love it',
        'Waterfront location makes it even better',
        'I gained 5 pounds last year but it was worth it!',
      ],
      'demo_4': [ // Wine Tasting Evening
        'Educational and delicious, perfect combination',
        'The sommelier really knows their stuff',
        'Intimate setting makes for great conversations',
        'Worth every penny for wine lovers',
        'Book early, this always sells out',
      ],
      'demo_5': [ // Community Marathon
        'Training starts now! Who\'s joining me?',
        'The 5K is perfect for beginners',
        'Love that everyone gets a medal',
        'Great cause and great exercise',
        'The route through downtown is beautiful',
      ],
      'demo_6': [ // Modern Art Exhibition
        'The interactive installations are mind-blowing',
        'Perfect for art lovers and curious minds',
        'Guided tours are definitely worth it',
        'Some pieces really make you think',
        'Great date activity that sparks conversation',
      ],
      'demo_7': [ // Tech Innovation Summit
        'Networking opportunities are incredible here',
        'The startup showcase is always inspiring',
        'Worth the investment for career growth',
        'Keynote speakers are industry legends',
        'Bring business cards and an open mind!',
      ],
    };

    return _cachedInteractions!;
  }

  /// Simulate realistic user behavior for event interactions
  static EventInteractionData simulateEventInteraction(String eventId, DemoUser user) {
    final interactions = getDemoInteractions();
    final eventComments = interactions[eventId] ?? [];
    
    // Determine if user would be interested based on their preferences
    final interestScore = _calculateUserInterestScore(eventId, user);
    
    return EventInteractionData(
      userId: user.id,
      eventId: eventId,
      isInterested: interestScore > 0.6,
      isFavorited: interestScore > 0.8,
      willAttend: interestScore > 0.7 && _random.nextDouble() > 0.3,
      hasCommented: interestScore > 0.5 && _random.nextDouble() > 0.6,
      comment: eventComments.isNotEmpty && _random.nextBool() 
          ? eventComments[_random.nextInt(eventComments.length)]
          : null,
      interactionTimestamp: DateTime.now().subtract(
        Duration(minutes: _random.nextInt(1440)), // Within last 24 hours
      ),
      engagementLevel: _mapInterestToEngagement(interestScore),
    );
  }

  /// Calculate how interested a user would be in an event
  static double _calculateUserInterestScore(String eventId, DemoUser user) {
    // Base interest from personality traits
    double score = 0.5;
    
    // Adjust based on user's activity level
    switch (user.activityLevel) {
      case ActivityLevel.high:
        score += 0.2;
        break;
      case ActivityLevel.medium:
        score += 0.1;
        break;
      case ActivityLevel.low:
        score -= 0.1;
        break;
    }
    
    // Adjust based on personality traits
    score += (user.personalityTraits['adventurous'] ?? 0.5) * 0.2;
    score += (user.personalityTraits['social'] ?? 0.5) * 0.15;
    
    // Add some randomness for realistic behavior
    score += (_random.nextDouble() - 0.5) * 0.3;
    
    return score.clamp(0.0, 1.0);
  }

  /// Map interest score to engagement level
  static EngagementLevel _mapInterestToEngagement(double interestScore) {
    if (interestScore > 0.8) return EngagementLevel.high;
    if (interestScore > 0.6) return EngagementLevel.medium;
    return EngagementLevel.low;
  }

  /// Generate realistic activity feed for demo mode
  static List<ActivityFeedItem> generateActivityFeed() {
    final users = getDemoUsers();
    final activities = <ActivityFeedItem>[];
    final now = DateTime.now();

    // Generate various types of activities
    for (int i = 0; i < 20; i++) {
      final user = users[_random.nextInt(users.length)];
      final activityType = ActivityType.values[_random.nextInt(ActivityType.values.length)];
      final timestamp = now.subtract(Duration(minutes: _random.nextInt(2880))); // Last 2 days

      activities.add(ActivityFeedItem(
        id: 'activity_$i',
        userId: user.id,
        userName: user.name,
        userImageUrl: user.profileImageUrl,
        activityType: activityType,
        timestamp: timestamp,
        content: _generateActivityContent(activityType, user),
        eventId: _random.nextBool() ? 'demo_${_random.nextInt(7) + 1}' : null,
      ));
    }

    // Sort by timestamp (newest first)
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities;
  }

  /// Generate content for different activity types
  static String _generateActivityContent(ActivityType type, DemoUser user) {
    switch (type) {
      case ActivityType.eventAttended:
        return 'attended an amazing event and had a great time!';
      case ActivityType.eventCreated:
        return 'created a new event. Check it out!';
      case ActivityType.eventFavorited:
        return 'added an event to their favorites';
      case ActivityType.userFollowed:
        return 'started following new event organizers';
      case ActivityType.commentPosted:
        return 'shared their thoughts on an upcoming event';
      case ActivityType.photoShared:
        return 'shared photos from a recent event';
    }
  }

  /// Simulate real-time notifications for demo mode
  static List<DemoNotification> generateDemoNotifications() {
    final users = getDemoUsers();
    final notifications = <DemoNotification>[];
    final now = DateTime.now();

    final notificationTypes = [
      'New event in your area: "Summer Jazz Festival"',
      '${users[1].name} is attending "Rock the Night Concert"',
      'Event reminder: "Street Food Festival" starts in 2 hours',
      'Price drop alert: "Wine Tasting Evening" tickets now \$65',
      '${users[2].name} commented on "Modern Art Exhibition"',
      'New follower: ${users[3].name} started following you',
      'Event update: "Tech Innovation Summit" added new speakers',
      'Weather alert: Perfect conditions for "Community Marathon"',
    ];

    for (int i = 0; i < 5; i++) {
      notifications.add(DemoNotification(
        id: 'notification_$i',
        title: 'SomethingToDo',
        message: notificationTypes[_random.nextInt(notificationTypes.length)],
        timestamp: now.subtract(Duration(minutes: _random.nextInt(120))),
        isRead: _random.nextBool(),
        type: NotificationType.values[_random.nextInt(NotificationType.values.length)],
      ));
    }

    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  /// Clear cached data to force refresh
  static void clearCache() {
    _cachedUsers = null;
    _cachedInteractions = null;
  }
}

// Supporting data models for demo functionality
class DemoUser {
  final String id;
  final String name;
  final String email;
  final String profileImageUrl;
  final String bio;
  final String location;
  final List<String> interests;
  final List<EventCategory> preferredCategories;
  final DateTime joinedDate;
  final int eventsAttended;
  final int eventsCreated;
  final int followers;
  final int following;
  final bool isVerified;
  final ActivityLevel activityLevel;
  final Map<String, double> personalityTraits;

  const DemoUser({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.bio,
    required this.location,
    required this.interests,
    required this.preferredCategories,
    required this.joinedDate,
    required this.eventsAttended,
    required this.eventsCreated,
    required this.followers,
    required this.following,
    required this.isVerified,
    required this.activityLevel,
    required this.personalityTraits,
  });
}

class EventInteractionData {
  final String userId;
  final String eventId;
  final bool isInterested;
  final bool isFavorited;
  final bool willAttend;
  final bool hasCommented;
  final String? comment;
  final DateTime interactionTimestamp;
  final EngagementLevel engagementLevel;

  const EventInteractionData({
    required this.userId,
    required this.eventId,
    required this.isInterested,
    required this.isFavorited,
    required this.willAttend,
    required this.hasCommented,
    this.comment,
    required this.interactionTimestamp,
    required this.engagementLevel,
  });
}

class ActivityFeedItem {
  final String id;
  final String userId;
  final String userName;
  final String userImageUrl;
  final ActivityType activityType;
  final DateTime timestamp;
  final String content;
  final String? eventId;

  const ActivityFeedItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.activityType,
    required this.timestamp,
    required this.content,
    this.eventId,
  });
}

class DemoNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  const DemoNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });
}

enum ActivityLevel { low, medium, high }
enum EngagementLevel { low, medium, high }
enum ActivityType {
  eventAttended,
  eventCreated,
  eventFavorited,
  userFollowed,
  commentPosted,
  photoShared,
}
enum NotificationType {
  eventRecommendation,
  socialActivity,
  eventReminder,
  priceAlert,
  weatherUpdate,
  systemNotification,
}