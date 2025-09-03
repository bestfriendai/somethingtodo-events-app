import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'platform_interactions.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  // Custom page transitions for mobile
  static Route<T> createSlideRoute<T>({
    required Widget page,
    RouteSettings? settings,
    SlideDirection direction = SlideDirection.fromRight,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        switch (direction) {
          case SlideDirection.fromRight:
            begin = const Offset(1.0, 0.0);
            break;
          case SlideDirection.fromLeft:
            begin = const Offset(-1.0, 0.0);
            break;
          case SlideDirection.fromTop:
            begin = const Offset(0.0, -1.0);
            break;
          case SlideDirection.fromBottom:
            begin = const Offset(0.0, 1.0);
            break;
        }

        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // Scale transition (good for modals)
  static Route<T> createScaleRoute<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.8;
        const end = 1.0;
        const curve = Curves.easeOutBack;

        var scaleTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var fadeTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut));

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  // Hero-style transition for image views
  static Route<T> createHeroRoute<T>({
    required Widget page,
    required String heroTag,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  // Platform-specific navigation
  static Future<T?> pushPage<T>({
    required Widget page,
    RouteSettings? settings,
    bool fullscreenDialog = false,
    SlideDirection direction = SlideDirection.fromRight,
  }) {
    PlatformInteractions.lightImpact();

    Route<T> route;

    if (Platform.isIOS) {
      route = CupertinoPageRoute<T>(
        builder: (context) => page,
        settings: settings,
        fullscreenDialog: fullscreenDialog,
      );
    } else {
      route = createSlideRoute<T>(
        page: page,
        settings: settings,
        direction: direction,
      );
    }

    return navigator?.push<T>(route) ?? Future.value(null);
  }

  static Future<T?> pushModal<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    PlatformInteractions.mediumImpact();

    return navigator?.push<T>(
          createScaleRoute<T>(page: page, settings: settings),
        ) ??
        Future.value(null);
  }

  static Future<T?> pushReplacement<T, TO>({
    required Widget page,
    TO? result,
    RouteSettings? settings,
  }) {
    PlatformInteractions.lightImpact();

    return navigator?.pushReplacement<T, TO>(
          createSlideRoute<T>(page: page, settings: settings),
          result: result,
        ) ??
        Future.value(null);
  }

  static void pop<T>([T? result]) {
    PlatformInteractions.lightImpact();
    navigator?.pop<T>(result);
  }

  static void popUntil(String routeName) {
    navigator?.popUntil(ModalRoute.withName(routeName));
  }

  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    PlatformInteractions.lightImpact();
    return navigator?.pushNamed<T>(routeName, arguments: arguments) ??
        Future.value(null);
  }

  static Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigator?.pushReplacementNamed<T, TO>(
          routeName,
          result: result,
          arguments: arguments,
        ) ??
        Future.value(null);
  }

  // Gesture-based navigation
  static bool handleBackGesture(BuildContext context) {
    if (navigator?.canPop() ?? false) {
      pop();
      return true;
    }
    return false;
  }

  // Deep link navigation
  static Future<void> navigateToDeepLink(String deepLink) async {
    try {
      final uri = Uri.parse(deepLink);
      final pathSegments = uri.pathSegments;

      if (pathSegments.isEmpty) return;

      switch (pathSegments.first) {
        case 'event':
          if (pathSegments.length > 1) {
            await pushNamed('/event/${pathSegments[1]}');
          }
          break;
        case 'feed':
          await pushNamed('/feed');
          break;
        case 'profile':
          await pushNamed('/profile');
          break;
        default:
          await pushNamed('/home');
      }
    } catch (e) {
      print('Error navigating to deep link: $e');
      await pushNamed('/home');
    }
  }

  // Analytics for navigation
  static void logNavigation(
    String routeName, {
    Map<String, dynamic>? parameters,
  }) {
    if (kDebugMode) {
      print('Navigation: $routeName ${parameters ?? ''}');
    }
    // Add analytics tracking here
  }
}

enum SlideDirection { fromRight, fromLeft, fromTop, fromBottom }

// Custom route animations
class SlideRightRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideRightRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
}

class ScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScaleRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
            ),
            child: child,
          );
        },
      );
}

// Swipe-back gesture detector for iOS-like navigation
class SwipeBackDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwipeBack;

  const SwipeBackDetector({super.key, required this.child, this.onSwipeBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        // Start tracking swipe from left edge
        if (details.globalPosition.dx < 20) {
          // Potential back swipe
        }
      },
      onHorizontalDragUpdate: (details) {
        // Track swipe progress
        if (details.delta.dx > 0 && details.globalPosition.dx < 100) {
          // Swiping right from left edge
        }
      },
      onHorizontalDragEnd: (details) {
        // Check if swipe was fast enough and far enough
        if (details.velocity.pixelsPerSecond.dx > 300 &&
            details.primaryVelocity! > 0) {
          if (onSwipeBack != null) {
            onSwipeBack?.call();
          } else {
            NavigationService.pop();
          }
        }
      },
      child: child,
    );
  }
}
