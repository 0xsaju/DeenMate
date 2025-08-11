import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qibla_direction.dart';

/// Abstract repository for Qibla direction data operations
/// Follows Clean Architecture principles for Islamic Qibla management
abstract class QiblaRepository {
  /// Get current Qibla direction for user's location
  Future<Either<Failure, QiblaDirection>> getCurrentQiblaDirection();

  /// Get Qibla direction for specific coordinates
  Future<Either<Failure, QiblaDirection>> getQiblaDirection({
    required double latitude,
    required double longitude,
  });

  /// Get current sensor data (compass + location)
  Future<Either<Failure, SensorData>> getCurrentSensorData();

  /// Initialize sensors and permissions
  Future<Either<Failure, void>> initializeSensors();

  /// Calibrate compass sensor
  Future<Either<Failure, void>> calibrateCompass();

  /// Check if sensors are available and working
  Future<Either<Failure, bool>> areSensorsAvailable();

  /// Get magnetic declination for location
  Future<Either<Failure, double?>> getMagneticDeclination({
    required double latitude,
    required double longitude,
  });

  /// Calculate distance to Kaaba
  Future<Either<Failure, double>> getDistanceToKaaba({
    required double latitude,
    required double longitude,
  });

  /// Validate Qibla calculation accuracy
  Future<Either<Failure, bool>> validateQiblaAccuracy({
    required QiblaDirection qiblaDirection,
  });

  /// Get location name from coordinates
  Future<Either<Failure, String>> getLocationName({
    required double latitude,
    required double longitude,
  });

  /// Save Qibla direction for offline access
  Future<Either<Failure, void>> cacheQiblaDirection(QiblaDirection direction);

  /// Get cached Qibla direction
  Future<Either<Failure, QiblaDirection?>> getCachedQiblaDirection();

  /// Clear cached Qibla data
  Future<Either<Failure, void>> clearCache();

  /// Get Qibla direction history
  Future<Either<Failure, List<QiblaDirection>>> getQiblaHistory({
    required DateTime fromDate,
    required DateTime toDate,
  });

  /// Export Qibla data
  Future<Either<Failure, String>> exportQiblaData({
    required DateTime fromDate,
    required DateTime toDate,
  });
}
