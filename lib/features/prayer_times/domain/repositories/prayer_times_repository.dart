import 'package:dartz/dartz.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_times.dart';
import '../entities/athan_settings.dart';
import '../entities/islamic_event.dart';
import '../entities/prayer_tracking.dart';
import '../entities/location.dart';
import '../entities/prayer_calculation_settings.dart';
import '../entities/calculation_method.dart';
import '../../domain/entities/prayer_statistics.dart';

/// Abstract repository for prayer times data operations
/// Follows Clean Architecture principles for Islamic prayer management
abstract class PrayerTimesRepository {
  /// Get prayer times for a specific date and location
  Future<Either<Failure, PrayerTimes>> getPrayerTimes({
    required DateTime date,
    required Location location,
    PrayerCalculationSettings? settings,
  });

  /// Get prayer times for a date range (useful for monthly view)
  Future<Either<Failure, List<PrayerTimes>>> getPrayerTimesRange({
    required DateTime startDate,
    required DateTime endDate,
    required Location location,
    PrayerCalculationSettings? settings,
  });

  /// Get prayer times for current location and date
  Future<Either<Failure, PrayerTimes>> getCurrentPrayerTimes();

  /// Get prayer times for next 7 days
  Future<Either<Failure, List<PrayerTimes>>> getWeeklyPrayerTimes({
    Location? location,
  });

  /// Save prayer tracking information
  Future<Either<Failure, void>> savePrayerTracking(PrayerTracking tracking);

  /// Get prayer tracking history
  Future<Either<Failure, List<PrayerTracking>>> getPrayerTrackingHistory({
    required DateTime startDate,
    required DateTime endDate,
    Location? location,
  });

  /// Mark a prayer as completed
  Future<Either<Failure, void>> markPrayerCompleted({
    required String prayerName,
    required DateTime date,
    required Location location,
  });

  /// Get prayer statistics
  Future<Either<Failure, PrayerStatistics>> getPrayerStatistics({
    required DateTime fromDate,
    required DateTime toDate,
  });

  /// Save prayer calculation settings
  Future<Either<Failure, void>> savePrayerSettings(PrayerCalculationSettings settings);

  /// Get saved prayer calculation settings
  Future<Either<Failure, PrayerCalculationSettings>> getPrayerSettings();

  /// Save Athan settings
  Future<Either<Failure, void>> saveAthanSettings(AthanSettings settings);

  /// Get Athan settings
  Future<Either<Failure, AthanSettings>> getAthanSettings();

  /// Get user's current location
  Future<Either<Failure, Location>> getCurrentLocation();

  /// Save user's preferred location
  Future<Either<Failure, void>> savePreferredLocation(Location location);

  /// Get saved preferred location
  Future<Either<Failure, Location?>> getPreferredLocation();

  /// Get location by city name
  Future<Either<Failure, List<Location>>> searchLocationsByCity(String cityName);

  /// Get Qibla direction for a location
  Future<Either<Failure, double>> getQiblaDirection(Location location);

  /// Cache prayer times locally for offline access
  Future<Either<Failure, void>> cachePrayerTimes(List<PrayerTimes> prayerTimesList);

  /// Get cached prayer times
  Future<Either<Failure, List<PrayerTimes>>> getCachedPrayerTimes({
    required DateTime date,
    Location? location,
  });

  /// Clear old cached data
  Future<Either<Failure, void>> clearOldCache({int daysToKeep = 30});

  /// Check if prayer times are available offline for date
  Future<Either<Failure, bool>> arePrayerTimesAvailableOffline({
    required DateTime date,
    Location? location,
  });

  /// Get available calculation methods
  Future<Either<Failure, List<CalculationMethod>>> getAvailableCalculationMethods();

  /// Validate prayer time calculation
  Future<Either<Failure, bool>> validatePrayerTimes({
    required PrayerTimes prayerTimes,
    required Location location,
  });

  /// Get Islamic events for a date (like Ramadan, Eid, etc.)
  Future<Either<Failure, List<IslamicEvent>>> getIslamicEvents({
    required DateTime date,
  });

  /// Get monthly prayer calendar
  Future<Either<Failure, List<PrayerTimes>>> getMonthlyPrayerCalendar({
    required int year,
    required int month,
    Location? location,
  });

  /// Export prayer times to external format (PDF, CSV, etc.)
  Future<Either<Failure, String>> exportPrayerTimes({
    required DateTime fromDate,
    required DateTime toDate,
    required String format, // 'pdf', 'csv', 'ics'
    Location? location,
  });

  /// Sync prayer data across devices (if user is logged in)
  Future<Either<Failure, void>> syncPrayerData();

  /// Backup prayer tracking data
  Future<Either<Failure, String>> backupPrayerData();

  /// Restore prayer tracking data from backup
  Future<Either<Failure, void>> restorePrayerData(String backupData);
}

/// Islamic event entity for special dates
class IslamicEvent {

  const IslamicEvent({
    required this.date,
    required this.hijriDate,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.type,
    this.affectsPrayerTimes = false,
    this.metadata,
  });

  factory IslamicEvent.fromJson(Map<String, dynamic> json) {
    final hijriData = json['hijriDate'] as Map<String, dynamic>;
    final hijriCalendar = HijriCalendar();
    hijriCalendar.hDay = hijriData['day'];
    hijriCalendar.hMonth = hijriData['month']; 
    hijriCalendar.hYear = hijriData['year'];
    
    return IslamicEvent(
      date: DateTime.parse(json['date']),
      hijriDate: hijriCalendar,
      name: json['name'],
      arabicName: json['arabicName'],
      description: json['description'],
      type: IslamicEventType.values.byName(json['type']),
      affectsPrayerTimes: json['affectsPrayerTimes'] ?? false,
      metadata: json['metadata'],
    );
  }
  final DateTime date;
  final HijriCalendar hijriDate;
  final String name;
  final String arabicName;
  final String description;
  final IslamicEventType type;
  final bool affectsPrayerTimes;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'hijriDate': {
      'day': hijriDate.hDay,
      'month': hijriDate.hMonth,
      'year': hijriDate.hYear,
    },
    'name': name,
    'arabicName': arabicName,
    'description': description,
    'type': type.name,
    'affectsPrayerTimes': affectsPrayerTimes,
    'metadata': metadata,
  };
}

/// Types of Islamic events
enum IslamicEventType {
  eid,
  ramadan,
  hajj,
  umrah,
  islamicNewYear,
  ashurah,
  mawlid,
  laylatAlQadr,
  rajab,
  shaban,
  jummamubarakah,
  other,
}
