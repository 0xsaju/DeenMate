import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';

class Location extends Equatable {
  const Location({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    this.state,
    this.timezone,
    this.address,
    this.elevation,
    this.district,
    this.region,
  });

  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final String? state;
  final String? timezone;
  final String? address;
  final double? elevation;
  final String? district;
  final String? region;

  @override
  List<Object?> get props => [latitude, longitude, city, country, state, timezone, address, elevation, district, region];

  Location copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? state,
    String? timezone,
    String? address,
    double? elevation,
    String? district,
    String? region,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      state: state ?? this.state,
      timezone: timezone ?? this.timezone,
      address: address ?? this.address,
      elevation: elevation ?? this.elevation,
      district: district ?? this.district,
      region: region ?? this.region,
    );
  }

  // JSON serialization methods
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      state: json['state'],
      timezone: json['timezone'],
      address: json['address'],
      elevation: json['elevation']?.toDouble(),
      district: json['district'],
      region: json['region'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'state': state,
      'timezone': timezone,
      'address': address,
      'elevation': elevation,
      'district': district,
      'region': region,
    };
  }
}

/// Location context for Islamic calculations
class LocationContext {
  const LocationContext({
    required this.location,
    required this.islamicRegion,
    required this.timezone,
    required this.elevation,
    this.qiblaDirection,
    this.isMuslimMajority = false,
  });

  final Location location;
  final String islamicRegion;
  final String timezone;
  final double elevation;
  final double? qiblaDirection;
  final bool isMuslimMajority;
}

/// Location state for UI management
abstract class LocationState {
  const LocationState();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  const LocationLoaded(this.location);
  final Location location;
}

class LocationError extends LocationState {
  const LocationError(this.failure);
  final Failure failure;
}

// Factory methods for LocationState
extension LocationStateFactory on LocationState {
  static const LocationState loading = LocationLoading();
  
  static LocationState loaded(Location location) => LocationLoaded(location);
  
  static LocationState error(Failure failure) => LocationError(failure);
}
