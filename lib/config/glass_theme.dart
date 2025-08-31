import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class GlassTheme {
  // Glass morphism colors
  static const Color glassWhite = Color(0xFFFFFFFF);
  static const Color glassBlack = Color(0xFF000000);
  
  // Gradient colors for liquid glass effect
  static const List<Color> primaryGradient = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFFF093FB),
    Color(0xFFF5576C),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF00F260),
    Color(0xFF0575E6),
  ];
  
  static const List<Color> warningGradient = [
    Color(0xFFF4C430),
    Color(0xFFFC6767),
  ];
  
  // Glass container properties
  static const double glassBorderRadius = 20.0;
  static const double glassBlur = 20.0;
  static const double glassBorder = 1.5;
  static const double glassOpacity = 0.2;
  
  // Common glass widget builder
  static Widget glassContainer({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = glassBorderRadius,
    double blur = glassBlur,
    double border = glassBorder,
    LinearGradient? linearGradient,
    LinearGradient? borderGradient,
  }) {
    return GlassmorphicContainer(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      borderRadius: borderRadius,
      blur: blur,
      alignment: Alignment.center,
      border: border,
      linearGradient: linearGradient ?? defaultLinearGradient(),
      borderGradient: borderGradient ?? defaultBorderGradient(),
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
  
  static Widget glassCard({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    double borderRadius = glassBorderRadius,
  }) {
    final container = GlassmorphicContainer(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      borderRadius: borderRadius,
      blur: glassBlur,
      alignment: Alignment.center,
      border: glassBorder,
      linearGradient: defaultLinearGradient(),
      borderGradient: defaultBorderGradient(),
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }
    return container;
  }
  
  static Widget glassButton({
    required Widget child,
    required VoidCallback onPressed,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    bool isPrimary = true,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassmorphicContainer(
        width: width ?? double.infinity,
        height: height ?? 48,
        borderRadius: 24,
        blur: 15,
        alignment: Alignment.center,
        border: 2,
        linearGradient: isPrimary 
            ? primaryButtonGradient() 
            : secondaryButtonGradient(),
        borderGradient: isPrimary
            ? primaryBorderGradient()
            : secondaryBorderGradient(),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: child,
      ),
    );
  }
  
  static Widget glassAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    double? height,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: height ?? 100,
      borderRadius: 0,
      blur: 25,
      alignment: Alignment.bottomCenter,
      border: 0,
      linearGradient: appBarGradient(),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(0),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leading != null) leading,
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (actions != null) Row(children: actions),
        ],
      ),
    );
  }
  
  static Widget glassTextField({
    required TextEditingController controller,
    String? hintText,
    IconData? prefixIcon,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 56,
      borderRadius: 28,
      blur: 20,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: textFieldGradient(),
      borderGradient: defaultBorderGradient(),
      margin: margin ?? EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: Colors.white.withOpacity(0.7),
                )
              : null,
        ),
      ),
    );
  }
  
  // Gradient definitions
  static LinearGradient defaultLinearGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.05),
      ],
    );
  }
  
  static LinearGradient primaryButtonGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryGradient[0].withOpacity(0.3),
        primaryGradient[1].withOpacity(0.2),
      ],
    );
  }
  
  static LinearGradient secondaryButtonGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.15),
        Colors.white.withOpacity(0.08),
      ],
    );
  }
  
  static LinearGradient appBarGradient() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryGradient[0].withOpacity(0.4),
        primaryGradient[1].withOpacity(0.2),
      ],
    );
  }
  
  static LinearGradient textFieldGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.08),
        Colors.white.withOpacity(0.04),
      ],
    );
  }
  
  static LinearGradient defaultBorderGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.5),
        Colors.white.withOpacity(0.2),
      ],
    );
  }
  
  static LinearGradient primaryBorderGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryGradient[0].withOpacity(0.8),
        primaryGradient[1].withOpacity(0.4),
      ],
    );
  }
  
  static LinearGradient secondaryBorderGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.4),
        Colors.white.withOpacity(0.2),
      ],
    );
  }
  
  // Background decoration for screens
  static BoxDecoration screenBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryGradient[0],
          primaryGradient[1],
          secondaryGradient[0],
        ],
      ),
    );
  }
  
  static BoxDecoration darkScreenBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0F2027),
          const Color(0xFF203A43),
          const Color(0xFF2C5364),
        ],
      ),
    );
  }
}