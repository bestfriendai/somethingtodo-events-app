import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernTheme {
  // 2025 Ultra-Modern Color Palette (Discord, Spotify, Linear vibes)
  static const Color primaryColor = Color(0xFF7C3AED); // Electric Purple
  static const Color secondaryColor = Color(0xFFEC4899); // Neon Pink (perfect!)
  static const Color accentColor = Color(0xFF06B6D4); // Cyber Blue
  static const Color warningColor = Color(0xFFEAB308); // Yellow
  static const Color errorColor = Color(0xFFEF4444); // Red
  
  // 2025 Dark theme base colors - Rich blacks and vibrant accents
  static const Color darkBackground = Color(0xFF0A0A0B); // Rich black like Arc Browser
  static const Color darkSurface = Color(0xFF111111); // Slightly lighter black
  static const Color darkCardSurface = Color(0xFF1A1A1B); // Card surface
  static const Color darkOnSurface = Color(0xFFFAFAFA); // Pure white text
  static const Color darkOnBackground = Color(0xFFE8E8E8); // Light gray text
  
  // Light theme colors (for accessibility)
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardSurface = Color(0xFFF8FAFC);
  static const Color lightOnSurface = Color(0xFF1E293B);
  static const Color lightOnBackground = Color(0xFF334155);
  
  // 2025 Ultra-vibrant gradients for $10M startup feel
  static const List<Color> sunsetGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFFFBE0B),
  ];
  
  static const List<Color> oceanGradient = [
    Color(0xFF06B6D4), // Cyber Blue
    Color(0xFF3B82F6), // Bright Blue
  ];
  
  static const List<Color> forestGradient = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];
  
  static const List<Color> purpleGradient = [
    Color(0xFF7C3AED), // Electric Purple
    Color(0xFF8B5CF6), // Violet
  ];
  
  static const List<Color> pinkGradient = [
    Color(0xFFEC4899), // Neon Pink
    Color(0xFFF97316), // Orange
  ];
  
  static const List<Color> neonGradient = [
    Color(0xFF06B6D4), // Cyber Blue
    Color(0xFF7C3AED), // Electric Purple
  ];
  
  // NEW: Aurora Borealis gradient for backgrounds
  static const List<Color> auroraGradient = [
    Color(0xFF0A0A0B), // Rich Black
    Color(0xFF7C3AED), // Electric Purple
    Color(0xFFEC4899), // Neon Pink
    Color(0xFF06B6D4), // Cyber Blue
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
  
  static const List<Color> warningGradient = [
    Color(0xFFFFB800),
    Color(0xFFFF6B00),
  ];
  
  static const List<Color> primaryGradient = [
    primaryColor,
    secondaryColor,
  ];
  
  // Typography - Inter font for modern feel
  static String get primaryFont => GoogleFonts.inter().fontFamily ?? 'Inter';
  static String get displayFont => GoogleFonts.inter().fontFamily ?? 'Inter';
  
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

  // Main dark theme (default for Gen Z)
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: primaryFont,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: darkSurface,
      onSurface: darkOnSurface,
      error: errorColor,
      surfaceContainerHighest: darkCardSurface,
    ),
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCardSurface,
    textTheme: GoogleFonts.interTextTheme(modernTextTheme).apply(
      bodyColor: darkOnBackground,
      displayColor: darkOnSurface,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: darkOnSurface,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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

  // Light theme for accessibility
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: primaryFont,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: lightSurface,
      onSurface: lightOnSurface,
      error: errorColor,
      surfaceContainerHighest: lightCardSurface,
    ),
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightCardSurface,
    textTheme: GoogleFonts.interTextTheme(modernTextTheme).apply(
      bodyColor: lightOnBackground,
      displayColor: lightOnSurface,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: lightOnSurface,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
        colors: gradient ?? [
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
      border: Border.all(
        color: glassBorder,
        width: 1,
      ),
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
  static BoxDecoration floatingNavDecoration({
    bool isDark = true,
  }) {
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

  // 2025 Enhanced category-specific gradients with improved visual hierarchy
  static const Map<String, List<Color>> categoryGradients = {
    // Technology: Cyber blue to electric purple
    'technology': [Color(0xFF06B6D4), Color(0xFF7C3AED)], // Cyber Blue to Electric Purple
    'tech': [Color(0xFF06B6D4), Color(0xFF7C3AED)], // Alias for technology
    
    // Arts: Sunset gradient (warm orange to deep pink)
    'arts': [Color(0xFFFF6B35), Color(0xFFEC4899)], // Sunset Orange to Deep Pink
    'art': [Color(0xFFFF6B35), Color(0xFFEC4899)], // Alias for arts
    
    // Sports: Forest gradient (deep green to bright emerald)
    'sports': [Color(0xFF065F46), Color(0xFF10B981)], // Forest Green to Emerald
    'sport': [Color(0xFF065F46), Color(0xFF10B981)], // Alias for sports
    
    // Food: Warm gradient (golden yellow to orange)
    'food': [Color(0xFFFBBF24), Color(0xFFFF6B35)], // Golden Yellow to Warm Orange
    'dining': [Color(0xFFFBBF24), Color(0xFFFF6B35)], // Alias for food
    
    // Music: Vibrant pink to purple
    'music': [Color(0xFFEC4899), Color(0xFF8B5CF6)], // Neon Pink to Violet
    'entertainment': [Color(0xFFEC4899), Color(0xFF8B5CF6)], // Alias for music
    
    // Business: Professional blue gradient
    'business': [Color(0xFF1E40AF), Color(0xFF3B82F6)], // Deep Blue to Bright Blue
    'professional': [Color(0xFF1E40AF), Color(0xFF3B82F6)], // Alias for business
    
    // Education: Knowledge gradient (blue to green)
    'education': [Color(0xFF0EA5E9), Color(0xFF059669)], // Sky Blue to Green
    'learning': [Color(0xFF0EA5E9), Color(0xFF059669)], // Alias for education
    
    // Health: Wellness gradient (pink to orange)
    'health': [Color(0xFFEC4899), Color(0xFFF97316)], // Pink to Orange
    'wellness': [Color(0xFFEC4899), Color(0xFFF97316)], // Alias for health
    
    // Community: Social gradient (yellow to orange)
    'community': [Color(0xFFEAB308), Color(0xFFFF9F43)], // Yellow to Orange
    'social': [Color(0xFFEAB308), Color(0xFFFF9F43)], // Alias for community
    
    // Default fallback
    'other': [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Purple gradient
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
    } else if (normalizedCategory.contains('food') || normalizedCategory.contains('restaurant')) {
      return categoryGradients['food']!;
    } else if (normalizedCategory.contains('music') || normalizedCategory.contains('concert')) {
      return categoryGradients['music']!;
    } else if (normalizedCategory.contains('business') || normalizedCategory.contains('work')) {
      return categoryGradients['business']!;
    } else if (normalizedCategory.contains('education') || normalizedCategory.contains('learn')) {
      return categoryGradients['education']!;
    } else if (normalizedCategory.contains('health') || normalizedCategory.contains('fitness')) {
      return categoryGradients['health']!;
    } else if (normalizedCategory.contains('community') || normalizedCategory.contains('social')) {
      return categoryGradients['community']!;
    }
    
    // Fallback to default gradient
    return categoryGradients['other']!;
  }
  
  // Get category gradient as LinearGradient widget
  static LinearGradient getCategoryLinearGradient(String category, {
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