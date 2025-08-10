import 'dart:math' as math;

import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

/// Comprehensive Islamic utility functions for DeenMate
/// Contains calculations and helpers for Islamic practices
class IslamicUtils {
  IslamicUtils._();

  // Islamic Constants
  static const double _kaabaLatitude = 21.4225;
  static const double _kaabaLongitude = 39.8262;
  static const double _earthRadius = 6371; // km
  static const double _zakatRate = 0.025; // 2.5%
  static const double _goldNisabGrams = 87.48; // 7.5 tola
  static const double _silverNisabGrams = 612.36; // 52.5 tola

  /// Calculate Qibla direction from given coordinates
  /// Returns bearing in degrees (0-360)
  static double calculateQiblaDirection(double latitude, double longitude) {
    // Convert to radians
    final lat1 = latitude * math.pi / 180;
    const lat2 = _kaabaLatitude * math.pi / 180;
    final deltaLng = (_kaabaLongitude - longitude) * math.pi / 180;

    final y = math.sin(deltaLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - 
              math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    
    // Normalize to 0-360 degrees
    return (bearing + 360) % 360;
  }

  /// Calculate distance to Kaaba in kilometers
  static double calculateDistanceToKaaba(double latitude, double longitude) {
    return calculateHaversineDistance(
      latitude, longitude, 
      _kaabaLatitude, _kaabaLongitude,
    );
  }

  /// Calculate distance between two points using Haversine formula
  static double calculateHaversineDistance(
    double lat1, double lng1, double lat2, double lng2,
  ) {
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
              math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return _earthRadius * c;
  }

  /// Calculate Zakat amount based on total zakatable wealth
  static double calculateZakat(double totalWealth) {
    return totalWealth * _zakatRate;
  }

  /// Check if wealth meets Gold Nisab threshold
  static bool meetsGoldNisab(double goldPricePerGram, double totalWealth) {
    final goldNisabValue = _goldNisabGrams * goldPricePerGram;
    return totalWealth >= goldNisabValue;
  }

  /// Check if wealth meets Silver Nisab threshold
  static bool meetsSilverNisab(double silverPricePerGram, double totalWealth) {
    final silverNisabValue = _silverNisabGrams * silverPricePerGram;
    return totalWealth >= silverNisabValue;
  }

  /// Get the applicable Nisab (lower of gold or silver)
  static double getApplicableNisab(
    double goldPricePerGram, 
    double silverPricePerGram,
  ) {
    final goldNisabValue = _goldNisabGrams * goldPricePerGram;
    final silverNisabValue = _silverNisabGrams * silverPricePerGram;
    
    // Return the lower Nisab value (more beneficial for the poor)
    return math.min(goldNisabValue, silverNisabValue);
  }

  /// Convert different weight units to grams
  static double convertToGrams(double weight, WeightUnit unit) {
    switch (unit) {
      case WeightUnit.grams:
        return weight;
      case WeightUnit.kilograms:
        return weight * 1000;
      case WeightUnit.ounces:
        return weight * 28.3495;
      case WeightUnit.pounds:
        return weight * 453.592;
      case WeightUnit.tola:
        return weight * 11.664; // 1 tola = 11.664 grams
      case WeightUnit.masha:
        return weight * 0.972; // 1 masha = 0.972 grams
      case WeightUnit.ratti:
        return weight * 0.121; // 1 ratti = 0.121 grams
    }
  }

  /// Get current Hijri date
  static HijriCalendar getCurrentHijriDate() {
    return HijriCalendar.now();
  }

  /// Convert Gregorian to Hijri date
  static HijriCalendar gregorianToHijri(DateTime gregorianDate) {
    return HijriCalendar.fromDate(gregorianDate);
  }

  /// Convert Hijri to Gregorian date
  static DateTime hijriToGregorian(HijriCalendar hijriDate) {
    return hijriDate.hijriToGregorian(hijriDate.hYear, hijriDate.hMonth, hijriDate.hDay);
  }

  /// Format Hijri date in Arabic
  static String formatHijriDateArabic(HijriCalendar hijriDate) {
    final monthNames = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
      'جمادى الأولى', 'جمادى الثانية', 'رجب', 'شعبان',
      'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
    ];
    
    return '${hijriDate.hDay} ${monthNames[hijriDate.hMonth - 1]} ${hijriDate.hYear}';
  }

  /// Format Hijri date in English
  static String formatHijriDateEnglish(HijriCalendar hijriDate) {
    final monthNames = [
      'Muharram', 'Safar', "Rabi' al-awwal", "Rabi' al-thani",
      'Jumada al-awwal', 'Jumada al-thani', 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
    ];
    
    return '${hijriDate.hDay} ${monthNames[hijriDate.hMonth - 1]} ${hijriDate.hYear} AH';
  }

  /// Get Islamic greeting based on time of day
  static String getIslamicGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 4 && hour < 6) {
      return 'السلام عليكم ورحمة الله وبركاته'; // Standard greeting
    } else if (hour >= 6 && hour < 12) {
      return 'صباح الخير'; // Good morning
    } else if (hour >= 12 && hour < 15) {
      return 'السلام عليكم'; // Peace be upon you
    } else if (hour >= 15 && hour < 18) {
      return 'طاب مساؤكم'; // Good afternoon
    } else if (hour >= 18 && hour < 22) {
      return 'مساء الخير'; // Good evening
    } else {
      return 'تصبحون على خير'; // Good night
    }
  }

  /// Check if current month is Ramadan
  static bool isRamadan() {
    final hijriDate = getCurrentHijriDate();
    return hijriDate.hMonth == 9; // Ramadan is the 9th month
  }

  /// Get days remaining in Ramadan (if currently Ramadan)
  static int? getRamadanDaysRemaining() {
    if (!isRamadan()) return null;
    
    final hijriDate = getCurrentHijriDate();
    final ramadanDays = hijriDate.lengthOfMonth;
    return ramadanDays - hijriDate.hDay;
  }

  /// Calculate Zakat al-Fitr amount (typically in local currency)
  static double calculateZakatAlFitr(double ricePricePerKg) {
    // Approximately 2.5 kg of rice or equivalent staple food
    return 2.5 * ricePricePerKg;
  }

  /// Get names of Allah (Asma ul-Husna) - first 10
  static List<String> getAsmaulHusna() {
    return [
      'الله', // Allah
      'الرحمن', // Ar-Rahman
      'الرحيم', // Ar-Raheem
      'الملك', // Al-Malik
      'القدوس', // Al-Quddus
      'السلام', // As-Salaam
      'المؤمن', // Al-Mu'min
      'المهيمن', // Al-Muhaimin
      'العزيز', // Al-Aziz
      'الجبار', // Al-Jabbar
    ];
  }

  /// Calculate lunar age for Islamic calendar events
  static int calculateLunarAge(DateTime date) {
    // Reference: Islamic calendar epoch (July 16, 622 CE)
    final epoch = DateTime(622, 7, 16);
    final daysSinceEpoch = date.difference(epoch).inDays;
    
    // Average lunar month is 29.530588 days
    final lunarMonths = daysSinceEpoch / 29.530588;
    return (lunarMonths * 29.530588).round() % 30;
  }

  /// Validate Islamic name (basic Arabic character check)
  static bool isValidIslamicName(String name) {
    // Check for Arabic characters and common Islamic name patterns
    final arabicRegex = RegExp(r'^[\u0600-\u06FF\u0750-\u077F\s]+$');
    final englishIslamicNames = [
      'Muhammad', 'Ahmad', 'Ali', 'Hassan', 'Hussein', 'Omar', 'Usman',
      'Abu', 'Abdullah', 'Abdul', 'Fatima', 'Aisha', 'Khadija', 'Zainab',
    ];
    
    return arabicRegex.hasMatch(name) || 
           englishIslamicNames.any((islamicName) => 
             name.toLowerCase().contains(islamicName.toLowerCase()),);
  }

  /// Format currency with Islamic number system (Arabic-Indic numerals)
  static String formatCurrencyIslamic(
    double amount, 
    String currencyCode,
    {bool useArabicNumerals = false,}
  ) {
    final formatter = NumberFormat.currency(
      symbol: currencyCode,
      decimalDigits: 2,
    );
    
    var formattedAmount = formatter.format(amount);
    
    if (useArabicNumerals) {
      formattedAmount = convertToArabicNumerals(formattedAmount);
    }
    
    return formattedAmount;
  }

  /// Convert Western numerals to Arabic-Indic numerals
  static String convertToArabicNumerals(String text) {
    const westernToArabic = {
      '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
    };
    
    var result = text;
    westernToArabic.forEach((western, arabic) {
      result = result.replaceAll(western, arabic);
    });
    
    return result;
  }

  /// Get prayer time adjustment for high latitude locations
  static double getHighLatitudeAdjustment(double latitude) {
    // For locations above 48.5° latitude, use special calculations
    if (latitude.abs() > 48.5) {
      return latitude.abs() * 0.1; // Simplified adjustment
    }
    return 0;
  }

  /// Validate if date is suitable for fasting
  static bool isValidFastingDate(DateTime date) {
    final hijriDate = gregorianToHijri(date);
    
    // Cannot fast on Eid days
    final isEidAlFitr = hijriDate.hMonth == 10 && hijriDate.hDay == 1;
    final isEidAlAdha = hijriDate.hMonth == 12 && 
                       hijriDate.hDay >= 10 && hijriDate.hDay <= 13;
    
    return !isEidAlFitr && !isEidAlAdha;
  }

  /// Calculate inheritance shares according to Islamic law (basic)
  static Map<String, double> calculateBasicInheritanceShares({
    required bool hasSpouse,
    required int numberOfSons,
    required int numberOfDaughters,
    required bool hasParents,
  }) {
    final shares = <String, double>{};
    double remainingShare = 1.0; // Total inheritance share

    // Spouse share
    if (hasSpouse) {
      if (numberOfSons + numberOfDaughters > 0) {
        shares['spouse'] = 0.125; // 1/8 if there are children
      } else {
        shares['spouse'] = 0.25; // 1/4 if no children
      }
      remainingShare -= shares['spouse']!;
    }

    // Parents share
    if (hasParents) {
      if (numberOfSons + numberOfDaughters > 0) {
        shares['parents'] = 0.167; // 1/6 each if there are children
      } else {
        shares['mother'] = 0.333; // 1/3 for mother if no children
        shares['father'] = remainingShare - 0.333; // Rest for father
        return shares;
      }
      remainingShare -= shares['parents']!;
    }

    // Children shares (male gets twice the share of female)
    if (numberOfSons + numberOfDaughters > 0) {
      final totalChildShares = (numberOfSons * 2) + numberOfDaughters;
      final sharePerMaleChild = remainingShare * 2 / totalChildShares;
      final sharePerFemaleChild = remainingShare / totalChildShares;

      if (numberOfSons > 0) {
        shares['sons'] = sharePerMaleChild * numberOfSons;
      }
      if (numberOfDaughters > 0) {
        shares['daughters'] = sharePerFemaleChild * numberOfDaughters;
      }
    }

    return shares;
  }
}

/// Weight units commonly used in Islamic countries
enum WeightUnit {
  grams,
  kilograms,
  ounces,
  pounds,
  tola,   // Common in South Asia
  masha,  // Traditional unit
  ratti,  // Traditional unit
}

/// Islamic calendar months
enum HijriMonth {
  muharram(1),
  safar(2),
  rabiAlAwwal(3),
  rabiAlThani(4),
  jumadaAlAwwal(5),
  jumadaAlThani(6),
  rajab(7),
  shaban(8),
  ramadan(9),
  shawwal(10),
  dhuAlQidah(11),
  dhuAlHijjah(12);

  const HijriMonth(this.number);
  final int number;
}

/// Prayer times enumeration
enum PrayerTime {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
  midnight,
}

/// Zakat categories for calculation
enum ZakatCategory {
  cash,
  gold,
  silver,
  business,
  investment,
  rental,
  agricultural,
  livestock,
}

/// Islamic inheritance relationships
enum InheritanceRelation {
  spouse,
  son,
  daughter,
  father,
  mother,
  brother,
  sister,
  grandfather,
  grandmother,
  uncle,
  aunt,
  nephew,
  niece,
}