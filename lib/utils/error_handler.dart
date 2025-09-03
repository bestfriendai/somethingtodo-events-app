import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centralized error handling utility for the SomethingToDo app.
/// 
/// This class provides consistent error handling, logging, and user-friendly
/// error messages across the entire application. It follows best practices
/// for error management and provides debugging support.
class ErrorHandler {
  /// Private constructor to prevent instantiation
  const ErrorHandler._();

  /// Handles theme-related errors with appropriate fallbacks.
  /// 
  /// This method provides safe fallbacks for theme operations and logs
  /// errors for debugging purposes.
  static T handleThemeError<T>(
    String operation,
    T Function() callback,
    T fallback,
  ) {
    try {
      return callback();
    } catch (error, stackTrace) {
      _logError('Theme Error in $operation', error, stackTrace);
      return fallback;
    }
  }

  /// Handles widget build errors with safe fallbacks.
  /// 
  /// This method ensures that widget build failures don't crash the app
  /// and provides appropriate error widgets for debugging.
  static Widget handleWidgetError(
    String widgetName,
    Widget Function() builder, {
    Widget? fallback,
  }) {
    try {
      return builder();
    } catch (error, stackTrace) {
      _logError('Widget Error in $widgetName', error, stackTrace);
      return fallback ?? _createErrorWidget(widgetName, error);
    }
  }

  /// Handles async operations with proper error management.
  /// 
  /// This method provides consistent error handling for async operations
  /// and ensures proper error propagation.
  static Future<T?> handleAsyncError<T>(
    String operation,
    Future<T> Function() callback,
  ) async {
    try {
      return await callback();
    } catch (error, stackTrace) {
      _logError('Async Error in $operation', error, stackTrace);
      return null;
    }
  }

  /// Handles color parsing errors with safe fallbacks.
  /// 
  /// This method ensures that invalid color values don't crash the app
  /// and provides appropriate fallback colors.
  static Color handleColorError(
    String colorValue,
    Color fallback,
  ) {
    try {
      // Try to parse the color value
      if (colorValue.startsWith('#')) {
        final hex = colorValue.substring(1);
        return Color(int.parse('FF$hex', radix: 16));
      }
      return fallback;
    } catch (error, stackTrace) {
      _logError('Color Parsing Error', error, stackTrace);
      return fallback;
    }
  }

  /// Handles gradient creation errors with safe fallbacks.
  /// 
  /// This method ensures that invalid gradient configurations don't crash
  /// the app and provides appropriate fallback gradients.
  static LinearGradient handleGradientError(
    List<Color>? colors,
    LinearGradient fallback,
  ) {
    try {
      if (colors == null || colors.isEmpty) {
        return fallback;
      }
      return LinearGradient(colors: colors);
    } catch (error, stackTrace) {
      _logError('Gradient Creation Error', error, stackTrace);
      return fallback;
    }
  }

  /// Logs errors with appropriate detail level based on build mode.
  /// 
  /// In debug mode, provides full error details. In release mode,
  /// logs minimal information for performance.
  static void _logError(String context, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('🚨 $context: $error');
      debugPrint('📍 Stack Trace: $stackTrace');
    } else {
      // In release mode, log minimal information
      debugPrint('Error in $context: ${error.runtimeType}');
    }
  }

  /// Creates a user-friendly error widget for debugging.
  /// 
  /// This widget provides visual feedback when components fail to render
  /// and includes debugging information in debug mode.
  static Widget _createErrorWidget(String widgetName, Object error) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red, width: 1.0),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 24.0,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Error in $widgetName',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 4.0),
            Text(
              error.toString(),
              style: TextStyle(
                color: Colors.red.withValues(alpha: 0.8),
                fontSize: 10.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Validates theme configuration and returns validation results.
  /// 
  /// This method checks theme configuration for common issues and
  /// provides recommendations for fixes.
  static ThemeValidationResult validateTheme(Map<String, dynamic> config) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check for required theme properties
    if (!config.containsKey('categoryGradients')) {
      errors.add('Missing categoryGradients configuration');
    }

    if (!config.containsKey('categoryColors')) {
      errors.add('Missing categoryColors configuration');
    }

    // Check for color consistency
    final gradients = config['categoryGradients'] as Map<String, dynamic>?;
    if (gradients != null) {
      for (final entry in gradients.entries) {
        final gradient = entry.value as List<dynamic>?;
        if (gradient == null || gradient.length < 2) {
          warnings.add('Invalid gradient for category: ${entry.key}');
        }
      }
    }

    return ThemeValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// Result of theme validation containing errors and warnings.
class ThemeValidationResult {
  /// Whether the theme configuration is valid
  final bool isValid;
  
  /// List of validation errors
  final List<String> errors;
  
  /// List of validation warnings
  final List<String> warnings;

  /// Creates a new theme validation result
  const ThemeValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  /// Whether the validation has any issues
  bool get hasIssues => errors.isNotEmpty || warnings.isNotEmpty;

  /// Total number of issues found
  int get issueCount => errors.length + warnings.length;
}
