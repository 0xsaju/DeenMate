import 'package:geolocator/geolocator.dart';

/// Abstract interface for location services
abstract class LocationService {
  Future<Position> getCurrentPosition();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<bool> isLocationServiceEnabled();
  Stream<Position> getPositionStream();
}

/// Implementation of LocationService using geolocator package
class LocationServiceImpl implements LocationService {
  
  @override
  Future<Position> getCurrentPosition() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get current position
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }
  
  @override
  Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }
  
  @override
  Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }
  
  @override
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }
  
  @override
  Stream<Position> getPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Update every 100 meters
    );
    
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
