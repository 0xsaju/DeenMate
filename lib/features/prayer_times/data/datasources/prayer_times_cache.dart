import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/prayer_times.dart';

/// Cache data source for prayer times
/// Stores prayer times locally for offline access
class PrayerTimesCache {
  static const String _cacheKey = 'prayer_times_cache';
  static const String _lastUpdateKey = 'prayer_times_last_update';
  static const Duration _cacheValidity = Duration(hours: 24);

  /// Save prayer times to cache
  Future<void> cachePrayerTimes(PrayerTimes prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();
    final prayerTimesJson = prayerTimes.toJson();
    
    await prefs.setString(_cacheKey, jsonEncode(prayerTimesJson));
    await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  /// Get cached prayer times
  Future<PrayerTimes?> getCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final lastUpdate = prefs.getString(_lastUpdateKey);

    if (cachedData == null || lastUpdate == null) {
      return null;
    }

    // Check if cache is still valid
    final lastUpdateTime = DateTime.parse(lastUpdate);
    final now = DateTime.now();
    
    if (now.difference(lastUpdateTime) > _cacheValidity) {
      // Cache expired, remove it
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastUpdateKey);
      return null;
    }

    try {
      final prayerTimesJson = jsonDecode(cachedData);
      return PrayerTimes.fromJson(prayerTimesJson);
    } catch (e) {
      // Invalid cache data, remove it
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastUpdateKey);
      return null;
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_lastUpdateKey);
  }

  /// Check if cache is available and valid
  Future<bool> hasValidCache() async {
    final cachedTimes = await getCachedPrayerTimes();
    return cachedTimes != null;
  }
}
