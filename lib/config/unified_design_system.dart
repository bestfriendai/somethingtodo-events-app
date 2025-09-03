import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';

/// Unified Design System that consolidates all theme variants
/// Supports Material, Glass, and Modern design languages
class UnifiedDesignSystem {
  // Design System Variants
  static const String materialVariant = 'material';
  static const String glassVariant = 'glass';
  static const String modernVariant = 'modern';

  // Core Brand Colors (consistent across all variants)
  static const Color primaryBrand = Color(0xFF6366F1); // Indigo
  static const Color secondaryBrand = Color(0xFF06D6A0); // Emerald
  static const Color accentBrand = Color(0xFFEC4899); // Pink

  // Semantic Colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color infoColor = Color(0xFF3B82F6);

  // Neutral Palette
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
  static const Color neutral950 = Color(0xFF0A0A0A);

  // Design Tokens
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2Xl = 48.0;
  static const double spacing3Xl = 64.0;

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2Xl = 24.0;
  static const double radiusFull = 9999.0;

  // Typography Scale
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );

  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF06D6A0), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFBE0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF475569), Color(0xFF64748B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Definitions
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: neutral900.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: neutral900.withValues(alpha: 0.1),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: neutral900.withValues(alpha: 0.06),
      blurRadius: 2,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: neutral900.withValues(alpha: 0.1),
      blurRadius: 15,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: neutral900.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: neutral900.withValues(alpha: 0.1),
      blurRadius: 25,
      offset: const Offset(0, 20),
    ),
    BoxShadow(
      color: neutral900.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 8),
    ),
  ];

  // Glass Effect Properties
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
    double borderRadius = radiusXl,
    double blur = glassBlur,
    double border = glassBorder,
    Color? borderColor,
    LinearGradient? gradient,
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
        linearGradient:
            gradient ??
            LinearGradient(
              colors: [
                Colors.white.withValues(alpha: glassOpacity),
                Colors.white.withValues(alpha: glassOpacity * 0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderGradient: LinearGradient(
          colors: [
            (borderColor ?? Colors.white).withValues(alpha: 0.2),
            (borderColor ?? Colors.white).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Container(padding: padding, child: child),
      ),
    );
  }

  /// Generate Material Design theme
  static ThemeData materialTheme({required bool isDark}) {
    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      filledButtonTheme: _buildFilledButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      bottomNavigationBarTheme: _buildBottomNavTheme(colorScheme),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme),
      floatingActionButtonTheme: _buildFABTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme),
      dividerTheme: _buildDividerTheme(colorScheme),
      extensions: [UnifiedDesignTokens(variant: materialVariant)],
    );
  }

  /// Generate Glass morphism theme
  static ThemeData glassTheme({required bool isDark}) {
    final colorScheme = isDark ? _darkGlassColorScheme : _lightGlassColorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: _buildGlassAppBarTheme(colorScheme),
      cardTheme: _buildGlassCardTheme(colorScheme),
      elevatedButtonTheme: _buildGlassElevatedButtonTheme(colorScheme),
      filledButtonTheme: _buildGlassFilledButtonTheme(colorScheme),
      outlinedButtonTheme: _buildGlassOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildGlassInputDecorationTheme(colorScheme),
      bottomNavigationBarTheme: _buildGlassBottomNavTheme(colorScheme),
      navigationBarTheme: _buildGlassNavigationBarTheme(colorScheme),
      floatingActionButtonTheme: _buildGlassFABTheme(colorScheme),
      chipTheme: _buildGlassChipTheme(colorScheme),
      dividerTheme: _buildDividerTheme(colorScheme),
      extensions: [UnifiedDesignTokens(variant: glassVariant)],
    );
  }

  /// Generate Modern theme
  static ThemeData modernTheme({required bool isDark}) {
    final colorScheme = isDark
        ? _darkModernColorScheme
        : _lightModernColorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: _buildModernAppBarTheme(colorScheme),
      cardTheme: _buildModernCardTheme(colorScheme),
      elevatedButtonTheme: _buildModernElevatedButtonTheme(colorScheme),
      filledButtonTheme: _buildModernFilledButtonTheme(colorScheme),
      outlinedButtonTheme: _buildModernOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildModernInputDecorationTheme(colorScheme),
      bottomNavigationBarTheme: _buildModernBottomNavTheme(colorScheme),
      navigationBarTheme: _buildModernNavigationBarTheme(colorScheme),
      floatingActionButtonTheme: _buildModernFABTheme(colorScheme),
      chipTheme: _buildModernChipTheme(colorScheme),
      dividerTheme: _buildDividerTheme(colorScheme),
      extensions: [UnifiedDesignTokens(variant: modernVariant)],
    );
  }

  // Color Schemes
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: primaryBrand,
    onPrimary: Colors.white,
    secondary: secondaryBrand,
    onSecondary: Colors.white,
    tertiary: accentBrand,
    onTertiary: Colors.white,
    error: errorColor,
    onError: Colors.white,
    surface: neutral50,
    onSurface: neutral900,
    onSurfaceVariant: neutral600,
    outline: neutral300,
    outlineVariant: neutral200,
    shadow: neutral900,
    scrim: neutral900,
    inverseSurface: neutral800,
    onInverseSurface: neutral100,
    inversePrimary: Color(0xFF9CA3FF),
    surfaceTint: primaryBrand,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF9CA3FF),
    onPrimary: Color(0xFF1E1B3A),
    secondary: Color(0xFF4FFFB0),
    onSecondary: Color(0xFF003828),
    tertiary: Color(0xFFFFB3D1),
    onTertiary: Color(0xFF3D1228),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: neutral900,
    onSurface: neutral100,
    onSurfaceVariant: neutral400,
    outline: neutral600,
    outlineVariant: neutral700,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: neutral100,
    onInverseSurface: neutral800,
    inversePrimary: primaryBrand,
    surfaceTint: Color(0xFF9CA3FF),
  );

  static const ColorScheme _lightGlassColorScheme = ColorScheme.light(
    primary: primaryBrand,
    onPrimary: Colors.white,
    secondary: secondaryBrand,
    onSecondary: Colors.white,
    tertiary: accentBrand,
    onTertiary: Colors.white,
    error: errorColor,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: neutral800,
    onSurfaceVariant: neutral600,
    outline: Colors.white,
    outlineVariant: Colors.white,
    shadow: neutral900,
    scrim: neutral900,
    inverseSurface: neutral800,
    onInverseSurface: neutral100,
    inversePrimary: Color(0xFF9CA3FF),
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _darkGlassColorScheme = ColorScheme.dark(
    primary: Color(0xFF9CA3FF),
    onPrimary: Colors.white,
    secondary: Color(0xFF4FFFB0),
    onSecondary: Colors.white,
    tertiary: Color(0xFFFFB3D1),
    onTertiary: Colors.white,
    error: Color(0xFFFFB4AB),
    onError: Colors.white,
    surface: Colors.black,
    onSurface: Colors.white,
    onSurfaceVariant: neutral300,
    outline: Colors.white,
    outlineVariant: Colors.white,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: neutral100,
    onInverseSurface: neutral800,
    inversePrimary: primaryBrand,
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _lightModernColorScheme = ColorScheme.light(
    primary: Color(0xFF7C3AED),
    onPrimary: Colors.white,
    secondary: Color(0xFFEC4899),
    onSecondary: Colors.white,
    tertiary: Color(0xFF06B6D4),
    onTertiary: Colors.white,
    error: errorColor,
    onError: Colors.white,
    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF1E293B),
    onSurfaceVariant: Color(0xFF334155),
    outline: Color(0xFFCBD5E1),
    outlineVariant: Color(0xFFE2E8F0),
    shadow: neutral900,
    scrim: neutral900,
    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Color(0xFFFAFAFA),
    inversePrimary: Color(0xFFA78BFA),
    surfaceTint: Color(0xFF7C3AED),
  );

  static const ColorScheme _darkModernColorScheme = ColorScheme.dark(
    primary: Color(0xFFA78BFA),
    onPrimary: Color(0xFF2D1B69),
    secondary: Color(0xFFF472B6),
    onSecondary: Color(0xFF5B1538),
    tertiary: Color(0xFF22D3EE),
    onTertiary: Color(0xFF003544),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: Color(0xFF0A0A0B),
    onSurface: Color(0xFFFAFAFA),
    onSurfaceVariant: Color(0xFFE8E8E8),
    outline: Color(0xFF64748B),
    outlineVariant: Color(0xFF334155),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFFAFAFA),
    onInverseSurface: Color(0xFF0A0A0B),
    inversePrimary: Color(0xFF7C3AED),
    surfaceTint: Color(0xFFA78BFA),
  );

  // Helper methods for building theme components
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: colorScheme.onSurface),
      displayMedium: displayMedium.copyWith(color: colorScheme.onSurface),
      displaySmall: displaySmall.copyWith(color: colorScheme.onSurface),
      headlineLarge: headlineLarge.copyWith(color: colorScheme.onSurface),
      headlineMedium: headlineMedium.copyWith(color: colorScheme.onSurface),
      headlineSmall: headlineSmall.copyWith(color: colorScheme.onSurface),
      titleLarge: titleLarge.copyWith(color: colorScheme.onSurface),
      titleMedium: titleMedium.copyWith(color: colorScheme.onSurface),
      titleSmall: titleSmall.copyWith(color: colorScheme.onSurface),
      bodyLarge: bodyLarge.copyWith(color: colorScheme.onSurface),
      bodyMedium: bodyMedium.copyWith(color: colorScheme.onSurface),
      bodySmall: bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
      labelLarge: labelLarge.copyWith(color: colorScheme.onSurface),
      labelMedium: labelMedium.copyWith(color: colorScheme.onSurfaceVariant),
      labelSmall: labelSmall.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
      titleTextStyle: titleLarge.copyWith(color: colorScheme.onSurface),
      toolbarTextStyle: bodyMedium.copyWith(color: colorScheme.onSurface),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(radiusMd)),
      ),
    );
  }

  static CardThemeData _buildCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 2,
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      margin: const EdgeInsets.all(spacingSm),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        textStyle: labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
      ),
    );
  }

  static FilledButtonThemeData _buildFilledButtonTheme(
    ColorScheme colorScheme,
  ) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        textStyle: labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        textStyle: labelLarge,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        textStyle: labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingMd,
      ),
      labelStyle: bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
      hintStyle: bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  // Placeholder methods for missing theme builders (simplified implementations)
  static BottomNavigationBarThemeData _buildBottomNavTheme(
    ColorScheme colorScheme,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
    );
  }

  static NavigationBarThemeData _buildNavigationBarTheme(
    ColorScheme colorScheme,
  ) {
    return NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return labelMedium.copyWith(color: colorScheme.onSurface);
        }
        return labelMedium.copyWith(color: colorScheme.onSurfaceVariant);
      }),
    );
  }

  static FloatingActionButtonThemeData _buildFABTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    );
  }

  static ChipThemeData _buildChipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.secondaryContainer,
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
      labelStyle: labelMedium.copyWith(color: colorScheme.onSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusFull),
      ),
    );
  }

  static DividerThemeData _buildDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    );
  }

  // Glass-specific theme builders (simplified - would need full implementation)
  static AppBarTheme _buildGlassAppBarTheme(ColorScheme colorScheme) =>
      _buildAppBarTheme(colorScheme);
  static CardThemeData _buildGlassCardTheme(ColorScheme colorScheme) =>
      _buildCardTheme(colorScheme);
  static ElevatedButtonThemeData _buildGlassElevatedButtonTheme(
    ColorScheme colorScheme,
  ) => _buildElevatedButtonTheme(colorScheme);
  static FilledButtonThemeData _buildGlassFilledButtonTheme(
    ColorScheme colorScheme,
  ) => _buildFilledButtonTheme(colorScheme);
  static OutlinedButtonThemeData _buildGlassOutlinedButtonTheme(
    ColorScheme colorScheme,
  ) => _buildOutlinedButtonTheme(colorScheme);
  static InputDecorationTheme _buildGlassInputDecorationTheme(
    ColorScheme colorScheme,
  ) => _buildInputDecorationTheme(colorScheme);
  static BottomNavigationBarThemeData _buildGlassBottomNavTheme(
    ColorScheme colorScheme,
  ) => _buildBottomNavTheme(colorScheme);
  static NavigationBarThemeData _buildGlassNavigationBarTheme(
    ColorScheme colorScheme,
  ) => _buildNavigationBarTheme(colorScheme);
  static FloatingActionButtonThemeData _buildGlassFABTheme(
    ColorScheme colorScheme,
  ) => _buildFABTheme(colorScheme);
  static ChipThemeData _buildGlassChipTheme(ColorScheme colorScheme) =>
      _buildChipTheme(colorScheme);

  // Modern-specific theme builders (simplified - would need full implementation)
  static AppBarTheme _buildModernAppBarTheme(ColorScheme colorScheme) =>
      _buildAppBarTheme(colorScheme);
  static CardThemeData _buildModernCardTheme(ColorScheme colorScheme) =>
      _buildCardTheme(colorScheme);
  static ElevatedButtonThemeData _buildModernElevatedButtonTheme(
    ColorScheme colorScheme,
  ) => _buildElevatedButtonTheme(colorScheme);
  static FilledButtonThemeData _buildModernFilledButtonTheme(
    ColorScheme colorScheme,
  ) => _buildFilledButtonTheme(colorScheme);
  static OutlinedButtonThemeData _buildModernOutlinedButtonTheme(
    ColorScheme colorScheme,
  ) => _buildOutlinedButtonTheme(colorScheme);
  static InputDecorationTheme _buildModernInputDecorationTheme(
    ColorScheme colorScheme,
  ) => _buildInputDecorationTheme(colorScheme);
  static BottomNavigationBarThemeData _buildModernBottomNavTheme(
    ColorScheme colorScheme,
  ) => _buildBottomNavTheme(colorScheme);
  static NavigationBarThemeData _buildModernNavigationBarTheme(
    ColorScheme colorScheme,
  ) => _buildNavigationBarTheme(colorScheme);
  static FloatingActionButtonThemeData _buildModernFABTheme(
    ColorScheme colorScheme,
  ) => _buildFABTheme(colorScheme);
  static ChipThemeData _buildModernChipTheme(ColorScheme colorScheme) =>
      _buildChipTheme(colorScheme);
}

/// Theme extension for unified design tokens
class UnifiedDesignTokens extends ThemeExtension<UnifiedDesignTokens> {
  final String variant;
  final Map<String, dynamic> tokens;

  const UnifiedDesignTokens({required this.variant, this.tokens = const {}});

  @override
  UnifiedDesignTokens copyWith({
    String? variant,
    Map<String, dynamic>? tokens,
  }) {
    return UnifiedDesignTokens(
      variant: variant ?? this.variant,
      tokens: tokens ?? this.tokens,
    );
  }

  @override
  UnifiedDesignTokens lerp(
    ThemeExtension<UnifiedDesignTokens>? other,
    double t,
  ) {
    if (other is! UnifiedDesignTokens) {
      return this;
    }
    return UnifiedDesignTokens(
      variant: t < 0.5 ? variant : other.variant,
      tokens: t < 0.5 ? tokens : other.tokens,
    );
  }

  /// Check if current variant is glass
  bool get isGlass => variant == UnifiedDesignSystem.glassVariant;

  /// Check if current variant is modern
  bool get isModern => variant == UnifiedDesignSystem.modernVariant;

  /// Check if current variant is material
  bool get isMaterial => variant == UnifiedDesignSystem.materialVariant;

  /// Get design tokens for current variant
  T? getToken<T>(String key) => tokens[key] as T?;
}
