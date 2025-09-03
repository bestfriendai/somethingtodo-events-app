import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;

/// UI validation utilities for checking theme consistency and accessibility
class UIValidation {
  /// Prevent instantiation
  const UIValidation._();

  /// Validate color contrast ratio meets WCAG standards
  static bool validateContrast(
    Color foreground,
    Color background, {
    double minRatio = 4.5,
  }) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();

    final ratio =
        (math.max(fgLuminance, bgLuminance) + 0.05) /
        (math.min(fgLuminance, bgLuminance) + 0.05);

    return ratio >= minRatio;
  }

  /// Validate touch target meets accessibility guidelines (minimum 44px)
  static bool validateTouchTarget(
    double width,
    double height, {
    double minSize = 44.0,
  }) {
    return width >= minSize && height >= minSize;
  }

  /// Validate theme consistency across color scheme
  static List<String> validateThemeConsistency(ThemeData theme) {
    final issues = <String>[];
    final colorScheme = theme.colorScheme;

    // Check if color scheme is properly defined
    if (colorScheme.primary == colorScheme.secondary) {
      issues.add('Primary and secondary colors are identical');
    }

    // Check contrast ratios for key color combinations
    if (!validateContrast(colorScheme.onPrimary, colorScheme.primary)) {
      issues.add('Primary text contrast ratio is insufficient');
    }

    if (!validateContrast(colorScheme.onSurface, colorScheme.surface)) {
      issues.add('Surface text contrast ratio is insufficient');
    }

    // Check if Material 3 is properly enabled
    if (!theme.useMaterial3) {
      issues.add('Material 3 is not enabled');
    }

    return issues;
  }

  /// Check for deprecated color usage patterns
  static List<String> checkDeprecatedUsage(String code) {
    final issues = <String>[];

    // Check for withOpacity usage
    if (code.contains('withOpacity(')) {
      issues.add('withOpacity() is deprecated, use withValues(alpha:) instead');
    }

    // Check for outdated Material 2 color properties
    if (code.contains('primaryColorDark') ||
        code.contains('primaryColorLight')) {
      issues.add('Material 2 color properties detected, migrate to Material 3');
    }

    return issues;
  }

  /// Log UI validation results
  static void logValidationResults(List<String> issues, String context) {
    if (issues.isEmpty) {
      developer.log(
        '✅ UI Validation passed for $context',
        name: 'UIValidation',
        level: 800,
      );
    } else {
      developer.log(
        '⚠️ UI Validation issues found in $context:',
        name: 'UIValidation',
        level: 900,
      );
      for (final issue in issues) {
        developer.log('  - $issue', name: 'UIValidation', level: 900);
      }
    }
  }

  /// Quick validation for development builds
  static void quickValidation(BuildContext context) {
    final theme = Theme.of(context);
    final issues = validateThemeConsistency(theme);
    logValidationResults(issues, 'Theme Consistency');
  }
}

/// Extension to add validation methods to ThemeData
extension ThemeValidation on ThemeData {
  /// Validate this theme data
  List<String> validate() => UIValidation.validateThemeConsistency(this);

  /// Check if theme is Material 3 compliant
  bool get isMaterial3Compliant => useMaterial3;

  /// Get contrast ratio for primary colors
  double get primaryContrastRatio {
    final fgLuminance = colorScheme.onPrimary.computeLuminance();
    final bgLuminance = colorScheme.primary.computeLuminance();
    return (math.max(fgLuminance, bgLuminance) + 0.05) /
        (math.min(fgLuminance, bgLuminance) + 0.05);
  }
}
