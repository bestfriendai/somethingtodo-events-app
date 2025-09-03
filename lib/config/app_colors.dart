import 'package:flutter/material.dart';

/// Application color constants and theme definitions.
///
/// This class provides centralized color management for the SomethingToDo app.
/// All colors have been updated to use a black monochromatic theme for
/// consistency and professional appearance.
class AppColors {
  /// Private constructor to prevent instantiation
  const AppColors._();
  // Primary colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A47A3);
  static const Color primaryLight = Color(0xFF9C95FF);

  // Secondary colors
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryDark = Color(0xFFE53E3E);
  static const Color secondaryLight = Color(0xFFFF9999);

  // Background colors
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFFFFFFF);

  // Utility function to get color with alpha (replaces withOpacity)
  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  // Glass effect colors
  static Color glassWhite(double alpha) =>
      Colors.white.withValues(alpha: alpha);
  static Color glassBlack(double alpha) =>
      Colors.black.withValues(alpha: alpha);
  static Color glassPrimary(double alpha) => primary.withValues(alpha: alpha);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [backgroundDark, surfaceDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
  );

  // Theme-specific gradients
  static LinearGradient cardGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ]
          : [
              Colors.black.withValues(alpha: 0.05),
              Colors.black.withValues(alpha: 0.02),
            ],
    );
  }

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  /// Event category colors - unified black theme.
  ///
  /// All event categories now use pure black (#000000) for consistent
  /// visual appearance across the application. This replaces the previous
  /// multi-colored category system with a professional monochromatic design.
  static const Map<String, Color> categoryColors = {
    'Music': Color(0xFF000000),
    'Sports': Color(0xFF000000),
    'Art': Color(0xFF000000),
    'Food': Color(0xFF000000),
    'Tech': Color(0xFF000000),
    'Comedy': Color(0xFF000000),
    'Theater': Color(0xFF000000),
    'Dance': Color(0xFF000000),
    'Business': Color(0xFF000000),
    'Other': Color(0xFF000000),
  };

  // Get category color with fallback
  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? categoryColors['Other']!;
  }

  // Status colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return info;
      case 'ongoing':
        return success;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return error;
      default:
        return Colors.grey;
    }
  }

  // Price colors
  static Color getPriceColor(double price) {
    if (price == 0) return success;
    if (price < 25) return info;
    if (price < 50) return warning;
    return error;
  }
}
