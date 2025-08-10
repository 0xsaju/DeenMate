import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/prayer_times_repository.dart';

/// Use case for marking a prayer as completed
class MarkPrayerCompletedUsecase {
  const MarkPrayerCompletedUsecase(this._repository);
  
  final PrayerTimesRepository _repository;

  Future<Either<Failure, void>> call({
    required String prayerName,
    required DateTime date,
    required Location location,
  }) async {
    return _repository.markPrayerCompleted(
      prayerName: prayerName,
      date: date,
      location: location,
    );
  }
}
