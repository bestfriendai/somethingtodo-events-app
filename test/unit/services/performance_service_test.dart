import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/scheduler.dart' as scheduler;

import 'package:somethingtodo/services/performance_service.dart';

void main() {
  group('PerformanceService Tests', () {
    late PerformanceService performanceService;

    setUp(() {
      performanceService = PerformanceService.instance;
    });

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('should be a singleton', () {
      final instance1 = PerformanceService.instance;
      final instance2 = PerformanceService.instance;
      expect(instance1, same(instance2));
    });

    test('should initialize without errors', () {
      expect(() => performanceService.initialize(), returnsNormally);
    });

    test('should have default performance settings', () {
      expect(performanceService.enableAnimations, isTrue);
      expect(performanceService.enableBlur, isTrue);
      expect(performanceService.enableShadows, isTrue);
      expect(performanceService.enableGradients, isTrue);
    });

    test('should return current FPS', () {
      final fps = performanceService.currentFPS;
      expect(fps, isA<double>());
      expect(fps, greaterThanOrEqualTo(0));
    });

    test('should set performance mode to high', () {
      performanceService.setPerformanceMode(PerformanceMode.high);
      
      expect(performanceService.enableAnimations, isTrue);
      expect(performanceService.enableBlur, isTrue);
      expect(performanceService.enableShadows, isTrue);
      expect(performanceService.enableGradients, isTrue);
    });

    test('should set performance mode to balanced', () {
      performanceService.setPerformanceMode(PerformanceMode.balanced);
      
      expect(performanceService.enableAnimations, isTrue);
      expect(performanceService.enableBlur, isFalse);
      expect(performanceService.enableShadows, isTrue);
      expect(performanceService.enableGradients, isTrue);
    });

    test('should set performance mode to battery', () {
      performanceService.setPerformanceMode(PerformanceMode.battery);
      
      expect(performanceService.enableAnimations, isFalse);
      expect(performanceService.enableBlur, isFalse);
      expect(performanceService.enableShadows, isFalse);
      expect(performanceService.enableGradients, isFalse);
    });

    test('should enable battery optimization', () {
      performanceService.enableBatteryOptimization();
      
      expect(performanceService.enableAnimations, isFalse);
      expect(performanceService.enableBlur, isFalse);
      expect(performanceService.enableShadows, isFalse);
      expect(performanceService.enableGradients, isFalse);
    });

    test('should disable battery optimization', () {
      performanceService.enableBatteryOptimization();
      performanceService.disableBatteryOptimization();
      
      expect(performanceService.enableAnimations, isTrue);
      expect(performanceService.enableBlur, isTrue);
      expect(performanceService.enableShadows, isTrue);
      expect(performanceService.enableGradients, isTrue);
    });

    test('should return performance stats', () {
      final stats = performanceService.getPerformanceStats();
      
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('currentFPS'), isTrue);
      expect(stats.containsKey('averageFPS'), isTrue);
      expect(stats.containsKey('enableAnimations'), isTrue);
      expect(stats.containsKey('enableBlur'), isTrue);
      expect(stats.containsKey('enableShadows'), isTrue);
      expect(stats.containsKey('enableGradients'), isTrue);
    });

    test('should optimize memory usage without errors', () {
      expect(() => performanceService.optimizeMemoryUsage(), returnsNormally);
    });

    testWidgets('should build optimized container', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: performanceService.buildOptimizedContainer(
              child: const Text('Test'),
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should build optimized blur with blur enabled', (WidgetTester tester) async {
      performanceService.setPerformanceMode(PerformanceMode.high);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: performanceService.buildOptimizedBlur(
              child: const Text('Blurred Text'),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.text('Blurred Text'), findsOneWidget);
    });

    testWidgets('should build container instead of blur when blur disabled', (WidgetTester tester) async {
      performanceService.setPerformanceMode(PerformanceMode.battery);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: performanceService.buildOptimizedBlur(
              child: const Text('Blurred Text'),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Blurred Text'), findsOneWidget);
    });

    testWidgets('should create optimized animation controller', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    final controller = performanceService.createOptimizedAnimationController(
                      duration: const Duration(seconds: 1),
                      vsync: TestTicker.provider(context),
                    );
                    
                    return Text('Controller created: ${controller.duration}');
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.textContaining('Controller created:'), findsOneWidget);
    });

    testWidgets('should build optimized list view', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: performanceService.buildOptimizedListView(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('should build optimized image', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: performanceService.buildOptimizedImage(
              imageUrl: 'https://example.com/test.jpg',
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, error, stackTrace) => const Icon(Icons.error),
            ),
          ),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Performance Widgets Tests', () {
    testWidgets('PerformantContainer should work', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformantContainer(
              color: Colors.red,
              child: Text('Performant Container'),
            ),
          ),
        ),
      );

      expect(find.byType(PerformantContainer), findsOneWidget);
      expect(find.text('Performant Container'), findsOneWidget);
    });

    testWidgets('PerformantBlur should work', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformantBlur(
              child: Text('Performant Blur'),
            ),
          ),
        ),
      );

      expect(find.byType(PerformantBlur), findsOneWidget);
      expect(find.text('Performant Blur'), findsOneWidget);
    });

    testWidgets('PerformantListView should work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformantListView(
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Performant Item $index'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(PerformantListView), findsOneWidget);
      expect(find.text('Performant Item 0'), findsOneWidget);
      expect(find.text('Performant Item 1'), findsOneWidget);
    });
  });

  group('PerformanceMode enum Tests', () {
    test('should have correct enum values', () {
      expect(PerformanceMode.values.length, 3);
      expect(PerformanceMode.values.contains(PerformanceMode.high), isTrue);
      expect(PerformanceMode.values.contains(PerformanceMode.balanced), isTrue);
      expect(PerformanceMode.values.contains(PerformanceMode.battery), isTrue);
    });
  });
}

// Helper class for testing

class TestTicker {
  static TickerProvider provider(BuildContext context) {
    return _TestTickerProvider();
  }
}

class _TestTickerProvider implements TickerProvider {
  @override
  scheduler.Ticker createTicker(scheduler.TickerCallback onTick) {
    return scheduler.Ticker(onTick);
  }
}