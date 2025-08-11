import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/qibla_direction.dart';

/// Local storage for Qibla direction data using Hive
/// Provides caching and history functionality
class QiblaLocalStorage {
  static const String _qiblaBoxName = 'qibla_directions';
  static const String _settingsBoxName = 'qibla_settings';

  late Box<Map> _qiblaBox;
  late Box<Map> _settingsBox;

  /// Initialize Hive boxes
  Future<void> initialize() async {
    _qiblaBox = await Hive.openBox<Map>(_qiblaBoxName);
    _settingsBox = await Hive.openBox<Map>(_settingsBoxName);
  }

  /// Save Qibla direction to local storage
  Future<void> saveQiblaDirection(QiblaDirection direction) async {
    try {
      final key = direction.timestamp.millisecondsSinceEpoch.toString();
      final data = direction.toJson();
      await _qiblaBox.put(key, data);
      
      // Keep only last 100 entries to prevent storage bloat
      await _cleanupOldEntries();
    } catch (e) {
      throw Exception('Failed to save Qibla direction: $e');
    }
  }

  /// Get the latest Qibla direction from cache
  Future<QiblaDirection?> getLatestQiblaDirection() async {
    try {
      if (_qiblaBox.isEmpty) return null;

      // Get the most recent entry
      final keys = _qiblaBox.keys.toList();
      keys.sort((a, b) => int.parse(b.toString()).compareTo(int.parse(a.toString())));
      
      if (keys.isNotEmpty) {
        final latestKey = keys.first;
        final data = _qiblaBox.get(latestKey);
        if (data != null) {
          return QiblaDirection.fromJson(Map<String, dynamic>.from(data));
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get latest Qibla direction: $e');
    }
  }

  /// Get Qibla direction history within a date range
  Future<List<QiblaDirection>> getQiblaHistory(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      final fromTimestamp = fromDate.millisecondsSinceEpoch;
      final toTimestamp = toDate.millisecondsSinceEpoch;
      
      final directions = <QiblaDirection>[];
      
      for (final key in _qiblaBox.keys) {
        final timestamp = int.parse(key.toString());
        if (timestamp >= fromTimestamp && timestamp <= toTimestamp) {
          final data = _qiblaBox.get(key);
          if (data != null) {
            try {
              final direction = QiblaDirection.fromJson(Map<String, dynamic>.from(data));
              directions.add(direction);
            } catch (e) {
              // Skip invalid entries
              continue;
            }
          }
        }
      }
      
      // Sort by timestamp (newest first)
      directions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return directions;
    } catch (e) {
      throw Exception('Failed to get Qibla history: $e');
    }
  }

  /// Get Qibla directions for a specific day
  Future<List<QiblaDirection>> getQiblaDirectionsForDay(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      return await getQiblaHistory(startOfDay, endOfDay);
    } catch (e) {
      throw Exception('Failed to get Qibla directions for day: $e');
    }
  }

  /// Get average Qibla direction for a time period
  Future<QiblaDirection?> getAverageQiblaDirection(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      final directions = await getQiblaHistory(fromDate, toDate);
      
      if (directions.isEmpty) return null;
      
      // Calculate average bearing
      double totalBearing = 0;
      double totalAccuracy = 0;
      double totalDistance = 0;
      int count = 0;
      
      for (final direction in directions) {
        totalBearing += direction.bearing;
        totalAccuracy += direction.accuracy;
        totalDistance += direction.distance;
        count++;
      }
      
      final averageBearing = totalBearing / count;
      final averageAccuracy = totalAccuracy / count;
      final averageDistance = totalDistance / count;
      
      // Use the most recent timestamp and location info
      final latest = directions.first;
      
      return QiblaDirection(
        bearing: averageBearing,
        accuracy: averageAccuracy,
        distance: averageDistance,
        isCalibrated: latest.isCalibrated,
        calibrationStatus: latest.calibrationStatus,
        timestamp: DateTime.now(),
        magneticDeclination: latest.magneticDeclination,
        locationName: latest.locationName,
        latitude: latest.latitude,
        longitude: latest.longitude,
      );
    } catch (e) {
      throw Exception('Failed to calculate average Qibla direction: $e');
    }
  }

  /// Save user preferences for Qibla settings
  Future<void> saveQiblaSettings({
    required bool enableNotifications,
    required bool showDistance,
    required bool showAccuracy,
    required String preferredLanguage,
    required bool useMagneticDeclination,
  }) async {
    try {
      final settings = {
        'enableNotifications': enableNotifications,
        'showDistance': showDistance,
        'showAccuracy': showAccuracy,
        'preferredLanguage': preferredLanguage,
        'useMagneticDeclination': useMagneticDeclination,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      await _settingsBox.put('user_settings', settings);
    } catch (e) {
      throw Exception('Failed to save Qibla settings: $e');
    }
  }

  /// Get user preferences for Qibla settings
  Future<Map<String, dynamic>> getQiblaSettings() async {
    try {
      final settings = _settingsBox.get('user_settings');
      if (settings != null) {
        return Map<String, dynamic>.from(settings);
      }
      
      // Return default settings
      return {
        'enableNotifications': true,
        'showDistance': true,
        'showAccuracy': true,
        'preferredLanguage': 'en',
        'useMagneticDeclination': true,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get Qibla settings: $e');
    }
  }

  /// Clear all cached Qibla direction data
  Future<void> clearCache() async {
    try {
      await _qiblaBox.clear();
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final totalEntries = _qiblaBox.length;
      final keys = _qiblaBox.keys.toList();
      
      if (keys.isEmpty) {
        return {
          'totalEntries': 0,
          'oldestEntry': null,
          'newestEntry': null,
          'cacheSize': 0,
        };
      }
      
      // Sort keys to get oldest and newest
      keys.sort((a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
      
      final oldestTimestamp = int.parse(keys.first.toString());
      final newestTimestamp = int.parse(keys.last.toString());
      
      return {
        'totalEntries': totalEntries,
        'oldestEntry': DateTime.fromMillisecondsSinceEpoch(oldestTimestamp).toIso8601String(),
        'newestEntry': DateTime.fromMillisecondsSinceEpoch(newestTimestamp).toIso8601String(),
        'cacheSize': await _calculateCacheSize(),
      };
    } catch (e) {
      throw Exception('Failed to get cache stats: $e');
    }
  }

  /// Clean up old entries to prevent storage bloat
  Future<void> _cleanupOldEntries() async {
    try {
      final keys = _qiblaBox.keys.toList();
      
      if (keys.length > 100) {
        // Sort by timestamp (oldest first)
        keys.sort((a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
        
        // Remove oldest entries, keeping only the last 100
        final keysToRemove = keys.take(keys.length - 100).toList();
        
        for (final key in keysToRemove) {
          await _qiblaBox.delete(key);
        }
      }
    } catch (e) {
      // Log error but don't throw to prevent breaking the main functionality
      print('Failed to cleanup old entries: $e');
    }
  }

  /// Calculate approximate cache size in bytes
  Future<int> _calculateCacheSize() async {
    try {
      int totalSize = 0;
      
      for (final key in _qiblaBox.keys) {
        final data = _qiblaBox.get(key);
        if (data != null) {
          // Rough estimation: convert to string and get length
          totalSize += data.toString().length;
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Close Hive boxes
  Future<void> close() async {
    await _qiblaBox.close();
    await _settingsBox.close();
  }
}
