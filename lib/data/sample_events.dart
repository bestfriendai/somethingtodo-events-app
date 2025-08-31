import '../models/event.dart';

class SampleEvents {
  static List<Event> getDemoEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final thisWeekend = today.add(Duration(days: (6 - now.weekday) + 1));
    final nextWeek = today.add(const Duration(days: 7));
    final nextMonth = today.add(const Duration(days: 30));

    return [
      // Music Events
      Event(
        id: 'demo_1',
        title: 'Summer Jazz Festival',
        description: 'Join us for an evening of smooth jazz under the stars. Featuring local and international artists performing classic and contemporary jazz pieces. Food trucks and artisan vendors will be available.',
        organizerName: 'City Music Society',
        organizerImageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop',
        venue: const EventVenue(
          name: 'Central Park Amphitheater',
          address: '123 Park Avenue',
          city: 'San Francisco',
          state: 'CA',
          country: 'USA',
          zipCode: '94102',
          latitude: 37.7749,
          longitude: -122.4194,
          description: 'Beautiful outdoor amphitheater with great acoustics',
          websiteUrl: 'https://centralparkamphitheater.com',
          phoneNumber: '(555) 123-4567',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop',
          'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=800&h=400&fit=crop',
          'https://images.unsplash.com/photo-1465056836041-7f43ac27dcb5?w=800&h=400&fit=crop',
        ],
        category: EventCategory.music,
        pricing: const EventPricing(
          isFree: false,
          price: 45.00,
          currency: 'USD',
          priceDescription: 'General Admission',
          tiers: [
            TicketTier(name: 'General Admission', price: 45.00, available: 200, sold: 150),
            TicketTier(name: 'VIP', price: 85.00, available: 50, sold: 35),
          ],
        ),
        startDateTime: today.add(const Duration(hours: 18)),
        endDateTime: today.add(const Duration(hours: 22)),
        tags: ['jazz', 'music', 'outdoor', 'live'],
        attendeeCount: 185,
        maxAttendees: 250,
        favoriteCount: 67,
        isFeatured: true,
        websiteUrl: 'https://summerjazzfest.com',
        ticketUrl: 'https://tickets.summerjazzfest.com',
        contactEmail: 'info@summerjazzfest.com',
        contactPhone: '(555) 987-6543',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'demo_organizer_1',
      ),

      Event(
        id: 'demo_2',
        title: 'Rock the Night Concert',
        description: 'High-energy rock concert featuring three amazing bands. Get ready for an unforgettable night of headbanging and incredible music!',
        organizerName: 'Rock Events Co.',
        venue: const EventVenue(
          name: 'The Music Hall',
          address: '456 Music Street',
          city: 'Los Angeles',
          state: 'CA',
          country: 'USA',
          zipCode: '90210',
          latitude: 34.0522,
          longitude: -118.2437,
          description: 'Premier indoor concert venue',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800&h=400&fit=crop',
          'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=800&h=400&fit=crop',
        ],
        category: EventCategory.music,
        pricing: const EventPricing(
          isFree: false,
          price: 65.00,
          currency: 'USD',
          priceDescription: 'Standing Room',
        ),
        startDateTime: tomorrow.add(const Duration(hours: 20)),
        endDateTime: tomorrow.add(const Duration(hours: 23, minutes: 30)),
        tags: ['rock', 'concert', 'live music', 'bands'],
        attendeeCount: 420,
        maxAttendees: 500,
        favoriteCount: 89,
        isFeatured: true,
      ),

      // Food Events
      Event(
        id: 'demo_3',
        title: 'Street Food Festival',
        description: 'Explore flavors from around the world! Over 50 food vendors offering authentic cuisines, cooking demonstrations, and live entertainment.',
        organizerName: 'Foodie Events',
        venue: const EventVenue(
          name: 'Waterfront Plaza',
          address: '789 Harbor Drive',
          city: 'San Diego',
          state: 'CA',
          country: 'USA',
          latitude: 32.7157,
          longitude: -117.1611,
          description: 'Scenic waterfront location with ocean views',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&h=400&fit=crop',
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&h=400&fit=crop',
        ],
        category: EventCategory.food,
        pricing: const EventPricing(
          isFree: true,
          priceDescription: 'Free entry, pay per vendor',
        ),
        startDateTime: thisWeekend.add(const Duration(hours: 11)),
        endDateTime: thisWeekend.add(const Duration(hours: 20)),
        tags: ['food', 'festival', 'international', 'family'],
        attendeeCount: 1500,
        maxAttendees: 2000,
        favoriteCount: 234,
        isFeatured: true,
      ),

      Event(
        id: 'demo_4',
        title: 'Wine Tasting Evening',
        description: 'Sample exquisite wines from local vineyards paired with artisanal cheeses. Learn about wine-making from expert sommeliers.',
        organizerName: 'Wine Society',
        venue: const EventVenue(
          name: 'The Wine Cellar',
          address: '321 Vine Street',
          city: 'Napa',
          state: 'CA',
          country: 'USA',
          latitude: 38.2975,
          longitude: -122.2869,
          description: 'Intimate wine cellar with rustic charm',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=800&h=400&fit=crop',
        ],
        category: EventCategory.food,
        pricing: const EventPricing(
          isFree: false,
          price: 75.00,
          currency: 'USD',
          priceDescription: 'Includes tastings and appetizers',
        ),
        startDateTime: nextWeek.add(const Duration(hours: 18)),
        endDateTime: nextWeek.add(const Duration(hours: 21)),
        tags: ['wine', 'tasting', 'sophisticated', 'adults only'],
        attendeeCount: 35,
        maxAttendees: 50,
        favoriteCount: 28,
      ),

      // Sports Events
      Event(
        id: 'demo_5',
        title: 'Community Marathon',
        description: 'Annual city marathon open to all fitness levels. 5K, 10K, and full marathon distances available. Medals for all finishers!',
        organizerName: 'City Running Club',
        venue: const EventVenue(
          name: 'City Stadium',
          address: '100 Stadium Way',
          city: 'Portland',
          state: 'OR',
          country: 'USA',
          latitude: 45.5152,
          longitude: -122.6784,
          description: 'Professional track and field facility',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
        ],
        category: EventCategory.sports,
        pricing: const EventPricing(
          isFree: false,
          price: 25.00,
          currency: 'USD',
          priceDescription: 'Registration fee includes race packet',
        ),
        startDateTime: nextWeek.add(const Duration(days: 1, hours: 7)),
        endDateTime: nextWeek.add(const Duration(days: 1, hours: 13)),
        tags: ['running', 'marathon', 'fitness', 'community'],
        attendeeCount: 850,
        maxAttendees: 1000,
        favoriteCount: 156,
      ),

      Event(
        id: 'demo_6',
        title: 'Beach Volleyball Tournament',
        description: 'Fun in the sun! Teams of all skill levels welcome. Prizes for winners and BBQ for all participants.',
        organizerName: 'Beach Sports League',
        venue: const EventVenue(
          name: 'Sunset Beach',
          address: '500 Beach Boulevard',
          city: 'Santa Monica',
          state: 'CA',
          country: 'USA',
          latitude: 34.0195,
          longitude: -118.4912,
          description: 'Beautiful beach with professional volleyball courts',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&h=400&fit=crop',
        ],
        category: EventCategory.sports,
        pricing: const EventPricing(
          isFree: false,
          price: 30.00,
          currency: 'USD',
          priceDescription: 'Per team (4 players max)',
        ),
        startDateTime: thisWeekend.add(const Duration(days: 1, hours: 9)),
        endDateTime: thisWeekend.add(const Duration(days: 1, hours: 17)),
        tags: ['volleyball', 'beach', 'tournament', 'summer'],
        attendeeCount: 64,
        maxAttendees: 80,
        favoriteCount: 23,
      ),

      // Arts Events
      Event(
        id: 'demo_7',
        title: 'Modern Art Exhibition',
        description: 'Discover the latest works from emerging local artists. Interactive installations, paintings, sculptures, and digital art.',
        organizerName: 'Contemporary Art Gallery',
        venue: const EventVenue(
          name: 'Modern Art Museum',
          address: '200 Art Avenue',
          city: 'San Francisco',
          state: 'CA',
          country: 'USA',
          latitude: 37.7849,
          longitude: -122.4094,
          description: 'Three-story contemporary art space',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=400&fit=crop',
        ],
        category: EventCategory.arts,
        pricing: const EventPricing(
          isFree: false,
          price: 15.00,
          currency: 'USD',
          priceDescription: 'General admission',
        ),
        startDateTime: today.add(const Duration(hours: 10)),
        endDateTime: nextMonth.add(const Duration(hours: 18)),
        tags: ['art', 'exhibition', 'modern', 'gallery'],
        attendeeCount: 245,
        maxAttendees: 0, // No limit for exhibition
        favoriteCount: 78,
      ),

      Event(
        id: 'demo_8',
        title: 'Comedy Night Live',
        description: 'Laugh until your sides hurt! Featuring local comedians and a special guest headliner. 18+ event with full bar available.',
        organizerName: 'Laugh Track Comedy',
        venue: const EventVenue(
          name: 'The Comedy Club',
          address: '150 Funny Street',
          city: 'Austin',
          state: 'TX',
          country: 'USA',
          latitude: 30.2672,
          longitude: -97.7431,
          description: 'Intimate comedy venue with great atmosphere',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1527224048964-5aa73d0b5c1b?w=800&h=400&fit=crop',
        ],
        category: EventCategory.arts,
        pricing: const EventPricing(
          isFree: false,
          price: 20.00,
          currency: 'USD',
          priceDescription: 'Cover charge, 2-drink minimum',
        ),
        startDateTime: tomorrow.add(const Duration(hours: 20)),
        endDateTime: tomorrow.add(const Duration(hours: 22, minutes: 30)),
        tags: ['comedy', 'stand-up', 'entertainment', 'adults only'],
        attendeeCount: 85,
        maxAttendees: 120,
        favoriteCount: 43,
      ),

      // Business Events
      Event(
        id: 'demo_9',
        title: 'Tech Startup Networking',
        description: 'Connect with fellow entrepreneurs, investors, and tech professionals. Pitch sessions, panel discussions, and plenty of networking opportunities.',
        organizerName: 'Startup Hub',
        venue: const EventVenue(
          name: 'Innovation Center',
          address: '600 Tech Drive',
          city: 'Palo Alto',
          state: 'CA',
          country: 'USA',
          latitude: 37.4419,
          longitude: -122.1430,
          description: 'Modern co-working and event space',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&h=400&fit=crop',
        ],
        category: EventCategory.business,
        pricing: const EventPricing(
          isFree: false,
          price: 35.00,
          currency: 'USD',
          priceDescription: 'Includes light refreshments',
        ),
        startDateTime: nextWeek.add(const Duration(hours: 18)),
        endDateTime: nextWeek.add(const Duration(hours: 21)),
        tags: ['networking', 'startup', 'tech', 'business'],
        attendeeCount: 127,
        maxAttendees: 150,
        favoriteCount: 56,
      ),

      Event(
        id: 'demo_10',
        title: 'Digital Marketing Workshop',
        description: 'Learn the latest digital marketing strategies from industry experts. Hands-on workshops covering SEO, social media, and content marketing.',
        organizerName: 'Marketing Masters',
        venue: const EventVenue(
          name: 'Business Conference Center',
          address: '300 Corporate Blvd',
          city: 'Seattle',
          state: 'WA',
          country: 'USA',
          latitude: 47.6062,
          longitude: -122.3321,
          description: 'Professional conference facility',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=400&fit=crop',
        ],
        category: EventCategory.business,
        pricing: const EventPricing(
          isFree: false,
          price: 125.00,
          currency: 'USD',
          priceDescription: 'Full-day workshop with materials',
        ),
        startDateTime: nextWeek.add(const Duration(days: 3, hours: 9)),
        endDateTime: nextWeek.add(const Duration(days: 3, hours: 17)),
        tags: ['marketing', 'workshop', 'digital', 'business'],
        attendeeCount: 45,
        maxAttendees: 60,
        favoriteCount: 31,
      ),

      // Education Events
      Event(
        id: 'demo_11',
        title: 'Coding Bootcamp Preview',
        description: 'Free introduction to programming! Learn the basics of web development, meet instructors, and see if coding is right for you.',
        organizerName: 'Code Academy',
        venue: const EventVenue(
          name: 'Tech Learning Center',
          address: '700 Education Way',
          city: 'San Jose',
          state: 'CA',
          country: 'USA',
          latitude: 37.3382,
          longitude: -121.8863,
          description: 'Modern classroom with latest tech equipment',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=800&h=400&fit=crop',
        ],
        category: EventCategory.education,
        pricing: const EventPricing(
          isFree: true,
          priceDescription: 'Free preview session',
        ),
        startDateTime: nextWeek.add(const Duration(days: 2, hours: 14)),
        endDateTime: nextWeek.add(const Duration(days: 2, hours: 17)),
        tags: ['coding', 'programming', 'education', 'career'],
        attendeeCount: 35,
        maxAttendees: 50,
        favoriteCount: 22,
      ),

      // Technology Events
      Event(
        id: 'demo_12',
        title: 'AI & Future Tech Conference',
        description: 'Explore the future of artificial intelligence and emerging technologies. Keynote speakers, demos, and interactive sessions.',
        organizerName: 'Future Tech Society',
        venue: const EventVenue(
          name: 'Convention Center',
          address: '800 Convention Ave',
          city: 'Las Vegas',
          state: 'NV',
          country: 'USA',
          latitude: 36.1699,
          longitude: -115.1398,
          description: 'Large convention facility with multiple halls',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800&h=400&fit=crop',
        ],
        category: EventCategory.technology,
        pricing: const EventPricing(
          isFree: false,
          price: 199.00,
          currency: 'USD',
          priceDescription: 'Full conference pass',
        ),
        startDateTime: nextMonth.add(const Duration(hours: 9)),
        endDateTime: nextMonth.add(const Duration(hours: 18)),
        tags: ['AI', 'technology', 'conference', 'future'],
        attendeeCount: 567,
        maxAttendees: 800,
        favoriteCount: 189,
        isFeatured: true,
      ),

      // Health Events
      Event(
        id: 'demo_13',
        title: 'Yoga in the Park',
        description: 'Start your day with peaceful yoga in nature. All levels welcome. Bring your own mat or rent one on-site.',
        organizerName: 'Zen Wellness',
        venue: const EventVenue(
          name: 'Lakeside Park',
          address: '900 Lake Drive',
          city: 'Austin',
          state: 'TX',
          country: 'USA',
          latitude: 30.2672,
          longitude: -97.7431,
          description: 'Peaceful park setting by the lake',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1506629905961-b33b671e7ba2?w=800&h=400&fit=crop',
        ],
        category: EventCategory.health,
        pricing: const EventPricing(
          isFree: false,
          price: 15.00,
          currency: 'USD',
          priceDescription: 'Drop-in class',
        ),
        startDateTime: tomorrow.add(const Duration(hours: 7)),
        endDateTime: tomorrow.add(const Duration(hours: 8)),
        tags: ['yoga', 'wellness', 'outdoor', 'meditation'],
        attendeeCount: 25,
        maxAttendees: 40,
        favoriteCount: 18,
      ),

      // Community Events
      Event(
        id: 'demo_14',
        title: 'Neighborhood Clean-up Day',
        description: 'Join your neighbors in keeping our community beautiful! Supplies provided. Lunch for all volunteers.',
        organizerName: 'Community Action Group',
        venue: const EventVenue(
          name: 'Community Center',
          address: '400 Community Street',
          city: 'Portland',
          state: 'OR',
          country: 'USA',
          latitude: 45.5152,
          longitude: -122.6784,
          description: 'Local community gathering place',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=800&h=400&fit=crop',
        ],
        category: EventCategory.community,
        pricing: const EventPricing(
          isFree: true,
          priceDescription: 'Free volunteer event',
        ),
        startDateTime: thisWeekend.add(const Duration(hours: 9)),
        endDateTime: thisWeekend.add(const Duration(hours: 13)),
        tags: ['volunteer', 'community', 'environment', 'service'],
        attendeeCount: 48,
        maxAttendees: 100,
        favoriteCount: 32,
      ),

      Event(
        id: 'demo_15',
        title: 'Farmers Market',
        description: 'Fresh local produce, artisanal goods, and live music. Support local farmers and small businesses every Saturday morning.',
        organizerName: 'Local Farmers Collective',
        venue: const EventVenue(
          name: 'Town Square',
          address: '250 Main Street',
          city: 'Boulder',
          state: 'CO',
          country: 'USA',
          latitude: 40.0150,
          longitude: -105.2705,
          description: 'Historic town square with covered pavilion',
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=400&fit=crop',
        ],
        category: EventCategory.community,
        pricing: const EventPricing(
          isFree: true,
          priceDescription: 'Free to browse, pay vendors directly',
        ),
        startDateTime: thisWeekend.add(const Duration(hours: 8)),
        endDateTime: thisWeekend.add(const Duration(hours: 14)),
        tags: ['farmers market', 'local', 'organic', 'community'],
        attendeeCount: 200,
        maxAttendees: 0, // No limit
        favoriteCount: 87,
      ),

      // More diverse events
      Event(
        id: 'demo_16',
        title: 'Photography Workshop',
        description: 'Learn professional photography techniques in this hands-on workshop. Camera provided if needed.',
        organizerName: 'Photo Society',
        venue: const EventVenue(
          name: 'Art Studio',
          address: '350 Creative Lane',
          city: 'Denver',
          state: 'CO',
          country: 'USA',
          latitude: 39.7392,
          longitude: -104.9903,
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&h=400&fit=crop',
        ],
        category: EventCategory.education,
        pricing: const EventPricing(
          isFree: false,
          price: 85.00,
          currency: 'USD',
        ),
        startDateTime: nextWeek.add(const Duration(days: 4, hours: 10)),
        endDateTime: nextWeek.add(const Duration(days: 4, hours: 16)),
        tags: ['photography', 'workshop', 'creative', 'skills'],
        attendeeCount: 15,
        maxAttendees: 20,
        favoriteCount: 12,
      ),

      Event(
        id: 'demo_17',
        title: 'Film Festival Opening Night',
        description: 'Celebrate independent cinema with screenings, director Q&As, and networking. Red carpet event with industry professionals.',
        organizerName: 'Independent Film Society',
        venue: const EventVenue(
          name: 'Historic Theater',
          address: '450 Cinema Boulevard',
          city: 'Los Angeles',
          state: 'CA',
          country: 'USA',
          latitude: 34.0522,
          longitude: -118.2437,
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1489599556916-c8b5a67ffb1b?w=800&h=400&fit=crop',
        ],
        category: EventCategory.arts,
        pricing: const EventPricing(
          isFree: false,
          price: 50.00,
          currency: 'USD',
        ),
        startDateTime: nextWeek.add(const Duration(days: 5, hours: 19)),
        endDateTime: nextWeek.add(const Duration(days: 5, hours: 23)),
        tags: ['film', 'festival', 'cinema', 'premiere'],
        attendeeCount: 180,
        maxAttendees: 250,
        favoriteCount: 95,
        isFeatured: true,
      ),

      Event(
        id: 'demo_18',
        title: 'Book Club Meeting',
        description: 'Monthly discussion of "The Great Gatsby". New members welcome! Light refreshments provided.',
        organizerName: 'City Book Club',
        venue: const EventVenue(
          name: 'Public Library',
          address: '100 Library Street',
          city: 'San Francisco',
          state: 'CA',
          country: 'USA',
          latitude: 37.7749,
          longitude: -122.4194,
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&h=400&fit=crop',
        ],
        category: EventCategory.education,
        pricing: const EventPricing(
          isFree: true,
        ),
        startDateTime: nextWeek.add(const Duration(days: 2, hours: 18, minutes: 30)),
        endDateTime: nextWeek.add(const Duration(days: 2, hours: 20, minutes: 30)),
        tags: ['books', 'reading', 'discussion', 'social'],
        attendeeCount: 12,
        maxAttendees: 20,
        favoriteCount: 8,
      ),

      Event(
        id: 'demo_19',
        title: 'Craft Beer Festival',
        description: 'Sample craft beers from 30+ local breweries. Food pairings, live music, and brewery tours available.',
        organizerName: 'Craft Brewers Association',
        venue: const EventVenue(
          name: 'Brewery District',
          address: '800 Hops Avenue',
          city: 'Portland',
          state: 'OR',
          country: 'USA',
          latitude: 45.5152,
          longitude: -122.6784,
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1608270586620-248524c67de9?w=800&h=400&fit=crop',
        ],
        category: EventCategory.food,
        pricing: const EventPricing(
          isFree: false,
          price: 40.00,
          currency: 'USD',
          priceDescription: 'Includes tasting glass and 10 tokens',
        ),
        startDateTime: thisWeekend.add(const Duration(days: 1, hours: 12)),
        endDateTime: thisWeekend.add(const Duration(days: 1, hours: 20)),
        tags: ['beer', 'craft', 'festival', 'tasting'],
        attendeeCount: 325,
        maxAttendees: 400,
        favoriteCount: 142,
      ),

      Event(
        id: 'demo_20',
        title: 'Outdoor Adventure Meetup',
        description: 'Hiking and rock climbing for all skill levels. Equipment provided for beginners. Professional guides included.',
        organizerName: 'Adventure Club',
        venue: const EventVenue(
          name: 'Mountain Trail Head',
          address: 'Rocky Mountain National Park',
          city: 'Estes Park',
          state: 'CO',
          country: 'USA',
          latitude: 40.3772,
          longitude: -105.5217,
        ),
        imageUrls: [
          'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800&h=400&fit=crop',
        ],
        category: EventCategory.sports,
        pricing: const EventPricing(
          isFree: false,
          price: 60.00,
          currency: 'USD',
          priceDescription: 'Includes guide and equipment rental',
        ),
        startDateTime: thisWeekend.add(const Duration(days: 1, hours: 8)),
        endDateTime: thisWeekend.add(const Duration(days: 1, hours: 16)),
        tags: ['hiking', 'climbing', 'outdoor', 'adventure'],
        attendeeCount: 16,
        maxAttendees: 20,
        favoriteCount: 29,
      ),
    ];
  }

  static List<Event> getFeaturedEvents() {
    return getDemoEvents().where((event) => event.isFeatured).toList();
  }

  static List<Event> getEventsByCategory(EventCategory category) {
    return getDemoEvents().where((event) => event.category == category).toList();
  }

  static List<Event> getFreeEvents() {
    return getDemoEvents().where((event) => event.pricing.isFree).toList();
  }

  static List<Event> getTodayEvents() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getDemoEvents().where((event) =>
      event.startDateTime.isAfter(startOfDay) &&
      event.startDateTime.isBefore(endOfDay)
    ).toList();
  }

  static List<Event> getThisWeekendEvents() {
    final now = DateTime.now();
    final weekend = now.add(Duration(days: (6 - now.weekday) + 1));
    final mondayAfter = weekend.add(const Duration(days: 2));
    
    return getDemoEvents().where((event) =>
      event.startDateTime.isAfter(weekend) &&
      event.startDateTime.isBefore(mondayAfter)
    ).toList();
  }

  static List<Event> getUpcomingEvents() {
    final now = DateTime.now();
    return getDemoEvents()
        .where((event) => event.startDateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  static List<Event> searchEvents(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getDemoEvents().where((event) {
      return event.title.toLowerCase().contains(lowercaseQuery) ||
             event.description.toLowerCase().contains(lowercaseQuery) ||
             event.venue.name.toLowerCase().contains(lowercaseQuery) ||
             event.organizerName.toLowerCase().contains(lowercaseQuery) ||
             event.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
}

// Sample chat responses for demo mode
class SampleChatResponses {
  static const Map<String, List<String>> responses = {
    'hello': [
      'Hello! I\'m here to help you discover amazing events in your area. What are you looking for today?',
      'Hi there! Ready to find some exciting events? I can help you with music, food, sports, and much more!',
      'Welcome! I\'m your personal event assistant. Tell me what interests you and I\'ll find perfect events for you.',
    ],
    'music': [
      'Great choice! I found several music events for you. There\'s a Jazz Festival tonight at Central Park Amphitheater and a Rock Concert tomorrow at The Music Hall. Which sounds more interesting?',
      'Music lover! 🎵 I see you have options from jazz to rock to indie performances. The Summer Jazz Festival is particularly popular right now.',
    ],
    'free': [
      'Looking for free events? Perfect! The Street Food Festival this weekend has free entry, and there\'s also a Neighborhood Clean-up Day and Farmers Market. All completely free!',
      'Budget-friendly fun coming right up! I found several free events including community activities, educational workshops, and outdoor yoga sessions.',
    ],
    'tonight': [
      'For tonight, I recommend the Summer Jazz Festival at Central Park Amphitheater starting at 6 PM. It\'s a beautiful outdoor venue with great music and food trucks!',
      'Tonight\'s highlights include live jazz music and a photography workshop. The jazz festival is especially popular and has great reviews!',
    ],
    'weekend': [
      'This weekend is packed with activities! Saturday has the Street Food Festival and Beach Volleyball Tournament. Sunday features the Craft Beer Festival and Outdoor Adventure Meetup. What sounds fun?',
      'Weekend plans sorted! 🎉 You\'ve got food festivals, sports tournaments, craft beer tasting, and outdoor adventures to choose from.',
    ],
    'food': [
      'Foodie alert! 🍽️ The Street Food Festival this weekend features 50+ vendors with international cuisines. There\'s also a Wine Tasting Evening next week for a more sophisticated experience.',
      'Delicious options await! From street food festivals to wine tastings, I\'ve found events that will satisfy any food lover.',
    ],
    'default': [
      'I\'m here to help you find the perfect events! Try asking me about music events, free activities, what\'s happening tonight, or this weekend.',
      'Let me help you discover something amazing! I can search for events by category, location, date, or even specific interests.',
      'Not sure what you\'re looking for? I can suggest popular events, free activities, or help you explore different categories like music, food, sports, and arts.',
    ],
  };

  static String getResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    String responseKey = 'default';

    // Simple keyword matching for demo
    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      responseKey = 'hello';
    } else if (message.contains('music') || message.contains('concert') || message.contains('jazz')) {
      responseKey = 'music';
    } else if (message.contains('free')) {
      responseKey = 'free';
    } else if (message.contains('tonight') || message.contains('today')) {
      responseKey = 'tonight';
    } else if (message.contains('weekend') || message.contains('saturday') || message.contains('sunday')) {
      responseKey = 'weekend';
    } else if (message.contains('food') || message.contains('restaurant') || message.contains('eat')) {
      responseKey = 'food';
    }

    final responses = SampleChatResponses.responses[responseKey]!;
    return responses[DateTime.now().millisecondsSinceEpoch % responses.length];
  }
}