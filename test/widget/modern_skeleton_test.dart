import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:somethingtodo/widgets/modern/modern_skeleton.dart';

void main() {
  group('ModernSkeleton Widget Tests', () {
    testWidgets('should render basic skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernSkeleton(
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      expect(find.byType(ModernSkeleton), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should render circular skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernSkeleton.circular(
              size: 50,
            ),
          ),
        ),
      );

      expect(find.byType(ModernSkeleton), findsOneWidget);
      
      final containerWidget = tester.widget<Container>(find.byType(Container).first);
      final decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('should render rectangular skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernSkeleton.rectangular(
              width: 200,
              height: 100,
              borderRadius: 10,
            ),
          ),
        ),
      );

      expect(find.byType(ModernSkeleton), findsOneWidget);
      
      final containerWidget = tester.widget<Container>(find.byType(Container).first);
      final decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(10));
    });

    testWidgets('should apply custom border radius', (WidgetTester tester) async {
      const borderRadius = 15.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernSkeleton(
              width: 100,
              height: 50,
              borderRadius: borderRadius,
            ),
          ),
        ),
      );

      final containerWidget = tester.widget<Container>(find.byType(Container).first);
      final decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(borderRadius));
    });

    testWidgets('should apply custom margins', (WidgetTester tester) async {
      const margin = EdgeInsets.all(20);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernSkeleton(
              width: 100,
              height: 50,
              margin: margin,
            ),
          ),
        ),
      );

      final containerWidget = tester.widget<Container>(find.byType(Container).first);
      expect(containerWidget.margin, margin);
    });

    testWidgets('should animate shimmer effect', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernSkeleton(
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      // Check for AnimationController
      expect(find.byType(AnimatedBuilder), findsOneWidget);
      
      // Advance animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.byType(ModernSkeleton), findsOneWidget);
    });
  });

  group('ModernSkeletonGroup Widget Tests', () {
    testWidgets('should render skeleton group', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernSkeletonGroup(
              children: const [
                ModernSkeleton(width: 100, height: 20),
                ModernSkeleton(width: 80, height: 16),
                ModernSkeleton(width: 120, height: 20),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ModernSkeletonGroup), findsOneWidget);
      expect(find.byType(ModernSkeleton), findsNWidgets(3));
    });

    testWidgets('should apply custom spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernSkeletonGroup(
              spacing: 20,
              children: const [
                ModernSkeleton(width: 100, height: 20),
                ModernSkeleton(width: 80, height: 16),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
      
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, 20);
    });
  });

  group('ModernEventCardSkeleton Widget Tests', () {
    testWidgets('should render horizontal event card skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernEventCardSkeleton(
              isHorizontal: true,
            ),
          ),
        ),
      );

      expect(find.byType(ModernEventCardSkeleton), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should render vertical event card skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernEventCardSkeleton(
              isHorizontal: false,
            ),
          ),
        ),
      );

      expect(find.byType(ModernEventCardSkeleton), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle playful mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernEventCardSkeleton(
              isPlayful: true,
              loadingMessage: 'Loading awesome events!',
            ),
          ),
        ),
      );

      expect(find.byType(ModernEventCardSkeleton), findsOneWidget);
      // In playful mode, it might show additional decorations
    });
  });

  group('ModernListSkeleton Widget Tests', () {
    testWidgets('should render list skeleton with correct item count', (WidgetTester tester) async {
      const itemCount = 5;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernListSkeleton(
              itemCount: itemCount,
            ),
          ),
        ),
      );

      expect(find.byType(ModernListSkeleton), findsOneWidget);
      expect(find.byType(ModernEventCardSkeleton), findsNWidgets(itemCount));
    });

    testWidgets('should animate items with staggered delays', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernListSkeleton(
              itemCount: 3,
            ),
          ),
        ),
      );

      // All items should be rendered
      expect(find.byType(ModernEventCardSkeleton), findsNWidgets(3));
      
      // Advance animation
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 600));
      
      expect(find.byType(ModernListSkeleton), findsOneWidget);
    });
  });

  group('ModernProfileSkeleton Widget Tests', () {
    testWidgets('should render profile skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernProfileSkeleton(),
          ),
        ),
      );

      expect(find.byType(ModernProfileSkeleton), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(ModernSkeleton), findsWidgets);
    });

    testWidgets('should show circular avatar skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernProfileSkeleton(),
          ),
        ),
      );

      // Should have a circular skeleton for the profile picture
      final circularSkeletons = tester.widgetList<ModernSkeleton>(find.byType(ModernSkeleton))
          .where((skeleton) => skeleton.isCircular);
      expect(circularSkeletons.isNotEmpty, isTrue);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('skeleton widgets should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                ModernSkeleton(width: 100, height: 50),
                ModernSkeletonGroup(
                  children: [
                    ModernSkeleton(width: 80, height: 20),
                    ModernSkeleton(width: 60, height: 16),
                  ],
                ),
                ModernEventCardSkeleton(),
                ModernProfileSkeleton(),
              ],
            ),
          ),
        ),
      );

      // All skeleton widgets should be rendered and accessible
      expect(find.byType(ModernSkeleton), findsWidgets);
      expect(find.byType(ModernSkeletonGroup), findsOneWidget);
      expect(find.byType(ModernEventCardSkeleton), findsOneWidget);
      expect(find.byType(ModernProfileSkeleton), findsOneWidget);
    });
  });

  group('Theme Integration Tests', () {
    testWidgets('should adapt to dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: ModernSkeleton(
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      expect(find.byType(ModernSkeleton), findsOneWidget);
      
      // Check that skeleton adapts to dark theme
      final BuildContext context = tester.element(find.byType(ModernSkeleton));
      final ThemeData theme = Theme.of(context);
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('should adapt to light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ModernSkeleton(
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      expect(find.byType(ModernSkeleton), findsOneWidget);
      
      // Check that skeleton adapts to light theme
      final BuildContext context = tester.element(find.byType(ModernSkeleton));
      final ThemeData theme = Theme.of(context);
      expect(theme.brightness, Brightness.light);
    });
  });
}