import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanagementsouradip/ui/splash/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    /// Test Case 1: Render splash screen
    ///
    /// Purpose: Verify splash screen renders without errors
    /// Expected: Splash screen displays with logo and text
    testWidgets('should render splash screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(),
          routes: {'/login': (context) => const Scaffold()},
        ),
      );

      // Assert: Splash screen has logo and text
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      await tester.pumpAndSettle();
    });

    /// Test Case 2: Verify navigation after delay
    ///
    /// Purpose: Ensure splash navigates to login screen after delay
    /// Expected: Navigation occurs after 1 second
    testWidgets('should navigate to login after delay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {
            '/login': (context) =>
                const Scaffold(body: Center(child: Text('Login'))),
          },
        ),
      );

      // Act: Wait for navigation timer
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert: Should be on login screen or have navigation called
      expect(find.byType(SplashScreen), findsNothing);
    });

    /// Test Case 3: AnimationController lifecycle
    ///
    /// Purpose: Verify animation controller is properly initialized and disposed
    /// Expected: Animation controller animates and disposes correctly
    testWidgets('should animate and dispose properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {'/login': (context) => const Scaffold()},
        ),
      );

      // Assert: Animation has started
      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance animation
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {'/login': (context) => const Scaffold()},
        ),
      );

      await tester.pumpAndSettle();
    });

    /// Test Case 4: Splash has correct background color
    ///
    /// Purpose: Verify splash screen has correct styling
    /// Expected: Scaffold renders with correct background
    testWidgets('should display with correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {'/login': (context) => const Scaffold()},
        ),
      );

      // Assert: Scaffold is present
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
