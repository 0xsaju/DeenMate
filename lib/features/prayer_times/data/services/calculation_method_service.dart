import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/calculation_method.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_calculation_settings.dart';

/// Service for managing prayer calculation methods
class CalculationMethodService {
  CalculationMethodService._();
  static final CalculationMethodService instance = CalculationMethodService._();

  /// Get all available calculation methods
  List<CalculationMethod> getAllMethods() {
    return CalculationMethod.values.toList();
  }

  /// Get calculation method by ID
  CalculationMethod? getMethodById(String id) {
    return CalculationMethod.fromName(id);
  }

  /// Get recommended methods for a location
  List<CalculationMethod> getRecommendedMethods(Location location) {
    final recommended = <CalculationMethod>[];
    
    // Get country-specific method
    final countryMethod = CalculationMethod.getRecommendedForRegion(location.country);
    recommended.add(countryMethod);
    
    // Add regional methods
    final regionalMethods = _getRegionalMethods(location.country);
    for (final method in regionalMethods) {
      if (!recommended.any((m) => m.name == method.name)) {
        recommended.add(method);
      }
    }
    
    // Add worldwide methods if not already included
    final worldwideMethods = _getWorldwideMethods();
    for (final method in worldwideMethods) {
      if (!recommended.any((m) => m.name == method.name)) {
        recommended.add(method);
      }
    }
    
    // Always include MWL as fallback
    if (!recommended.any((m) => m.name == 'mwl')) {
      recommended.add(CalculationMethod.mwl);
    }
    
    return recommended;
  }

  /// Get regional methods for a country
  List<CalculationMethod> _getRegionalMethods(String country) {
    switch (country.toLowerCase()) {
      case 'saudi arabia':
      case 'united arab emirates':
      case 'qatar':
      case 'bahrain':
      case 'kuwait':
      case 'oman':
        return [CalculationMethod.makkah, CalculationMethod.mwl];
      case 'united states':
      case 'canada':
        return [CalculationMethod.isna, CalculationMethod.mwl];
      case 'egypt':
        return [CalculationMethod.egypt, CalculationMethod.mwl];
      case 'pakistan':
      case 'bangladesh':
      case 'india':
        return [CalculationMethod.karachi, CalculationMethod.mwl];
      case 'iran':
        return [CalculationMethod.tehran, CalculationMethod.jafari];
      case 'france':
        return [CalculationMethod.mwl, CalculationMethod.isna];
      default:
        return [CalculationMethod.mwl];
    }
  }

  /// Get worldwide methods
  List<CalculationMethod> _getWorldwideMethods() {
    return [CalculationMethod.mwl, CalculationMethod.isna];
  }

  /// Create prayer calculation settings from method
  PrayerCalculationSettings createSettingsFromMethod(
    CalculationMethod method,
    Location location,
  ) {
    return PrayerCalculationSettings(
      calculationMethod: method.name,
      madhab: Madhab.shafi, // Default to Shafi
      adjustments: const {},
      highLatitudeRule: HighLatitudeRule.middleOfNight,
      isDST: false,
    );
  }

  /// Compare two calculation methods
  Map<String, dynamic> compareMethod(CalculationMethod method, Location location) {
    final isRegional = _isRegionalMethod(method, location);
    final isWorldwide = _isWorldwideMethod(method);
    
    return {
      'method': method.displayName,
      'region': isRegional ? location.country : 'Worldwide',
      'description': 'Standard calculation method',
      'fajrAngle': method.fajrAngle,
      'ishaAngle': method.ishaAngle,
      'ishaInterval': method.ishaInterval,
      'organization': method.organization,
      'isCustom': method.isCustom,
      'isRecommended': isRegional || isWorldwide,
      'regionalMatch': isRegional,
      'suitability': isRegional ? 95 : (isWorldwide ? 85 : 70),
    };
  }

  /// Get method description
  String getMethodDescription(CalculationMethod method, Location location) {
    final buffer = StringBuffer(method.displayName);
    
    // Add regional information
    final isRegional = _isRegionalMethod(method, location);
    final isWorldwide = _isWorldwideMethod(method);
    
    if (isRegional) {
      buffer.write('\n\nRecommended for ${location.country}');
    } else if (isWorldwide) {
      buffer.write('\n\nWorldwide standard method');
    }
    
    // Add method-specific information
    switch (method) {
      case CalculationMethod.makkah:
        buffer.write('\n\nUsed in Saudi Arabia and Gulf countries');
        buffer.write('\nIsha: 90 minutes after Maghrib');
        break;
      case CalculationMethod.isna:
        buffer.write('\n\nUsed in North America');
        buffer.write('\nFajr: 15°, Isha: 15°');
        break;
      case CalculationMethod.egypt:
        buffer.write('\n\nUsed in Egypt and some African countries');
        buffer.write('\nFajr: 19.5°, Isha: 17.5°');
        break;
      case CalculationMethod.karachi:
        buffer.write('\n\nUsed in Pakistan, Bangladesh, India');
        buffer.write('\nFajr: 18°, Isha: 18°');
        break;
      case CalculationMethod.tehran:
        buffer.write('\n\nUsed in Iran and some Central Asian countries');
        buffer.write('\nFajr: 17.7°, Isha: 14°');
        break;
      case CalculationMethod.jafari:
        buffer.write('\n\nUsed by Shia communities');
        buffer.write('\nFajr: 16°, Isha: 14°');
        break;
      case CalculationMethod.mwl:
        buffer.write('\n\nMost widely used method globally');
        buffer.write('\nFajr: 18°, Isha: 17°');
        break;
    }
    
    return buffer.toString();
  }

  /// Check if method is regional for location
  bool _isRegionalMethod(CalculationMethod method, Location location) {
    final regionalMethods = _getRegionalMethods(location.country);
    return regionalMethods.contains(method);
  }

  /// Check if method is worldwide
  bool _isWorldwideMethod(CalculationMethod method) {
    return method == CalculationMethod.mwl || method == CalculationMethod.isna;
  }

  /// Compare two methods
  double compareMethods(CalculationMethod method1, CalculationMethod method2) {
    // Simple comparison based on method type
    if (method1 == method2) return 1.0;
    
    // Check if both are worldwide methods
    if (_isWorldwideMethod(method1) && _isWorldwideMethod(method2)) {
      return 0.8;
    }
    
    // Check if both are regional methods
    if (!_isWorldwideMethod(method1) && !_isWorldwideMethod(method2)) {
      return 0.6;
    }
    
    return 0.3;
  }

  /// Get method recommendations for high latitudes
  List<CalculationMethod> getHighLatitudeRecommendations(Location location) {
    final recommendations = <CalculationMethod>[];
    
    if (location.latitude.abs() > 48.0) {
      // High latitude - recommend methods with better high latitude handling
      recommendations.addAll([
        CalculationMethod.mwl,
        CalculationMethod.isna,
        CalculationMethod.karachi,
      ]);
    }
    
    return recommendations;
  }

  /// Create custom calculation method
  CalculationMethod createCustomMethod({
    required String name,
    required String description,
    required double fajrAngle,
    required double ishaAngle,
    String? ishaInterval,
    String madhab = 'Standard',
  }) {
    // For now, return MWL as fallback since we can't create custom enums
    // In a real implementation, you'd need a different approach for custom methods
    return CalculationMethod.mwl;
  }
}
