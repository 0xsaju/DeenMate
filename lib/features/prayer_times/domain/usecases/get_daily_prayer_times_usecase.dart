import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_calculation_settings.dart';
import '../../domain/repositories/prayer_times_repository.dart';

/// Use case for getting daily prayer times
class GetDailyPrayerTimesUsecase {
  const GetDailyPrayerTimesUsecase(this._repository);
  
  final PrayerTimesRepository _repository;

  Future<Either<Failure, PrayerTimes>> call({
    required DateTime date,
    required Location location,
    PrayerCalculationSettings? settings,
  }) async {
    return _repository.getPrayerTimes(
      date: date,
      location: location,
      settings: settings,
    );
  }
}
