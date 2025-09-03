import 'package:flutter/material.dart';
import 'dart:async';

class NavigationHelper {
  static void navigateToHome(BuildContext context) {
    print('🔍 NavigationHelper.navigateToHome called');

    // Use multiple fallback approaches to ensure navigation works
    _attemptNavigation(context, '/home', 0);
  }

  static void _attemptNavigation(
    BuildContext context,
    String route,
    int attempt,
  ) {
    if (attempt > 3) {
      print('❌ All navigation attempts failed');
      return;
    }

    print('🔍 Navigation attempt ${attempt + 1}');

    try {
      switch (attempt) {
        case 0:
          // Method 1: Delayed navigation with postFrameCallback
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              try {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(route, (route) => false);
                print('✅ Navigation successful (method 1)');
              } catch (e) {
                print('❌ Method 1 failed: $e');
                _attemptNavigation(context, route, attempt + 1);
              }
            }
          });
          break;

        case 1:
          // Method 2: Timer-based delayed navigation
          Timer(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              try {
                Navigator.of(context).pushReplacementNamed(route);
                print('✅ Navigation successful (method 2)');
              } catch (e) {
                print('❌ Method 2 failed: $e');
                _attemptNavigation(context, route, attempt + 1);
              }
            }
          });
          break;

        case 2:
          // Method 3: Immediate navigation
          if (context.mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(route, (route) => false);
            print('✅ Navigation successful (method 3)');
          }
          break;

        case 3:
          // Method 4: Force page reload (web-specific fallback)
          print('🔄 Using page reload fallback');
          if (context.mounted) {
            // This will trigger a full page reload which should work
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
          }
          break;
      }
    } catch (e) {
      print('❌ Navigation attempt ${attempt + 1} failed: $e');
      if (attempt < 3) {
        _attemptNavigation(context, route, attempt + 1);
      }
    }
  }

  static void navigateToAuth(BuildContext context) {
    _attemptNavigation(context, '/auth', 0);
  }
}
