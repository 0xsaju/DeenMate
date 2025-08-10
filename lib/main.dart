import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/final_enhanced_home_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_navigation_screen.dart';
import 'features/onboarding/presentation/providers/onboarding_providers.dart';

void main() {
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
            ? MaterialApp(
                title: 'DeenMate',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.system,
                home: const FinalEnhancedHomeScreen(),
              )
            : MaterialApp(
                title: 'DeenMate - Onboarding',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.system,
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