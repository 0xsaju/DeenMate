import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_tracking.dart';
import '../../domain/entities/prayer_calculation_settings.dart';
import '../../domain/entities/athan_settings.dart';

/// Local storage service for prayer times using Hive and SharedPreferences
/// Provides offline access and caching capabilities
class PrayerTimesLocalStorage {
  static const String _prayerTimesBoxName = 'prayer_times_box';
  static const String _prayerTrackingBoxName = 'prayer_tracking_box';
  static const String _settingsBoxName = 'prayer_settings_box';
  static const String _locationBoxName = 'location_box';

  // SharedPreferences keys
  static const String _settingsKey = 'prayer_calculation_settings';
  static const String _athanSettingsKey = 'athan_settings';
  static const String _preferredLocationKey = 'preferred_location';
  static const String _lastUpdateKey = 'last_prayer_times_update';
  static const String _jamaatOffsetsKey = 'jamaat_offsets_minutes';

  late Box<String> _prayerTimesBox;
  late Box<String> _prayerTrackingBox;
  late Box<String> _settingsBox;
  late Box<String> _locationBox;
  late SharedPreferences _prefs;

  bool _isInitialized = false;

  /// Initialize local storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive boxes
      _prayerTimesBox = await Hive.openBox<String>(_prayerTimesBoxName);
      _prayerTrackingBox = await Hive.openBox<String>(_prayerTrackingBoxName);
      _settingsBox = await Hive.openBox<String>(_settingsBoxName);
      _locationBox = await Hive.openBox<String>(_locationBoxName);

      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      _isInitialized = true;
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'initialize',
        message: 'Failed to initialize prayer times local storage: $e',
      );
    }
  }

  /// Get Jama'at offsets in minutes per prayer (defaults to 15 if not set)
  Future<Map<String, int>> getJamaatOffsets() async {
    await _ensureInitialized();
    try {
      final jsonString = _prefs.getString(_jamaatOffsetsKey);
      Map<String, int> defaults = {
        'fajr': 15,
        'dhuhr': 15,
        'asr': 15,
        'maghrib': 15,
        'isha': 15,
      };
      if (jsonString == null) {
        return defaults;
      }
      final Map<String, dynamic> data =
          json.decode(jsonString) as Map<String, dynamic>;
      final result = <String, int>{};
      for (final entry in data.entries) {
        final v = entry.value;
        result[entry.key.toLowerCase()] = v is int ? v : (v as num).toInt();
      }
      // Ensure all keys exist
      defaults.forEach((k, v) => result.putIfAbsent(k, () => v));
      return result;
    } catch (e) {
      return {
        'fajr': 15,
        'dhuhr': 15,
        'asr': 15,
        'maghrib': 15,
        'isha': 15,
      };
    }
  }

  /// Save Jama'at offsets in minutes per prayer
  Future<void> saveJamaatOffsets(Map<String, int> offsets) async {
    await _ensureInitialized();
    try {
      // Normalize keys and values
      final normalized = <String, int>{};
      offsets.forEach((k, v) {
        normalized[k.toLowerCase()] = v;
      });
      await _prefs.setString(_jamaatOffsetsKey, json.encode(normalized));
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'save_jamaat_offsets',
        message: 'Failed to save Jama\'at offsets: $e',
      );
    }
  }

  /// Save prayer times to local storage
  Future<void> savePrayerTimes(PrayerTimes prayerTimes) async {
    await _ensureInitialized();

    try {
      final key =
          _generatePrayerTimesKey(prayerTimes.date, prayerTimes.location);
      final jsonString = json.encode(prayerTimes.toJson());

      await _prayerTimesBox.put(key, jsonString);

      // Update last update timestamp
      await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'save_prayer_times',
        message: 'Failed to save prayer times: $e',
      );
    }
  }

  /// Save multiple prayer times (for bulk operations)
  Future<void> savePrayerTimesList(List<PrayerTimes> prayerTimesList) async {
    await _ensureInitialized();

    try {
      final dataToSave = <String, String>{};

      for (final prayerTimes in prayerTimesList) {
        final key =
            _generatePrayerTimesKey(prayerTimes.date, prayerTimes.location);
        final jsonString = json.encode(prayerTimes.toJson());
        dataToSave[key] = jsonString;
      }

      await _prayerTimesBox.putAll(dataToSave);
      await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'save_prayer_times_list',
        message: 'Failed to save prayer times list: $e',
      );
    }
  }

  /// Get prayer times from local storage
  Future<PrayerTimes?> getPrayerTimes(DateTime date, Location location) async {
    await _ensureInitialized();

    try {
      final key = _generatePrayerTimesKey(date, location);
      final jsonString = _prayerTimesBox.get(key);

      if (jsonString != null) {
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        return PrayerTimes.fromJson(jsonData);
      }

      return null;
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'get_prayer_times',
        message: 'Failed to get prayer times: $e',
      );
    }
  }

  /// Get prayer times for a date range
  Future<List<PrayerTimes>> getPrayerTimesRange(
    DateTime startDate,
    DateTime endDate,
    Location location,
  ) async {
    await _ensureInitialized();

    try {
      final prayerTimesList = <PrayerTimes>[];

      for (var date = startDate;
          date.isBefore(endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        final prayerTimes = await getPrayerTimes(date, location);
        if (prayerTimes != null) {
          prayerTimesList.add(prayerTimes);
        }
      }

      return prayerTimesList;
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'get_prayer_times_range',
        message: 'Failed to get prayer times range: $e',
      );
    }
  }

  /// Check if prayer times are available for a specific date and location
  Future<bool> arePrayerTimesAvailable(DateTime date, Location location) async {
    await _ensureInitialized();

    try {
      final key = _generatePrayerTimesKey(date, location);
      return _prayerTimesBox.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  /// Save prayer tracking information
  Future<void> savePrayerTracking(PrayerTracking tracking) async {
    await _ensureInitialized();

    try {
      final key = _generateTrackingKey(tracking.date, tracking.prayerName);
      final jsonString = json.encode(tracking.toJson());

      await _prayerTrackingBox.put(key, jsonString);
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'save_prayer_tracking',
        message: 'Failed to save prayer tracking: $e',
      );
    }
  }

  /// Get prayer tracking history
  Future<List<PrayerTracking>> getPrayerTrackingHistory(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    await _ensureInitialized();

    try {
      final trackingList = <PrayerTracking>[];

      for (final key in _prayerTrackingBox.keys) {
        final jsonString = _prayerTrackingBox.get(key);
        if (jsonString != null) {
          final jsonData = json.decode(jsonString) as Map<String, dynamic>;
          final tracking = PrayerTracking.fromJson(jsonData);

          if (tracking.date
                  .isAfter(fromDate.subtract(const Duration(days: 1))) &&
              tracking.date.isBefore(toDate.add(const Duration(days: 1)))) {
            trackingList.add(tracking);
          }
        }
      }

      // Sort by date (newest first)
      trackingList.sort((a, b) => b.date.compareTo(a.date));

      return trackingList;
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'get_prayer_tracking_history',
        message: 'Failed to get prayer tracking history: $e',
      );
    }
  }

  /// Mark prayer as completed
  Future<void> markPrayerCompleted({
    required String prayerName,
    required DateTime date,
    required Location location,
  }) async {
    await _ensureInitialized();

    try {
      final tracking = PrayerTracking(
        date: date,
        prayerName: prayerName,
        isCompleted: true,
        isOnTime: true,
        completedAt: DateTime.now(),
        notes: null,
        completionType: null,
      );

      final key = _generatePrayerTrackingKey(date, prayerName);
      final jsonString = json.encode(tracking.toJson());
      await _prayerTrackingBox.put(key, jsonString);
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'mark_prayer_completed',
        message: 'Failed to mark prayer as completed: $e',
      );
    }
  }

  /// Save prayer calculation settings
  Future<void> savePrayerSettings(PrayerCalculationSettings settings) async {
    await _ensureInitialized();

    try {
      final jsonString = json.encode(settings.toJson());
      await _prefs.setString(_settingsKey, jsonString);
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'save_prayer_settings',
        message: 'Failed to save prayer settings: $e',
      );
    }
  }

  /// Get prayer calculation settings
  Future<PrayerCalculationSettings?> getPrayerSettings() async {
    await _ensureInitialized();

    try {
      final jsonString = _prefs.getString(_settingsKey);
      if (jsonString != null) {
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        return PrayerCalculationSettings.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'get_prayer_settings',
        message: 'Failed to get prayer settings: $e',
      );
    }
  }

  /// Save Athan settings
  Future<void> saveAthanSettings(AthanSettings settings) async {
    await _ensureInitialized();

    try {
      final jsonString = json.encode(settings.toJson());
      await _prefs.setString(_athanSettingsKey, jsonString);
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'save_athan_settings',
        message: 'Failed to save Athan settings: $e',
      );
    }
  }

  /// Get Athan settings
  Future<AthanSettings?> getAthanSettings() async {
    await _ensureInitialized();

    try {
      final jsonString = _prefs.getString(_athanSettingsKey);
      if (jsonString != null) {
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        return AthanSettings.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'get_athan_settings',
        message: 'Failed to get Athan settings: $e',
      );
    }
  }

  /// Save preferred location
  Future<void> savePreferredLocation(Location location) async {
    await _ensureInitialized();

    try {
      final jsonString = json.encode(location.toJson());
      await _prefs.setString(_preferredLocationKey, jsonString);
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'save_preferred_location',
        message: 'Failed to save preferred location: $e',
      );
    }
  }

  /// Get preferred location
  Future<Location?> getPreferredLocation() async {
    await _ensureInitialized();

    try {
      final jsonString = _prefs.getString(_preferredLocationKey);
      if (jsonString != null) {
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        return Location.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'get_preferred_location',
        message: 'Failed to get preferred location: $e',
      );
    }
  }

  /// Clear old cached data to save space
  Future<void> clearOldCache({int daysToKeep = 30}) async {
    await _ensureInitialized();

    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final keysToDelete = <String>[];

      // Check prayer times cache
      for (final key in _prayerTimesBox.keys) {
        final parts = key.split('_');
        if (parts.length >= 3) {
          try {
            final dateStr = '${parts[0]}-${parts[1]}-${parts[2]}';
            final date = DateTime.parse(dateStr);
            if (date.isBefore(cutoffDate)) {
              keysToDelete.add(key);
            }
          } catch (e) {
            // If we can't parse the date, delete the key
            keysToDelete.add(key);
          }
        }
      }

      // Delete old prayer times
      await _prayerTimesBox.deleteAll(keysToDelete);

      // Clear old prayer tracking (keep longer for statistics)
      final trackingKeysToDelete = <String>[];
      final trackingCutoffDate =
          DateTime.now().subtract(Duration(days: daysToKeep * 3));

      for (final key in _prayerTrackingBox.keys) {
        try {
          final jsonString = _prayerTrackingBox.get(key);
          if (jsonString != null) {
            final jsonData = json.decode(jsonString) as Map<String, dynamic>;
            final tracking = PrayerTracking.fromJson(jsonData);
            if (tracking.date.isBefore(trackingCutoffDate)) {
              trackingKeysToDelete.add(key);
            }
          }
        } catch (e) {
          // If we can't parse the tracking data, delete the key
          trackingKeysToDelete.add(key);
        }
      }

      await _prayerTrackingBox.deleteAll(trackingKeysToDelete);
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'clear_old_cache',
        message: 'Failed to clear old cache: $e',
      );
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStatistics() async {
    await _ensureInitialized();

    try {
      final prayerTimesCount = _prayerTimesBox.length;
      final trackingCount = _prayerTrackingBox.length;
      final settingsCount = _settingsBox.length;
      final locationCount = _locationBox.length;

      final lastUpdate = _prefs.getString(_lastUpdateKey);
      final lastUpdateDate =
          lastUpdate != null ? DateTime.parse(lastUpdate) : null;

      return {
        'prayerTimesCount': prayerTimesCount,
        'trackingCount': trackingCount,
        'settingsCount': settingsCount,
        'locationCount': locationCount,
        'lastUpdate': lastUpdateDate?.toIso8601String(),
        'totalSize':
            prayerTimesCount + trackingCount + settingsCount + locationCount,
      };
    } catch (e) {
      return {
        'error': 'Failed to get cache statistics: $e',
      };
    }
  }

  /// Export prayer data for backup
  Future<Map<String, dynamic>> exportPrayerData() async {
    await _ensureInitialized();

    try {
      final exportData = <String, dynamic>{
        'exportTime': DateTime.now().toIso8601String(),
        'version': '1.0',
        'prayerTimes': {},
        'prayerTracking': {},
        'settings': {},
      };

      // Export prayer times
      for (final key in _prayerTimesBox.keys) {
        exportData['prayerTimes'][key] = _prayerTimesBox.get(key);
      }

      // Export prayer tracking
      for (final key in _prayerTrackingBox.keys) {
        exportData['prayerTracking'][key] = _prayerTrackingBox.get(key);
      }

      // Export settings
      final prayerSettings = _prefs.getString(_settingsKey);
      final athanSettings = _prefs.getString(_athanSettingsKey);
      final preferredLocation = _prefs.getString(_preferredLocationKey);

      exportData['settings'] = {
        'prayerSettings': prayerSettings,
        'athanSettings': athanSettings,
        'preferredLocation': preferredLocation,
      };

      return exportData;
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'export_prayer_data',
        message: 'Failed to export prayer data: $e',
      );
    }
  }

  /// Import prayer data from backup
  Future<void> importPrayerData(Map<String, dynamic> backupData) async {
    await _ensureInitialized();

    try {
      // Import prayer times
      final prayerTimesData =
          backupData['prayerTimes'] as Map<String, dynamic>? ?? {};
      for (final entry in prayerTimesData.entries) {
        await _prayerTimesBox.put(entry.key, entry.value);
      }

      // Import prayer tracking
      final trackingData =
          backupData['prayerTracking'] as Map<String, dynamic>? ?? {};
      for (final entry in trackingData.entries) {
        await _prayerTrackingBox.put(entry.key, entry.value);
      }

      // Import settings
      final settingsData =
          backupData['settings'] as Map<String, dynamic>? ?? {};

      if (settingsData['prayerSettings'] != null) {
        await _prefs.setString(_settingsKey, settingsData['prayerSettings']);
      }

      if (settingsData['athanSettings'] != null) {
        await _prefs.setString(
            _athanSettingsKey, settingsData['athanSettings']);
      }

      if (settingsData['preferredLocation'] != null) {
        await _prefs.setString(
            _preferredLocationKey, settingsData['preferredLocation']);
      }
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'import_prayer_data',
        message: 'Failed to import prayer data: $e',
      );
    }
  }

  /// Generate unique key for prayer times
  String _generatePrayerTimesKey(DateTime date, Location location) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final locationStr =
        '${location.latitude.toStringAsFixed(4)}_${location.longitude.toStringAsFixed(4)}';
    return '${dateStr}_$locationStr';
  }

  /// Generate unique key for prayer tracking
  String _generateTrackingKey(DateTime date, String prayerName) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${dateStr}_$prayerName';
  }

  /// Generate unique key for prayer tracking (alias for compatibility)
  String _generatePrayerTrackingKey(DateTime date, String prayerName) {
    return _generateTrackingKey(date, prayerName);
  }

  /// Ensure storage is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Close all storage connections
  Future<void> close() async {
    if (_isInitialized) {
      await _prayerTimesBox.close();
      await _prayerTrackingBox.close();
      await _settingsBox.close();
      await _locationBox.close();
      _isInitialized = false;
    }
  }
}
