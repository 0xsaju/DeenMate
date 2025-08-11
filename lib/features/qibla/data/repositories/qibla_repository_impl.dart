import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/qibla_direction.dart';
import '../../domain/repositories/qibla_repository.dart';
import '../services/sensor_service.dart';
import '../datasources/qibla_local_storage.dart';

/// Implementation of QiblaRepository
/// Coordinates between sensors and local storage with Islamic compliance
class QiblaRepositoryImpl implements QiblaRepository {
  const QiblaRepositoryImpl({
    required SensorService sensorService,
    required QiblaLocalStorage localStorage,
  })  : _sensorService = sensorService,
        _localStorage = localStorage;

  final SensorService _sensorService;
  final QiblaLocalStorage _localStorage;

  @override
  Future<Either<Failure, QiblaDirection>> getCurrentQiblaDirection() async {
    try {
      // 1. Get current location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 2. Calculate Qibla direction
      final qiblaDirection = await getQiblaDirection(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return qiblaDirection;
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure.locationUnavailable(
        message: 'Failed to get current location: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, QiblaDirection>> getQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // 1. Calculate basic Qibla direction
      final bearing = SensorService.calculateQiblaDirection(latitude, longitude);
      
      // 2. Calculate distance to Kaaba
      final distance = SensorService.calculateDistanceToKaaba(latitude, longitude);
      
      // 3. Get magnetic declination (if available)
      final magneticDeclination = await getMagneticDeclination(
        latitude: latitude,
        longitude: longitude,
      );
      
      final declination = magneticDeclination.getOrElse(() => null);
      
      // 4. Get location name
      final locationName = await getLocationName(
        latitude: latitude,
        longitude: longitude,
      );
      
      final locationNameStr = locationName.fold(
        (failure) => null,
        (name) => name,
      );
      
      // 5. Create Qibla direction entity
      final qiblaDirection = QiblaDirection(
        bearing: bearing,
        accuracy: _calculateAccuracy(latitude, longitude),
        distance: distance,
        isCalibrated: _sensorService.currentStatus.isReady,
        calibrationStatus: _getCalibrationStatus(),
        timestamp: DateTime.now(),
        magneticDeclination: declination,
        locationName: locationNameStr,
        latitude: latitude,
        longitude: longitude,
      );
      
      // 6. Cache the result
      await cacheQiblaDirection(qiblaDirection);
      
      return Right(qiblaDirection);
    } catch (e) {
      return Left(Failure.qiblaCalculationFailure(
        message: 'Failed to calculate Qibla direction: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, SensorData>> getCurrentSensorData() async {
    try {
      final sensorData = await _sensorService.getCurrentSensorData();
      return Right(sensorData);
    } catch (e) {
      return Left(Failure.sensorFailure(
        message: 'Failed to get sensor data: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> initializeSensors() async {
    try {
      await _sensorService.initialize();
      return const Right(null);
    } catch (e) {
      return Left(Failure.sensorFailure(
        message: 'Failed to initialize sensors: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> calibrateCompass() async {
    try {
      await _sensorService.calibrateCompass();
      return const Right(null);
    } catch (e) {
      return Left(Failure.sensorFailure(
        message: 'Failed to calibrate compass: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> areSensorsAvailable() async {
    try {
      // Check if location services are enabled
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        return const Right(false);
      }
      
      // Check if we have location permission
      final locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever) {
        return const Right(false);
      }
      
      // Check if compass is available
      await _sensorService.getCurrentSensorData();
      
      return Right(true);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, double?>> getMagneticDeclination({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final declination = await SensorService.getMagneticDeclination(latitude, longitude);
      return Right(declination);
    } catch (e) {
      return Left(Failure.sensorFailure(
        message: 'Failed to get magnetic declination: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, double>> getDistanceToKaaba({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final distance = SensorService.calculateDistanceToKaaba(latitude, longitude);
      return Right(distance);
    } catch (e) {
      return Left(Failure.qiblaCalculationFailure(
        message: 'Failed to calculate distance to Kaaba: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> validateQiblaAccuracy({
    required QiblaDirection qiblaDirection,
  }) async {
    try {
      // Check if accuracy is within acceptable range for prayer
      return Right(qiblaDirection.isAccurateForPrayer);
    } catch (e) {
      return Left(Failure.validationFailure(
        field: 'qibla_accuracy',
        message: 'Failed to validate Qibla accuracy: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> getLocationName({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // For now, return coordinates as location name
      // In production, you would use a reverse geocoding service
      return Right('${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}');
    } catch (e) {
      return Right('${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}');
    }
  }

  @override
  Future<Either<Failure, void>> cacheQiblaDirection(QiblaDirection direction) async {
    try {
      await _localStorage.saveQiblaDirection(direction);
      return const Right(null);
    } catch (e) {
      return Left(Failure.cacheFailure(
        message: 'Failed to cache Qibla direction: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, QiblaDirection?>> getCachedQiblaDirection() async {
    try {
      final cached = await _localStorage.getLatestQiblaDirection();
      return Right(cached);
    } catch (e) {
      return Left(Failure.cacheFailure(
        message: 'Failed to get cached Qibla direction: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await _localStorage.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(Failure.cacheFailure(
        message: 'Failed to clear cache: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, List<QiblaDirection>>> getQiblaHistory({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final history = await _localStorage.getQiblaHistory(fromDate, toDate);
      return Right(history);
    } catch (e) {
      return Left(Failure.cacheFailure(
        message: 'Failed to get Qibla history: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> exportQiblaData({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final history = await getQiblaHistory(fromDate: fromDate, toDate: toDate);
      
      return history.fold(
        Left.new,
        (qiblaDirections) {
          // Create CSV format export
          final csvData = StringBuffer();
          csvData.writeln('Date,Time,Bearing,Distance,Accuracy,Location');
          
          for (final direction in qiblaDirections) {
            csvData.writeln(
              '${direction.timestamp.toIso8601String().split('T')[0]},'
              '${direction.timestamp.toIso8601String().split('T')[1].split('.')[0]},'
              '${direction.formattedBearing},'
              '${direction.formattedDistance},'
              '${direction.accuracy.toStringAsFixed(1)}°,'
              '${direction.locationName ?? 'Unknown'}',
            );
          }
          
          return Right(csvData.toString());
        },
      );
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to export Qibla data: $e',
      ));
    }
  }

  // Helper methods

  double _calculateAccuracy(double latitude, double longitude) {
    // Calculate accuracy based on location accuracy and compass accuracy
    // This is a simplified calculation - in production you'd use actual sensor accuracy
    return 5.0; // Default to 5 degrees accuracy
  }

  QiblaCalibrationStatus _getCalibrationStatus() {
    final status = _sensorService.currentStatus;
    
    if (status.isCalibrating) {
      return QiblaCalibrationStatus.calibrating;
    } else if (status.isReady) {
      return QiblaCalibrationStatus.calibrated;
    } else if (status.isError) {
      return QiblaCalibrationStatus.failed;
    } else {
      return QiblaCalibrationStatus.notCalibrated;
    }
  }
}
