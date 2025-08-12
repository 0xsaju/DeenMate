import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/islamic_utils.dart';
import '../../../../core/state/prayer_settings_state.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_tracking.dart';
import '../../domain/entities/prayer_calculation_settings.dart';
import '../../domain/entities/athan_settings.dart';
import '../../domain/entities/calculation_method.dart';
import '../../domain/entities/prayer_statistics.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import '../datasources/aladhan_api.dart';
import '../datasources/prayer_times_local_storage.dart';

/// Implementation of PrayerTimesRepository
/// Coordinates between API and local storage with Islamic compliance
class PrayerTimesRepositoryImpl implements PrayerTimesRepository {

  const PrayerTimesRepositoryImpl({
    required AladhanApi aladhanApi,
    required PrayerTimesLocalStorage localStorage,
  })  : _aladhanApi = aladhanApi,
        _localStorage = localStorage;
  final AladhanApi _aladhanApi;
  final PrayerTimesLocalStorage _localStorage;

  @override
  Future<Either<Failure, PrayerTimes>> getPrayerTimes({
    required DateTime date,
    required Location location,
    PrayerCalculationSettings? settings,
  }) async {
    try {
      // First try to get from local storage
      final cachedPrayerTimes = await _localStorage.getPrayerTimes(date, location);
      
      if (cachedPrayerTimes != null && _isCacheValid(cachedPrayerTimes)) {
        return Right(cachedPrayerTimes);
      }

      // If not cached or cache is stale, fetch from API
      final prayerTimes = await _aladhanApi.getPrayerTimes(
        date: date,
        location: location,
        settings: settings,
      );

      // Cache the result for offline access
      await _localStorage.savePrayerTimes(prayerTimes);

      return Right(prayerTimes);
    } on Failure catch (failure) {
      // If API fails, try to return cached data even if stale
      final cachedPrayerTimes = await _localStorage.getPrayerTimes(date, location);
      if (cachedPrayerTimes != null) {
        return Right(cachedPrayerTimes.copyWith(
          metadata: {
            ...cachedPrayerTimes.metadata,
            'source': 'Local Cache (Offline)',
            'warning': 'Data may be outdated due to network issues',
          },
        ),);
      }
      return Left(failure);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get prayer times',
        details: e.toString(),
      ),);
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> getPrayerTimesRange({
    required DateTime startDate,
    required DateTime endDate,
    required Location location,
    PrayerCalculationSettings? settings,
  }) async {
    try {
      // Check how many days we need
      final daysDifference = endDate.difference(startDate).inDays + 1;
      
      if (daysDifference > 31) {
        return const Left(Failure.validationFailure(
          field: 'dateRange',
          message: 'Date range cannot exceed 31 days',
        ),);
      }

      // Try to get from local storage first
      final cachedPrayerTimes = await _localStorage.getPrayerTimesRange(
        startDate,
        endDate,
        location,
      );

      // Check if we have all the data cached and it's valid
      if (cachedPrayerTimes.length == daysDifference &&
          cachedPrayerTimes.every(_isCacheValid)) {
        return Right(cachedPrayerTimes);
      }

      // Fetch from API
      final prayerTimesList = await _aladhanApi.getPrayerTimesRange(
        startDate: startDate,
        endDate: endDate,
        location: location,
        settings: settings,
      );

      // Cache all results
      await _localStorage.savePrayerTimesList(prayerTimesList);

      return Right(prayerTimesList);
    } on Failure catch (failure) {
      // Return cached data if available
      final cachedPrayerTimes = await _localStorage.getPrayerTimesRange(
        startDate,
        endDate,
        location,
      );
      
      if (cachedPrayerTimes.isNotEmpty) {
        return Right(cachedPrayerTimes.map((pt) => pt.copyWith(
          metadata: {
            ...pt.metadata,
            'source': 'Local Cache (Offline)',
            'warning': 'Data may be outdated due to network issues',
          },
        ),).toList(),);
      }
      
      return Left(failure);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get prayer times range',
        details: e.toString(),
      ),);
    }
  }

  @override
  Future<Either<Failure, PrayerTimes>> getCurrentPrayerTimes() async {
    try {
      print('=== REPOSITORY getCurrentPrayerTimes START ===');
      print('Repository: Getting current prayer times...');
      
      // Get current location first
      final locationResult = await getCurrentLocation();
      print('Repository: Location result: ${locationResult.isRight() ? 'Success' : 'Failed'}');
      
      if (locationResult.isLeft()) {
        print('Repository: Location failed, trying preferred location...');
        // Try to use preferred location if GPS fails
        final preferredLocationResult = await getPreferredLocation();
        if (preferredLocationResult.isLeft() || preferredLocationResult.getOrElse(() => null) == null) {
          print('Repository: Preferred location also failed');
          return Left(locationResult.fold((failure) => failure, (_) => throw Exception()));
        }
      }

      final location = locationResult.fold(
        (failure) async {
          print('Repository: Using preferred location due to GPS failure');
          final preferredLocation = await getPreferredLocation();
          return preferredLocation.getOrElse(() => null);
        },
        (loc) async {
          print('Repository: Using GPS location: ${loc.latitude}, ${loc.longitude}');
          return loc;
        },
      );

      final resolvedLocation = await location;
      if (resolvedLocation == null) {
        print('Repository: No location available');
        return const Left(Failure.locationUnavailable(
          message: 'Unable to determine location for prayer times',
        ),);
      }

      // Get prayer calculation settings from global state (force reload)
      await PrayerSettingsState.instance.loadSettings();
      final method = PrayerSettingsState.instance.calculationMethod;
      final settings = PrayerCalculationSettings(
        calculationMethod: method,
        madhab: Madhab.shafi,
      );
      print('Repository: Using calculation method: $method (forced reload)');

      print('Repository: Calling API with location: ${resolvedLocation.latitude}, ${resolvedLocation.longitude}');
      print('Repository: Settings - Method: ${settings.calculationMethod}, Madhab: ${settings.madhab}');
      
      final result = await getPrayerTimes(
        date: DateTime.now(),
        location: resolvedLocation,
        settings: settings,
      );
      
      print('Repository: API call result: ${result.isRight() ? 'Success' : 'Failed'}');
      if (result.isRight()) {
        final prayerTimes = result.getOrElse(() => throw Exception('No data'));
        print('Repository: Prayer times - Fajr: ${prayerTimes.fajr.time}, Dhuhr: ${prayerTimes.dhuhr.time}');
      }
      print('=== REPOSITORY getCurrentPrayerTimes END ===');
      
      return result;
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get current prayer times',
        details: e.toString(),
      ),);
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> getWeeklyPrayerTimes({
    Location? location,
  }) async {
    try {
      Location resolvedLocation;
      
      if (location != null) {
        resolvedLocation = location;
      } else {
        final locationResult = await getCurrentLocation();
        if (locationResult.isLeft()) {
          final preferredLocationResult = await getPreferredLocation();
          if (preferredLocationResult.isLeft() || 
              preferredLocationResult.getOrElse(() => null) == null) {
            return const Left(Failure.locationUnavailable(
              message: 'Location is required for weekly prayer times',
            ),);
          }
          resolvedLocation = preferredLocationResult.getOrElse(() => null)!;
        } else {
          resolvedLocation = locationResult.getOrElse(() => throw Exception());
        }
      }

      final today = DateTime.now();
      final endDate = today.add(const Duration(days: 6));

      return await getPrayerTimesRange(
        startDate: today,
        endDate: endDate,
        location: resolvedLocation,
      );
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get weekly prayer times',
        details: e.toString(),
      ),);
    }
  }

  @override
  Future<Either<Failure, void>> savePrayerTracking(PrayerTracking tracking) async {
    try {
      await _localStorage.savePrayerTracking(tracking);
      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.databaseFailure(
        operation: 'save_prayer_tracking',
        message: 'Failed to save prayer tracking: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, List<PrayerTracking>>> getPrayerTrackingHistory({
    required DateTime startDate,
    required DateTime endDate,
    Location? location,
  }) async {
    try {
      final tracking = await _localStorage.getPrayerTrackingHistory(
        startDate,
        endDate,
      );
      return Right(tracking);
    } catch (e) {
      return Left(Failure.cacheFailure(
        message: 'Failed to get prayer tracking history: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> markPrayerCompleted({
    required String prayerName,
    required DateTime date,
    required Location location,
  }) async {
    try {
      await _localStorage.markPrayerCompleted(
        prayerName: prayerName,
        date: date,
        location: location,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure.cacheFailure(
        message: 'Failed to mark prayer as completed: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, PrayerStatistics>> getPrayerStatistics({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final history = await _localStorage.getPrayerTrackingHistory(fromDate, toDate);
      
      // Calculate statistics from history
      final statistics = _calculateStatistics(history, fromDate, toDate);
      return Right(statistics);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.databaseFailure(
        operation: 'get_prayer_statistics',
        message: 'Failed to calculate prayer statistics: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, void>> savePrayerSettings(PrayerCalculationSettings settings) async {
    try {
      await _localStorage.savePrayerSettings(settings);
      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.databaseFailure(
        operation: 'save_prayer_settings',
        message: 'Failed to save prayer settings: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, PrayerCalculationSettings>> getPrayerSettings() async {
    try {
      final settings = await _localStorage.getPrayerSettings();
      if (settings != null) {
        return Right(settings);
      } else {
        // Return default settings
        return Right(_getDefaultSettings());
      }
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.databaseFailure(
        operation: 'get_prayer_settings',
        message: 'Failed to get prayer settings: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, void>> saveAthanSettings(AthanSettings settings) async {
    try {
      await _localStorage.saveAthanSettings(settings);
      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.databaseFailure(
        operation: 'save_athan_settings',
        message: 'Failed to save Athan settings: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, AthanSettings>> getAthanSettings() async {
    try {
      final settings = await _localStorage.getAthanSettings();
      if (settings != null) {
        return Right(settings);
      } else {
        // Return default Athan settings
        return Right(_getDefaultAthanSettings());
      }
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.databaseFailure(
        operation: 'get_athan_settings',
        message: 'Failed to get Athan settings: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, Location>> getCurrentLocation() async {
    try {
      // Check location permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(Failure.locationPermissionDenied());
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const Left(Failure.locationPermissionDenied(
          message: 'Location permissions are permanently denied. Please enable them in device settings.',
        ),);
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(Failure.locationServiceDisabled());
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Create location object with timezone detection
      final location = Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: 'Current Location',
        country: 'Unknown',
        timezone: _detectTimezone(position.latitude, position.longitude),
        elevation: position.altitude,
      );

      // Save as preferred location for future use
      await savePreferredLocation(location);

      return Right(location);
    } on LocationServiceDisabledException {
      return const Left(Failure.locationServiceDisabled());
    } on PermissionDeniedException {
      return const Left(Failure.locationPermissionDenied());
    } on TimeoutException {
      return const Left(Failure.timeoutFailure(
        message: 'Location request timed out. Please try again.',
      ),);
    } catch (e) {
      return Left(Failure.locationUnavailable(
        message: 'Failed to get current location: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, void>> savePreferredLocation(Location location) async {
    try {
      await _localStorage.savePreferredLocation(location);
      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.databaseFailure(
        operation: 'save_preferred_location',
        message: 'Failed to save preferred location: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, Location?>> getPreferredLocation() async {
    try {
      final location = await _localStorage.getPreferredLocation();
      return Right(location);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.databaseFailure(
        operation: 'get_preferred_location',
        message: 'Failed to get preferred location: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, List<Location>>> searchLocationsByCity(String cityName) async {
    try {
      // Use AlAdhan API to search by address
      final location = await _aladhanApi.getLocationByAddress(cityName);
      return Right([location]);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to search locations: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, double>> getQiblaDirection(Location location) async {
    try {
      // First try to calculate using local Islamic utils
      final qiblaDirection = IslamicUtils.calculateQiblaDirection(
        location.latitude,
        location.longitude,
      );

      // Validate with API if possible
      try {
        final apiDirection = await _aladhanApi.getQiblaDirection(location);
        
        // If API result differs significantly (>5 degrees), prefer API
        if ((qiblaDirection - apiDirection).abs() > 5) {
          return Right(apiDirection);
        }
      } catch (e) {
        // API failed, use local calculation
      }

      return Right(qiblaDirection);
    } catch (e) {
      return const Left(Failure.qiblaCalculationFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cachePrayerTimes(List<PrayerTimes> prayerTimesList) async {
    try {
      await _localStorage.savePrayerTimesList(prayerTimesList);
      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.cacheFailure(
        message: 'Failed to cache prayer times: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> getCachedPrayerTimes({
    required DateTime date,
    Location? location,
  }) async {
    try {
      if (location == null) {
        final locationResult = await getPreferredLocation();
        if (locationResult.isLeft() || locationResult.getOrElse(() => null) == null) {
          return const Left(Failure.locationUnavailable(
            message: 'Location is required to get cached prayer times',
          ),);
        }
        location = locationResult.getOrElse(() => null);
      }

      final endDate = date.add(const Duration(days: 6)); // Get a week's worth
      final cachedPrayerTimes = await _localStorage.getPrayerTimesRange(
        date,
        endDate,
        location!,
      );

      return Right(cachedPrayerTimes);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.cacheFailure(
        message: 'Failed to get cached prayer times: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, void>> clearOldCache({int daysToKeep = 30}) async {
    try {
      await _localStorage.clearOldCache(daysToKeep: daysToKeep);
      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.cacheFailure(
        message: 'Failed to clear old cache: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, bool>> arePrayerTimesAvailableOffline({
    required DateTime date,
    Location? location,
  }) async {
    try {
      if (location == null) {
        final locationResult = await getPreferredLocation();
        if (locationResult.isLeft() || locationResult.getOrElse(() => null) == null) {
          return const Right(false);
        }
        location = locationResult.getOrElse(() => null);
      }

      final isAvailable = await _localStorage.arePrayerTimesAvailable(date, location!);
      return Right(isAvailable);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, List<CalculationMethod>>> getAvailableCalculationMethods() async {
    try {
      final methods = await _aladhanApi.getAvailableCalculationMethods();
      return Right(methods);
    } catch (e) {
      // Return default methods if API fails
      return const Right(CalculationMethod.values);
    }
  }

  @override
  Future<Either<Failure, bool>> validatePrayerTimes({
    required PrayerTimes prayerTimes,
    required Location location,
  }) async {
    try {
      // Validate prayer sequence
      final prayers = [
        prayerTimes.fajr,
        prayerTimes.sunrise,
        prayerTimes.dhuhr,
        prayerTimes.asr,
        prayerTimes.maghrib,
        prayerTimes.isha,
      ];

      for (var i = 0; i < prayers.length - 1; i++) {
        if (prayers[i].time.isAfter(prayers[i + 1].time)) {
          return const Right(false);
        }
      }

      // Check minimum intervals
      final fajrSunriseInterval = prayers[1].time.difference(prayers[0].time);
      if (fajrSunriseInterval.inMinutes < 10) {
        return const Right(false);
      }

      final maghribIshaInterval = prayers[5].time.difference(prayers[4].time);
      if (maghribIshaInterval.inMinutes < 20) {
        return const Right(false);
      }

      return const Right(true);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to validate prayer times: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, List<IslamicEvent>>> getIslamicEvents({
    required DateTime date,
  }) async {
    try {
      final hijriDate = IslamicUtils.gregorianToHijri(date);
      final events = <IslamicEvent>[];

      // Check for major Islamic events
      if (hijriDate.hMonth == 9) {
        events.add(IslamicEvent(
          date: date,
          hijriDate: hijriDate,
          name: 'Ramadan',
          arabicName: 'رمضان',
          description: 'The holy month of fasting',
          type: IslamicEventType.ramadan,
          affectsPrayerTimes: true,
        ),);
      }

      if (hijriDate.hMonth == 10 && hijriDate.hDay == 1) {
        events.add(IslamicEvent(
          date: date,
          hijriDate: hijriDate,
          name: 'Eid al-Fitr',
          arabicName: 'عيد الفطر',
          description: 'Festival of Breaking the Fast',
          type: IslamicEventType.eid,
        ),);
      }

      if (hijriDate.hMonth == 12 && hijriDate.hDay >= 10 && hijriDate.hDay <= 13) {
        events.add(IslamicEvent(
          date: date,
          hijriDate: hijriDate,
          name: 'Eid al-Adha',
          arabicName: 'عيد الأضحى',
          description: 'Festival of Sacrifice',
          type: IslamicEventType.eid,
        ),);
      }

      if (hijriDate.hMonth == 1 && hijriDate.hDay == 10) {
        events.add(IslamicEvent(
          date: date,
          hijriDate: hijriDate,
          name: 'Day of Ashura',
          arabicName: 'يوم عاشوراء',
          description: 'The 10th day of Muharram',
          type: IslamicEventType.ashurah,
        ),);
      }

      // Add weekly Jummah
      if (date.weekday == DateTime.friday) {
        events.add(IslamicEvent(
          date: date,
          hijriDate: hijriDate,
          name: 'Jummah',
          arabicName: 'جمعة مباركة',
          description: 'Blessed Friday',
          type: IslamicEventType.jummamubarakah,
          affectsPrayerTimes: true,
        ),);
      }

      return Right(events);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get Islamic events: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> getMonthlyPrayerCalendar({
    required int year,
    required int month,
    Location? location,
  }) async {
    try {
      if (location == null) {
        final locationResult = await getPreferredLocation();
        if (locationResult.isLeft() || locationResult.getOrElse(() => null) == null) {
          return const Left(Failure.locationUnavailable(
            message: 'Location is required for monthly prayer calendar',
          ),);
        }
        location = locationResult.getOrElse(() => null);
      }

      final startDate = DateTime(year, month);
      final endDate = DateTime(year, month + 1, 0); // Last day of month

      return await getPrayerTimesRange(
        startDate: startDate,
        endDate: endDate,
        location: location!,
      );
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get monthly prayer calendar: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, String>> exportPrayerTimes({
    required DateTime fromDate,
    required DateTime toDate,
    required String format,
    Location? location,
  }) async {
    try {
      // Get prayer times for the range
      final prayerTimesResult = await getPrayerTimesRange(
        startDate: fromDate,
        endDate: toDate,
        location: location!,
      );

      return prayerTimesResult.fold(
        Left.new,
        (prayerTimesList) async {
          // For now, return a simple string representation
          // This would be implemented with actual PDF/CSV generation
          final exportData = prayerTimesList.map((pt) {
            return '${pt.date.toIso8601String().split('T')[0]}: '
                   'Fajr: ${pt.fajr.getFormattedTime()}, '
                   'Dhuhr: ${pt.dhuhr.getFormattedTime()}, '
                   'Asr: ${pt.asr.getFormattedTime()}, '
                   'Maghrib: ${pt.maghrib.getFormattedTime()}, '
                   'Isha: ${pt.isha.getFormattedTime()}';
          }).join('\n');

          return Right(exportData);
        },
      );
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to export prayer times: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, void>> syncPrayerData() async {
    // This would implement cloud sync functionality
    // For now, return success
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> backupPrayerData() async {
    try {
      final backupData = await _localStorage.exportPrayerData();
      // Convert to JSON string for backup
      return Right(backupData.toString());
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.unknownFailure(
        message: 'Failed to backup prayer data: $e',
      ),);
    }
  }

  @override
  Future<Either<Failure, void>> restorePrayerData(String backupData) async {
    try {
      // Parse backup data and restore
      // This is a simplified implementation
      await _localStorage.importPrayerData({'backup': backupData});
      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure.unknownFailure(
        message: 'Failed to restore prayer data: $e',
      ),);
    }
  }

  // Helper methods

  /// Check if cached prayer times are still valid (within 24 hours)
  bool _isCacheValid(PrayerTimes prayerTimes) {
    if (prayerTimes.lastUpdated == null) return false;
    
    final cacheAge = DateTime.now().difference(prayerTimes.lastUpdated!);
    return cacheAge.inHours < 24;
  }

  /// Get default prayer calculation settings
  PrayerCalculationSettings _getDefaultSettings() {
    return const PrayerCalculationSettings(
      calculationMethod: 'MWL', // Muslim World League
      madhab: Madhab.shafi, // Shafi'i madhab for Asr calculation
      adjustments: {
        'fajr': 0,
        'sunrise': 0,
        'dhuhr': 0,
        'asr': 0,
        'maghrib': 0,
        'isha': 0,
        'midnight': 0,
      },
      timeFormat: '12h',
      language: 'en',
    );
  }

  /// Get default Athan settings
  AthanSettings _getDefaultAthanSettings() {
    return const AthanSettings(
      isEnabled: true,
      muadhinVoice: 'default',
      volume: 0.8,
      durationSeconds: 180,
      vibrateEnabled: true,
      prayerSpecificSettings: {
        'fajr': true,
        'dhuhr': true,
        'asr': true,
        'maghrib': true,
        'isha': true,
      },
    );
  }

  /// Detect timezone based on coordinates (simplified)
  String _detectTimezone(double latitude, double longitude) {
    // This is a simplified timezone detection
    // In a real implementation, you'd use a proper timezone detection library
    
    // Rough timezone calculation based on longitude
    final timezoneOffset = (longitude / 15).round();
    
    if (timezoneOffset >= 0) {
      return 'UTC+$timezoneOffset';
    } else {
      return 'UTC$timezoneOffset';
    }
  }

  /// Calculate prayer statistics from tracking history
  PrayerStatistics _calculateStatistics(
    List<PrayerTracking> history,
    DateTime fromDate,
    DateTime toDate,
  ) {
    final totalDays = toDate.difference(fromDate).inDays + 1;
    final totalPossiblePrayers = totalDays * 5; // 5 daily prayers
    
    final completedPrayers = history.where((h) => h.isCompleted).length;
    final onTimePrayers = history.where((h) => h.isOnTime && h.isCompleted).length;
    
    final completionRate = totalPossiblePrayers > 0 
        ? completedPrayers / totalPossiblePrayers 
        : 0.0;
    
    final onTimeRate = completedPrayers > 0 
        ? onTimePrayers / completedPrayers 
        : 0.0;

    // Calculate prayer-wise completion
    final prayerWiseCompletion = <String, int>{};
    final prayerNames = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    
    for (final prayerName in prayerNames) {
      final count = history
          .where((h) => h.prayerName.toLowerCase() == prayerName && h.isCompleted)
          .length;
      prayerWiseCompletion[prayerName] = count;
    }

    // Calculate streak (consecutive days with all prayers completed)
    final streak = _calculateStreak(history, toDate);

    return PrayerStatistics(
      date: fromDate,
      completedPrayers: prayerWiseCompletion.map((k, v) => MapEntry(k, v > 0)),
      totalPrayers: totalPossiblePrayers,
      completedCount: completedPrayers,
      completionRate: completionRate,
      totalPrayerTime: Duration(minutes: completedPrayers * 5), // Estimate 5 minutes per prayer
      missedPrayers: prayerNames.where((name) => prayerWiseCompletion[name] == 0).toList(),
      onTimePrayers: prayerNames.where((name) => history.any((h) => h.prayerName.toLowerCase() == name && h.isOnTime && h.isCompleted)).toList(),
      delayedPrayers: prayerNames.where((name) => prayerWiseCompletion[name]! > 0 && prayerWiseCompletion[name]! < totalDays).toList(),
    );
  }

  /// Calculate prayer streak
  List<DateTime> _calculateStreak(List<PrayerTracking> history, DateTime endDate) {
    final streak = <DateTime>[];
    final prayerNames = {'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'};
    
    // Group by date
    final prayersByDate = <String, Set<String>>{};
    for (final prayer in history.where((h) => h.isCompleted)) {
      final dateKey = '${prayer.date.year}-${prayer.date.month}-${prayer.date.day}';
      prayersByDate[dateKey] = prayersByDate[dateKey] ?? <String>{};
      prayersByDate[dateKey]!.add(prayer.prayerName.toLowerCase());
    }
    
    // Check consecutive days with all prayers completed
    var currentDate = endDate;
    while (true) {
      final dateKey = '${currentDate.year}-${currentDate.month}-${currentDate.day}';
      final dayPrayers = prayersByDate[dateKey] ?? <String>{};
      
      if (prayerNames.every(dayPrayers.contains)) {
        streak.insert(0, currentDate);
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
      
      // Prevent infinite loop
      if (streak.length > 365) break;
    }
    
    return streak;
  }
}
