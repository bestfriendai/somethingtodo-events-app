import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:somethingtodo/services/delight_service.dart';

void main() {
  group('DelightService Tests', () {
    late DelightService delightService;

    setUp(() {
      delightService = DelightService.instance;
    });

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('should be a singleton', () {
      final instance1 = DelightService.instance;
      final instance2 = DelightService.instance;
      expect(instance1, same(instance2));
    });

    test('should initialize properly', () async {
      await delightService.initialize();
      // Test passes if no exception is thrown
      expect(true, isTrue);
    });

    test('should return random loading message', () {
      final message = delightService.getRandomLoadingMessage();
      expect(message, isA<String>());
      expect(message.isNotEmpty, isTrue);
    });

    test('should return random empty state message', () {
      final message = delightService.getRandomEmptyStateMessage();
      expect(message, isA<String>());
      expect(message.isNotEmpty, isTrue);
    });

    test('should return random share message', () {
      final message = delightService.getRandomShareMessage();
      expect(message, isA<String>());
      expect(message.isNotEmpty, isTrue);
    });

    test('should return different messages on multiple calls', () {
      final messages = <String>{};
      for (int i = 0; i < 50; i++) {
        messages.add(delightService.getRandomLoadingMessage());
      }
      // Should get at least 2 different messages in 50 calls
      expect(messages.length, greaterThan(1));
    });

    test('should detect time-based messages', () {
      final message = delightService.getTimeBasedMessage();
      // Message can be null or string depending on current time
      expect(message, anyOf(isNull, isA<String>()));
    });

    testWidgets('should show confetti overlay', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    delightService.showConfetti(context);
                  },
                  child: const Text('Show Confetti'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show confetti
      await tester.tap(find.text('Show Confetti'));
      await tester.pump();

      // Verify overlay is shown
      expect(find.byType(ConfettiOverlay), findsOneWidget);
    });

    testWidgets('should show heart explosion', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    delightService.showHeartExplosion(context, const Offset(100, 100));
                  },
                  child: const Text('Show Hearts'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show heart explosion
      await tester.tap(find.text('Show Hearts'));
      await tester.pump();

      // Verify overlay is shown
      expect(find.byType(HeartExplosion), findsOneWidget);
    });

    testWidgets('should trigger easter egg', (WidgetTester tester) async {
      await delightService.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    delightService.triggerEasterEgg(context, 'test');
                  },
                  child: const Text('Trigger Easter Egg'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to trigger easter egg
      await tester.tap(find.text('Trigger Easter Egg'));
      await tester.pump();

      // Verify toast is shown
      expect(find.byType(DelightToast), findsOneWidget);
    });

    testWidgets('should show mini celebration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    delightService.showMiniCelebration(context, '🎉');
                  },
                  child: const Text('Mini Celebration'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show mini celebration
      await tester.tap(find.text('Mini Celebration'));
      await tester.pump();

      // Verify toast is shown
      expect(find.byType(DelightToast), findsOneWidget);
    });

    testWidgets('should show sparkle effect', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    delightService.showSparkleEffect(context, const Offset(50, 50));
                  },
                  child: const Text('Show Sparkles'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show sparkle effect
      await tester.tap(find.text('Show Sparkles'));
      await tester.pump();

      // Verify overlay is shown
      expect(find.byType(SparkleEffect), findsOneWidget);
    });
  });

  group('Konami Code Tests', () {
    late DelightService delightService;

    setUp(() {
      delightService = DelightService.instance;
    });

    testWidgets('should handle konami code sequence', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => delightService.inputKonamiDirection('up', context),
                      child: const Text('Up'),
                    ),
                    ElevatedButton(
                      onPressed: () => delightService.inputKonamiDirection('down', context),
                      child: const Text('Down'),
                    ),
                    ElevatedButton(
                      onPressed: () => delightService.inputKonamiDirection('left', context),
                      child: const Text('Left'),
                    ),
                    ElevatedButton(
                      onPressed: () => delightService.inputKonamiDirection('right', context),
                      child: const Text('Right'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Input correct konami sequence: up, up, down, down, left, right, left, right
      await tester.tap(find.text('Up'));
      await tester.tap(find.text('Up'));
      await tester.tap(find.text('Down'));
      await tester.tap(find.text('Down'));
      await tester.tap(find.text('Left'));
      await tester.tap(find.text('Right'));
      await tester.tap(find.text('Left'));
      await tester.tap(find.text('Right'));
      await tester.pump();

      // Should trigger confetti and achievement
      expect(find.byType(ConfettiOverlay), findsOneWidget);
      expect(find.byType(AchievementToast), findsOneWidget);
    });
  });
}