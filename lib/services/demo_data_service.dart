import 'dart:math';
import '../models/event.dart';

class DemoDataService {
  static final Random _random = Random();
  static List<DemoUser>? _cachedUsers;
  static Map<String, List<String>>? _cachedInteractions;
  static List<Event>? _cachedEvents;

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
        profileImageUrl:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face',
        bio:
            'Tech enthusiast and music lover. Always looking for the next great concert or innovation conference.',
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
        profileImageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
        bio:
            'Foodie and sports fan. Love discovering new restaurants and cheering for my favorite teams.',
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
        profileImageUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
        bio:
            'Art curator and culture enthusiast. Passionate about supporting local artists and creative communities.',
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
        profileImageUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
        bio:
            'Fitness enthusiast and outdoor adventurer. Always up for a challenge and meeting new people.',
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
        profileImageUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop&crop=face',
        bio:
            'Business professional and networking expert. Love connecting people and discovering new opportunities.',
        location: 'San Jose, CA',
        interests: [
          'business',
          'networking',
          'professional development',
          'startups',
        ],
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
      'demo_1': [
        // Summer Jazz Festival
        'Can\'t wait for this! The lineup looks amazing 🎷',
        'Been to this venue before, the acoustics are incredible',
        'Anyone know if there will be food trucks?',
        'Perfect way to spend a summer evening!',
        'The VIP tickets are worth it for the better view',
      ],
      'demo_2': [
        // Rock the Night Concert
        'These bands are going to be EPIC! 🤘',
        'Got my tickets! Who else is going?',
        'The Music Hall has such great energy for rock shows',
        'This is going to be loud and amazing!',
        'Perfect date night activity',
      ],
      'demo_3': [
        // Street Food Festival
        'Free entry is the best! More money for food 😋',
        'The Korean BBQ truck is a must-try',
        'Great family event, kids will love it',
        'Waterfront location makes it even better',
        'I gained 5 pounds last year but it was worth it!',
      ],
      'demo_4': [
        // Wine Tasting Evening
        'Educational and delicious, perfect combination',
        'The sommelier really knows their stuff',
        'Intimate setting makes for great conversations',
        'Worth every penny for wine lovers',
        'Book early, this always sells out',
      ],
      'demo_5': [
        // Community Marathon
        'Training starts now! Who\'s joining me?',
        'The 5K is perfect for beginners',
        'Love that everyone gets a medal',
        'Great cause and great exercise',
        'The route through downtown is beautiful',
      ],
      'demo_6': [
        // Modern Art Exhibition
        'The interactive installations are mind-blowing',
        'Perfect for art lovers and curious minds',
        'Guided tours are definitely worth it',
        'Some pieces really make you think',
        'Great date activity that sparks conversation',
      ],
      'demo_7': [
        // Tech Innovation Summit
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
  static EventInteractionData simulateEventInteraction(
    String eventId,
    DemoUser user,
  ) {
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
      final activityType =
          ActivityType.values[_random.nextInt(ActivityType.values.length)];
      final timestamp = now.subtract(
        Duration(minutes: _random.nextInt(2880)),
      ); // Last 2 days

      activities.add(
        ActivityFeedItem(
          id: 'activity_$i',
          userId: user.id,
          userName: user.name,
          userImageUrl: user.profileImageUrl,
          activityType: activityType,
          timestamp: timestamp,
          content: _generateActivityContent(activityType, user),
          eventId: _random.nextBool() ? 'demo_${_random.nextInt(7) + 1}' : null,
        ),
      );
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
      notifications.add(
        DemoNotification(
          id: 'notification_$i',
          title: 'SomethingToDo',
          message: notificationTypes[_random.nextInt(notificationTypes.length)],
          timestamp: now.subtract(Duration(minutes: _random.nextInt(120))),
          isRead: _random.nextBool(),
          type: NotificationType
              .values[_random.nextInt(NotificationType.values.length)],
        ),
      );
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

// Add static methods for getting demo events
extension DemoEventMethods on DemoDataService {
  /// Get demo events for a specific location
  static Future<List<Event>> getDemoEvents({
    required String location,
    int limit = 50,
  }) async {
    // Generate diverse demo events
    final events = <Event>[];
    final categories = EventCategory.values;
    final now = DateTime.now();

    for (int i = 0; i < limit && i < 100; i++) {
      final category = categories[i % categories.length];
      final dayOffset = (i ~/ 5) + 1;
      final startTime = now.add(Duration(days: dayOffset, hours: (i % 24)));

      events.add(
        Event(
          id: 'demo_event_$i',
          title: _generateEventTitle(category, i),
          description: _generateEventDescription(category),
          organizerName: _getRandomOrganizer(),
          venue: _generateVenue(location, i),
          imageUrls: [_getEventImage(category, i)],
          category: category,
          pricing: _generatePricing(category, i),
          startDateTime: startTime,
          endDateTime: startTime.add(const Duration(hours: 3)),
          tags: _generateTags(category),
          attendeeCount: DemoDataService._random.nextInt(500) + 50,
          maxAttendees: DemoDataService._random.nextInt(1000) + 100,
          favoriteCount: DemoDataService._random.nextInt(200),
          status: EventStatus.active,
          isFeatured: i < 5,
          isPremium: i % 10 == 0,
          createdAt: now.subtract(Duration(days: 30 - i)),
          updatedAt: now.subtract(Duration(days: 1)),
          createdBy: 'demo_system',
        ),
      );
    }

    return events;
  }

  /// Get trending demo events
  static Future<List<Event>> getTrendingEvents({int limit = 50}) async {
    final events = await getDemoEvents(
      location: 'San Francisco',
      limit: limit * 2,
    );
    // Sort by favorite count to simulate trending
    events.sort((a, b) => b.favoriteCount.compareTo(a.favoriteCount));
    return events.take(limit).toList();
  }

  static String _generateEventTitle(EventCategory category, int index) {
    final titles = {
      EventCategory.music: [
        'Summer Music Festival',
        'Jazz Night at the Park',
        'Rock Concert Series',
        'Classical Symphony',
        'Indie Band Showcase',
      ],
      EventCategory.sports: [
        'Basketball Tournament',
        'Marathon Training Session',
        'Yoga in the Park',
        'Soccer League Finals',
        'Tennis Championship',
      ],
      EventCategory.food: [
        'Food Truck Festival',
        'Wine Tasting Evening',
        'Cooking Masterclass',
        'Farmers Market',
        'Restaurant Week',
      ],
      EventCategory.technology: [
        'Tech Startup Pitch Night',
        'AI Conference 2024',
        'Coding Bootcamp',
        'Web3 Workshop',
        'Mobile Dev Meetup',
      ],
      EventCategory.arts: [
        'Art Gallery Opening',
        'Photography Exhibition',
        'Street Art Tour',
        'Pottery Workshop',
        'Film Festival',
      ],
      EventCategory.business: [
        'Networking Mixer',
        'Entrepreneur Summit',
        'Business Strategy Workshop',
        'Leadership Conference',
        'Sales Training',
      ],
      EventCategory.education: [
        'University Open Day',
        'Science Fair',
        'History Lecture Series',
        'Language Exchange',
        'Study Skills Workshop',
      ],
      EventCategory.health: [
        'Wellness Retreat',
        'Mental Health Workshop',
        'Fitness Bootcamp',
        'Nutrition Seminar',
        'Meditation Session',
      ],
      EventCategory.community: [
        'Neighborhood Cleanup',
        'Community BBQ',
        'Volunteer Fair',
        'Town Hall Meeting',
        'Cultural Festival',
      ],
      EventCategory.other: [
        'Special Event',
        'Grand Opening',
        'Anniversary Celebration',
        'Pop-up Experience',
        'Mystery Event',
      ],
    };

    final categoryTitles = titles[category] ?? titles[EventCategory.other]!;
    return '${categoryTitles[index % categoryTitles.length]} ${index > 20 ? "#$index" : ""}';
  }

  static String _generateEventDescription(EventCategory category) {
    final descriptions = {
      EventCategory.music:
          'Join us for an unforgettable musical experience featuring talented artists and amazing performances.',
      EventCategory.sports:
          'Get active and have fun with fellow sports enthusiasts in this exciting event.',
      EventCategory.food:
          'Discover delicious flavors and culinary delights at this food-focused gathering.',
      EventCategory.technology:
          'Explore the latest innovations and connect with tech professionals.',
      EventCategory.arts:
          'Immerse yourself in creativity and artistic expression at this cultural event.',
      EventCategory.business:
          'Network with professionals and learn valuable business insights.',
      EventCategory.education:
          'Expand your knowledge and learn something new at this educational event.',
      EventCategory.health:
          'Focus on your wellbeing and health at this wellness-focused gathering.',
      EventCategory.community:
          'Connect with your community and make a positive impact.',
      EventCategory.other:
          'Join us for this special event and create lasting memories.',
    };
    return descriptions[category] ?? descriptions[EventCategory.other]!;
  }

  static String _getRandomOrganizer() {
    final organizers = [
      'City Events Co.',
      'Community Connect',
      'EventPro Productions',
      'Local Happenings',
      'Social Scene',
      'Experience Creators',
      'Urban Adventures',
      'Cultural Collective',
    ];
    return organizers[DemoDataService._random.nextInt(organizers.length)];
  }

  static EventVenue _generateVenue(String location, int index) {
    final venues = [
      EventVenue(
        name: 'Golden Gate Park',
        address: 'Golden Gate Park',
        city: 'San Francisco',
        state: 'CA',
        country: 'USA',
        latitude: 37.7694,
        longitude: -122.4862,
      ),
      EventVenue(
        name: 'Moscone Center',
        address: '747 Howard St',
        city: 'San Francisco',
        state: 'CA',
        country: 'USA',
        latitude: 37.7842,
        longitude: -122.4006,
      ),
      EventVenue(
        name: 'Chase Center',
        address: '1 Warriors Way',
        city: 'San Francisco',
        state: 'CA',
        country: 'USA',
        latitude: 37.7680,
        longitude: -122.3878,
      ),
      EventVenue(
        name: 'Ferry Building',
        address: 'Ferry Building Marketplace',
        city: 'San Francisco',
        state: 'CA',
        country: 'USA',
        latitude: 37.7956,
        longitude: -122.3933,
      ),
      EventVenue(
        name: 'Union Square',
        address: 'Union Square',
        city: 'San Francisco',
        state: 'CA',
        country: 'USA',
        latitude: 37.7880,
        longitude: -122.4075,
      ),
    ];
    return venues[index % venues.length];
  }

  static String _getEventImage(EventCategory category, int index) {
    final images = {
      EventCategory.music: [
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800',
        'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800',
        'https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?w=800',
      ],
      EventCategory.sports: [
        'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800',
        'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800',
        'https://images.unsplash.com/photo-1544298621-35a764866ff0?w=800',
      ],
      EventCategory.food: [
        'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
        'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800',
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
      ],
      EventCategory.technology: [
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
        'https://images.unsplash.com/photo-1591115765373-5207764f72e7?w=800',
        'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=800',
      ],
      EventCategory.arts: [
        'https://images.unsplash.com/photo-1549490349-8643362247b5?w=800',
        'https://images.unsplash.com/photo-1561214115-f2f134cc4912?w=800',
        'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800',
      ],
    };

    final categoryImages =
        images[category] ??
        [
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800',
          'https://images.unsplash.com/photo-1505236858219-8359eb29e329?w=800',
        ];
    return categoryImages[index % categoryImages.length];
  }

  static EventPricing _generatePricing(EventCategory category, int index) {
    if (index % 3 == 0) {
      return const EventPricing(isFree: true, price: 0, currency: 'USD');
    }

    final basePrice = {
      EventCategory.music: 45.0,
      EventCategory.sports: 25.0,
      EventCategory.food: 35.0,
      EventCategory.technology: 75.0,
      EventCategory.arts: 20.0,
      EventCategory.business: 50.0,
      EventCategory.education: 15.0,
      EventCategory.health: 30.0,
      EventCategory.community: 0.0,
      EventCategory.other: 25.0,
    };

    final price = (basePrice[category] ?? 25.0) + (index % 5) * 10;
    return EventPricing(
      isFree: false,
      price: price,
      currency: 'USD',
      priceDescription: 'Early bird pricing available',
    );
  }

  static List<String> _generateTags(EventCategory category) {
    final tags = {
      EventCategory.music: [
        'live music',
        'concert',
        'performance',
        'entertainment',
      ],
      EventCategory.sports: ['fitness', 'active', 'outdoor', 'competition'],
      EventCategory.food: ['dining', 'culinary', 'tasting', 'foodie'],
      EventCategory.technology: ['tech', 'innovation', 'startup', 'digital'],
      EventCategory.arts: ['creative', 'culture', 'exhibition', 'artistic'],
      EventCategory.business: [
        'networking',
        'professional',
        'career',
        'entrepreneur',
      ],
      EventCategory.education: ['learning', 'workshop', 'seminar', 'training'],
      EventCategory.health: ['wellness', 'fitness', 'mindfulness', 'healthy'],
      EventCategory.community: ['local', 'volunteer', 'social', 'neighborhood'],
      EventCategory.other: ['special', 'unique', 'experience', 'fun'],
    };
    return tags[category] ?? tags[EventCategory.other]!;
  }
}
