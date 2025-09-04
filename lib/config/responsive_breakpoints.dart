import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Responsive breakpoints and utilities for SomethingToDo app
///
/// Defines breakpoints for mobile, tablet, and desktop layouts
/// following Material Design guidelines and modern responsive patterns
class ResponsiveBreakpoints {
  /// Prevent instantiation
  const ResponsiveBreakpoints._();

  // Breakpoint constants
  static const double mobile = 600;
  static const double tablet = 905;
  static const double desktop = 1240;

  /// Check if current screen width is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  /// Check if current screen width is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobile && width < desktop;
  }

  /// Check if current screen width is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  /// Get responsive card width based on screen size
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (isMobile(context)) {
      return screenWidth - 32; // Full width with margins
    } else if (isTablet(context)) {
      return math.min(400, screenWidth * 0.8);
    } else {
      return 400; // Fixed width for desktop
    }
  }

  /// Get responsive column count for grids
  static int getColumnCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Get responsive text scale factor
  static double getTextScaleFactor(BuildContext context) {
    if (isMobile(context)) {
      return 1.0;
    } else if (isTablet(context)) {
      return 1.1;
    } else {
      return 1.2;
    }
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    final scaleFactor = getTextScaleFactor(context);
    return baseSize * scaleFactor;
  }

  /// Get responsive spacing value
  static double getSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing;
    } else if (isTablet(context)) {
      return baseSpacing * 1.25;
    } else {
      return baseSpacing * 1.5;
    }
  }
}

/// Extension to make responsive utilities more convenient
extension ResponsiveContext on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Check if mobile
  bool get isMobile => ResponsiveBreakpoints.isMobile(this);

  /// Check if tablet
  bool get isTablet => ResponsiveBreakpoints.isTablet(this);

  /// Check if desktop
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(this);

  /// Get responsive padding
  EdgeInsets get responsivePadding =>
      ResponsiveBreakpoints.getResponsivePadding(this);

  /// Get responsive margin
  EdgeInsets get responsiveMargin =>
      ResponsiveBreakpoints.getResponsiveMargin(this);

  /// Get card width
  double get cardWidth => ResponsiveBreakpoints.getCardWidth(this);

  /// Get column count
  int get columnCount => ResponsiveBreakpoints.getColumnCount(this);

  /// Get text scale factor
  double get textScaleFactor => ResponsiveBreakpoints.getTextScaleFactor(this);
}
