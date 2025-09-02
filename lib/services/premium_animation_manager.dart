import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/modern_theme.dart';

class PremiumAnimationManager {
  static final PremiumAnimationManager _instance = PremiumAnimationManager._internal();
  factory PremiumAnimationManager() => _instance;
  PremiumAnimationManager._internal();

  static PremiumAnimationManager get instance => _instance;

  // Animation presets for consistency
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration ultraSlowDuration = Duration(milliseconds: 800);

  // Curve presets
  static const Curve premiumCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve sharpCurve = Curves.easeInOut;
  static const Curve smoothCurve = Curves.easeOutQuart;

  // Global animation settings
  bool _animationsEnabled = true;
  double _animationScale = 1.0;
  bool _reducedMotion = false;

  bool get animationsEnabled => _animationsEnabled;
  double get animationScale => _animationScale;
  bool get reducedMotion => _reducedMotion;

  void setAnimationsEnabled(bool enabled) {
    _animationsEnabled = enabled;
  }

  void setAnimationScale(double scale) {
    _animationScale = scale.clamp(0.1, 2.0);
  }

  void setReducedMotion(bool reduced) {
    _reducedMotion = reduced;
    if (reduced) {
      _animationScale = 0.5;
    }
  }

  Duration scaledDuration(Duration duration) {
    if (!_animationsEnabled) return Duration.zero;
    return Duration(
      milliseconds: (duration.inMilliseconds * _animationScale).round(),
    );
  }

  // Premium entrance animations
  static Widget fadeInUp(
    Widget child, {
    Duration? delay,
    Duration? duration,
    double distance = 30,
  }) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .fadeIn(
          duration: instance.scaledDuration(duration ?? normalDuration),
          curve: premiumCurve,
        )
        .slideY(
          begin: distance / 100,
          duration: instance.scaledDuration(duration ?? normalDuration),
          curve: bouncyCurve,
        );
  }

  static Widget fadeInScale(
    Widget child, {
    Duration? delay,
    Duration? duration,
    double beginScale = 0.8,
  }) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .fadeIn(
          duration: instance.scaledDuration(duration ?? normalDuration),
          curve: premiumCurve,
        )
        .scale(
          begin: Offset(beginScale, beginScale),
          duration: instance.scaledDuration(duration ?? normalDuration),
          curve: bouncyCurve,
        );
  }

  static Widget shimmerEffect(
    Widget child, {
    Duration? duration,
    Color? color,
  }) {
    if (!instance.animationsEnabled) return child;
    
    return child.animate(onPlay: (controller) => controller.repeat()).shimmer(
      duration: instance.scaledDuration(duration ?? const Duration(seconds: 2)),
      color: color ?? Colors.white.withValues(alpha: 0.3),
    );
  }

  static Widget pulseEffect(
    Widget child, {
    Duration? duration,
    double scale = 1.05,
  }) {
    if (!instance.animationsEnabled) return child;
    
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: Offset(scale, scale),
          duration: instance.scaledDuration(duration ?? const Duration(seconds: 1)),
          curve: Curves.easeInOut,
        );
  }

  static Widget glowEffect(
    Widget child, {
    Duration? duration,
    List<Color>? colors,
  }) {
    if (!instance.animationsEnabled) return child;
    
    final glowColors = colors ?? ModernTheme.neonGradient;
    
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .effect(
          duration: instance.scaledDuration(duration ?? const Duration(seconds: 2)),
        )
        .custom(
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: glowColors.first.withValues(alpha: value * 0.3),
                    blurRadius: 20 * value,
                    spreadRadius: 5 * value,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: child,
        );
  }

  // Page transition animations
  static PageRouteBuilder createRoute({
    required Widget page,
    required RouteSettings settings,
    TransitionType transition = TransitionType.slideUp,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: instance.scaledDuration(normalDuration),
      reverseTransitionDuration: instance.scaledDuration(normalDuration),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          child: child,
          animation: animation,
          transition: transition,
        );
      },
    );
  }

  static Widget _buildTransition({
    required Widget child,
    required Animation<double> animation,
    required TransitionType transition,
  }) {
    switch (transition) {
      case TransitionType.slideUp:
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
              CurveTween(curve: premiumCurve),
            ),
          ),
          child: child,
        );
      case TransitionType.slideRight:
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(1, 0), end: Offset.zero).chain(
              CurveTween(curve: premiumCurve),
            ),
          ),
          child: child,
        );
      case TransitionType.scale:
        return ScaleTransition(
          scale: animation.drive(
            Tween(begin: 0.8, end: 1.0).chain(
              CurveTween(curve: bouncyCurve),
            ),
          ),
          child: child,
        );
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case TransitionType.rotation:
        return RotationTransition(
          turns: animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: premiumCurve),
            ),
          ),
          child: child,
        );
    }
  }

  // Staggered list animations
  static List<Widget> staggeredList(
    List<Widget> children, {
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration itemDuration = const Duration(milliseconds: 600),
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      
      return fadeInUp(
        child,
        delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
        duration: itemDuration,
      );
    }).toList();
  }

  // Haptic feedback integration
  static void triggerHaptic(HapticType type) {
    if (!instance.animationsEnabled) return;
    
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  // Loading animations
  static Widget createLoadingAnimation({
    LoadingAnimationType type = LoadingAnimationType.pulse,
    List<Color>? colors,
    double size = 50,
  }) {
    final loadingColors = colors ?? ModernTheme.neonGradient;
    
    switch (type) {
      case LoadingAnimationType.pulse:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: loadingColors),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        
      case LoadingAnimationType.rotation:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 4),
            gradient: LinearGradient(colors: loadingColors),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(
          duration: const Duration(milliseconds: 1000),
        );
        
      case LoadingAnimationType.bounce:
        return Container(
          width: size / 3,
          height: size / 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: loadingColors.first,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -size / 2,
          duration: const Duration(milliseconds: 600),
          curve: Curves.bounceOut,
        );
    }
  }

  // Success animations
  static Widget successCheckmark({
    double size = 60,
    Color? color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? Colors.green,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size * 0.6,
      ),
    )
    .animate()
    .scale(
      begin: const Offset(0, 0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
    )
    .then(delay: 100.ms)
    .fadeIn(duration: 200.ms);
  }

  // Error animations  
  static Widget errorShake(Widget child) {
    return child
        .animate()
        .shake(
          duration: const Duration(milliseconds: 600),
          hz: 4,
          offset: const Offset(5, 0),
        );
  }

  // Attention-grabbing animations
  static Widget attentionGrabber(Widget child) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: const Duration(milliseconds: 1000),
        )
        .then()
        .tint(color: Colors.yellow.withValues(alpha: 0.3));
  }
}

enum TransitionType {
  slideUp,
  slideRight,
  scale,
  fade,
  rotation,
}

enum HapticType {
  light,
  medium,
  heavy,
  selection,
}

enum LoadingAnimationType {
  pulse,
  rotation,
  bounce,
}