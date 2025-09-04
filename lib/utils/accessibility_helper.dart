import 'package:flutter/material.dart';

/// Accessibility helper utilities for the SomethingToDo app.
///
/// This class provides comprehensive accessibility support including
/// semantic labels, screen reader support, and high contrast themes
/// for users with disabilities.
class AccessibilityHelper {
  /// Private constructor to prevent instantiation
  const AccessibilityHelper._();

  /// Creates semantic labels for event categories.
  ///
  /// This method provides descriptive labels for screen readers
  /// to announce event categories in a user-friendly way.
  static String getCategorySemanticLabel(String category) {
    final categoryLabels = {
      'music': 'Music event category',
      'sports': 'Sports event category',
      'food': 'Food and dining event category',
      'art': 'Arts and culture event category',
      'tech': 'Technology event category',
      'business': 'Business and professional event category',
      'education': 'Educational event category',
      'health': 'Health and wellness event category',
      'community': 'Community event category',
      'other': 'Other event category',
    };

    return categoryLabels[category.toLowerCase()] ??
        '${category.toLowerCase()} event category';
  }

  /// Creates semantic labels for event cards.
  ///
  /// This method provides comprehensive descriptions for screen readers
  /// to announce event information in an accessible format.
  static String getEventCardSemanticLabel({
    required String title,
    required String category,
    required DateTime dateTime,
    required String location,
    required bool isFree,
    double? price,
  }) {
    final buffer = StringBuffer();

    // Event title
    buffer.write('Event: $title. ');

    // Category
    buffer.write('Category: ${getCategorySemanticLabel(category)}. ');

    // Date and time
    final formattedDate = _formatDateForScreenReader(dateTime);
    buffer.write('Date and time: $formattedDate. ');

    // Location
    buffer.write('Location: $location. ');

    // Pricing
    if (isFree) {
      buffer.write('Free event. ');
    } else if (price != null) {
      buffer.write('Price: \$${price.toStringAsFixed(2)}. ');
    }

    // Action hint
    buffer.write('Double tap to view event details.');

    return buffer.toString();
  }

  /// Creates semantic labels for navigation buttons.
  ///
  /// This method provides clear action descriptions for navigation
  /// elements to improve screen reader accessibility.
  static String getNavigationSemanticLabel(String action, String destination) {
    return '$action button. Navigates to $destination screen.';
  }

  /// Creates semantic labels for interactive elements.
  ///
  /// This method provides action-oriented descriptions for buttons
  /// and other interactive elements.
  static String getInteractiveSemanticLabel(String action, {String? context}) {
    final buffer = StringBuffer();
    buffer.write('$action button');

    if (context != null) {
      buffer.write(' for $context');
    }

    buffer.write('. Double tap to activate.');
    return buffer.toString();
  }

  /// Wraps a widget with semantic information for accessibility.
  ///
  /// This method adds comprehensive semantic information to widgets
  /// to improve screen reader support and navigation.
  static Widget wrapWithSemantics({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? focusable,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button ?? false,
      header: header ?? false,
      focusable: focusable ?? true,
      onTap: onTap,
      child: child,
    );
  }

  /// Creates an accessible card widget with proper semantic structure.
  ///
  /// This method wraps card content with appropriate semantic information
  /// for screen readers and keyboard navigation.
  static Widget createAccessibleCard({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint ?? 'Double tap to interact',
      button: onTap != null,
      focusable: true,
      onTap: onTap,
      child: Card(
        color: backgroundColor,
        child: InkWell(onTap: onTap, child: child),
      ),
    );
  }

  /// Checks if high contrast mode is enabled.
  ///
  /// This method detects system-level high contrast settings
  /// and can be used to adjust UI accordingly.
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Gets appropriate colors for high contrast mode.
  ///
  /// This method provides high contrast color alternatives
  /// for better accessibility compliance.
  static Color getHighContrastColor(
    BuildContext context,
    Color normalColor,
    Color highContrastColor,
  ) {
    return isHighContrastEnabled(context) ? highContrastColor : normalColor;
  }

  /// Creates accessible text with proper contrast ratios.
  ///
  /// This method ensures text meets WCAG accessibility guidelines
  /// for color contrast and readability.
  static Widget createAccessibleText(
    String text, {
    required BuildContext context,
    TextStyle? style,
    Color? backgroundColor,
    String? semanticLabel,
  }) {
    final effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    final textColor = effectiveStyle?.color ?? Colors.black;

    // Ensure sufficient contrast for accessibility
    final contrastColor = _ensureContrast(textColor, backgroundColor);

    return Semantics(
      label: semanticLabel ?? text,
      child: Text(text, style: effectiveStyle?.copyWith(color: contrastColor)),
    );
  }

  /// Formats date and time for screen reader announcement.
  ///
  /// This method creates human-readable date/time strings that
  /// are optimized for screen reader pronunciation.
  static String _formatDateForScreenReader(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTimeForScreenReader(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow at ${_formatTimeForScreenReader(dateTime)}';
    } else if (difference.inDays < 7) {
      final weekday = _getWeekdayName(dateTime.weekday);
      return '$weekday at ${_formatTimeForScreenReader(dateTime)}';
    } else {
      final month = _getMonthName(dateTime.month);
      return '$month ${dateTime.day} at ${_formatTimeForScreenReader(dateTime)}';
    }
  }

  /// Formats time for screen reader announcement.
  static String _formatTimeForScreenReader(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    if (minute == 0) {
      return '$displayHour $period';
    } else {
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// Gets weekday name for screen reader.
  static String _getWeekdayName(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  /// Gets month name for screen reader.
  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Ensures sufficient color contrast for accessibility.
  static Color _ensureContrast(Color textColor, Color? backgroundColor) {
    if (backgroundColor == null) return textColor;

    // Calculate relative luminance and adjust if needed
    final textLuminance = _calculateLuminance(textColor);
    final backgroundLuminance = _calculateLuminance(backgroundColor);

    final contrastRatio = (textLuminance + 0.05) / (backgroundLuminance + 0.05);

    // WCAG AA requires 4.5:1 contrast ratio for normal text
    if (contrastRatio < 4.5) {
      return backgroundLuminance > 0.5 ? Colors.black : Colors.white;
    }

    return textColor;
  }

  /// Calculates relative luminance of a color.
  static double _calculateLuminance(Color color) {
    final r = (color.r * 255.0).round() / 255.0;
    final g = (color.g * 255.0).round() / 255.0;
    final b = (color.b * 255.0).round() / 255.0;

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
}
