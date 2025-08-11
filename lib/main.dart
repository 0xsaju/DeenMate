import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/screens/onboarding_navigation_screen.dart';
import 'features/onboarding/presentation/providers/onboarding_providers.dart';
import 'core/navigation/shell_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
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
    return Consumer(
      builder: (context, ref, child) {
        final hasCompletedOnboarding = ref.watch(onboardingStateProvider);
        
        return hasCompletedOnboarding.when(
          data: (completed) => completed
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
                ),
          loading: () => MaterialApp(
            title: 'DeenMate',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => MaterialApp(
            title: 'DeenMate',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const OnboardingNavigationScreen(),
          ),
        );
      },
    );
  }
}