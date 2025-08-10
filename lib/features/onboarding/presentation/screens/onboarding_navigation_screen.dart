import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_providers.dart';
import '01_welcome_screen.dart';

/// Onboarding navigation screen that manages the onboarding flow
/// This screen acts as a container for the onboarding process
class OnboardingNavigationScreen extends ConsumerStatefulWidget {
  const OnboardingNavigationScreen({super.key});

  @override
  ConsumerState<OnboardingNavigationScreen> createState() => _OnboardingNavigationScreenState();
}

class _OnboardingNavigationScreenState extends ConsumerState<OnboardingNavigationScreen> {
  @override
  void initState() {
    super.initState();
    // Reset onboarding state when entering onboarding flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resetOnboardingProvider);
    });
  }

  void _nextPage() {
    // For now, just mark onboarding as completed to test navigation
    ref.read(markOnboardingCompletedProvider(true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WelcomeScreen(onNext: _nextPage),
    );
  }
}
