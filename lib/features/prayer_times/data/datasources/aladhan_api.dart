import 'package:dio/dio.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_calculation_settings.dart';
import '../../domain/entities/calculation_method.dart';

/// API service for fetching prayer times from AlAdhan API
/// Provides accurate Islamic prayer times with multiple calculation methods
class AladhanApi {

  AladhanApi(this._dio);
  final Dio _dio;
  final String _baseUrl = 'https://api.aladhan.com/v1';

  /// Get prayer times for a specific date and location
  Future<PrayerTimes> getPrayerTimes({
    required DateTime date,
    required Location location,
    PrayerCalculationSettings? settings,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/timings/${_formatDate(date)}',
        queryParameters: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'method': _getCalculationMethodCode(settings?.calculationMethod ?? 'MWL'),
          'school': _getMadhabCode(settings?.madhab),
          'tune': _formatAdjustments(settings?.adjustments ?? {}),
          'timezone': location.timezone,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'DeenMate/1.0.0',
          },
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return _parsePrayerTimesResponse(response.data, date, location, settings);
      } else {
        throw Failure.serverFailure(
          message: 'Failed to fetch prayer times',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const Failure.timeoutFailure();
      } else if (e.response?.statusCode != null) {
        throw Failure.serverFailure(
          message: 'AlAdhan API error: ${e.message}',
          statusCode: e.response!.statusCode!,
        );
      } else {
        throw Failure.networkFailure(
          message: 'Network error while fetching prayer times: ${e.message}',
        );
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure.unknownFailure(
        message: 'Unexpected error fetching prayer times',
        details: e.toString(),
      );
    }
  }

  /// Get prayer times for multiple days
  Future<List<PrayerTimes>> getPrayerTimesRange({
    required DateTime startDate,
    required DateTime endDate,
    required Location location,
    PrayerCalculationSettings? settings,
  }) async {
    final prayerTimesList = <PrayerTimes>[];

    try {
      // Use calendar endpoint for date ranges
      final response = await _dio.get(
        '$_baseUrl/calendar/${startDate.year}/${startDate.month}',
        queryParameters: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'method': _getCalculationMethodCode(settings?.calculationMethod ?? 'MWL'),
          'school': _getMadhabCode(settings?.madhab),
          'tune': _formatAdjustments(settings?.adjustments ?? {}),
          'timezone': location.timezone,
        },
        options: Options(

          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> calendarData = data['data'] ?? [];

        for (final dayData in calendarData) {
          final dateStr = dayData['date']['gregorian']['date'];
          final dayDate = DateFormat('dd-MM-yyyy').parse(dateStr);
          
          if (dayDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
              dayDate.isBefore(endDate.add(const Duration(days: 1)))) {
            final prayerTimes = _parsePrayerTimesFromCalendar(dayData, dayDate, location, settings);
            prayerTimesList.add(prayerTimes);
          }
        }

        return prayerTimesList;
      } else {
        throw Failure.serverFailure(
          message: 'Failed to fetch prayer times range',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure.unknownFailure(
        message: 'Error fetching prayer times range',
        details: e.toString(),
      );
    }
  }

  /// Get current location using AlAdhan's address API
  Future<Location> getLocationByAddress(String address) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/addressToTiming/${_formatDate(DateTime.now())}',
        queryParameters: {
          'address': address,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final meta = data['data']['meta'] as Map<String, dynamic>;
        
        return Location(
          latitude: (meta['latitude'] as num).toDouble(),
          longitude: (meta['longitude'] as num).toDouble(),
          city: meta['city'] ?? '',
          country: meta['country'] ?? '',
          timezone: meta['timezone'] ?? 'UTC',
          address: address,
        );
      } else {
        throw Failure.locationUnavailable(
          message: 'Unable to find location for address: $address',
        );
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const Failure.locationUnavailable(
        message: 'Failed to get location from address',
      );
    }
  }

  /// Get Qibla direction for a location
  Future<double> getQiblaDirection(Location location) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/qibla/${location.latitude}/${location.longitude}',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return (data['data']['direction'] as num).toDouble();
      } else {
        throw const Failure.qiblaCalculationFailure();
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const Failure.qiblaCalculationFailure(
        message: 'Failed to calculate Qibla direction from API',
      );
    }
  }

  /// Parse prayer times response from API
  PrayerTimes _parsePrayerTimesResponse(
    Map<String, dynamic> data,
    DateTime date,
    Location location,
    PrayerCalculationSettings? settings,
  ) {
    final timingsData = data['data']['timings'] as Map<String, dynamic>;
    final metaData = data['data']['meta'] as Map<String, dynamic>;
    final dateData = data['data']['date'] as Map<String, dynamic>;
    final hijriData = dateData['hijri'] as Map<String, dynamic>;

    // Parse prayer times
    final fajr = _parsePrayerTime(timingsData['Fajr'], 'fajr', 'الفجر');
    final sunrise = _parsePrayerTime(timingsData['Sunrise'], 'sunrise', 'الشروق');
    final dhuhr = _parsePrayerTime(timingsData['Dhuhr'], 'dhuhr', 'الظهر');
    final asr = _parsePrayerTime(timingsData['Asr'], 'asr', 'العصر');
    final maghrib = _parsePrayerTime(timingsData['Maghrib'], 'maghrib', 'المغرب');
    final isha = _parsePrayerTime(timingsData['Isha'], 'isha', 'العشاء');
    final midnight = _parsePrayerTime(timingsData['Midnight'], 'midnight', 'منتصف الليل');

    // Parse Hijri date
    final hijriCalendar = HijriCalendar()
      ..hDay = hijriData['day']
      ..hMonth = hijriData['month']['number']
      ..hYear = hijriData['year'];

    return PrayerTimes(
      date: date,
      hijriDate: '${hijriCalendar.hDay}-${hijriCalendar.hMonth}-${hijriCalendar.hYear}',
      location: location,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      midnight: midnight,
      calculationMethod: settings?.calculationMethod ?? 'MWL',
      metadata: {
        'source': 'AlAdhan API',
        'method': metaData['method']['name'],
        'school': metaData['school'],
        'timezone': metaData['timezone'],
        'latitude': metaData['latitude'],
        'longitude': metaData['longitude'],
        'offset': metaData['offset'],
        'requestTime': DateTime.now().toIso8601String(),
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// Parse prayer times from calendar endpoint
  PrayerTimes _parsePrayerTimesFromCalendar(
    Map<String, dynamic> dayData,
    DateTime date,
    Location location,
    PrayerCalculationSettings? settings,
  ) {
    final timingsData = dayData['timings'] as Map<String, dynamic>;
    final dateData = dayData['date'] as Map<String, dynamic>;
    final hijriData = dateData['hijri'] as Map<String, dynamic>;

    // Parse prayer times
    final fajr = _parsePrayerTime(timingsData['Fajr'], 'fajr', 'الفجر');
    final sunrise = _parsePrayerTime(timingsData['Sunrise'], 'sunrise', 'الشروق');
    final dhuhr = _parsePrayerTime(timingsData['Dhuhr'], 'dhuhr', 'الظهر');
    final asr = _parsePrayerTime(timingsData['Asr'], 'asr', 'العصر');
    final maghrib = _parsePrayerTime(timingsData['Maghrib'], 'maghrib', 'المغرب');
    final isha = _parsePrayerTime(timingsData['Isha'], 'isha', 'العشاء');
    final midnight = _parsePrayerTime(timingsData['Midnight'], 'midnight', 'منتصف الليل');

    // Parse Hijri date
    final hijriCalendar = HijriCalendar()
      ..hDay = hijriData['day']
      ..hMonth = hijriData['month']['number']
      ..hYear = hijriData['year'];

    return PrayerTimes(
      date: date,
      hijriDate: '${hijriCalendar.hDay}-${hijriCalendar.hMonth}-${hijriCalendar.hYear}',
      location: location,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      midnight: midnight,
      calculationMethod: settings?.calculationMethod ?? 'MWL',
      metadata: {
        'source': 'AlAdhan API Calendar',
        'requestTime': DateTime.now().toIso8601String(),
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// Parse individual prayer time
  PrayerTime _parsePrayerTime(String timeString, String name, String arabicName) {
    // Remove timezone suffix if present (e.g., "05:30 (+06)")
    final cleanTimeString = timeString.split(' ')[0];
    
    // Parse time
    final timeParts = cleanTimeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    final now = DateTime.now();
    final prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

    return PrayerTime(
      time: prayerTime,
      name: name,
      isCompleted: false,
      status: _determinePrayerStatus(prayerTime),
    );
  }

  /// Determine prayer status based on time
  PrayerStatus _determinePrayerStatus(DateTime prayerTime) {
    final now = DateTime.now();
    
    if (now.isBefore(prayerTime)) {
      return PrayerStatus.upcoming;
    } else if (now.difference(prayerTime).inMinutes < 30) {
      return PrayerStatus.current;
    } else {
      return PrayerStatus.inProgress;
    }
  }

  /// Format date for API
  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  /// Get calculation method code for API
  String _getCalculationMethodCode(String method) {
    switch (method.toUpperCase()) {
      case 'MWL':
        return '3'; // Muslim World League
      case 'ISNA':
        return '2'; // Islamic Society of North America
      case 'EGYPT':
        return '5'; // Egyptian General Authority of Survey
      case 'MAKKAH':
        return '4'; // Umm Al-Qura University, Makkah
      case 'KARACHI':
        return '1'; // University of Islamic Sciences, Karachi
      case 'TEHRAN':
        return '7'; // Institute of Geophysics, University of Tehran
      case 'JAFARI':
        return '0'; // Shia Ithna-Ashari, Leva Institute, Qum
      case 'DUBAI':
        return '8'; // Dubai
      case 'SINGAPORE':
        return '11'; // Singapore
      case 'NORTH_AMERICA':
        return '2'; // ISNA
      case 'KUWAIT':
        return '9'; // Kuwait
      default:
        return '3'; // Default to Muslim World League
    }
  }

  /// Convert Madhab enum to API code
  String _getMadhabCode(Madhab? madhab) {
    switch (madhab) {
      case Madhab.hanafi:
        return '1'; // Hanafi
      case Madhab.shafi:
      case Madhab.maliki:
      case Madhab.hanbali:
      default:
        return '0'; // Shafi, Maliki, Hanbali (standard)
    }
  }

  /// Convert Madhab enum to API code
  String _getMadhabCodeFromString(String? madhabString) {
    if (madhabString == null) return '0';
    
    switch (madhabString.toLowerCase()) {
      case 'hanafi':
        return '1';
      case 'shafi':
      case 'maliki':
      case 'hanbali':
      default:
        return '0';
    }
  }

  /// Format adjustments for API
  String _formatAdjustments(Map<String, double> adjustments) {
    // AlAdhan expects comma-separated values: fajr,sunrise,dhuhr,asr,maghrib,isha,midnight
    final fajr = adjustments['fajr']?.toInt() ?? 0;
    final sunrise = adjustments['sunrise']?.toInt() ?? 0;
    final dhuhr = adjustments['dhuhr']?.toInt() ?? 0;
    final asr = adjustments['asr']?.toInt() ?? 0;
    final maghrib = adjustments['maghrib']?.toInt() ?? 0;
    final isha = adjustments['isha']?.toInt() ?? 0;
    final midnight = adjustments['midnight']?.toInt() ?? 0;

    return '$fajr,$sunrise,$dhuhr,$asr,$maghrib,$isha,$midnight';
  }

  /// Check API health
  Future<bool> checkApiHealth() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/status',
        options: Options(

          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get available calculation methods from API
  Future<List<CalculationMethod>> getAvailableCalculationMethods() async {
    try {
      final response = await _dio.get('$_baseUrl/methods');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final methods = data['data'] as Map<String, dynamic>;
        
        final availableMethods = <CalculationMethod>[];
        
        for (final method in CalculationMethod.values) {
          if (methods.containsKey(_getCalculationMethodCode(method.name))) {
            availableMethods.add(method);
          }
        }
        
        return availableMethods;
      }
      
      // Return default methods if API call fails
      return CalculationMethod.values;
    } catch (e) {
      // Return default methods if error occurs
      return CalculationMethod.values;
    }
  }
}
