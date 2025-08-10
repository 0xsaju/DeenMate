import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_calculation_settings.dart';
import '../../domain/repositories/prayer_times_repository.dart';

/// Use case for getting monthly prayer times
class GetMonthlyPrayerTimesUsecase {
  const GetMonthlyPrayerTimesUsecase(this._repository);
  
  final PrayerTimesRepository _repository;

  Future<Either<Failure, List<PrayerTimes>>> call({
    required DateTime startDate,
    required DateTime endDate,
    required Location location,
    PrayerCalculationSettings? settings,
  }) async {
    return _repository.getPrayerTimesRange(
      startDate: startDate,
      endDate: endDate,
      location: location,
      settings: settings,
    );
  }
}
