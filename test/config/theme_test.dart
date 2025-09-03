import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:somethingtodo/config/modern_theme.dart';
import 'package:somethingtodo/config/app_colors.dart';

void main() {
  group('ModernTheme Tests', () {
    test('all category gradients should be black', () {
      // Test that all category gradients use black colors
      final gradients = ModernTheme.categoryGradients;
      
      for (final entry in gradients.entries) {
        final gradient = entry.value;
        expect(gradient.length, equals(2));
        expect(gradient[0], equals(const Color(0xFF000000))); // Pure black
        expect(gradient[1], equals(const Color(0xFF1A1A1A))); // Dark gray
      }
    });

    test('should have all required categories', () {
      final gradients = ModernTheme.categoryGradients;
      
      // Check that all expected categories are present
      expect(gradients.containsKey('technology'), isTrue);
      expect(gradients.containsKey('tech'), isTrue);
      expect(gradients.containsKey('arts'), isTrue);
      expect(gradients.containsKey('art'), isTrue);
      expect(gradients.containsKey('sports'), isTrue);
      expect(gradients.containsKey('sport'), isTrue);
      expect(gradients.containsKey('food'), isTrue);
      expect(gradients.containsKey('dining'), isTrue);
      expect(gradients.containsKey('music'), isTrue);
      expect(gradients.containsKey('entertainment'), isTrue);
      expect(gradients.containsKey('business'), isTrue);
      expect(gradients.containsKey('professional'), isTrue);
      expect(gradients.containsKey('education'), isTrue);
      expect(gradients.containsKey('learning'), isTrue);
      expect(gradients.containsKey('health'), isTrue);
      expect(gradients.containsKey('wellness'), isTrue);
      expect(gradients.containsKey('community'), isTrue);
      expect(gradients.containsKey('social'), isTrue);
      expect(gradients.containsKey('other'), isTrue);
    });

    test('category aliases should have same gradients', () {
      final gradients = ModernTheme.categoryGradients;
      
      // Test that aliases have the same gradients as their main categories
      expect(gradients['technology'], equals(gradients['tech']));
      expect(gradients['arts'], equals(gradients['art']));
      expect(gradients['sports'], equals(gradients['sport']));
      expect(gradients['food'], equals(gradients['dining']));
      expect(gradients['music'], equals(gradients['entertainment']));
      expect(gradients['business'], equals(gradients['professional']));
      expect(gradients['education'], equals(gradients['learning']));
      expect(gradients['health'], equals(gradients['wellness']));
      expect(gradients['community'], equals(gradients['social']));
    });
  });

  group('AppColors Tests', () {
    test('all category colors should be black', () {
      final categoryColors = AppColors.categoryColors;
      
      for (final entry in categoryColors.entries) {
        expect(entry.value, equals(const Color(0xFF000000)));
      }
    });

    test('should have all required category colors', () {
      final categoryColors = AppColors.categoryColors;
      
      expect(categoryColors.containsKey('Music'), isTrue);
      expect(categoryColors.containsKey('Sports'), isTrue);
      expect(categoryColors.containsKey('Art'), isTrue);
      expect(categoryColors.containsKey('Food'), isTrue);
      expect(categoryColors.containsKey('Tech'), isTrue);
      expect(categoryColors.containsKey('Comedy'), isTrue);
      expect(categoryColors.containsKey('Theater'), isTrue);
      expect(categoryColors.containsKey('Dance'), isTrue);
      expect(categoryColors.containsKey('Business'), isTrue);
      expect(categoryColors.containsKey('Other'), isTrue);
    });
  });
}
