import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/01_welcome_screen.dart';
import 'screens/02_language_screen.dart';
import 'screens/03_location_screen.dart';
import 'screens/04_calculation_method_screen.dart';
import 'screens/05_madhhab_screen.dart';
import 'screens/06_notifications_screen.dart';
import 'screens/07_theme_screen.dart';
import 'screens/08_complete_screen.dart';

/// Onboarding router configuration
class OnboardingRouter {
  static const String welcome = '/onboarding/welcome';
  static const String language = '/onboarding/language';
  static const String location = '/onboarding/location';
  static const String calculationMethod = '/onboarding/calculation-method';
  static const String madhhab = '/onboarding/madhhab';
  static const String notifications = '/onboarding/notifications';
  static const String theme = '/onboarding/theme';
  static const String complete = '/onboarding/complete';

  /// Get onboarding routes
  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: language,
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: location,
        builder: (context, state) => const LocationScreen(),
      ),
      GoRoute(
        path: calculationMethod,
        builder: (context, state) => const CalculationMethodScreen(),
      ),
      GoRoute(
        path: madhhab,
        builder: (context, state) => const MadhhabScreen(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: theme,
        builder: (context, state) => const ThemeScreen(),
      ),
      GoRoute(
        path: complete,
        builder: (context, state) => const CompleteScreen(),
      ),
    ];
  }

  /// Check if user should see onboarding
  static Future<bool> shouldShowOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      return !onboardingCompleted;
    } catch (e) {
      // If there's an error, show onboarding
      return true;
    }
  }

  /// Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Reset onboarding (for testing)
  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', false);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get initial onboarding route
  static String getInitialRoute() {
    return welcome;
  }

  /// Navigate to onboarding
  static void navigateToOnboarding(BuildContext context) {
    context.go(welcome);
  }

  /// Navigate to next onboarding step
  static void navigateToNext(BuildContext context, String currentRoute) {
    switch (currentRoute) {
      case welcome:
        context.go(language);
        break;
      case language:
        context.go(location);
        break;
      case location:
        context.go(calculationMethod);
        break;
      case calculationMethod:
        context.go(madhhab);
        break;
      case madhhab:
        context.go(notifications);
        break;
      case notifications:
        context.go(theme);
        break;
      case theme:
        context.go(complete);
        break;
      case complete:
        // Navigate to main app
        context.go('/home');
        break;
    }
  }

  /// Navigate to previous onboarding step
  static void navigateToPrevious(BuildContext context, String currentRoute) {
    switch (currentRoute) {
      case language:
        context.go(welcome);
        break;
      case location:
        context.go(language);
        break;
      case calculationMethod:
        context.go(location);
        break;
      case madhhab:
        context.go(calculationMethod);
        break;
      case notifications:
        context.go(madhhab);
        break;
      case theme:
        context.go(notifications);
        break;
      case complete:
        context.go(theme);
        break;
    }
  }

  /// Get step number from route
  static int getStepNumber(String route) {
    switch (route) {
      case welcome:
        return 1;
      case language:
        return 2;
      case location:
        return 3;
      case calculationMethod:
        return 4;
      case madhhab:
        return 5;
      case notifications:
        return 6;
      case theme:
        return 7;
      case complete:
        return 8;
      default:
        return 1;
    }
  }

  /// Get total steps
  static int getTotalSteps() {
    return 8;
  }
}
