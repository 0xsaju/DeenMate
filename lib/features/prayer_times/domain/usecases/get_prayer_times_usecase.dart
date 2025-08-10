import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_calculation_settings.dart';
import '../../domain/entities/calculation_method.dart';
import '../../domain/repositories/prayer_times_repository.dart';

/// Use case for getting prayer times with Islamic validation
class GetPrayerTimesUsecase {

  const GetPrayerTimesUsecase(this.repository);
  final PrayerTimesRepository repository;

  /// Get prayer times for a specific date and location
  Future<Either<Failure, PrayerTimes>> call(GetPrayerTimesParams params) async {
    // Validate Islamic requirements
    final validationResult = await _validateParams(params);
    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected success in validation'),
      );
    }

    // Get prayer times from repository
    final result = await repository.getPrayerTimes(
      date: params.date,
      location: params.location,
      settings: params.settings,
    );

    return result.fold(
      Left.new,
      (prayerTimes) async {
        // Post-process with Islamic validations
        final validatedPrayerTimes = await _validatePrayerTimes(prayerTimes);
        return Right(validatedPrayerTimes);
      },
    );
  }

  /// Validate input parameters according to Islamic guidelines
  Future<Either<Failure, void>> _validateParams(GetPrayerTimesParams params) async {
    // Check if location is valid
    if (params.location.latitude < -90 || params.location.latitude > 90) {
      return const Left(Failure.locationUnavailable(
        message: 'Invalid latitude. Must be between -90 and 90 degrees.',
      ),);
    }

    if (params.location.longitude < -180 || params.location.longitude > 180) {
      return const Left(Failure.locationUnavailable(
        message: 'Invalid longitude. Must be between -180 and 180 degrees.',
      ),);
    }

    // Check for extreme latitudes that may have irregular prayer times
    if (params.location.latitude.abs() > 65) {
      // Special handling for locations with white nights or polar nights
      // Following Islamic scholarly opinion on high latitude areas
      return const Left(Failure.prayerTimeCalculationFailure(
        message: 'Prayer times for extreme latitudes require special consideration. '
               'Please consult local Islamic scholars for guidance.',
      ),);
    }

    // Validate calculation method if provided
    if (params.settings?.calculationMethod != null) {
      final validMethods = CalculationMethod.values.map((e) => e.name).toList();
      if (!validMethods.contains(params.settings!.calculationMethod)) {
        return const Left(Failure.invalidCalculationMethod(
          method: '',
          message: 'Invalid calculation method. Please select a recognized Islamic method.',
        ),);
      }
    }

    return const Right(null);
  }

  /// Validate calculated prayer times according to Islamic rules
  Future<PrayerTimes> _validatePrayerTimes(PrayerTimes prayerTimes) async {
    // Ensure proper prayer sequence
    final prayers = [
      prayerTimes.fajr,
      prayerTimes.sunrise,
      prayerTimes.dhuhr,
      prayerTimes.asr,
      prayerTimes.maghrib,
      prayerTimes.isha,
    ];

    // Validate prayer time sequence
    for (var i = 0; i < prayers.length - 1; i++) {
      if (prayers[i].time.isAfter(prayers[i + 1].time)) {
        throw const Failure.prayerTimeCalculationFailure(
          message: 'Prayer times are not in correct sequence. Please check your location and calculation method.',
        );
      }
    }

    // Validate minimum intervals between prayers (Islamic requirement)
    _validateMinimumIntervals(prayers);

    // Add Islamic context to prayer times
    return prayerTimes.copyWith(
      metadata: {
        ...prayerTimes.metadata,
        'validated': true,
        'validationTime': DateTime.now().toIso8601String(),
        'islamicCompliance': true,
      },
    );
  }

  /// Validate minimum intervals between prayers according to Islamic law
  void _validateMinimumIntervals(List<PrayerTime> prayers) {
    // Minimum 10 minutes between Fajr and Sunrise (scholarly consensus)
    final fajrSunriseInterval = prayers[1].time.difference(prayers[0].time);
    if (fajrSunriseInterval.inMinutes < 10) {
      throw const Failure.prayerTimeCalculationFailure(
        message: 'Insufficient time between Fajr and Sunrise. Please check calculation method.',
      );
    }

    // Minimum 20 minutes between Maghrib and Isha (scholarly consensus)
    final maghribIshaInterval = prayers[5].time.difference(prayers[4].time);
    if (maghribIshaInterval.inMinutes < 20) {
      throw const Failure.prayerTimeCalculationFailure(
        message: 'Insufficient time between Maghrib and Isha. Please check calculation method.',
      );
    }

    // Asr cannot be after Maghrib
    if (prayers[3].time.isAfter(prayers[4].time)) {
      throw const Failure.prayerTimeCalculationFailure(
        message: 'Asr time cannot be after Maghrib. Please check your location settings.',
      );
    }
  }
}

/// Parameters for getting prayer times
class GetPrayerTimesParams {

  const GetPrayerTimesParams({
    required this.date,
    required this.location,
    this.settings,
  });
  final DateTime date;
  final Location location;
  final PrayerCalculationSettings? settings;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is GetPrayerTimesParams &&
    runtimeType == other.runtimeType &&
    date == other.date &&
    location == other.location &&
    settings == other.settings;

  @override
  int get hashCode => date.hashCode ^ location.hashCode ^ settings.hashCode;
}
