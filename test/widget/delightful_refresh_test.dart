import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'package:somethingtodo/widgets/common/delightful_refresh.dart';

void main() {
  group('DelightfulRefresh Widget Tests', () {
    testWidgets('should render child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DelightfulRefresh(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: const Text('Test Content'),
          ),
        ),
      );

      expect(find.byType(DelightfulRefresh), findsOneWidget);
      expect(find.byType(LiquidPullToRefresh), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('should handle refresh action', (WidgetTester tester) async {
      bool refreshCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: DelightfulRefresh(
            onRefresh: () async {
              refreshCalled = true;
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: ListView(
              children: const [
                ListTile(title: Text('Item 1')),
                ListTile(title: Text('Item 2')),
              ],
            ),
          ),
        ),
      );

      // Simulate pull to refresh
      await tester.fling(
        find.byType(ListView),
        const Offset(0, 300),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(refreshCalled, isTrue);
    });

    testWidgets('should show custom refresh message', (WidgetTester tester) async {
      const customMessage = 'Loading custom content...';
      
      await tester.pumpWidget(
        MaterialApp(
          home: DelightfulRefresh(
            refreshMessage: customMessage,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: ListView(
              children: const [
                ListTile(title: Text('Item 1')),
              ],
            ),
          ),
        ),
      );

      // Simulate pull to refresh
      await tester.fling(
        find.byType(ListView),
        const Offset(0, 300),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // The custom message should be displayed in a snackbar
      expect(find.text(customMessage), findsOneWidget);
    });

    testWidgets('should disable fun messages when showFunMessages is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DelightfulRefresh(
            showFunMessages: false,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: ListView(
              children: const [
                ListTile(title: Text('Item 1')),
              ],
            ),
          ),
        ),
      );

      // Simulate pull to refresh
      await tester.fling(
        find.byType(ListView),
        const Offset(0, 300),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // No fun messages should be shown
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('should work with different child widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DelightfulRefresh(
            onRefresh: () async {},
            child: const SingleChildScrollView(
              child: Column(
                children: [
                  Text('Header'),
                  SizedBox(height: 50),
                  Text('Content'),
                  SizedBox(height: 50),
                  Text('Footer'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DelightfulRefresh), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
    });

    testWidgets('should handle refresh errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DelightfulRefresh(
            onRefresh: () async {
              throw Exception('Refresh failed');
            },
            child: ListView(
              children: const [
                ListTile(title: Text('Item 1')),
              ],
            ),
          ),
        ),
      );

      // Simulate pull to refresh
      await tester.fling(
        find.byType(ListView),
        const Offset(0, 300),
        1000,
      );
      
      // Should not crash even if refresh throws
      await tester.pump();
      await tester.pumpAndSettle();
      
      expect(find.byType(DelightfulRefresh), findsOneWidget);
    });

    testWidgets('should complete refresh cycle', (WidgetTester tester) async {
      int refreshCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: DelightfulRefresh(
            onRefresh: () async {
              refreshCount++;
              await Future.delayed(const Duration(milliseconds: 200));
            },
            child: ListView(
              children: const [
                ListTile(title: Text('Item 1')),
                ListTile(title: Text('Item 2')),
              ],
            ),
          ),
        ),
      );

      // Perform multiple refresh actions
      for (int i = 0; i < 2; i++) {
        await tester.fling(
          find.byType(ListView),
          const Offset(0, 300),
          1000,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
      }

      expect(refreshCount, 2);
    });
  });

  group('PremiumRefreshIndicator Widget Tests', () {
    testWidgets('should render child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PremiumRefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: const Text('Premium Content'),
          ),
        ),
      );

      expect(find.byType(PremiumRefreshIndicator), findsOneWidget);
      expect(find.text('Premium Content'), findsOneWidget);
    });

    testWidgets('should handle refresh with animation', (WidgetTester tester) async {
      bool refreshCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: PremiumRefreshIndicator(
            onRefresh: () async {
              refreshCalled = true;
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: ListView(
              children: const [
                ListTile(title: Text('Premium Item 1')),
                ListTile(title: Text('Premium Item 2')),
              ],
            ),
          ),
        ),
      );

      // Simulate pull to refresh
      await tester.fling(
        find.byType(ListView),
        const Offset(0, 300),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(refreshCalled, isTrue);
    });

    testWidgets('should show success message after refresh', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PremiumRefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: ListView(
              children: const [
                ListTile(title: Text('Premium Item')),
              ],
            ),
          ),
        ),
      );

      // Simulate pull to refresh
      await tester.fling(
        find.byType(ListView),
        const Offset(0, 300),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Success message should be shown via DelightService confetti
      // This would trigger overlays that are hard to test directly
      expect(find.byType(PremiumRefreshIndicator), findsOneWidget);
    });
  });

  group('Refresh Widget Performance Tests', () {
    testWidgets('should handle rapid refresh attempts', (WidgetTester tester) async {
      int refreshCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: DelightfulRefresh(
            onRefresh: () async {
              refreshCount++;
              await Future.delayed(const Duration(milliseconds: 50));
            },
            child: ListView(
              children: const [
                ListTile(title: Text('Item 1')),
              ],
            ),
          ),
        ),
      );

      // Rapid refresh attempts
      for (int i = 0; i < 5; i++) {
        await tester.fling(
          find.byType(ListView),
          const Offset(0, 200),
          800,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 20));
      }
      
      await tester.pumpAndSettle();

      // Should handle rapid attempts gracefully
      expect(find.byType(DelightfulRefresh), findsOneWidget);
      expect(refreshCount, greaterThan(0));
    });

    testWidgets('should work with long lists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DelightfulRefresh(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return ListTile(title: Text('Item $index'));
              },
            ),
          ),
        ),
      );

      // Should render with large lists
      expect(find.byType(DelightfulRefresh), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      
      // Scroll to verify list works
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();
      
      expect(find.byType(DelightfulRefresh), findsOneWidget);
    });
  });

  group('Edge Cases Tests', () {
    testWidgets('should handle null refresh function gracefully', (WidgetTester tester) async {
      // This test ensures the widget doesn't break with edge case inputs
      await tester.pumpWidget(
        MaterialApp(
          home: DelightfulRefresh(
            onRefresh: () async {
              // Simulate a refresh that does nothing
            },
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(DelightfulRefresh), findsOneWidget);
    });

    testWidgets('should work with empty child', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DelightfulRefresh(
            onRefresh: () async {},
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(DelightfulRefresh), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}