/// Qibla direction entity with comprehensive Islamic calculations
class QiblaDirection {
  final double bearing; // Bearing in degrees (0-360)
  final double accuracy; // Accuracy in degrees
  final double distance; // Distance to Kaaba in km
  final bool isCalibrated; // Whether compass is calibrated
  final QiblaCalibrationStatus calibrationStatus;
  final DateTime timestamp;
  final double? magneticDeclination; // Magnetic declination correction
  final String? locationName; // Human-readable location name
  final double? latitude; // Current latitude
  final double? longitude; // Current longitude

  const QiblaDirection({
    required this.bearing,
    required this.accuracy,
    required this.distance,
    required this.isCalibrated,
    required this.calibrationStatus,
    required this.timestamp,
    this.magneticDeclination,
    this.locationName,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'bearing': bearing,
      'accuracy': accuracy,
      'distance': distance,
      'isCalibrated': isCalibrated,
      'calibrationStatus': calibrationStatus.name,
      'timestamp': timestamp.toIso8601String(),
      'magneticDeclination': magneticDeclination,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory QiblaDirection.fromJson(Map<String, dynamic> json) {
    return QiblaDirection(
      bearing: json['bearing'] as double,
      accuracy: json['accuracy'] as double,
      distance: json['distance'] as double,
      isCalibrated: json['isCalibrated'] as bool,
      calibrationStatus: QiblaCalibrationStatus.values.firstWhere(
        (e) => e.name == json['calibrationStatus'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      magneticDeclination: json['magneticDeclination'] as double?,
      locationName: json['locationName'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }
}

/// Qibla compass event data
class QiblaCompassEvent {
  final double heading; // Compass heading in degrees
  final double accuracy; // Accuracy in degrees
  final DateTime timestamp;

  const QiblaCompassEvent({
    required this.heading,
    required this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory QiblaCompassEvent.fromJson(Map<String, dynamic> json) {
    return QiblaCompassEvent(
      heading: json['heading'] as double,
      accuracy: json['accuracy'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Location event data
class LocationEvent {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime? timestamp;

  const LocationEvent({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory LocationEvent.fromJson(Map<String, dynamic> json) {
    return LocationEvent(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double,
      altitude: json['altitude'] as double?,
      speed: json['speed'] as double?,
      heading: json['heading'] as double?,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }
}

/// Sensor data combining compass and location
class SensorData {
  final double compassHeading;
  final LocationEvent? location;
  final double qiblaDirection;
  final double accuracy;
  final bool isCalibrated;
  final DateTime? timestamp;

  const SensorData({
    required this.compassHeading,
    this.location,
    required this.qiblaDirection,
    required this.accuracy,
    required this.isCalibrated,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'compassHeading': compassHeading,
      'location': location?.toJson(),
      'qiblaDirection': qiblaDirection,
      'accuracy': accuracy,
      'isCalibrated': isCalibrated,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      compassHeading: json['compassHeading'] as double,
      location: json['location'] != null 
          ? LocationEvent.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      qiblaDirection: json['qiblaDirection'] as double,
      accuracy: json['accuracy'] as double,
      isCalibrated: json['isCalibrated'] as bool,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }
}

/// Qibla calibration status
enum QiblaCalibrationStatus {
  notCalibrated,
  calibrating,
  calibrated,
  failed,
}

/// Qibla direction accuracy levels
enum QiblaAccuracy {
  excellent, // < 5 degrees
  good, // 5-15 degrees
  fair, // 15-30 degrees
  poor, // > 30 degrees
}

/// Simple sensor status class
class SensorStatus {
  final String type;
  final String? message;

  const SensorStatus._(this.type, [this.message]);

  static const SensorStatus initializing = SensorStatus._('initializing');
  static const SensorStatus calibrating = SensorStatus._('calibrating');
  static const SensorStatus ready = SensorStatus._('ready');
  static SensorStatus error(String message) => SensorStatus._('error', message);
  static const SensorStatus permissionDenied = SensorStatus._('permissionDenied');
  static const SensorStatus locationDisabled = SensorStatus._('locationDisabled');
  static const SensorStatus compassUnavailable = SensorStatus._('compassUnavailable');

  bool get isInitializing => type == 'initializing';
  bool get isCalibrating => type == 'calibrating';
  bool get isReady => type == 'ready';
  bool get isError => type == 'error';
  bool get isPermissionDenied => type == 'permissionDenied';
  bool get isLocationDisabled => type == 'locationDisabled';
  bool get isCompassUnavailable => type == 'compassUnavailable';
}

/// Extension methods for Qibla calculations
extension QiblaDirectionExtension on QiblaDirection {
  /// Get accuracy level based on accuracy value
  QiblaAccuracy get accuracyLevel {
    if (accuracy < 5) return QiblaAccuracy.excellent;
    if (accuracy < 15) return QiblaAccuracy.good;
    if (accuracy < 30) return QiblaAccuracy.fair;
    return QiblaAccuracy.poor;
  }

  /// Get direction text for UI
  String get directionText {
    if (bearing >= 337.5 || bearing < 22.5) return 'North';
    if (bearing >= 22.5 && bearing < 67.5) return 'Northeast';
    if (bearing >= 67.5 && bearing < 112.5) return 'East';
    if (bearing >= 112.5 && bearing < 157.5) return 'Southeast';
    if (bearing >= 157.5 && bearing < 202.5) return 'South';
    if (bearing >= 202.5 && bearing < 247.5) return 'Southwest';
    if (bearing >= 247.5 && bearing < 292.5) return 'West';
    return 'Northwest';
  }

  /// Get Arabic direction text
  String get arabicDirectionText {
    switch (directionText) {
      case 'North': return 'شمال';
      case 'Northeast': return 'شمال شرق';
      case 'East': return 'شرق';
      case 'Southeast': return 'جنوب شرق';
      case 'South': return 'جنوب';
      case 'Southwest': return 'جنوب غرب';
      case 'West': return 'غرب';
      case 'Northwest': return 'شمال غرب';
      default: return 'غير محدد';
    }
  }

  /// Get Bengali direction text
  String get bengaliDirectionText {
    switch (directionText) {
      case 'North': return 'উত্তর';
      case 'Northeast': return 'উত্তর-পূর্ব';
      case 'East': return 'পূর্ব';
      case 'Southeast': return 'দক্ষিণ-পূর্ব';
      case 'South': return 'দক্ষিণ';
      case 'Southwest': return 'দক্ষিণ-পশ্চিম';
      case 'West': return 'পশ্চিম';
      case 'Northwest': return 'উত্তর-পশ্চিম';
      default: return 'অনির্দিষ্ট';
    }
  }

  /// Check if direction is accurate enough for prayer
  bool get isAccurateForPrayer => accuracyLevel == QiblaAccuracy.excellent || 
                                  accuracyLevel == QiblaAccuracy.good;

  /// Get formatted distance string
  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    } else if (distance < 1000) {
      return '${distance.toStringAsFixed(1)} km';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} thousand km';
    }
  }

  /// Get formatted bearing string
  String get formattedBearing => '${bearing.toStringAsFixed(1)}°';
}
