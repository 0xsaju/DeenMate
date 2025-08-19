import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_calculation_settings.dart';
import '../../domain/repositories/prayer_times_repository.dart';

/// Use case for getting current and next prayer information
class GetCurrentAndNextPrayerUsecase {
  const GetCurrentAndNextPrayerUsecase(this._repository);

  final PrayerTimesRepository _repository;

  Future<Either<Failure, Map<String, dynamic>>> call({
    required Location location,
    PrayerCalculationSettings? settings,
  }) async {
    try {
      print('=== USECASE getCurrentAndNextPrayer START ===');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      print('UseCase: Current time: $now, Today: $today');
      print('UseCase: Settings - Method: ${settings?.calculationMethod}');

      final prayerTimesResult = await _repository.getPrayerTimes(
        date: today,
        location: location,
        settings: settings,
      );

      return prayerTimesResult.fold(
        (failure) => Left(failure),
        (prayerTimes) {
          print(
              'UseCase: Prayer times received - Fajr: ${prayerTimes.fajr.time}, Dhuhr: ${prayerTimes.dhuhr.time}');

          final currentPrayer = _getCurrentPrayer(prayerTimes, now);
          final nextPrayer = _getNextPrayer(prayerTimes, now);

          print(
              'UseCase: Calculated - Current: $currentPrayer, Next: $nextPrayer');
          print('=== USECASE getCurrentAndNextPrayer END ===');

          return Right({
            'currentPrayer': currentPrayer,
            'nextPrayer': nextPrayer,
            'prayerTimes': prayerTimes,
          });
        },
      );
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get current and next prayer',
        details: e.toString(),
      ));
    }
  }

  String? _getCurrentPrayer(PrayerTimes prayerTimes, DateTime now) {
    // Only include actual prayers, not Sunrise
    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes.fajr.time},
      {'name': 'Dhuhr', 'time': prayerTimes.dhuhr.time},
      {'name': 'Asr', 'time': prayerTimes.asr.time},
      {'name': 'Maghrib', 'time': prayerTimes.maghrib.time},
      {'name': 'Isha', 'time': prayerTimes.isha.time},
    ];

    // Find the current prayer window (between the last prayer and the next prayer)
    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final prayerTime = prayer['time'] as DateTime;

      // If current time is before this prayer, the current prayer is the previous one
      if (now.isBefore(prayerTime)) {
        // If we're before the first prayer (Fajr), no current prayer
        if (i == 0) {
          return null;
        }
        // Return the previous prayer as the current prayer window
        return prayers[i - 1]['name'] as String;
      }
    }

    // If we're after all prayers, the current prayer is the last one (Isha)
    return prayers.last['name'] as String;
  }

  String? _getNextPrayer(PrayerTimes prayerTimes, DateTime now) {
    // Only include actual prayers, not Sunrise
    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes.fajr.time},
      {'name': 'Dhuhr', 'time': prayerTimes.dhuhr.time},
      {'name': 'Asr', 'time': prayerTimes.asr.time},
      {'name': 'Maghrib', 'time': prayerTimes.maghrib.time},
      {'name': 'Isha', 'time': prayerTimes.isha.time},
    ];

    // Find the next upcoming prayer
    for (final prayer in prayers) {
      if (now.isBefore(prayer['time'] as DateTime)) {
        return prayer['name'] as String;
      }
    }

    // If all prayers have passed, next prayer is tomorrow's Fajr
    return 'Fajr';
  }
}
