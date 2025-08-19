import 'package:deen_mate/features/prayer_times/domain/entities/isha_time_data.dart';
import 'package:deen_mate/features/prayer_times/domain/entities/prayer_times.dart';

/// Use case for calculating authentic Isha prayer times based on Sahih hadiths
///
/// Primary Source: Sahih Muslim (612) - "The time of Isha is until the middle of the night"
/// Islamic Midnight = (Maghrib Time + Fajr Time) ÷ 2
class CalculateIshaTimeUsecase {
  const CalculateIshaTimeUsecase();

  /// Calculate Islamic midnight based on Maghrib and Fajr times
  ///
  /// Islamic Midnight = (Maghrib Time + Fajr Time) ÷ 2
  /// This represents the true middle of the night, not clock midnight
  DateTime calculateIslamicMidnight(DateTime maghribTime, DateTime fajrTime) {
    // Ensure Fajr is the next day if it's before Maghrib
    DateTime nextDayFajr = fajrTime;
    if (fajrTime.isBefore(maghribTime)) {
      nextDayFajr = fajrTime.add(const Duration(days: 1));
    }

    // Calculate the middle point
    final nightDuration = nextDayFajr.difference(maghribTime);
    final halfNightDuration =
        Duration(microseconds: nightDuration.inMicroseconds ~/ 2);

    return maghribTime.add(halfNightDuration);
  }

  /// Calculate the optimal Isha prayer window (first third of the night)
  ///
  /// Best Time: First third of the night (Prophet's ﷺ preference)
  /// Calculation: Maghrib + (Night Duration ÷ 3)
  DateTime calculateOptimalIshaEndTime(
      DateTime maghribTime, DateTime fajrTime) {
    // Ensure Fajr is the next day if it's before Maghrib
    DateTime nextDayFajr = fajrTime;
    if (fajrTime.isBefore(maghribTime)) {
      nextDayFajr = fajrTime.add(const Duration(days: 1));
    }

    // Calculate first third of the night
    final nightDuration = nextDayFajr.difference(maghribTime);
    final firstThirdDuration =
        Duration(microseconds: nightDuration.inMicroseconds ~/ 3);

    return maghribTime.add(firstThirdDuration);
  }

  /// Calculate Isha start time with buffer for complete darkness
  ///
  /// Begin after Maghrib twilight disappears
  /// Buffer of 10-15 minutes after Maghrib for complete darkness
  DateTime calculateIshaStartTime(DateTime maghribTime) {
    // Add 15 minutes buffer for complete darkness after Maghrib
    return maghribTime.add(const Duration(minutes: 15));
  }

  /// Get the current Isha status based on current time
  IshaStatus getIshaStatus(
    DateTime currentTime,
    DateTime ishaStartTime,
    DateTime optimalEndTime,
    DateTime islamicMidnight,
  ) {
    if (currentTime.isBefore(ishaStartTime)) {
      return IshaStatus.optimal; // Not yet Isha time
    }

    if (currentTime.isBefore(optimalEndTime)) {
      return IshaStatus.optimal; // Best time
    }

    if (currentTime.isBefore(islamicMidnight)) {
      // Check if approaching deadline (30 minutes before)
      final timeUntilMidnight = islamicMidnight.difference(currentTime);
      if (timeUntilMidnight.inMinutes <= 30) {
        return IshaStatus.ending; // Approaching deadline
      }
      return IshaStatus.permissible; // Permissible but less preferred
    }

    return IshaStatus.ended; // Past Islamic midnight
  }

  /// Calculate complete Isha time data for a given date
  IshaTimeData calculateIshaTimeData(
    PrayerTimes prayerTimes,
    ScholarlyView scholarlyView,
  ) {
    final maghribTime = prayerTimes.maghrib.time;
    final fajrTime = prayerTimes.fajr.time;

    // Calculate key times
    final ishaStartTime = calculateIshaStartTime(maghribTime);
    final islamicMidnight = calculateIslamicMidnight(maghribTime, fajrTime);
    final optimalEndTime = calculateOptimalIshaEndTime(maghribTime, fajrTime);

    // Calculate night duration
    DateTime nextDayFajr = fajrTime;
    if (fajrTime.isBefore(maghribTime)) {
      nextDayFajr = fajrTime.add(const Duration(days: 1));
    }
    final nightDuration = nextDayFajr.difference(maghribTime);

    // Determine absolute end time based on scholarly view
    final absoluteEndTime =
        scholarlyView == ScholarlyView.strict ? islamicMidnight : nextDayFajr;

    // Get current status
    final currentTime = DateTime.now();
    final status = getIshaStatus(
      currentTime,
      ishaStartTime,
      optimalEndTime,
      islamicMidnight,
    );

    // Calculate time until Islamic midnight
    final timeUntilMidnight = islamicMidnight.difference(currentTime);

    return IshaTimeData(
      startTime: ishaStartTime,
      optimalEndTime: optimalEndTime,
      absoluteEndTime: absoluteEndTime,
      islamicMidnight: islamicMidnight,
      status: status,
      scholarlyView: scholarlyView,
      nightDuration: nightDuration,
      timeUntilMidnight:
          timeUntilMidnight.isNegative ? Duration.zero : timeUntilMidnight,
    );
  }

  /// Get educational information about Isha prayer times
  Map<String, String> getIshaEducationalInfo() {
    return {
      'hadith_source': 'Sahih Muslim (612)',
      'hadith_text': 'The time of Isha is until the middle of the night',
      'explanation':
          'Islamic midnight is calculated as the middle point between Maghrib and Fajr, not clock midnight. The Prophet ﷺ preferred praying Isha in the first third of the night.',
      'scholarly_differences':
          'Some scholars (Ibn Hazm, Al-Albani) consider Islamic midnight as a hard deadline, while the majority view allows until Fajr but considers it less preferred after midnight.',
    };
  }
}
