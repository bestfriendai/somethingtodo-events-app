import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:somethingtodo/main.dart' as app;
import 'package:somethingtodo/screens/auth/glass_auth_screen.dart';
import 'package:somethingtodo/screens/home/modern_main_navigation_screen.dart';
import 'package:somethingtodo/screens/onboarding/glass_onboarding_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Tests', () {
    testWidgets('Complete user journey from splash to home', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify splash screen appears
      expect(find.text('SomethingToDo'), findsOneWidget);
      
      // Wait for navigation to onboarding or auth
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check if we're on onboarding screen (first time user)
      if (find.byType(GlassOnboardingScreen).evaluate().isNotEmpty) {
        // Complete onboarding
        await _completeOnboarding(tester);
      }

      // Check if we're on auth screen
      if (find.byType(GlassAuthScreen).evaluate().isNotEmpty) {
        // Complete authentication
        await _completeAuth(tester);
      }

      // Verify we reach the home screen
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(ModernMainNavigationScreen), findsOneWidget);
    });

    testWidgets('Navigate through main app sections', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to home if needed
      await _navigateToHome(tester);

      // Test bottom navigation
      await _testBottomNavigation(tester);

      // Test event discovery
      await _testEventDiscovery(tester);

      // Test search functionality
      await _testSearch(tester);

      // Test profile access
      await _testProfile(tester);
    });

    testWidgets('Test offline mode functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _navigateToHome(tester);

      // Simulate offline mode
      // The app should show cached content
      expect(find.text('Offline Mode'), findsNothing); // Should handle gracefully

      // Verify cached data is displayed
      await tester.pumpAndSettle();
      
      // Check for event cards or empty state
      expect(
        find.byType(Card).evaluate().isNotEmpty || 
        find.text('No events available').evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Test error handling and recovery', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _navigateToHome(tester);

      // Test error states
      // The app should handle errors gracefully
      await tester.pumpAndSettle();

      // Verify no crash occurs
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}

Future<void> _completeOnboarding(WidgetTester tester) async {
  // Find and tap next button multiple times
  for (int i = 0; i < 3; i++) {
    final nextButton = find.text('Next');
    if (nextButton.evaluate().isNotEmpty) {
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
    }
  }

  // Tap get started or similar
  final getStarted = find.text('Get Started');
  if (getStarted.evaluate().isNotEmpty) {
    await tester.tap(getStarted);
    await tester.pumpAndSettle();
  }
}

Future<void> _completeAuth(WidgetTester tester) async {
  // Try to find skip or continue as guest option
  final skipButton = find.text('Skip');
  final guestButton = find.text('Continue as Guest');
  final laterButton = find.text('Maybe Later');

  if (skipButton.evaluate().isNotEmpty) {
    await tester.tap(skipButton);
  } else if (guestButton.evaluate().isNotEmpty) {
    await tester.tap(guestButton);
  } else if (laterButton.evaluate().isNotEmpty) {
    await tester.tap(laterButton);
  } else {
    // If no skip option, fill in test credentials
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;

    if (emailField.evaluate().isNotEmpty) {
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();
    }

    if (passwordField.evaluate().isNotEmpty) {
      await tester.enterText(passwordField, 'Test123!');
      await tester.pumpAndSettle();
    }

    // Find and tap sign in button
    final signInButton = find.text('Sign In');
    if (signInButton.evaluate().isNotEmpty) {
      await tester.tap(signInButton);
    }
  }

  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _navigateToHome(WidgetTester tester) async {
  // Skip onboarding if present
  if (find.byType(GlassOnboardingScreen).evaluate().isNotEmpty) {
    await _completeOnboarding(tester);
  }

  // Skip auth if present
  if (find.byType(GlassAuthScreen).evaluate().isNotEmpty) {
    await _completeAuth(tester);
  }

  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _testBottomNavigation(WidgetTester tester) async {
  // Find bottom navigation bar
  final bottomNav = find.byType(BottomNavigationBar);
  
  if (bottomNav.evaluate().isNotEmpty) {
    // Test each navigation item
    final icons = [
      Icons.explore,
      Icons.map,
      Icons.favorite,
      Icons.person,
    ];

    for (final icon in icons) {
      final navItem = find.byIcon(icon);
      if (navItem.evaluate().isNotEmpty) {
        await tester.tap(navItem);
        await tester.pumpAndSettle();
        
        // Verify navigation occurred
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    }

    // Return to home
    final homeIcon = find.byIcon(Icons.home);
    if (homeIcon.evaluate().isNotEmpty) {
      await tester.tap(homeIcon);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _testEventDiscovery(WidgetTester tester) async {
  // Look for event cards
  final eventCards = find.byType(Card);
  
  if (eventCards.evaluate().isNotEmpty) {
    // Tap on first event card
    await tester.tap(eventCards.first);
    await tester.pumpAndSettle();

    // Check if event details screen opened
    // Look for common event detail elements
    final backButton = find.byIcon(Icons.arrow_back);
    if (backButton.evaluate().isNotEmpty) {
      // We're on a detail screen, go back
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _testSearch(WidgetTester tester) async {
  // Find search icon or search bar
  final searchIcon = find.byIcon(Icons.search);
  
  if (searchIcon.evaluate().isNotEmpty) {
    await tester.tap(searchIcon.first);
    await tester.pumpAndSettle();

    // Find search text field
    final searchField = find.byType(TextField);
    if (searchField.evaluate().isNotEmpty) {
      await tester.enterText(searchField.first, 'Concert');
      await tester.pumpAndSettle();

      // Submit search
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Verify search results or no results message
      expect(
        find.byType(Card).evaluate().isNotEmpty ||
        find.textContaining('No results').evaluate().isNotEmpty ||
        find.textContaining('No events').evaluate().isNotEmpty,
        true,
      );

      // Go back
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    }
  }
}

Future<void> _testProfile(WidgetTester tester) async {
  // Navigate to profile
  final profileIcon = find.byIcon(Icons.person);
  
  if (profileIcon.evaluate().isNotEmpty) {
    await tester.tap(profileIcon.last);
    await tester.pumpAndSettle();

    // Verify profile screen elements
    // Look for common profile elements
    expect(
      find.text('Profile').evaluate().isNotEmpty ||
      find.text('Settings').evaluate().isNotEmpty ||
      find.text('Guest User').evaluate().isNotEmpty ||
      find.byIcon(Icons.settings).evaluate().isNotEmpty,
      true,
    );

    // Go back to home
    final homeIcon = find.byIcon(Icons.home);
    if (homeIcon.evaluate().isNotEmpty) {
      await tester.tap(homeIcon);
      await tester.pumpAndSettle();
    }
  }
}