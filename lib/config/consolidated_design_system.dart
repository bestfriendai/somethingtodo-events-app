import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:glassmorphism/glassmorphism.dart';
import 'responsive_breakpoints.dart';

/// Consolidated Design System
///
/// This unified design system consolidates the glass_theme.dart, modern_theme.dart,
/// and unified_design_system.dart into a single, cohesive design language that
/// supports multiple visual variants while maintaining consistency.
///
/// Features:
/// - Material 3 compliance with modern color semantics
/// - Glass morphism effects with proper blur and transparency
/// - Consistent design tokens (spacing, typography, colors)
/// - Accessibility-first design with proper contrast ratios
/// - Mobile-optimized touch targets and interactions
/// - Unified component system with variant support
class ConsolidatedDesignSystem {
  /// Prevent instantiation
  ConsolidatedDesignSystem._();

  // ==========================================================================
  // DESIGN VARIANTS
  // ==========================================================================

  static const String materialVariant = 'material';
  static const String glassVariant = 'glass';
  static const String modernVariant = 'modern';

  // ==========================================================================
  // CORE BRAND COLORS (Material 3 Semantic Colors)
  // ==========================================================================

  // Primary brand colors
  static const Color primarySeed = Color(0xFF6366F1); // Indigo
  static const Color secondarySeed = Color(0xFF8B5CF6); // Light Purple
  static const Color tertiarySeed = Color(0xFF64748B); // Slate Gray

  // Semantic colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color infoColor = Color(0xFF3B82F6);

  // ==========================================================================
  // DESIGN TOKENS
  // ==========================================================================

  // Spacing Scale (8pt grid system)
  static const double spacing0 = 0.0;
  static const double spacing1 = 2.0;
  static const double spacing2 = 4.0;
  static const double spacing3 = 8.0;
  static const double spacing4 = 12.0;
  static const double spacing5 = 16.0;
  static const double spacing6 = 20.0;
  static const double spacing7 = 24.0;
  static const double spacing8 = 32.0;
  static const double spacing9 = 40.0;
  static const double spacing10 = 48.0;
  static const double spacing12 = 64.0;
  static const double spacing16 = 80.0;
  static const double spacing20 = 96.0;

  // Semantic spacing aliases for easier usage
  static const double spacingXs = spacing2;
  static const double spacingSm = spacing3;
  static const double spacingMd = spacing5;
  static const double spacingLg = spacing7;
  static const double spacingXl = spacing8;

  // Border Radius Scale
  static const double radiusNone = 0.0;
  static const double radiusXs = 2.0;
  static const double radiusSm = 4.0;
  static const double radiusBase = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radius2Xl = 20.0;
  static const double radius3Xl = 24.0;
  static const double radiusFull = 999.0;

  // Semantic radius aliases
  static const double radiusMd = radiusLg;

  // Elevation Scale
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 4.0;
  static const double elevation4 = 6.0;
  static const double elevation5 = 8.0;
  static const double elevation6 = 12.0;

  // Touch Target Sizes (Accessibility compliant - minimum 44px)
  static const double touchTargetSm = 40.0;
  static const double touchTargetBase = 44.0;
  static const double touchTargetLg = 48.0;
  static const double touchTargetXl = 56.0;

  // ==========================================================================
  // TYPOGRAPHY SYSTEM
  // ==========================================================================

  static String get fontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';

  static TextTheme get textTheme => TextTheme(
    // Display styles - for hero/large text
    displayLarge: GoogleFonts.inter(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),

    // Headline styles - for page titles and section headers
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.29,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.33,
    ),

    // Title styles - for component titles
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.50,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),

    // Body styles - for main content
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.50,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),

    // Label styles - for buttons and form labels
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    ),
  );

  // ==========================================================================
  // COLOR SCHEMES (Material 3 Dynamic Colors)
  // ==========================================================================

  /// Generate light theme color scheme
  static ColorScheme get lightColorScheme => ColorScheme.fromSeed(
    seedColor: primarySeed,
    brightness: Brightness.light,
    secondary: secondarySeed,
    tertiary: tertiarySeed,
    error: errorColor,
  );

  /// Generate dark theme color scheme
  static ColorScheme get darkColorScheme => ColorScheme.fromSeed(
    seedColor: primarySeed,
    brightness: Brightness.dark,
    secondary: secondarySeed,
    tertiary: tertiarySeed,
    error: errorColor,
  );

  // ==========================================================================
  // GLASS MORPHISM PROPERTIES
  // ==========================================================================

  static const double glassBlur = 20.0;
  static const double glassBorder = 1.0;
  static const double glassOpacity = 0.1;

  /// Create a glass morphism container
  static Widget glassContainer({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = radius2Xl,
    double blur = glassBlur,
    double border = glassBorder,
    Color? borderColor,
    LinearGradient? gradient,
    bool isDark = false,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: GlassmorphicContainer(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        borderRadius: borderRadius,
        blur: blur,
        alignment: Alignment.center,
        border: border,
        linearGradient: gradient ?? _defaultGlassGradient(isDark),
        borderGradient: _defaultGlassBorderGradient(isDark, borderColor),
        child: Container(padding: padding, child: child),
      ),
    );
  }

  static LinearGradient _defaultGlassGradient(bool isDark) {
    return LinearGradient(
      colors: [
        (isDark ? Colors.white : Colors.white).withValues(
          alpha: glassOpacity * (isDark ? 0.8 : 1.0),
        ),
        (isDark ? Colors.white : Colors.white).withValues(
          alpha: glassOpacity * (isDark ? 0.4 : 0.5),
        ),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient _defaultGlassBorderGradient(
    bool isDark,
    Color? borderColor,
  ) {
    final color = borderColor ?? (isDark ? Colors.white : Colors.white);
    return LinearGradient(
      colors: [
        color.withValues(alpha: isDark ? 0.3 : 0.2),
        color.withValues(alpha: isDark ? 0.1 : 0.1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ==========================================================================
  // THEME GENERATION
  // ==========================================================================

  /// Generate Material variant theme
  static ThemeData materialTheme({required bool isDark}) {
    final colorScheme = isDark ? darkColorScheme : lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      fontFamily: fontFamily,

      // App Bar
      appBarTheme: AppBarTheme(
        elevation: elevation0,
        scrolledUnderElevation: elevation1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(radiusLg),
          ),
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: elevation2,
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2Xl),
        ),
        margin: const EdgeInsets.all(spacing3),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevation2,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, touchTargetBase),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing7,
            vertical: spacing4,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, touchTargetBase),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing7,
            vertical: spacing4,
          ),
        ),
      ),

      // Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: elevation3,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing5,
          vertical: spacing4,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Extensions
      extensions: [
        ConsolidatedDesignTokens(
          variant: materialVariant,
          spacing: _spacingTokens,
          radius: _radiusTokens,
          elevation: _elevationTokens,
        ),
      ],
    );
  }

  /// Generate Glass variant theme
  static ThemeData glassTheme({required bool isDark}) {
    final baseTheme = materialTheme(isDark: isDark);
    final colorScheme = baseTheme.colorScheme;

    return baseTheme.copyWith(
      // Override for glass-specific styling
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        elevation: elevation0,
        scrolledUnderElevation: elevation0,
      ),

      cardTheme: baseTheme.cardTheme.copyWith(
        color: Colors.transparent,
        elevation: elevation0,
        surfaceTintColor: Colors.transparent,
      ),

      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF8FAFC),

      extensions: [
        ConsolidatedDesignTokens(
          variant: glassVariant,
          spacing: _spacingTokens,
          radius: _radiusTokens,
          elevation: _elevationTokens,
        ),
      ],
    );
  }

  /// Generate Modern variant theme
  static ThemeData modernTheme({required bool isDark}) {
    final baseTheme = materialTheme(isDark: isDark);
    final colorScheme = baseTheme.colorScheme;

    return baseTheme.copyWith(
      // Modern-specific overrides with enhanced colors and gradients
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0A0A0B)
          : const Color(0xFFFAFAFA),

      cardTheme: baseTheme.cardTheme.copyWith(
        color: isDark ? const Color(0xFF1A1A1B) : const Color(0xFFFFFFFF),
        elevation: elevation3,
      ),

      extensions: [
        ConsolidatedDesignTokens(
          variant: modernVariant,
          spacing: _spacingTokens,
          radius: _radiusTokens,
          elevation: _elevationTokens,
        ),
      ],
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }

  static Map<String, double> get _spacingTokens => {
    '0': spacing0,
    '1': spacing1,
    '2': spacing2,
    '3': spacing3,
    '4': spacing4,
    '5': spacing5,
    '6': spacing6,
    '7': spacing7,
    '8': spacing8,
    '9': spacing9,
    '10': spacing10,
    '12': spacing12,
    '16': spacing16,
    '20': spacing20,
  };

  static Map<String, double> get _radiusTokens => {
    'none': radiusNone,
    'xs': radiusXs,
    'sm': radiusSm,
    'base': radiusBase,
    'lg': radiusLg,
    'xl': radiusXl,
    '2xl': radius2Xl,
    '3xl': radius3Xl,
    'full': radiusFull,
  };

  static Map<String, double> get _elevationTokens => {
    '0': elevation0,
    '1': elevation1,
    '2': elevation2,
    '3': elevation3,
    '4': elevation4,
    '5': elevation5,
    '6': elevation6,
  };

  // ==========================================================================
  // ACCESSIBILITY HELPERS
  // ==========================================================================

  /// Get semantic color for better contrast
  static Color getSemanticColor(ColorScheme colorScheme, String semanticRole) {
    switch (semanticRole) {
      case 'primary':
        return colorScheme.primary;
      case 'secondary':
        return colorScheme.secondary;
      case 'error':
        return colorScheme.error;
      case 'success':
        return successColor;
      case 'warning':
        return warningColor;
      default:
        return colorScheme.primary;
    }
  }

  /// Ensure minimum contrast ratio for accessibility
  static Color ensureContrast(
    Color foreground,
    Color background, {
    double minRatio = 4.5,
  }) {
    final luminanceFg = foreground.computeLuminance();
    final luminanceBg = background.computeLuminance();
    final ratio =
        (math.max(luminanceFg, luminanceBg) + 0.05) /
        (math.min(luminanceFg, luminanceBg) + 0.05);

    if (ratio >= minRatio) {
      return foreground;
    }

    // If contrast is insufficient, return high contrast alternative
    return luminanceBg > 0.5 ? Colors.black : Colors.white;
  }

  /// Get accessible touch target size
  static double getAccessibleTouchTarget(
    BuildContext context, {
    double baseSize = touchTargetBase,
  }) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    return math.max(baseSize * textScale, touchTargetBase);
  }

  // ==========================================================================
  // RESPONSIVE HELPERS
  // ==========================================================================

  /// Get responsive spacing value
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    return ResponsiveBreakpoints.getSpacing(context, baseSpacing);
  }

  /// Get responsive text size
  static double responsiveTextSize(BuildContext context, double baseSize) {
    final scaleFactor = ResponsiveBreakpoints.getTextScaleFactor(context);
    return baseSize * scaleFactor;
  }

  // ==========================================================================
  // COMPONENT BUILDERS
  // ==========================================================================

  /// Create a modern card with optional gradient and responsive design
  static Widget modernCard({
    required Widget child,
    required BuildContext context,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = radius2Xl,
    bool isDark = false,
    List<Color>? gradient,
    VoidCallback? onTap,
    String? semanticLabel,
    bool isAccessible = true,
  }) {
    final responsivePadding =
        padding ?? EdgeInsets.all(responsiveSpacing(context, spacing5));
    final responsiveMargin =
        margin ?? EdgeInsets.all(responsiveSpacing(context, spacing3));

    Widget container = Container(
      padding: responsivePadding,
      margin: responsiveMargin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              )
            : null,
        color: gradient == null
            ? (isDark ? const Color(0xFF1A1A1B) : Colors.white)
            : null,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withValues(
              alpha: isDark ? 0.3 : 0.1,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      Widget interactive = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );

      // Add semantic wrapper for accessibility
      if (isAccessible && semanticLabel != null) {
        return Semantics(
          label: semanticLabel,
          button: true,
          child: interactive,
        );
      }

      return interactive;
    }

    return container;
  }

  /// Create enhanced shadows for depth
  static List<BoxShadow> enhancedShadow({
    bool isDark = false,
    double intensity = 1.0,
  }) {
    return [
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black).withValues(
          alpha: (isDark ? 0.4 : 0.15) * intensity,
        ),
        blurRadius: 20 * intensity,
        offset: Offset(0, 8 * intensity),
      ),
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black).withValues(
          alpha: (isDark ? 0.2 : 0.05) * intensity,
        ),
        blurRadius: 40 * intensity,
        offset: Offset(0, 16 * intensity),
      ),
    ];
  }
}

/// Theme extension for design tokens
class ConsolidatedDesignTokens
    extends ThemeExtension<ConsolidatedDesignTokens> {
  final String variant;
  final Map<String, double> spacing;
  final Map<String, double> radius;
  final Map<String, double> elevation;

  const ConsolidatedDesignTokens({
    required this.variant,
    required this.spacing,
    required this.radius,
    required this.elevation,
  });

  @override
  ConsolidatedDesignTokens copyWith({
    String? variant,
    Map<String, double>? spacing,
    Map<String, double>? radius,
    Map<String, double>? elevation,
  }) {
    return ConsolidatedDesignTokens(
      variant: variant ?? this.variant,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  ConsolidatedDesignTokens lerp(
    ThemeExtension<ConsolidatedDesignTokens>? other,
    double t,
  ) {
    if (other is! ConsolidatedDesignTokens) return this;
    return ConsolidatedDesignTokens(
      variant: t < 0.5 ? variant : other.variant,
      spacing: t < 0.5 ? spacing : other.spacing,
      radius: t < 0.5 ? radius : other.radius,
      elevation: t < 0.5 ? elevation : other.elevation,
    );
  }

  /// Get spacing value by key
  double getSpacing(String key) => spacing[key] ?? 0.0;

  /// Get radius value by key
  double getRadius(String key) => radius[key] ?? 0.0;

  /// Get elevation value by key
  double getElevation(String key) => elevation[key] ?? 0.0;

  /// Check variant type
  bool get isMaterial => variant == ConsolidatedDesignSystem.materialVariant;
  bool get isGlass => variant == ConsolidatedDesignSystem.glassVariant;
  bool get isModern => variant == ConsolidatedDesignSystem.modernVariant;
}
