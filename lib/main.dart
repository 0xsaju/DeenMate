import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/state/prayer_settings_state.dart';
import 'core/state/app_lifecycle_manager.dart';
import 'core/theme/theme_provider.dart';
import 'core/localization/language_provider.dart';
import 'core/localization/language_models.dart';
import 'features/onboarding/presentation/screens/onboarding_navigation_screen.dart';
import 'features/onboarding/presentation/providers/onboarding_providers.dart';
import 'core/navigation/shell_wrapper.dart';
import 'features/prayer_times/presentation/providers/prayer_times_providers.dart';
import 'features/prayer_times/presentation/providers/notification_providers.dart';
import 'features/quran/presentation/state/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Clear Quran cache to force new translation ID
  try {
    final prefsBox = await Hive.openBox('quran_prefs');
    final versesBox = await Hive.openBox('verses');
    await prefsBox.clear();
    await versesBox.clear();
    print('Quran cache cleared successfully');
  } catch (e) {
    print('Cache clear error: $e');
  }

  // Initialize prayer settings state
  await PrayerSettingsState.instance.loadSettings();

  // Initialize language system
  await Hive.initFlutter();

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
      // Ensure storage is initialized and cache prefetched at app start
      ref.watch(prayerLocalInitAndPrefetchProvider);
      // Initialize notifications/Azan and schedule
      ref.watch(notificationInitProvider);
      ref.watch(autoNotificationSchedulerProvider);
      // Background download essential Quran text (silently, no UI)
      ref.watch(quranBackgroundDownloadProvider);
      // Listen to connectivity to auto-refresh when back online
      ref.watch(prayerTimesConnectivityRefreshProvider);
      // Schedule daily prayer time refreshes (4 times per day)
      ref.watch(prayerTimesScheduledRefreshProvider);
      // Refresh when prayer settings change
      ref.watch(prayerTimesSettingsRefreshProvider);
    }
    return hasCompletedOnboarding
        ? MaterialApp.router(
            title: 'DeenMate',
            debugShowCheckedModeBanner: false,
            theme: ref.watch(themeDataProvider),
            themeMode: ThemeMode.system,
            locale: ref.watch(currentLocaleProvider),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: SupportedLanguage.values.map((lang) => lang.locale).toList(),
            routerConfig: EnhancedAppRouter.router,
            builder: (context, child) {
              return AppLifecycleManager(
                child: WillPopScope(
                  onWillPop: () async {
                    // Show exit confirmation dialog
                    final shouldExit = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Exit DeenMate'),
                        content: const Text(
                            'Are you sure you want to exit the app?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Exit'),
                          ),
                        ],
                      ),
                    );
                    return shouldExit ?? false;
                  },
                  child: child!,
                ),
              );
            },
          )
        : MaterialApp(
            title: 'DeenMate - Onboarding',
            debugShowCheckedModeBanner: false,
            theme: ref.watch(themeDataProvider),
            themeMode: ThemeMode.system,
            locale: ref.watch(currentLocaleProvider),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: SupportedLanguage.values.map((lang) => lang.locale).toList(),
            home: const OnboardingNavigationScreen(),
          );
  }
}
