import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider to check if user has completed onboarding
final onboardingStateProvider = FutureProvider<bool>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  } catch (e) {
    // If there's an error, assume onboarding is not completed
    return false;
  }
});

/// Provider to mark onboarding as completed
final markOnboardingCompletedProvider = FutureProvider.family<void, bool>((ref, completed) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', completed);
    // Invalidate the onboarding state provider to refresh the UI
    ref.invalidate(onboardingStateProvider);
  } catch (e) {
    // Handle error silently
  }
});

/// Provider to reset onboarding (for testing purposes)
final resetOnboardingProvider = FutureProvider<void>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', false);
    // Invalidate the onboarding state provider to refresh the UI
    ref.invalidate(onboardingStateProvider);
  } catch (e) {
    // Handle error silently
  }
});
