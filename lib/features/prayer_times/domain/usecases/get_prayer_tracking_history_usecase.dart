import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_tracking.dart';
import '../../domain/repositories/prayer_times_repository.dart';

/// Use case for getting prayer tracking history
class GetPrayerTrackingHistoryUsecase {
  const GetPrayerTrackingHistoryUsecase(this._repository);
  
  final PrayerTimesRepository _repository;

  Future<Either<Failure, List<PrayerTracking>>> call({
    required DateTime startDate,
    required DateTime endDate,
    required Location location,
  }) async {
    return _repository.getPrayerTrackingHistory(
      startDate: startDate,
      endDate: endDate,
      location: location,
    );
  }
}
