import 'package:equatable/equatable.dart';

/// Islamic prayer calculation methods
enum CalculationMethod {
  mwl('Muslim World League'),
  isna('Islamic Society of North America'),
  egypt('Egyptian General Authority of Survey'),
  makkah('Umm Al-Qura University, Makkah'),
  karachi('University of Islamic Sciences, Karachi'),
  tehran('Institute of Geophysics, University of Tehran'),
  jafari('Shia Ithna Ashari, Leva Research Institute, Qum');

  const CalculationMethod(this.displayName);
  final String displayName;

  /// Get calculation method by name
  static CalculationMethod? fromName(String name) {
    try {
      return CalculationMethod.values.firstWhere((e) => e.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Get recommended method for region
  static CalculationMethod getRecommendedForRegion(String country) {
    switch (country.toLowerCase()) {
      case 'saudi arabia':
      case 'united arab emirates':
      case 'qatar':
      case 'bahrain':
      case 'kuwait':
      case 'oman':
        return CalculationMethod.makkah;
      case 'united states':
      case 'canada':
        return CalculationMethod.isna;
      case 'egypt':
        return CalculationMethod.egypt;
      case 'pakistan':
        return CalculationMethod.karachi;
      case 'iran':
        return CalculationMethod.tehran;
      default:
        return CalculationMethod.mwl;
    }
  }
}

/// High latitude calculation methods for extreme locations
enum HighLatitudeMethod {
  /// Angle-based method (default)
  angleBased('AngleBased'),
  
  /// Seventh of the day/night
  seventhOfDay('SeventhOfDay'),
  
  /// Twilight angle method
  twilightAngle('TwilightAngle'),
  
  /// Middle of the night
  middleOfNight('MiddleOfNight');

  const HighLatitudeMethod(this.value);
  final String value;

  String get description {
    switch (this) {
      case HighLatitudeMethod.angleBased:
        return 'Standard angle-based calculation';
      case HighLatitudeMethod.seventhOfDay:
        return 'Divide night into seven parts';
      case HighLatitudeMethod.twilightAngle:
        return 'Use twilight angle for calculation';
      case HighLatitudeMethod.middleOfNight:
        return 'Calculate based on middle of night';
    }
  }
}
