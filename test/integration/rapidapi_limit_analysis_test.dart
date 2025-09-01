import 'package:flutter_test/flutter_test.dart';
import 'package:somethingtodo/services/rapidapi_events_service.dart';
import 'package:somethingtodo/config/app_config.dart';

void main() {
  group('RapidAPI Limit Analysis Tests', () {
    late RapidAPIEventsService service;

    setUpAll(() {
      service = RapidAPIEventsService();
    });

    test('should analyze different limit values and query types', () async {
      if (AppConfig.rapidApiKey == 'demo-key' || AppConfig.rapidApiKey.isEmpty) {
        print('Skipping test - no RapidAPI key configured');
        return;
      }

      // Test different limit values
      final limitTests = [10, 20, 30, 50, 100];
      
      for (final limit in limitTests) {
        try {
          print('\n🔍 Testing limit: $limit');
          
          final events = await service.searchEvents(
            query: 'events',
            location: 'United States',
            limit: limit,
          );
          
          print('   Requested: $limit, Received: ${events.length}');
          
          if (events.length < limit) {
            print('   ⚠️  API returned fewer events than requested');
          } else {
            print('   ✅ API returned requested number of events');
          }
          
        } catch (e) {
          print('   ❌ Error with limit $limit: $e');
        }
        
        // Small delay to avoid rate limiting
        await Future.delayed(Duration(milliseconds: 500));
      }
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('should test different query strategies for more events', () async {
      if (AppConfig.rapidApiKey == 'demo-key' || AppConfig.rapidApiKey.isEmpty) {
        print('Skipping test - no RapidAPI key configured');
        return;
      }

      final queryStrategies = [
        {'query': 'music concert', 'location': 'New York'},
        {'query': 'sports events', 'location': 'California'},
        {'query': 'festival', 'location': 'Texas'},
        {'query': 'entertainment', 'location': 'Florida'},
        {'query': 'events', 'location': 'Chicago'},
      ];

      for (final strategy in queryStrategies) {
        try {
          print('\n🎯 Testing strategy: ${strategy['query']} in ${strategy['location']}');
          
          final events = await service.searchEvents(
            query: strategy['query']!,
            location: strategy['location']!,
            limit: 50,
          );
          
          print('   Found ${events.length} events');
          
          if (events.isNotEmpty) {
            print('   Sample events:');
            for (int i = 0; i < events.length.clamp(0, 3); i++) {
              print('   - ${events[i].title}');
            }
          }
          
        } catch (e) {
          print('   ❌ Error with strategy ${strategy['query']}: $e');
        }
        
        await Future.delayed(Duration(milliseconds: 500));
      }
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('should test location-based searches for more events', () async {
      if (AppConfig.rapidApiKey == 'demo-key' || AppConfig.rapidApiKey.isEmpty) {
        print('Skipping test - no RapidAPI key configured');
        return;
      }

      final locations = [
        {'name': 'New York', 'lat': 40.7128, 'lng': -74.0060},
        {'name': 'Los Angeles', 'lat': 34.0522, 'lng': -118.2437},
        {'name': 'Chicago', 'lat': 41.8781, 'lng': -87.6298},
        {'name': 'Miami', 'lat': 25.7617, 'lng': -80.1918},
      ];

      for (final location in locations) {
        try {
          print('\n📍 Testing location: ${location['name']}');
          
          final events = await service.getEventsNearLocation(
            latitude: location['lat'] as double,
            longitude: location['lng'] as double,
            radiusKm: 100, // Increased radius
            limit: 50,
          );
          
          print('   Found ${events.length} events near ${location['name']}');
          
        } catch (e) {
          print('   ❌ Error for ${location['name']}: $e');
        }
        
        await Future.delayed(Duration(milliseconds: 500));
      }
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('should analyze API response structure for pagination info', () async {
      if (AppConfig.rapidApiKey == 'demo-key' || AppConfig.rapidApiKey.isEmpty) {
        print('Skipping test - no RapidAPI key configured');
        return;
      }

      try {
        print('\n🔬 Analyzing API response structure...');
        
        // Make a direct API call to examine the full response
        final events = await service.searchEvents(
          query: 'music',
          location: 'New York',
          limit: 50,
        );
        
        print('Events returned: ${events.length}');
        
        if (events.isNotEmpty) {
          final firstEvent = events.first;
          print('Sample event structure:');
          print('- ID: ${firstEvent.id}');
          print('- Title: ${firstEvent.title}');
          print('- Location: ${firstEvent.location}');
          print('- Date: ${firstEvent.dateTime}');
        }
        
        // Test if the API supports pagination or has built-in limits
        print('\n📄 Testing potential pagination...');
        
        final moreEvents = await service.searchEvents(
          query: 'events music concert festival',
          limit: 100, // Try even higher limit
        );
        
        print('With broader query and limit 100: ${moreEvents.length} events');
        
      } catch (e) {
        print('❌ Analysis failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 45)));
  });
}
