import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real prayer times API service using AlAdhan API
class PrayerTimesApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  final Dio _dio = Dio();
  static const String _cacheKey = 'cached_prayer_times';
  static const String _lastFetchKey = 'last_prayer_fetch';
  
  /// Prayer calculation methods
  static const Map<int, String> calculationMethods = {
    1: 'University of Islamic Sciences, Karachi',
    2: 'Islamic Society of North America (ISNA)',
    3: 'Muslim World League (MWL)',
    4: 'Umm al-Qura, Makkah',
    5: 'Egyptian General Authority of Survey',
    7: 'Institute of Geophysics, University of Tehran',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'Majlis Ugama Islam Singapura, Singapore',
    12: 'Union Organization islamic de France',
    13: 'Diyanet İşleri Başkanlığı, Turkey',
    14: 'Spiritual Administration of Muslims of Russia',
  };

  /// Get prayer times for current location
  Future<Map<String, dynamic>?> getPrayerTimes({
    double? latitude,
    double? longitude,
    int method = 2, // Default to ISNA
    bool forceRefresh = false,
  }) async {
    try {
      // Get location if not provided
      Position? position;
      if (latitude == null || longitude == null) {
        position = await _getCurrentLocation();
        if (position == null) return null;
        latitude = position.latitude;
        longitude = position.longitude;
      }

      // Check cache first
      if (!forceRefresh) {
        final cachedData = await _getCachedPrayerTimes();
        if (cachedData != null) return cachedData;
      }

      // Fetch from API
      final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final response = await _dio.get(
        '$_baseUrl/timings/$today',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
          'format': 'json',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Cache the response
        await _cachePrayerTimes(data);
        
        return _formatPrayerTimes(data);
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      // Return cached data if available
      return _getCachedPrayerTimes();
    }
    
    return null;
  }

  /// Get prayer times for specific date
  Future<Map<String, dynamic>?> getPrayerTimesForDate({
    required DateTime date,
    double? latitude,
    double? longitude,
    int method = 2,
  }) async {
    try {
      Position? position;
      if (latitude == null || longitude == null) {
        position = await _getCurrentLocation();
        if (position == null) return null;
        latitude = position.latitude;
        longitude = position.longitude;
      }

      final dateStr = DateFormat('dd-MM-yyyy').format(date);
      final response = await _dio.get(
        '$_baseUrl/timings/$dateStr',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
          'format': 'json',
        },
      );

      if (response.statusCode == 200) {
        return _formatPrayerTimes(response.data);
      }
    } catch (e) {
      print('Error fetching prayer times for date: $e');
    }
    
    return null;
  }

  /// Get current location
  Future<Position?> _getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Format prayer times response
  Map<String, dynamic> _formatPrayerTimes(Map<String, dynamic> data) {
    final timings = data['data']['timings'];
    final date = data['data']['date'];
    final meta = data['data']['meta'];
    
    return {
      'prayers': {
        'fajr': _formatTime(timings['Fajr']),
        'sunrise': _formatTime(timings['Sunrise']),
        'dhuhr': _formatTime(timings['Dhuhr']),
        'asr': _formatTime(timings['Asr']),
        'maghrib': _formatTime(timings['Maghrib']),
        'isha': _formatTime(timings['Isha']),
      },
      'date': {
        'readable': date['readable'],
        'timestamp': date['timestamp'],
        'hijri': {
          'date': date['hijri']['date'],
          'month': date['hijri']['month'],
          'year': date['hijri']['year'],
          'designation': date['hijri']['designation'],
        },
        'gregorian': {
          'date': date['gregorian']['date'],
          'month': date['gregorian']['month'],
          'year': date['gregorian']['year'],
        },
      },
      'meta': {
        'latitude': meta['latitude'],
        'longitude': meta['longitude'],
        'timezone': meta['timezone'],
        'method': meta['method'],
        'location': _getLocationName(meta),
      },
      'fetchTime': DateTime.now().toIso8601String(),
    };
  }

  /// Format time string
  String _formatTime(String timeStr) {
    // Remove timezone info if present
    final cleanTime = timeStr.split(' ')[0];
    
    try {
      final time = DateFormat('HH:mm').parse(cleanTime);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return cleanTime;
    }
  }

  /// Get location name from meta
  String _getLocationName(Map<String, dynamic> meta) {
    if (meta.containsKey('location')) {
      return meta['location'];
    }
    return '${meta['latitude']}, ${meta['longitude']}';
  }

  /// Cache prayer times
  Future<void> _cachePrayerTimes(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(data));
      await prefs.setString(_lastFetchKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching prayer times: $e');
    }
  }

  /// Get cached prayer times
  Future<Map<String, dynamic>?> _getCachedPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final lastFetch = prefs.getString(_lastFetchKey);
      
      if (cachedData != null && lastFetch != null) {
        final lastFetchTime = DateTime.parse(lastFetch);
        final now = DateTime.now();
        
        // Use cache if it's from today
        if (now.difference(lastFetchTime).inHours < 12) {
          final data = jsonDecode(cachedData);
          return _formatPrayerTimes(data);
        }
      }
    } catch (e) {
      print('Error reading cached prayer times: $e');
    }
    
    return null;
  }

  /// Get next prayer information
  Map<String, dynamic>? getNextPrayer(Map<String, dynamic> prayerTimes) {
    final prayers = prayerTimes['prayers'] as Map<String, dynamic>;
    final now = DateTime.now();
    
    final prayerList = [
      {'name': 'Fajr', 'nameArabic': 'الفجر', 'nameBengali': 'ফজর', 'time': prayers['fajr']},
      {'name': 'Sunrise', 'nameArabic': 'الشروق', 'nameBengali': 'সূর্যোদয়', 'time': prayers['sunrise']},
      {'name': 'Dhuhr', 'nameArabic': 'الظهر', 'nameBengali': 'যুহর', 'time': prayers['dhuhr']},
      {'name': 'Asr', 'nameArabic': 'العصر', 'nameBengali': 'আসর', 'time': prayers['asr']},
      {'name': 'Maghrib', 'nameArabic': 'المغرب', 'nameBengali': 'মাগরিব', 'time': prayers['maghrib']},
      {'name': 'Isha', 'nameArabic': 'العشاء', 'nameBengali': 'ইশা', 'time': prayers['isha']},
    ];

    for (final prayer in prayerList) {
      try {
        final prayerTime = DateFormat('h:mm a').parse(prayer['time']);
        final prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          prayerTime.hour,
          prayerTime.minute,
        );

        if (prayerDateTime.isAfter(now)) {
          final difference = prayerDateTime.difference(now);
          return {
            ...prayer,
            'timeRemaining': _formatDuration(difference),
            'datetime': prayerDateTime,
          };
        }
      } catch (e) {
        print('Error parsing prayer time: ${prayer['time']}');
      }
    }

    // If no prayer left today, return Fajr of next day
    final fajrTime = DateFormat('h:mm a').parse(prayers['fajr']);
    final nextFajr = DateTime(
      now.year,
      now.month,
      now.day + 1,
      fajrTime.hour,
      fajrTime.minute,
    );
    
    return {
      'name': 'Fajr',
      'nameArabic': 'الفجر',
      'nameBengali': 'ফজর',
      'time': prayers['fajr'],
      'timeRemaining': _formatDuration(nextFajr.difference(now)),
      'datetime': nextFajr,
    };
  }

  /// Format duration to readable string
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Calculate Qibla direction
  double calculateQiblaDirection(double latitude, double longitude) {
    // Kaaba coordinates
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;
    
    // Convert to radians
    final lat1 = latitude * (3.14159265359 / 180);
    const lat2 = kaabaLat * (3.14159265359 / 180);
    final dLng = (kaabaLng - longitude) * (3.14159265359 / 180);
    
    // Calculate bearing
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - 
              math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    
    final bearing = math.atan2(y, x);
    
    // Convert to degrees and normalize
    var qiblaDirection = bearing * (180 / 3.14159265359);
    qiblaDirection = (qiblaDirection + 360) % 360;
    
    return qiblaDirection;
  }
}


