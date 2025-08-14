import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/state/prayer_settings_state.dart';
import 'features/onboarding/presentation/screens/onboarding_navigation_screen.dart';
import 'features/onboarding/presentation/providers/onboarding_providers.dart';
import 'core/navigation/shell_wrapper.dart';
import 'features/prayer_times/presentation/providers/prayer_times_providers.dart';
import 'features/prayer_times/presentation/providers/notification_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize prayer settings state
  await PrayerSettingsState.instance.loadSettings();

  runApp(
    const ProviderScope(
      child: DeenMateApp(),
    ),
  );
}

class DeenMateApp extends ConsumerWidget {
  const DeenMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedOnboarding = ref.watch(onboardingProvider);
    // Warm cache for instant UI (no GPS prompt)
    ref.listen(cachedCurrentPrayerTimesProvider, (_, __) {});
    // Only prefetch after onboarding (prevents early GPS prompt)
    if (hasCompletedOnboarding) {
      ref.watch(prayerLocalInitAndPrefetchProvider);
      // Initialize notifications/Azan and schedule
      ref.watch(notificationInitProvider);
      ref.watch(autoNotificationSchedulerProvider);
    }
    return hasCompletedOnboarding
        ? MaterialApp.router(
            title: 'DeenMate',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('bn'),
              Locale('ar'),
            ],
            routerConfig: EnhancedAppRouter.router,
          )
        : MaterialApp(
            title: 'DeenMate - Onboarding',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('bn'),
              Locale('ar'),
            ],
            home: const OnboardingNavigationScreen(),
          );
  }
}
