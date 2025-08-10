import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:dio/dio.dart';
import 'dart:async';

import '../../../../core/error/failures.dart';
import '../../domain/entities/location.dart' as prayer_location;

/// Service for handling GPS location and geocoding operations
/// Provides accurate location data for Islamic prayer time calculations
class LocationService {
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100, // Update every 100 meters
    timeLimit: Duration(seconds: 15),
  );

  /// Get current GPS location with Islamic context
  Future<prayer_location.Location> getCurrentLocation() async {
    try {
      // Check and request permissions
      await _ensureLocationPermissions();

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const Failure.locationServiceDisabled(
          message: 'Location services are disabled. Please enable them for accurate prayer times.',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Get address information
      final placemarks = await _getPlacemarks(position.latitude, position.longitude);
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;

      // Determine timezone
      final timezone = await _determineTimezone(position.latitude, position.longitude);

      return prayer_location.Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: placemark?.locality ?? placemark?.subAdministrativeArea ?? 'Unknown',
        country: placemark?.country ?? 'Unknown',
        timezone: timezone,
        address: _formatAddress(placemark),
        elevation: position.altitude,
        district: placemark?.subLocality ?? placemark?.thoroughfare,
        region: placemark?.administrativeArea,
      );
    } on LocationServiceDisabledException {
      throw const Failure.locationServiceDisabled();
    } on PermissionDeniedException {
      throw const Failure.locationPermissionDenied();
    } on TimeoutException {
      throw const Failure.timeoutFailure(
        message: 'Location request timed out. Please check your GPS signal.',
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure.locationUnavailable(
        message: 'Failed to get current location: ${e.toString()}',
      );
    }
  }

  /// Get location from coordinates
  Future<prayer_location.Location> getLocationFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Validate coordinates
      if (latitude < -90 || latitude > 90) {
        throw const Failure.validationFailure(
          field: 'latitude',
          message: 'Latitude must be between -90 and 90 degrees',
        );
      }

      if (longitude < -180 || longitude > 180) {
        throw const Failure.validationFailure(
          field: 'longitude',
          message: 'Longitude must be between -180 and 180 degrees',
        );
      }

      // Get address information
      final placemarks = await _getPlacemarks(latitude, longitude);
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;

      // Determine timezone
      final timezone = await _determineTimezone(latitude, longitude);

      return prayer_location.Location(
        latitude: latitude,
        longitude: longitude,
        city: placemark?.locality ?? placemark?.subAdministrativeArea ?? 'Unknown',
        country: placemark?.country ?? 'Unknown',
        timezone: timezone,
        address: _formatAddress(placemark),
        district: placemark?.subLocality ?? placemark?.thoroughfare,
        region: placemark?.administrativeArea,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure.locationUnavailable(
        message: 'Failed to get location from coordinates: ${e.toString()}',
      );
    }
  }

  /// Search locations by city name or address
  Future<List<prayer_location.Location>> searchLocations(String query) async {
    try {
      if (query.trim().isEmpty) {
        throw const Failure.validationFailure(
          field: 'query',
          message: 'Search query cannot be empty',
        );
      }

      final locations = await geocoding.locationFromAddress(query);
      final results = <prayer_location.Location>[];

      for (final location in locations) {
        final placemarks = await _getPlacemarks(location.latitude, location.longitude);
        final placemark = placemarks.isNotEmpty ? placemarks.first : null;
        
        results.add(prayer_location.Location(
          latitude: location.latitude,
          longitude: location.longitude,
          country: placemark?.country ?? '',
          city: placemark?.locality ?? '',
          address: _formatAddress(placemark),
        ));
      }

      if (results.isEmpty) {
        throw Failure.locationUnavailable(
          message: 'No locations found for "$query"',
        );
      }

      return results;
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure.locationUnavailable(
        message: 'Failed to search locations: ${e.toString()}',
      );
    }
  }

  /// Get distance between two locations in kilometers
  double getDistanceBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convert meters to kilometers
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always || 
             permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Get location accuracy information
  Future<LocationAccuracyStatus> getLocationAccuracy() async {
    try {
      final permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        return LocationAccuracyStatus.denied;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationAccuracyStatus.disabled;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      if (position.accuracy <= 10) {
        return LocationAccuracyStatus.high;
      } else if (position.accuracy <= 50) {
        return LocationAccuracyStatus.medium;
      } else {
        return LocationAccuracyStatus.low;
      }
    } catch (e) {
      return LocationAccuracyStatus.unavailable;
    }
  }

  /// Listen to location changes for live prayer time updates
  Stream<prayer_location.Location> watchLocation() {
    return Geolocator.getPositionStream(locationSettings: _locationSettings)
        .asyncMap((position) async {
      try {
        final placemarks = await _getPlacemarks(position.latitude, position.longitude);
        final placemark = placemarks.isNotEmpty ? placemarks.first : null;
        final timezone = await _determineTimezone(position.latitude, position.longitude);

        return prayer_location.Location(
          latitude: position.latitude,
          longitude: position.longitude,
          city: placemark?.locality ?? placemark?.subAdministrativeArea ?? 'Unknown',
          country: placemark?.country ?? 'Unknown',
          timezone: timezone,
          address: _formatAddress(placemark),
          elevation: position.altitude,
          district: placemark?.subLocality ?? placemark?.thoroughfare,
          region: placemark?.administrativeArea,
        );
      } catch (e) {
        // Return basic location if geocoding fails
        return prayer_location.Location(
          latitude: position.latitude,
          longitude: position.longitude,
          city: 'Current Location',
          country: 'Unknown',
          timezone: 'UTC',
          elevation: position.altitude,
        );
      }
    });
  }

  /// Validate if coordinates are within valid prayer time calculation range
  bool isValidForPrayerTimes(double latitude, double longitude) {
    // Check for extreme latitudes where prayer time calculation becomes problematic
    if (latitude.abs() > 65) {
      return false;
    }

    // Check for valid coordinate ranges
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      return false;
    }

    return true;
  }

  /// Get Islamic location context (e.g., if it's a Muslim-majority country)
  Future<prayer_location.LocationContext> getIslamicLocationContext(prayer_location.Location location) async {
    try {
      // List of Muslim-majority countries (simplified)
      const muslimMajorityCountries = {
        'Afghanistan', 'Albania', 'Algeria', 'Azerbaijan', 'Bahrain', 'Bangladesh',
        'Brunei', 'Burkina Faso', 'Chad', 'Comoros', 'Djibouti', 'Egypt',
        'Gambia', 'Guinea', 'Indonesia', 'Iran', 'Iraq', 'Jordan', 'Kazakhstan',
        'Kuwait', 'Kyrgyzstan', 'Lebanon', 'Libya', 'Malaysia', 'Maldives',
        'Mali', 'Mauritania', 'Morocco', 'Niger', 'Oman', 'Pakistan',
        'Palestine', 'Qatar', 'Saudi Arabia', 'Senegal', 'Sierra Leone',
        'Somalia', 'Sudan', 'Syria', 'Tajikistan', 'Tunisia', 'Turkey',
        'Turkmenistan', 'United Arab Emirates', 'Uzbekistan', 'Yemen',
      };

      final isMuslimMajority = muslimMajorityCountries.contains(location.country);
      
      // Determine if it's close to Mecca (within 100km)
      const meccaLatitude = 21.4225;
      const meccaLongitude = 39.8262;
      
      final distanceToMecca = getDistanceBetween(
        startLatitude: location.latitude,
        startLongitude: location.longitude,
        endLatitude: meccaLatitude,
        endLongitude: meccaLongitude,
      );

      final isNearMecca = distanceToMecca <= 100;

      return prayer_location.LocationContext(
        location: location,
        islamicRegion: 'Unknown',
        timezone: location.timezone ?? 'UTC+0',
        elevation: location.elevation ?? 0.0,
        qiblaDirection: null,
        isMuslimMajority: isMuslimMajority,
      );
    } catch (e) {
      return prayer_location.LocationContext(
        location: location,
        islamicRegion: 'Unknown',
        timezone: location.timezone ?? 'UTC+0',
        elevation: location.elevation ?? 0.0,
        qiblaDirection: null,
        isMuslimMajority: false,
      );
    }
  }

  // Private helper methods

  /// Ensure location permissions are granted
  Future<void> _ensureLocationPermissions() async {
    var permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const Failure.locationPermissionDenied(
          message: 'Location permissions are denied. Please grant location access for accurate prayer times.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const Failure.locationPermissionDenied(
        message: 'Location permissions are permanently denied. Please enable them in device settings.',
      );
    }
  }

  /// Get placemarks with error handling
  Future<List<geocoding.Placemark>> _getPlacemarks(double latitude, double longitude) async {
    try {
      return await geocoding.placemarkFromCoordinates(latitude, longitude);
    } catch (e) {
      // Return empty list if geocoding fails
      return [];
    }
  }

  /// Format address from placemark
  String _formatAddress(geocoding.Placemark? placemark) {
    if (placemark == null) return 'Unknown Location';

    final parts = <String>[];
    
    if (placemark.name != null && placemark.name!.isNotEmpty) {
      parts.add(placemark.name!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      parts.add(placemark.country!);
    }

    return parts.join(', ');
  }

  /// Determine timezone (simplified implementation)
  Future<String> _determineTimezone(double latitude, double longitude) async {
    // This is a simplified timezone detection
    // In production, you'd use a proper timezone detection service
    
    // Rough timezone calculation based on longitude
    final timezoneOffset = (longitude / 15).round();
    
    if (timezoneOffset >= 0) {
      return 'UTC+$timezoneOffset';
    } else {
      return 'UTC$timezoneOffset';
    }
  }

  /// Get recommended calculation method based on country
  String _getRecommendedCalculationMethod(String country) {
    switch (country.toLowerCase()) {
      case 'saudi arabia':
      case 'united arab emirates':
      case 'qatar':
      case 'bahrain':
      case 'kuwait':
      case 'oman':
        return 'MAKKAH'; // Umm Al-Qura University, Makkah
      
      case 'egypt':
      case 'libya':
      case 'sudan':
        return 'EGYPT'; // Egyptian General Authority of Survey
      
      case 'pakistan':
      case 'india':
      case 'bangladesh':
        return 'KARACHI'; // University of Islamic Sciences, Karachi
      
      case 'iran':
        return 'TEHRAN'; // Institute of Geophysics, University of Tehran
      
      case 'united states':
      case 'canada':
        return 'ISNA'; // Islamic Society of North America
      
      case 'singapore':
        return 'SINGAPORE';
      
      case 'dubai':
        return 'DUBAI';
      
      default:
        return 'MWL'; // Muslim World League (default)
    }
  }
}

/// Location accuracy status for prayer time calculations
enum LocationAccuracyStatus {
  high,     // < 10 meters accuracy
  medium,   // 10-50 meters accuracy
  low,      // > 50 meters accuracy
  denied,   // Permission denied
  disabled, // Location services disabled
  unavailable, // Cannot determine
}

/// Islamic context for a location
class LocationContext {

  const LocationContext({
    required this.location,
    required this.islamicRegion,
    required this.timezone,
    required this.elevation,
    required this.qiblaDirection,
    required this.isMuslimMajority,
  });

  factory LocationContext.fromJson(Map<String, dynamic> json) {
    return LocationContext(
      location: json['location'] as prayer_location.Location,
      islamicRegion: json['islamicRegion'] ?? 'Unknown',
      timezone: json['timezone'] ?? 'UTC',
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0.0,
      qiblaDirection: json['qiblaDirection'],
      isMuslimMajority: json['isMuslimMajority'] ?? false,
    );
  }
  final prayer_location.Location location;
  final String islamicRegion;
  final String timezone;
  final double elevation;
  final double? qiblaDirection;
  final bool isMuslimMajority;

  Map<String, dynamic> toJson() => {
    'location': location.toJson(),
    'islamicRegion': islamicRegion,
    'timezone': timezone,
    'elevation': elevation,
    'qiblaDirection': qiblaDirection,
    'isMuslimMajority': isMuslimMajority,
  };
}
