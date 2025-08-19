import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deen_mate/features/prayer_times/domain/entities/isha_time_data.dart';
import 'package:deen_mate/features/prayer_times/domain/usecases/calculate_isha_time_usecase.dart';
import 'package:deen_mate/features/prayer_times/presentation/providers/prayer_times_providers.dart';

/// Provider for Isha time calculation use case
final ishaTimeCalculationProvider = Provider<CalculateIshaTimeUsecase>((ref) {
  return const CalculateIshaTimeUsecase();
});

/// Provider for user's scholarly view preference
/// Default to majority view (Jumhur) as it's more commonly followed
final scholarlyViewProvider = StateProvider<ScholarlyView>((ref) {
  return ScholarlyView.majority;
});

/// Provider for Isha time data based on current prayer times
final ishaTimeDataProvider = FutureProvider<IshaTimeData>((ref) async {
  final prayerTimes = await ref.read(currentPrayerTimesProvider.future);
  final scholarlyView = ref.read(scholarlyViewProvider);
  final calculator = ref.read(ishaTimeCalculationProvider);

  return calculator.calculateIshaTimeData(prayerTimes, scholarlyView);
});

/// Stream provider for real-time Isha status updates
final ishaStatusStreamProvider = StreamProvider<IshaTimeData>((ref) async* {
  final calculator = ref.read(ishaTimeCalculationProvider);
  final scholarlyView = ref.read(scholarlyViewProvider);

  // Initial calculation
  final prayerTimes = await ref.read(currentPrayerTimesProvider.future);
  var currentData =
      calculator.calculateIshaTimeData(prayerTimes, scholarlyView);
  yield currentData;

  // Update every minute to track status changes
  yield* Stream.periodic(const Duration(minutes: 1), (_) {
    final now = DateTime.now();
    final newStatus = calculator.getIshaStatus(
      now,
      currentData.startTime,
      currentData.optimalEndTime,
      currentData.islamicMidnight,
    );

    // Update time until midnight
    final timeUntilMidnight = currentData.islamicMidnight.difference(now);

    currentData = currentData.copyWith(
      status: newStatus,
      timeUntilMidnight:
          timeUntilMidnight.isNegative ? Duration.zero : timeUntilMidnight,
    );

    return currentData;
  });
});

/// Provider for Isha notification settings
final ishaNotificationSettingsProvider =
    StateProvider<Map<String, bool>>((ref) {
  return {
    'enable_deadline_reminders': true,
    'enable_optimal_time_reminders': true,
    'enable_educational_notifications': false,
  };
});

/// Provider for Isha deadline reminder timing (in minutes before Islamic midnight)
final ishaDeadlineReminderTimingProvider = StateProvider<List<int>>((ref) {
  return [15, 30, 60]; // Remind 15, 30, and 60 minutes before
});

/// Provider for educational information about Isha prayer times
final ishaEducationalInfoProvider = Provider<Map<String, String>>((ref) {
  final calculator = ref.read(ishaTimeCalculationProvider);
  return calculator.getIshaEducationalInfo();
});

/// Provider for Isha time display format preferences
final ishaDisplayPreferencesProvider = StateProvider<Map<String, bool>>((ref) {
  return {
    'show_islamic_midnight': true,
    'show_optimal_window': true,
    'show_scholarly_differences': false,
    'show_educational_tips': false,
  };
});

/// Helper provider to check if current time is within Isha prayer window
final isCurrentTimeIshaProvider = Provider<bool>((ref) {
  final ishaData = ref.watch(ishaTimeDataProvider).value;
  if (ishaData == null) return false;

  final now = DateTime.now();
  return now.isAfter(ishaData.startTime) &&
      now.isBefore(ishaData.absoluteEndTime);
});

/// Provider for Isha prayer urgency level
final ishaUrgencyLevelProvider = Provider<String>((ref) {
  final ishaData = ref.watch(ishaStatusStreamProvider).value;
  if (ishaData == null) return 'normal';

  switch (ishaData.status) {
    case IshaStatus.optimal:
      return 'optimal';
    case IshaStatus.permissible:
      return 'permissible';
    case IshaStatus.ending:
      return 'urgent';
    case IshaStatus.ended:
      return 'missed';
  }
});

/// Provider for Isha prayer status message
final ishaStatusMessageProvider = Provider<String>((ref) {
  final ishaData = ref.watch(ishaStatusStreamProvider).value;
  if (ishaData == null) return '';

  switch (ishaData.status) {
    case IshaStatus.optimal:
      return 'Best time to pray Isha';
    case IshaStatus.permissible:
      return 'Still permissible to pray Isha';
    case IshaStatus.ending:
      final minutes = ishaData.timeUntilMidnight.inMinutes;
      return 'Isha time ending in $minutes minutes';
    case IshaStatus.ended:
      return ishaData.scholarlyView == ScholarlyView.strict
          ? 'Isha time has ended (Qada required)'
          : 'Isha time has ended (less preferred)';
  }
});
