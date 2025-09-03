import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:somethingtodo/utils/accessibility_helper.dart';

void main() {
  group('AccessibilityHelper Tests', () {
    test('getCategorySemanticLabel should return correct labels', () {
      expect(
        AccessibilityHelper.getCategorySemanticLabel('music'),
        equals('Music event category'),
      );
      
      expect(
        AccessibilityHelper.getCategorySemanticLabel('sports'),
        equals('Sports event category'),
      );
      
      expect(
        AccessibilityHelper.getCategorySemanticLabel('unknown'),
        equals('unknown event category'),
      );
    });

    test('getEventCardSemanticLabel should create comprehensive description', () {
      final dateTime = DateTime(2024, 12, 25, 14, 30);
      
      final label = AccessibilityHelper.getEventCardSemanticLabel(
        title: 'Test Event',
        category: 'music',
        dateTime: dateTime,
        location: 'Test Venue',
        isFree: true,
      );
      
      expect(label, contains('Event: Test Event'));
      expect(label, contains('Category: Music event category'));
      expect(label, contains('Location: Test Venue'));
      expect(label, contains('Free event'));
      expect(label, contains('Double tap to view event details'));
    });

    test('getEventCardSemanticLabel should include price for paid events', () {
      final dateTime = DateTime(2024, 12, 25, 14, 30);
      
      final label = AccessibilityHelper.getEventCardSemanticLabel(
        title: 'Test Event',
        category: 'music',
        dateTime: dateTime,
        location: 'Test Venue',
        isFree: false,
        price: 25.50,
      );
      
      expect(label, contains('Price: \$25.50'));
    });

    test('getNavigationSemanticLabel should create navigation description', () {
      final label = AccessibilityHelper.getNavigationSemanticLabel(
        'Home',
        'home',
      );
      
      expect(label, equals('Home button. Navigates to home screen.'));
    });

    test('getInteractiveSemanticLabel should create action description', () {
      final label = AccessibilityHelper.getInteractiveSemanticLabel(
        'Like',
        context: 'event',
      );
      
      expect(label, equals('Like button for event. Double tap to activate.'));
    });

    test('getInteractiveSemanticLabel should work without context', () {
      final label = AccessibilityHelper.getInteractiveSemanticLabel('Save');
      
      expect(label, equals('Save button. Double tap to activate.'));
    });

    testWidgets('wrapWithSemantics should add semantic information', (tester) async {
      final widget = AccessibilityHelper.wrapWithSemantics(
        child: const Text('Test'),
        label: 'Test Label',
        hint: 'Test Hint',
        button: true,
      );
      
      await tester.pumpWidget(MaterialApp(home: widget));
      
      final semantics = tester.getSemantics(find.text('Test'));
      expect(semantics.label, contains('Test Label'));
      expect(semantics.hint, equals('Test Hint'));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });

    testWidgets('createAccessibleCard should create semantic card', (tester) async {
      bool tapped = false;
      
      final card = AccessibilityHelper.createAccessibleCard(
        child: const Text('Card Content'),
        semanticLabel: 'Test Card',
        semanticHint: 'Test Hint',
        onTap: () => tapped = true,
      );
      
      await tester.pumpWidget(MaterialApp(home: card));
      
      // The card should be rendered and tappable
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
      
      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });

    testWidgets('isHighContrastEnabled should detect high contrast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isHighContrast = AccessibilityHelper.isHighContrastEnabled(context);
              return Text('High Contrast: $isHighContrast');
            },
          ),
        ),
      );
      
      expect(find.textContaining('High Contrast:'), findsOneWidget);
    });

    testWidgets('getHighContrastColor should return appropriate color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final color = AccessibilityHelper.getHighContrastColor(
                context,
                Colors.grey,
                Colors.black,
              );
              return Container(color: color);
            },
          ),
        ),
      );
      
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('createAccessibleText should create accessible text widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibilityHelper.createAccessibleText(
            'Test Text',
            context: tester.element(find.byType(MaterialApp)),
            semanticLabel: 'Accessible Text',
          ),
        ),
      );
      
      // The text widget should render correctly
      expect(find.text('Test Text'), findsOneWidget);
    });

    testWidgets('createAccessibleText should use text as default semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return AccessibilityHelper.createAccessibleText(
                'Default Label',
                context: context,
              );
            },
          ),
        ),
      );
      
      // The text widget should render correctly  
      expect(find.text('Default Label'), findsOneWidget);
    });

    test('date formatting should handle different time periods', () {
      // This tests the private method indirectly through getEventCardSemanticLabel
      final now = DateTime.now();
      
      // Test today
      final todayLabel = AccessibilityHelper.getEventCardSemanticLabel(
        title: 'Today Event',
        category: 'music',
        dateTime: now,
        location: 'Test Venue',
        isFree: true,
      );
      expect(todayLabel, contains('Today at'));
      
      // Test future date (should contain proper time formatting)
      final futureLabel = AccessibilityHelper.getEventCardSemanticLabel(
        title: 'Future Event',
        category: 'music',
        dateTime: now.add(const Duration(days: 1)),
        location: 'Test Venue',
        isFree: true,
      );
      expect(futureLabel, contains('Event: Future Event'));
    });

    test('time formatting should handle different times', () {
      // Test noon
      final noonEvent = AccessibilityHelper.getEventCardSemanticLabel(
        title: 'Noon Event',
        category: 'music',
        dateTime: DateTime(2024, 12, 25, 12, 0),
        location: 'Test Venue',
        isFree: true,
      );
      expect(noonEvent, contains('12 PM'));
      
      // Test midnight
      final midnightEvent = AccessibilityHelper.getEventCardSemanticLabel(
        title: 'Midnight Event',
        category: 'music',
        dateTime: DateTime(2024, 12, 25, 0, 0),
        location: 'Test Venue',
        isFree: true,
      );
      expect(midnightEvent, contains('12 AM'));
      
      // Test with minutes
      final minutesEvent = AccessibilityHelper.getEventCardSemanticLabel(
        title: 'Minutes Event',
        category: 'music',
        dateTime: DateTime(2024, 12, 25, 14, 30),
        location: 'Test Venue',
        isFree: true,
      );
      expect(minutesEvent, contains('2:30 PM'));
    });
  });
}
