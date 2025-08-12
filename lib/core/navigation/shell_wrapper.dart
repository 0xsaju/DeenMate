import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/prayer_times/presentation/screens/athan_settings_screen.dart';
import '../../features/prayer_times/presentation/screens/calculation_method_screen.dart';
import '../../features/prayer_times/presentation/screens/prayer_times_screen.dart';
import '../../features/qibla/presentation/screens/qibla_compass_screen.dart';
// import '../../features/zakat/presentation/screens/zakat_calculator_screen.dart';
import '../../features/islamic_content/presentation/screens/islamic_content_screen.dart';
import '../routing/app_router.dart';
import '../widgets/enhanced_home_dashboard.dart';
import '../widgets/themed_widgets.dart';
import 'bottom_navigation_wrapper.dart';
import 'more_screen.dart';

/// Shell wrapper that adds bottom navigation to existing routing
/// This doesn't break the existing routing system, just adds navigation UI
class ShellWrapper extends StatelessWidget {

  const ShellWrapper({
    required this.child, required this.state, super.key,
  });
  final Widget child;
  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    // Use enhanced dashboard for home route, otherwise use existing child
    final bodyWidget = state.matchedLocation == AppRouter.home 
        ? const EnhancedHomeDashboard()
        : state.matchedLocation == '/more'
        ? const MoreScreen()
        : child;

    return BottomNavigationWrapper(
      currentLocation: state.matchedLocation,
      child: bodyWidget,
    );
  }
}

/// Modified router configuration that includes shell wrapper
class EnhancedAppRouter {
  static const String home = '/';
  static const String zakatCalculator = '/zakat-calculator';
  static const String prayerTimes = '/prayer-times';
  static const String qiblaFinder = '/qibla-finder';
  static const String more = '/more';
  static const String sawmTracker = '/sawm-tracker';
  static const String islamicWill = '/islamic-will';
  static const String settings = '/settings';
  static const String athanSettings = '/athan-settings';
  static const String calculationMethod = '/calculation-method';
  static const String profile = '/profile';
  static const String history = '/history';
  static const String reports = '/reports';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      // Shell route with bottom navigation
      ShellRoute(
        builder: (context, state, child) => ShellWrapper(
          state: state,
          child: child,
        ),
        routes: [
          // Home route
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const SizedBox.shrink(), // Shell handles this
          ),

          // Main feature routes
          // GoRoute(
          //   path: zakatCalculator,
          //   name: 'zakat-calculator',
          //   builder: (context, state) => const ZakatCalculatorScreen(),
          // ),

          GoRoute(
            path: prayerTimes,
            name: 'prayer-times',
            builder: (context, state) => const PrayerTimesScreen(),
          ),

          GoRoute(
            path: qiblaFinder,
            name: 'qibla-finder',
            builder: (context, state) => const QiblaCompassScreen(),
          ),

          GoRoute(
            path: more,
            name: 'more',
            builder: (context, state) => const SizedBox.shrink(), // Shell handles this
          ),

          // Islamic Content
          GoRoute(
            path: '/islamic-content',
            name: 'islamic-content',
            builder: (context, state) => const IslamicContentScreen(),
          ),

          // Secondary routes
          GoRoute(
            path: sawmTracker,
            name: 'sawm-tracker',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Sawm Tracker',
              icon: Icons.calendar_month,
              description: 'Track your fasting during Ramadan',
            ),
          ),

          GoRoute(
            path: islamicWill,
            name: 'islamic-will',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Islamic Will',
              icon: Icons.description,
              description: 'Generate Islamic will according to Shariah',
            ),
          ),

          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Settings',
              icon: Icons.settings,
              description: 'Configure app preferences',
            ),
          ),

          GoRoute(
            path: profile,
            name: 'profile',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Profile',
              icon: Icons.person,
              description: 'Manage your profile information',
            ),
          ),

          GoRoute(
            path: history,
            name: 'history',
            builder: (context, state) => const PlaceholderScreen(
              title: 'History',
              icon: Icons.history,
              description: 'View your calculation history',
            ),
          ),

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
      ),

      // Routes that should not have bottom navigation
      GoRoute(
        path: athanSettings,
        name: 'athan-settings',
        builder: (context, state) => const AthanSettingsScreen(),
      ),

      GoRoute(
        path: calculationMethod,
        name: 'calculation-method',
        builder: (context, state) => const CalculationMethodScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
}

// Real screens are now imported from the actual feature modules

class PlaceholderScreen extends StatelessWidget {

  const PlaceholderScreen({
    required this.title, required this.icon, required this.description, super.key,
  });
  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: ThemedAppBar(
        titleText: title,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
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
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 80,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ThemedCard(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Icon(
                      Icons.construction,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coming Soon!',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This feature is under development.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {

  const ErrorScreen({super.key, this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: ThemedAppBar(
        titleText: 'Error',
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ThemedElevatedButton(
                onPressed: () => context.go(EnhancedAppRouter.home),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home),
                    SizedBox(width: 8),
                    Text('Go Home'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
