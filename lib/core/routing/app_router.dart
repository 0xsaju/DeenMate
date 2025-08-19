import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/prayer_times/presentation/screens/athan_settings_screen.dart';
import '../../features/settings/presentation/screens/app_settings_screen.dart';
import '../../features/prayer_times/presentation/screens/calculation_method_screen.dart';
import '../../features/prayer_times/presentation/screens/isha_time_demo_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/qibla/presentation/screens/qibla_compass_screen.dart';
import '../../features/home/presentation/screens/zakat_calculator_screen.dart';

/// Application routing configuration using GoRouter
/// Provides type-safe navigation with Islamic app structure
class AppRouter {
  static const String home = '/';
  static const String zakatCalculator = '/zakat-calculator';
  static const String prayerTimes = '/prayer-times';
  static const String qiblaFinder = '/qibla-finder';
  static const String sawmTracker = '/sawm-tracker';
  static const String islamicWill = '/islamic-will';
  static const String settings = '/settings';
  static const String athanSettings = '/athan-settings';
  static const String calculationMethod = '/calculation-method';
  static const String ishaTimeDemo = '/isha-time-demo';
  static const String profile = '/profile';
  static const String history = '/history';
  static const String reports = '/reports';

  static final GoRouter _router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      // Home route now points to HomeScreen (prayer experience)
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Zakat Calculator
      GoRoute(
        path: zakatCalculator,
        name: 'zakat-calculator',
        builder: (context, state) => const ZakatCalculatorScreen(),
      ),

      // Prayer Times (alias to home for now)
      GoRoute(
        path: prayerTimes,
        name: 'prayer-times',
        builder: (context, state) => const HomeScreen(),
      ),

      // Qibla Finder
      GoRoute(
        path: qiblaFinder,
        name: 'qibla-finder',
        builder: (context, state) => const QiblaCompassScreen(),
      ),

      // Sawm Tracker (placeholder)
      GoRoute(
        path: sawmTracker,
        name: 'sawm-tracker',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Sawm Tracker',
          icon: Icons.calendar_month,
          description: 'Track your fasting during Ramadan',
        ),
      ),

      // Islamic Will (placeholder)
      GoRoute(
        path: islamicWill,
        name: 'islamic-will',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Islamic Will',
          icon: Icons.description,
          description: 'Generate Islamic will according to Shariah',
        ),
      ),

      // Settings
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const AppSettingsScreen(),
      ),

      // Athan Settings
      GoRoute(
        path: athanSettings,
        name: 'athan-settings',
        builder: (context, state) => const AthanSettingsScreen(),
      ),

      // Calculation Method
      GoRoute(
        path: calculationMethod,
        name: 'calculation-method',
        builder: (context, state) => const CalculationMethodScreen(),
      ),

      // Profile (placeholder)
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Profile',
          icon: Icons.person,
          description: 'Manage your profile information',
        ),
      ),

      // History (placeholder)
      GoRoute(
        path: history,
        name: 'history',
        builder: (context, state) => const PlaceholderScreen(
          title: 'History',
          icon: Icons.history,
          description: 'View your calculation history',
        ),
      ),

      // Reports (placeholder)
      GoRoute(
        path: reports,
        name: 'reports',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Reports',
          icon: Icons.assessment,
          description: 'Generate and view reports',
        ),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );

  static GoRouter get router => _router;
}

// Home is now provided by HomeScreen (prayer experience)

/// Placeholder screen for features under development
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.description,
    super.key,
  });
  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 80,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  children: [
                    Icon(Icons.construction, color: Colors.blue[700]),
                    const SizedBox(height: 8),
                    Text(
                      'Coming Soon!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This feature is under development and will be available in future updates.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRouter.home),
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error screen for navigation errors
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (error != null) ...[
                Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
              ElevatedButton.icon(
                onPressed: () => context.go(AppRouter.home),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
