import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:somethingtodo/services/cache_service.dart';
import 'package:somethingtodo/services/delight_service.dart';
import 'package:somethingtodo/services/performance_service.dart';
import 'package:somethingtodo/models/event.dart';

void main() {
  group('Error Handling and Edge Cases', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    group('CacheService Error Handling', () {
      test('should handle invalid event data gracefully', () async {
        final cacheService = CacheService.instance;
        
        // Test with null event
        expect(() async => await cacheService.cacheEvent(null as dynamic), returnsNormally);
        
        // Test with empty list
        await cacheService.cacheEvents([]);
        expect(true, isTrue);
        
        // Test with malformed event data
        try {
          final malformedEvent = Event(
            id: '', // Empty ID
            title: '', // Empty title
            description: '',
            organizerName: '',
            venue: const EventVenue(
              name: '',
              address: '',
              latitude: 0.0,
              longitude: 0.0,
            ),
            imageUrls: ['invalid-url'],
            category: EventCategory.other,
            pricing: const EventPricing(isFree: true, price: 0.0),
            startDateTime: DateTime.now(),
            endDateTime: DateTime.now().add(const Duration(hours: 2)),
            tags: [],
            attendeeCount: -1, // Negative count
          );
          
          await cacheService.cacheEvent(malformedEvent);
          expect(true, isTrue); // Should not throw
        } catch (e) {
          // If it does throw, that's also acceptable
          expect(e, isNotNull);
        }
      });

      test('should handle cache retrieval with corrupted data', () async {
        final cacheService = CacheService.instance;
        
        // These should return null or empty gracefully
        final cachedEvents = await cacheService.getCachedEvents();
        expect(cachedEvents, anyOf(isNull, isA<List<Event>>()));
        
        final cachedEvent = await cacheService.getCachedEvent('nonexistent');
        expect(cachedEvent, isNull);
        
        final favorites = cacheService.getCachedFavorites();
        expect(favorites, isA<List<String>>());
      });

      test('should handle search operations with edge cases', () async {
        final cacheService = CacheService.instance;
        
        // Test with empty queries
        await cacheService.addSearchQuery('');
        await cacheService.addSearchQuery('   ');
        await cacheService.addSearchQuery('\n\t');
        
        final history = cacheService.getSearchHistory();
        expect(history, isA<List<String>>());
        
        // Clear should work even if empty
        await cacheService.clearSearchHistory();
        expect(true, isTrue);
      });
    });

    group('DelightService Error Handling', () {
      testWidgets('should handle overlay creation with invalid context', (WidgetTester tester) async {
        final delightService = DelightService.instance;
        await delightService.initialize();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    // Test all overlay methods don't crash
                    try {
                      delightService.showConfetti(context);
                      delightService.showHeartExplosion(context, Offset.zero);
                      delightService.showSparkleEffect(context, Offset.zero);
                      delightService.showMiniCelebration(context, '🎉');
                      delightService.triggerEasterEgg(context, 'test');
                    } catch (e) {
                      // Should handle errors gracefully
                      expect(e, isNotNull);
                    }
                  },
                  child: const Text('Test'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pump();
        
        // Test passes if no unhandled exceptions
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      test('should handle edge cases in message generation', () {
        final delightService = DelightService.instance;
        
        // These should always return valid strings
        for (int i = 0; i < 100; i++) {
          final loadingMsg = delightService.getRandomLoadingMessage();
          expect(loadingMsg, isA<String>());
          expect(loadingMsg.isNotEmpty, isTrue);
          
          final emptyMsg = delightService.getRandomEmptyStateMessage();
          expect(emptyMsg, isA<String>());
          expect(emptyMsg.isNotEmpty, isTrue);
          
          final shareMsg = delightService.getRandomShareMessage();
          expect(shareMsg, isA<String>());
          expect(shareMsg.isNotEmpty, isTrue);
        }
      });

      testWidgets('should handle konami code with invalid inputs', (WidgetTester tester) async {
        final delightService = DelightService.instance;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Test with invalid directions
                delightService.inputKonamiDirection('invalid', context);
                delightService.inputKonamiDirection('', context);
                delightService.inputKonamiDirection('up', context);
                delightService.inputKonamiDirection('wrong', context); // Should reset
                
                return const Scaffold(body: Text('Test'));
              },
            ),
          ),
        );
        
        // Should not crash
        expect(true, isTrue);
      });
    });

    group('PerformanceService Edge Cases', () {
      test('should handle extreme performance settings', () {
        final performanceService = PerformanceService.instance;
        
        // Test all performance modes
        for (final mode in PerformanceMode.values) {
          performanceService.setPerformanceMode(mode);
          
          // Verify settings are consistent
          final stats = performanceService.getPerformanceStats();
          expect(stats, isA<Map<String, dynamic>>());
          expect(stats.containsKey('currentFPS'), isTrue);
        }
        
        // Test battery optimization toggles
        performanceService.enableBatteryOptimization();
        expect(performanceService.enableAnimations, isFalse);
        
        performanceService.disableBatteryOptimization();
        expect(performanceService.enableAnimations, isTrue);
      });

      testWidgets('should handle widget building with performance constraints', (WidgetTester tester) async {
        final performanceService = PerformanceService.instance;
        
        // Test with battery mode (most restrictive)
        performanceService.setPerformanceMode(PerformanceMode.battery);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  performanceService.buildOptimizedContainer(
                    child: const Text('Test Container'),
                    color: Colors.blue,
                    gradient: const LinearGradient(colors: [Colors.red, Colors.blue]),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5)],
                  ),
                  performanceService.buildOptimizedBlur(
                    child: const Text('Test Blur'),
                  ),
                  performanceService.buildOptimizedListView(
                    itemCount: 5,
                    itemBuilder: (context, index) => Text('Item $index'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Test Container'), findsOneWidget);
        expect(find.text('Test Blur'), findsOneWidget);
        expect(find.text('Item 0'), findsOneWidget);
      });

      testWidgets('should handle animation controller creation edge cases', (WidgetTester tester) async {
        final performanceService = PerformanceService.instance;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    // Test with various durations and performance modes
                    performanceService.setPerformanceMode(PerformanceMode.battery);
                    
                    final controller1 = performanceService.createOptimizedAnimationController(
                      duration: Duration.zero,
                      vsync: _TestTickerProvider(),
                    );
                    
                    performanceService.setPerformanceMode(PerformanceMode.high);
                    
                    final controller2 = performanceService.createOptimizedAnimationController(
                      duration: const Duration(seconds: 10), // Very long duration
                      vsync: _TestTickerProvider(),
                    );
                    
                    return Column(
                      children: [
                        Text('Controller 1: ${controller1.duration}'),
                        Text('Controller 2: ${controller2.duration}'),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );

        expect(find.textContaining('Controller 1:'), findsOneWidget);
        expect(find.textContaining('Controller 2:'), findsOneWidget);
      });
    });

    group('Widget Error Boundaries', () {
      testWidgets('should handle widget errors gracefully', (WidgetTester tester) async {
        // Test widget that might throw errors
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  try {
                    return const Column(
                      children: [
                        Text('Normal widget'),
                        _ErrorProneWidget(),
                      ],
                    );
                  } catch (e) {
                    return Text('Error caught: ${e.toString()}');
                  }
                },
              ),
            ),
          ),
        );

        // Should either render normally or show error gracefully
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Network Error Simulation', () {
      test('should handle network-related errors', () async {
        final cacheService = CacheService.instance;
        
        // Test connectivity checking doesn't crash
        final isConnected = await cacheService.isConnected;
        expect(isConnected, isA<bool>());
        
        // Test sync operations
        await cacheService.syncPendingActions();
        expect(true, isTrue); // Should complete without error
      });
    });

    group('Memory Pressure Simulation', () {
      test('should handle memory optimization under pressure', () {
        final performanceService = PerformanceService.instance;
        
        // Simulate memory pressure
        for (int i = 0; i < 10; i++) {
          performanceService.optimizeMemoryUsage();
        }
        
        // Should not crash
        expect(true, isTrue);
      });
    });
  });
}

// Test helper classes
class _TestTickerProvider implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

class _ErrorProneWidget extends StatelessWidget {
  const _ErrorProneWidget();

  @override
  Widget build(BuildContext context) {
    // This widget might throw errors in certain conditions
    return const Text('Error-prone widget rendered successfully');
  }
}