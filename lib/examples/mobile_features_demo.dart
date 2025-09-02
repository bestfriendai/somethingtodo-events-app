import 'package:flutter/material.dart';
import '../services/platform_interactions.dart';
import '../services/cache_service.dart';
import '../widgets/mobile/mobile_bottom_sheet.dart';
import '../widgets/mobile/optimized_event_list.dart';
import '../screens/feed/vertical_feed_screen.dart';
import '../models/event.dart';

/// Demo class showing how to use the new mobile features
class MobileFeaturesDemo {
  
  /// Example: Show a platform-specific action sheet
  static void demonstrateActionSheet(BuildContext context) {
    PlatformInteractions.showPlatformActionSheet(
      context: context,
      title: 'Choose Action',
      message: 'What would you like to do?',
      actions: [
        PlatformAction(
          title: 'Share Event',
          icon: Icons.share,
          onPressed: () {
            PlatformInteractions.showToast(
              context: context,
              message: 'Event shared!',
              icon: Icons.check_circle,
            );
          },
        ),
        PlatformAction(
          title: 'Add to Favorites',
          icon: Icons.favorite,
          onPressed: () {
            // Handle favorite action
          },
        ),
        PlatformAction(
          title: 'Delete Event',
          icon: Icons.delete,
          isDestructive: true,
          onPressed: () {
            // Handle delete action
          },
        ),
      ],
    );
  }

  /// Example: Show a mobile bottom sheet
  static void demonstrateBottomSheet(BuildContext context, Event event) {
    MobileBottomSheet.show(
      context: context,
      title: 'Event Details',
      isScrollable: true,
      initialChildSize: 0.7,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(event.description),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      PlatformInteractions.lightImpact();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      PlatformInteractions.mediumImpact();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.confirmation_num),
                    label: const Text('Get Tickets'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Example: Open TikTok-style feed
  static void demonstrateFeedView(BuildContext context, List<Event> events) {
    Navigator.push(
      context,
      PlatformInteractions.createPlatformRoute(
        page: VerticalFeedScreen(initialEvents: events),
        fullscreenDialog: true,
      ),
    );
  }

  /// Example: Cache management
  static Future<void> demonstrateCaching(List<Event> events) async {
    // Initialize cache
    await CacheService.instance.initialize();
    
    // Cache events for offline use
    await CacheService.instance.cacheEvents(events);
    
    // Cache user preferences
    await CacheService.instance.cacheUserPreference('theme', 'dark');
    
    // Check connectivity
    final isConnected = await CacheService.instance.isConnected;
    debugPrint('Connected: $isConnected');

    // Get cached data
    final cachedEvents = await CacheService.instance.getCachedEvents();
    debugPrint('Cached events: ${cachedEvents?.length ?? 0}');
  }

  /// Example: Platform-specific toast
  static void demonstrateToast(BuildContext context) {
    PlatformInteractions.showToast(
      context: context,
      message: 'This is a native-feeling toast!',
      icon: Icons.check_circle,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    );
  }

  /// Example: Haptic feedback patterns
  static void demonstrateHaptics() {
    // Light feedback for selections
    PlatformInteractions.lightImpact();
    
    // Medium feedback for actions
    PlatformInteractions.mediumImpact();
    
    // Heavy feedback for important actions
    PlatformInteractions.heavyImpact();
  }
}

/// Example usage in a widget
class MobileFeaturesExampleScreen extends StatelessWidget {
  final List<Event> sampleEvents;

  const MobileFeaturesExampleScreen({
    super.key,
    required this.sampleEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Features Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => MobileFeaturesDemo.demonstrateFeedView(
                context, 
                sampleEvents,
              ),
              child: const Text('Open TikTok-Style Feed'),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () => MobileFeaturesDemo.demonstrateActionSheet(context),
              child: const Text('Show Action Sheet'),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () => MobileFeaturesDemo.demonstrateBottomSheet(
                context,
                sampleEvents.first,
              ),
              child: const Text('Show Bottom Sheet'),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () => MobileFeaturesDemo.demonstrateToast(context),
              child: const Text('Show Toast'),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: MobileFeaturesDemo.demonstrateHaptics,
              child: const Text('Test Haptic Feedback'),
            ),
            const SizedBox(height: 32),
            
            // Optimized event list demo
            const Text(
              'Swipeable Event Cards:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: OptimizedEventList(
                events: sampleEvents,
                enableSwipeActions: true,
                enablePullToRefresh: true,
                onRefresh: () async {
                  // Simulate refresh
                  await Future.delayed(const Duration(seconds: 1));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}