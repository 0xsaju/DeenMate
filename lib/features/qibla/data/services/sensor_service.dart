import 'dart:async';
import 'dart:math';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/qibla_direction.dart';

/// Service for handling device sensors (compass, GPS) and calculating Qibla direction
/// Implements Islamic-compliant calculations and error handling
class SensorService {
  SensorService();

  // Stream controllers for sensor data
  final StreamController<QiblaCompassEvent> _compassController = StreamController.broadcast();
  final StreamController<LocationEvent> _locationController = StreamController.broadcast();
  final StreamController<SensorData> _sensorDataController = StreamController.broadcast();
  final StreamController<SensorStatus> _statusController = StreamController.broadcast();

  // Stream subscriptions
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _locationSubscription;

  // Current state
  SensorStatus _currentStatus = SensorStatus.initializing;
  SensorData? _currentSensorData;
  bool _isInitialized = false;

  // Getters
  Stream<QiblaCompassEvent> get compassStream => _compassController.stream;
  Stream<LocationEvent> get locationStream => _locationController.stream;
  Stream<SensorData> get sensorDataStream => _sensorDataController.stream;
  Stream<SensorStatus> get statusStream => _statusController.stream;
  SensorStatus get currentStatus => _currentStatus;
  SensorData? get currentSensorData => _currentSensorData;

  /// Initialize sensors and start monitoring
  Future<void> initialize() async {
    try {
      _updateStatus(SensorStatus.initializing);

      // Check permissions
      final locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested != LocationPermission.whileInUse && 
            requested != LocationPermission.always) {
          _updateStatus(SensorStatus.permissionDenied);
          return;
        }
      }

      // Check if location services are enabled
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        _updateStatus(SensorStatus.locationDisabled);
        return;
      }

      // Initialize compass
      await _initializeCompass();

      // Initialize location
      await _initializeLocation();

      _isInitialized = true;
      _updateStatus(SensorStatus.ready);
    } catch (e) {
      _updateStatus(SensorStatus.error('Initialization failed: $e'));
    }
  }

  /// Initialize compass sensor
  Future<void> _initializeCompass() async {
    try {
      // Check if compass is available
      final compassStream = FlutterCompass.events;
      if (compassStream == null) {
        _updateStatus(SensorStatus.compassUnavailable);
        return;
      }

      final compassAvailability = await compassStream.first;
      if (compassAvailability.heading == null) {
        _updateStatus(SensorStatus.compassUnavailable);
        return;
      }

      // Start listening to compass events
      _compassSubscription = compassStream.listen((event) {
        if (event.heading != null) {
          final compassEvent = QiblaCompassEvent(
            heading: event.heading!,
            accuracy: event.accuracy ?? 0.0,
            timestamp: DateTime.now(),
          );
          _compassController.add(compassEvent);
          _updateSensorData();
        }
      });
    } catch (e) {
      _updateStatus(SensorStatus.compassUnavailable);
    }
  }

  /// Initialize location sensor
  Future<void> _initializeLocation() async {
    try {
      // Get initial position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final locationEvent = LocationEvent(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp,
      );

      _locationController.add(locationEvent);

      // Start listening to location updates
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((position) {
        final locationEvent = LocationEvent(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          speed: position.speed,
          heading: position.heading,
          timestamp: position.timestamp,
        );

        _locationController.add(locationEvent);
        _updateSensorData();
      });
    } catch (e) {
      _updateStatus(SensorStatus.error('Location initialization failed: $e'));
    }
  }

  /// Calibrate compass sensor
  Future<void> calibrateCompass() async {
    try {
      _updateStatus(SensorStatus.calibrating);

      // Perform figure-8 calibration pattern
      await _performCompassCalibration();

      _updateStatus(SensorStatus.ready);
    } catch (e) {
      _updateStatus(SensorStatus.error('Calibration failed: $e'));
    }
  }

  /// Perform compass calibration using figure-8 pattern
  Future<void> _performCompassCalibration() async {
    // This is a simplified calibration - in production you'd implement
    // a proper figure-8 calibration pattern with user guidance
    await Future.delayed(const Duration(seconds: 3));
  }

  /// Get current sensor data
  Future<SensorData> getCurrentSensorData() async {
    if (_currentSensorData != null) {
      return _currentSensorData!;
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // Calculate Qibla direction
    final qiblaDirection = calculateQiblaDirection(
      position.latitude,
      position.longitude,
    );

    // Get compass heading
    final compassStream = FlutterCompass.events;
    if (compassStream == null) {
      throw Exception('Compass not available');
    }

    final compassEvent = await compassStream.first;
    final compassHeading = compassEvent.heading ?? 0.0;

    final sensorData = SensorData(
      compassHeading: compassHeading,
      location: LocationEvent(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp,
      ),
      qiblaDirection: qiblaDirection,
      accuracy: _calculateAccuracy(position.accuracy, compassEvent.accuracy ?? 0.0),
      isCalibrated: _currentStatus.isReady,
      timestamp: DateTime.now(),
    );

    _currentSensorData = sensorData;
    return sensorData;
  }

  /// Update sensor data when new readings are available
  void _updateSensorData() {
    if (!_isInitialized) return;

    // This would be called when new compass or location data is available
    // For now, we'll just update the timestamp
    if (_currentSensorData != null) {
      _currentSensorData = SensorData(
        compassHeading: _currentSensorData!.compassHeading,
        location: _currentSensorData!.location,
        qiblaDirection: _currentSensorData!.qiblaDirection,
        accuracy: _currentSensorData!.accuracy,
        isCalibrated: _currentStatus.isReady,
        timestamp: DateTime.now(),
      );

      _sensorDataController.add(_currentSensorData!);
    }
  }

  /// Update status and notify listeners
  void _updateStatus(SensorStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// Calculate accuracy based on location and compass accuracy
  double _calculateAccuracy(double locationAccuracy, double compassAccuracy) {
    // Combine location and compass accuracy
    // This is a simplified calculation
    return max(locationAccuracy / 1000, compassAccuracy); // Convert meters to degrees
  }

  /// Dispose of resources
  void dispose() {
    _compassSubscription?.cancel();
    _locationSubscription?.cancel();
    _compassController.close();
    _locationController.close();
    _sensorDataController.close();
    _statusController.close();
  }

  // Static methods for calculations

  /// Calculate Qibla direction (bearing) from current location to Kaaba
  /// Uses the great circle formula for Islamic-compliant calculations
  static double calculateQiblaDirection(double latitude, double longitude) {
    // Kaaba coordinates (21.4225° N, 39.8262° E)
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;

    // Convert to radians
    final lat1 = latitude * pi / 180;
    final lon1 = longitude * pi / 180;
    final lat2 = kaabaLat * pi / 180;
    final lon2 = kaabaLon * pi / 180;

    // Calculate bearing using great circle formula
    final y = sin(lon2 - lon1) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);
    final bearing = atan2(y, x) * 180 / pi;

    // Normalize to 0-360 degrees
    return (bearing + 360) % 360;
  }

  /// Calculate distance to Kaaba in kilometers
  static double calculateDistanceToKaaba(double latitude, double longitude) {
    // Kaaba coordinates (21.4225° N, 39.8262° E)
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;

    // Convert to radians
    final lat1 = latitude * pi / 180;
    final lon1 = longitude * pi / 180;
    final lat2 = kaabaLat * pi / 180;
    final lon2 = kaabaLon * pi / 180;

    // Haversine formula for great circle distance
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Earth's radius in kilometers
    const earthRadius = 6371.0;
    return earthRadius * c;
  }

  /// Get magnetic declination for a given location
  /// This is a simplified implementation - in production you'd use a proper API
  static Future<double?> getMagneticDeclination(double latitude, double longitude) async {
    try {
      // This would typically call a magnetic declination API
      // For now, we'll return a rough estimate based on latitude
      if (latitude > 60) {
        return 15.0; // High northern latitudes
      } else if (latitude > 30) {
        return 5.0; // Mid northern latitudes
      } else if (latitude > -30) {
        return 0.0; // Equatorial region
      } else if (latitude > -60) {
        return -5.0; // Mid southern latitudes
      } else {
        return -15.0; // High southern latitudes
      }
    } catch (e) {
      return null;
    }
  }
}
