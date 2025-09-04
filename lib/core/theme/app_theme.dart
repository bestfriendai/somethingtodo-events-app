import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized theme configuration for SomethingToDo app
///
/// This file consolidates all theme-related configurations including:
/// - Color schemes for light and dark modes
/// - Typography definitions
/// - Component themes
/// - Spacing and sizing constants
/// - Animation configurations
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  // ============================================================================
  // COLOR PALETTE
  // ============================================================================

  /// Primary brand colors
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 700

  /// Secondary colors
  static const Color secondaryColor = Color(0xFF7C3AED); // Violet 600
  static const Color tertiaryColor = Color(0xFF059669); // Emerald 600
  static const Color accentColor = Color(0xFF6B7280); // Gray 500

  /// Semantic colors
  static const Color successColor = Color(0xFF059669); // Emerald 600
  static const Color warningColor = Color(0xFFD97706); // Amber 600
  static const Color errorColor = Color(0xFFDC2626); // Red 600
  static const Color infoColor = Color(0xFF3B82F6); // Blue 500

  /// Dark theme colors
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkSurface = Color(0xFF1E1E3F);
  static const Color darkCard = Color(0xFF2D2D5F);

  /// Light theme colors
  static const Color lightBackground = Color(0xFFFAFBFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);

  /// Event category gradient (black theme)
  static const List<Color> blackGradient = [
    Color(0xFF000000),
    Color(0xFF1A1A1A),
  ];

  // ============================================================================
  // SPACING SYSTEM
  // ============================================================================

  static const double space2xs = 2.0;
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2xl = 48.0;
  static const double space3xl = 64.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 28.0;
  static const double radiusFull = 999.0;

  // ============================================================================
  // ANIMATION
  // ============================================================================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 600);

  static const Curve curveEaseInOut = Curves.easeInOutCubic;
  static const Curve curveEaseOut = Curves.easeOutCubic;
  static const Curve curveBounce = Curves.elasticOut;

  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================

  static String get fontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';

  static TextTheme get textTheme => TextTheme(
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.1,
      fontFamily: fontFamily,
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
      fontFamily: fontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      height: 1.3,
      fontFamily: fontFamily,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.3,
      fontFamily: fontFamily,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
      fontFamily: fontFamily,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
      fontFamily: fontFamily,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.5,
      fontFamily: fontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.5,
      fontFamily: fontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.5,
      fontFamily: fontFamily,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.5,
      fontFamily: fontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
      fontFamily: fontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.5,
      fontFamily: fontFamily,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      fontFamily: fontFamily,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      fontFamily: fontFamily,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      fontFamily: fontFamily,
    ),
  );

  // ============================================================================
  // THEME DATA
  // ============================================================================

  /// Dark theme configuration
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: darkSurface,
      error: errorColor,
    ),
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCard,
    textTheme: GoogleFonts.interTextTheme(textTheme).apply(
      bodyColor: Colors.white.withOpacity(0.9),
      displayColor: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXl),
      ),
      color: darkCard,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: spaceLg,
          vertical: spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spaceMd,
        vertical: spaceMd,
      ),
    ),
  );

  /// Light theme configuration
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: lightSurface,
      error: errorColor,
    ),
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightCard,
    textTheme: GoogleFonts.interTextTheme(textTheme).apply(
      bodyColor: const Color(0xFF1E293B),
      displayColor: const Color(0xFF0F172A),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF0F172A),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXl),
      ),
      color: lightCard,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: spaceLg,
          vertical: spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spaceMd,
        vertical: spaceMd,
      ),
    ),
  );

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get elevation shadow based on theme brightness
  static List<BoxShadow> getElevation(
    BuildContext context, {
    double elevation = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.black : Colors.black.withOpacity(0.1);

    return [
      BoxShadow(
        color: color.withOpacity(0.1 * elevation),
        blurRadius: 4 * elevation,
        offset: Offset(0, 2 * elevation),
      ),
    ];
  }

  /// Check if dark mode is enabled
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get category gradient colors
  static List<Color> getCategoryGradient(String? category) {
    // All categories now use the black gradient for consistency
    return blackGradient;
  }
}
