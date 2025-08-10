import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

/// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});

/// Location permission provider
final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  return Geolocator.checkPermission();
});

/// Current position provider
final currentPositionProvider = FutureProvider<Position>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getCurrentPosition();
});

/// Location settings provider
final locationSettingsProvider = FutureProvider<bool>((ref) async {
  return Geolocator.isLocationServiceEnabled();
});

/// Geocoding provider for getting address from coordinates
final geocodingProvider = FutureProvider.family<List<Placemark>, Position>((ref, position) async {
  return placemarkFromCoordinates(position.latitude, position.longitude);
});
