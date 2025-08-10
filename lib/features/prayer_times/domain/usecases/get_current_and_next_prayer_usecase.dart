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
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final prayerTimesResult = await _repository.getPrayerTimes(
        date: today,
        location: location,
        settings: settings,
      );

      return prayerTimesResult.fold(
        (failure) => Left(failure),
        (prayerTimes) {
          final currentPrayer = _getCurrentPrayer(prayerTimes, now);
          final nextPrayer = _getNextPrayer(prayerTimes, now);
          
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
    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes.fajr.time},
      {'name': 'Sunrise', 'time': prayerTimes.sunrise.time},
      {'name': 'Dhuhr', 'time': prayerTimes.dhuhr.time},
      {'name': 'Asr', 'time': prayerTimes.asr.time},
      {'name': 'Maghrib', 'time': prayerTimes.maghrib.time},
      {'name': 'Isha', 'time': prayerTimes.isha.time},
    ];

    for (int i = 0; i < prayers.length - 1; i++) {
      final currentPrayer = prayers[i];
      final nextPrayer = prayers[i + 1];
      
      if (now.isAfter(currentPrayer['time'] as DateTime) && 
          now.isBefore(nextPrayer['time'] as DateTime)) {
        return currentPrayer['name'] as String;
      }
    }
    
    // Check if it's after Isha (last prayer of the day)
    if (now.isAfter(prayerTimes.isha.time)) {
      return 'Isha';
    }
    
    return null;
  }

  String? _getNextPrayer(PrayerTimes prayerTimes, DateTime now) {
    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes.fajr.time},
      {'name': 'Sunrise', 'time': prayerTimes.sunrise.time},
      {'name': 'Dhuhr', 'time': prayerTimes.dhuhr.time},
      {'name': 'Asr', 'time': prayerTimes.asr.time},
      {'name': 'Maghrib', 'time': prayerTimes.maghrib.time},
      {'name': 'Isha', 'time': prayerTimes.isha.time},
    ];

    for (final prayer in prayers) {
      if (now.isBefore(prayer['time'] as DateTime)) {
        return prayer['name'] as String;
      }
    }
    
    // If all prayers have passed, next prayer is tomorrow's Fajr
    return 'Fajr';
  }
}
