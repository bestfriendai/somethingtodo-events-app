import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:somethingtodo/utils/error_handler.dart';

void main() {
  group('ErrorHandler Tests', () {
    test('handleThemeError should return result on success', () {
      final result = ErrorHandler.handleThemeError(
        'test operation',
        () => 'success',
        'fallback',
      );
      
      expect(result, equals('success'));
    });

    test('handleThemeError should return fallback on error', () {
      final result = ErrorHandler.handleThemeError(
        'test operation',
        () => throw Exception('test error'),
        'fallback',
      );
      
      expect(result, equals('fallback'));
    });

    test('handleColorError should parse valid hex color', () {
      final color = ErrorHandler.handleColorError('#FF0000', Colors.blue);
      
      expect(color, equals(const Color(0xFFFF0000)));
    });

    test('handleColorError should return fallback for invalid color', () {
      final color = ErrorHandler.handleColorError('invalid', Colors.blue);
      
      expect(color, equals(Colors.blue));
    });

    test('handleGradientError should create gradient from valid colors', () {
      final gradient = ErrorHandler.handleGradientError(
        [Colors.red, Colors.blue],
        const LinearGradient(colors: [Colors.black, Colors.white]),
      );
      
      expect(gradient.colors, equals([Colors.red, Colors.blue]));
    });

    test('handleGradientError should return fallback for null colors', () {
      final fallback = const LinearGradient(colors: [Colors.black, Colors.white]);
      final gradient = ErrorHandler.handleGradientError(null, fallback);
      
      expect(gradient, equals(fallback));
    });

    test('handleGradientError should return fallback for empty colors', () {
      final fallback = const LinearGradient(colors: [Colors.black, Colors.white]);
      final gradient = ErrorHandler.handleGradientError([], fallback);
      
      expect(gradient, equals(fallback));
    });

    testWidgets('handleWidgetError should return widget on success', (tester) async {
      final widget = ErrorHandler.handleWidgetError(
        'TestWidget',
        () => const Text('success'),
      );
      
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.text('success'), findsOneWidget);
    });

    testWidgets('handleWidgetError should return error widget on failure', (tester) async {
      final widget = ErrorHandler.handleWidgetError(
        'TestWidget',
        () => throw Exception('test error'),
      );
      
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error in TestWidget'), findsOneWidget);
    });

    testWidgets('handleWidgetError should use custom fallback', (tester) async {
      final fallback = const Text('custom fallback');
      final widget = ErrorHandler.handleWidgetError(
        'TestWidget',
        () => throw Exception('test error'),
        fallback: fallback,
      );
      
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.text('custom fallback'), findsOneWidget);
    });

    test('handleAsyncError should return result on success', () async {
      final result = await ErrorHandler.handleAsyncError(
        'test operation',
        () async => 'success',
      );
      
      expect(result, equals('success'));
    });

    test('handleAsyncError should return null on error', () async {
      final result = await ErrorHandler.handleAsyncError(
        'test operation',
        () async => throw Exception('test error'),
      );
      
      expect(result, isNull);
    });

    test('validateTheme should return valid result for complete config', () {
      final config = {
        'categoryGradients': {
          'music': [Colors.red, Colors.blue],
          'sports': [Colors.green, Colors.yellow],
        },
        'categoryColors': {
          'music': Colors.red,
          'sports': Colors.green,
        },
      };
      
      final result = ErrorHandler.validateTheme(config);
      
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
    });

    test('validateTheme should return errors for missing config', () {
      final config = <String, dynamic>{};
      
      final result = ErrorHandler.validateTheme(config);
      
      expect(result.isValid, isFalse);
      expect(result.errors, contains('Missing categoryGradients configuration'));
      expect(result.errors, contains('Missing categoryColors configuration'));
    });

    test('validateTheme should return warnings for invalid gradients', () {
      final config = {
        'categoryGradients': {
          'music': [Colors.red], // Invalid: only one color
          'sports': null, // Invalid: null gradient
        },
        'categoryColors': {
          'music': Colors.red,
        },
      };
      
      final result = ErrorHandler.validateTheme(config);
      
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.any((w) => w.contains('music')), isTrue);
      expect(result.warnings.any((w) => w.contains('sports')), isTrue);
    });

    test('ThemeValidationResult should calculate issues correctly', () {
      final result = ThemeValidationResult(
        isValid: false,
        errors: ['error1', 'error2'],
        warnings: ['warning1'],
      );
      
      expect(result.hasIssues, isTrue);
      expect(result.issueCount, equals(3));
    });

    test('ThemeValidationResult should handle no issues', () {
      final result = ThemeValidationResult(
        isValid: true,
        errors: [],
        warnings: [],
      );
      
      expect(result.hasIssues, isFalse);
      expect(result.issueCount, equals(0));
    });
  });
}
