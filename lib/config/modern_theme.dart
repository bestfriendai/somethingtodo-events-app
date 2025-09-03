import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern theme configuration for the SomethingToDo app.
///
/// This class provides a comprehensive theme system with black-based
/// category gradients, modern color palettes, and consistent styling
/// across the entire application.
///
/// The theme has been updated to use a monochromatic black design
/// for all event categories and UI components.
class ModernTheme {
  /// Private constructor to prevent instantiation
  const ModernTheme._();
  // 2025 Ultra-Modern Color Palette (Refined & Professional)
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo 600 - More accessible
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400 - For lighter elements
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 700 - For emphasis
  static const Color secondaryColor = Color(0xFF7C3AED); // Violet 600
  static const Color tertiaryColor = Color(0xFF059669); // Emerald 600 - For success states
  static const Color accentColor = Color(0xFF6B7280); // Gray 500 - Better contrast
  static const Color warningColor = Color(0xFFD97706); // Amber 600 - More accessible
  static const Color errorColor = Color(0xFFDC2626); // Red 600 - Better contrast
  static const Color successColor = Color(0xFF059669); // Emerald 600

  // Enhanced Dark Theme Colors - Better contrast and readability
  static const Color darkBackground = Color(0xFF0F0F23); // Deep indigo-black for sophistication
  static const Color darkSurface = Color(0xFF1E1E3F); // Slightly lighter with indigo tint
  static const Color darkCardSurface = Color(0xFF2D2D5F); // Card surface with subtle indigo
  static const Color darkSurfaceVariant = Color(0xFF374151); // For different elevation levels
  static const Color darkOnSurface = Color(0xFFE5E7EB); // Softer white for better readability
  static const Color darkOnBackground = Color(0xFFD1D5DB); // Light gray with better contrast
  static const Color darkOnSurfaceVariant = Color(0xFF9CA3AF); // For secondary text

  // Enhanced Light Theme Colors - Better hierarchy and contrast
  static const Color lightBackground = Color(0xFFFAFBFF); // Subtle blue tint
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardSurface = Color(0xFFF1F5F9); // Slate 50
  static const Color lightSurfaceVariant = Color(0xFFE2E8F0); // Slate 200
  static const Color lightOnSurface = Color(0xFF0F172A); // Slate 900
  static const Color lightOnBackground = Color(0xFF1E293B); // Slate 800
  static const Color lightOnSurfaceVariant = Color(0xFF475569); // Slate 600

  // Modern Professional Gradients - Refined and accessible
  static const List<Color> primaryGradient = [
    primaryColor,
    primaryLight,
  ];

  static const List<Color> sunsetGradient = [
    Color(0xFFF59E0B), // Amber 500
    Color(0xFFEF4444), // Red 500
  ];

  static const List<Color> oceanGradient = [
    Color(0xFF0EA5E9), // Sky 500
    Color(0xFF3B82F6), // Blue 500
  ];

  static const List<Color> forestGradient = [
    Color(0xFF10B981), // Emerald 500
    Color(0xFF059669), // Emerald 600
  ];

  static const List<Color> purpleGradient = [
    primaryColor,
    secondaryColor,
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981), // Emerald 500
    Color(0xFF059669), // Emerald 600
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF59E0B), // Amber 500
    Color(0xFFD97706), // Amber 600
  ];

  static const List<Color> errorGradient = [
    Color(0xFFEF4444), // Red 500
    errorColor,
  ];

  static const List<Color> neonGradient = [
    Color(0xFF06B6D4), // Cyan 500
    Color(0xFF3B82F6), // Blue 500
  ];

  static const List<Color> pinkGradient = [
    Color(0xFFEC4899), // Pink 500
    Color(0xFFF97316), // Orange 500
  ];

  // NEW: Aurora Borealis gradient for backgrounds
  static const List<Color> auroraGradient = [
    Color(0xFF0A0A0B), // Rich Black
    Color(0xFF374151), // Cool Gray
    Color(0xFF6B7280), // Medium Gray
    Color(0xFF4B5563), // Dark Gray
    Color(0xFF0A0A0B), // Back to Rich Black
  ];

  // NEW: Mesh gradient for modern backgrounds
  static const List<Color> meshGradient = [
    Color(0xFF0A0A0B),
    Color(0xFF1A0A1A),
    Color(0xFF0A1A1A),
    Color(0xFF0A0A0B),
  ];

  // NEW: Glassmorphic colors
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x2AFFFFFF);


  // Typography - Inter font for modern feel with NotoSans fallback
  static String get primaryFont => GoogleFonts.inter().fontFamily ?? 'NotoSans';
  static String get displayFont => GoogleFonts.inter().fontFamily ?? 'NotoSans';

  static TextTheme get modernTextTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      height: 1.3,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.5,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.5,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
    ),
  );

  // Enhanced Dark Theme - Modern and accessible
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: primaryFont,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: primaryDark,
      onPrimaryContainer: primaryLight,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: tertiaryColor,
      onTertiary: Colors.white,
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceContainerHighest: darkCardSurface,
      surfaceContainerHigh: darkSurfaceVariant,
      onSurfaceVariant: darkOnSurfaceVariant,
      error: errorColor,
      onError: Colors.white,
      outline: Color(0xFF6B7280),
      outlineVariant: Color(0xFF374151),
    ),
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCardSurface,
    textTheme: GoogleFonts.interTextTheme(
      modernTextTheme,
    ).apply(bodyColor: darkOnBackground, displayColor: darkOnSurface),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: darkOnSurface,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: 'NotoSans',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: darkOnSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: 'NotoSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: darkCardSurface,
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  // Enhanced Light Theme - Clean and professional
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: primaryFont,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: primaryLight,
      onPrimaryContainer: primaryDark,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: tertiaryColor,
      onTertiary: Colors.white,
      surface: lightSurface,
      onSurface: lightOnSurface,
      surfaceContainerHighest: lightCardSurface,
      surfaceContainerHigh: lightSurfaceVariant,
      onSurfaceVariant: lightOnSurfaceVariant,
      error: errorColor,
      onError: Colors.white,
      outline: Color(0xFF6B7280),
      outlineVariant: Color(0xFFE2E8F0),
    ),
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightCardSurface,
    textTheme: GoogleFonts.interTextTheme(
      modernTextTheme,
    ).apply(bodyColor: lightOnBackground, displayColor: lightOnSurface),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: lightOnSurface,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: 'NotoSans',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: lightOnSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: 'NotoSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: lightCardSurface,
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  // Modern container with neumorphic elements
  static BoxDecoration modernCardDecoration({
    bool isDark = true,
    List<Color>? gradient,
    double borderRadius = 20,
  }) {
    if (gradient != null) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );
    }

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: isDark ? darkCardSurface : lightCardSurface,
      boxShadow: [
        if (isDark) ...[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ] else ...[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ],
    );
  }

  // Modern button decoration
  static BoxDecoration modernButtonDecoration({
    required List<Color> gradient,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradient,
      ),
      boxShadow: [
        BoxShadow(
          color: gradient.first.withValues(alpha: 0.4),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // 2025 Animated background decoration with aurora effects
  static BoxDecoration modernBackgroundDecoration({
    List<Color>? gradient,
    bool useAuroraEffect = false,
  }) {
    if (useAuroraEffect) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: auroraGradient,
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      );
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            gradient ??
            [
              const Color(0xFF0A0A0B), // Rich black
              const Color(0xFF111111),
              const Color(0xFF1A1A1B),
            ],
      ),
    );
  }

  // NEW: Glassmorphic decoration
  static BoxDecoration glassmorphicDecoration({
    double borderRadius = 20,
    double blur = 10,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: glassWhite,
      border: Border.all(color: glassBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // NEW: Floating navigation bar decoration
  static BoxDecoration floatingNavDecoration({bool isDark = true}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      color: isDark
          ? const Color(0x90111111) // Semi-transparent dark
          : const Color(0x90FFFFFF), // Semi-transparent white
      border: Border.all(
        color: isDark ? glassBorder : Colors.black12,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Black gradient variations for all event categories.
  ///
  /// All categories now use consistent black gradients ranging from
  /// pure black (#000000) to dark gray (#1A1A1A) for a professional,
  /// monochromatic appearance.
  ///
  /// This replaces the previous colorful category system with a unified
  /// black theme that provides better visual consistency.
  static const Map<String, List<Color>> categoryGradients = {
    // Technology: Black gradient
    'technology': [
      Color(0xFF000000),
      Color(0xFF1A1A1A),
    ], // Pure Black to Dark Gray
    'tech': [Color(0xFF000000), Color(0xFF1A1A1A)], // Alias for technology
    // Arts: Black gradient
    'arts': [Color(0xFF000000), Color(0xFF1A1A1A)], // Pure Black to Dark Gray
    'art': [Color(0xFF000000), Color(0xFF1A1A1A)], // Alias for arts
    // Sports: Black gradient
    'sports': [Color(0xFF000000), Color(0xFF1A1A1A)], // Pure Black to Dark Gray
    'sport': [Color(0xFF000000), Color(0xFF1A1A1A)], // Alias for sports
    // Food: Black gradient
    'food': [Color(0xFF000000), Color(0xFF1A1A1A)], // Pure Black to Dark Gray
    'dining': [Color(0xFF000000), Color(0xFF1A1A1A)], // Alias for food
    // Music: Black gradient
    'music': [Color(0xFF000000), Color(0xFF1A1A1A)], // Pure Black to Dark Gray
    'entertainment': [Color(0xFF000000), Color(0xFF1A1A1A)], // Alias for music
    // Business: Black gradient
    'business': [
      Color(0xFF000000),
      Color(0xFF1A1A1A),
    ], // Pure Black to Dark Gray
    'professional': [
      Color(0xFF000000),
      Color(0xFF1A1A1A),
    ], // Alias for business
    // Education: Black gradient
    'education': [
      Color(0xFF000000),
      Color(0xFF1A1A1A),
    ], // Pure Black to Dark Gray
    'learning': [Color(0xFF000000), Color(0xFF1A1A1A)], // Alias for education
    // Health: Black gradient
    'health': [Color(0xFF000000), Color(0xFF1A1A1A)], // Pure Black to Dark Gray
    'wellness': [Color(0xFF000000), Color(0xFF1A1A1A)], // Alias for health
    // Community: Black gradient
    'community': [
      Color(0xFF000000),
      Color(0xFF1A1A1A),
    ], // Pure Black to Dark Gray
    'social': [Color(0xFF000000), Color(0xFF1A1A1A)], // Alias for community
    // Default fallback
    'other': [Color(0xFF000000), Color(0xFF1A1A1A)], // Black gradient
  };

  // Get category gradient with enhanced matching
  static List<Color> getCategoryGradient(String category) {
    final normalizedCategory = category.toLowerCase().trim();

    // Direct match first
    if (categoryGradients.containsKey(normalizedCategory)) {
      return categoryGradients[normalizedCategory]!;
    }

    // Fuzzy matching for common variations
    if (normalizedCategory.contains('tech')) {
      return categoryGradients['technology']!;
    } else if (normalizedCategory.contains('art')) {
      return categoryGradients['arts']!;
    } else if (normalizedCategory.contains('sport')) {
      return categoryGradients['sports']!;
    } else if (normalizedCategory.contains('food') ||
        normalizedCategory.contains('restaurant')) {
      return categoryGradients['food']!;
    } else if (normalizedCategory.contains('music') ||
        normalizedCategory.contains('concert')) {
      return categoryGradients['music']!;
    } else if (normalizedCategory.contains('business') ||
        normalizedCategory.contains('work')) {
      return categoryGradients['business']!;
    } else if (normalizedCategory.contains('education') ||
        normalizedCategory.contains('learn')) {
      return categoryGradients['education']!;
    } else if (normalizedCategory.contains('health') ||
        normalizedCategory.contains('fitness')) {
      return categoryGradients['health']!;
    } else if (normalizedCategory.contains('community') ||
        normalizedCategory.contains('social')) {
      return categoryGradients['community']!;
    }

    // Fallback to default gradient
    return categoryGradients['other']!;
  }

  // Get category gradient as LinearGradient widget
  static LinearGradient getCategoryLinearGradient(
    String category, {
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: getCategoryGradient(category),
    );
  }

  // Get category primary color (first color of gradient)
  static Color getCategoryPrimaryColor(String category) {
    return getCategoryGradient(category).first;
  }

  // Get category secondary color (second color of gradient)
  static Color getCategorySecondaryColor(String category) {
    return getCategoryGradient(category).last;
  }
}
