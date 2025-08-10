import 'package:deen_mate/core/utils/islamic_utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for Islamic utility functions
/// Ensures accurate Islamic calculations and validations
void main() {
  group('Islamic Utils Tests', () {
    group('Qibla Direction Tests', () {
      test('calculates correct Qibla direction for New York', () {
        // New York coordinates
        const latitude = 40.7128;
        const longitude = -74.0060;
        
        final qiblaDirection = IslamicUtils.calculateQiblaDirection(latitude, longitude);
        
        // Expected direction for New York to Mecca is approximately 58-60 degrees
        expect(qiblaDirection, greaterThan(55));
        expect(qiblaDirection, lessThan(65));
      });

      test('calculates correct Qibla direction for London', () {
        // London coordinates
        const latitude = 51.5074;
        const longitude = -0.1278;
        
        final qiblaDirection = IslamicUtils.calculateQiblaDirection(latitude, longitude);
        
        // Expected direction for London to Mecca is approximately 118-122 degrees
        expect(qiblaDirection, greaterThan(115));
        expect(qiblaDirection, lessThan(125));
      });

      test('calculates correct Qibla direction for Sydney', () {
        // Sydney coordinates
        const latitude = -33.8688;
        const longitude = 151.2093;
        
        final qiblaDirection = IslamicUtils.calculateQiblaDirection(latitude, longitude);
        
        // Expected direction for Sydney to Mecca is approximately 277-282 degrees
        expect(qiblaDirection, greaterThan(275));
        expect(qiblaDirection, lessThan(285));
      });

      test('returns value between 0 and 360 degrees', () {
        const testLocations = [
          [0.0, 0.0],      // Equator, Prime Meridian
          [90.0, 0.0],     // North Pole
          [-90.0, 0.0],    // South Pole
          [0.0, 180.0],    // Opposite side of Earth
          [21.4225, 39.8262], // Mecca itself
        ];

        for (final location in testLocations) {
          final qiblaDirection = IslamicUtils.calculateQiblaDirection(
            location[0], 
            location[1],
          );
          
          expect(qiblaDirection, greaterThanOrEqualTo(0));
          expect(qiblaDirection, lessThan(360));
        }
      });
    });

    group('Distance to Kaaba Tests', () {
      test('calculates correct distance from New York to Kaaba', () {
        const latitude = 40.7128;
        const longitude = -74.0060;
        
        final distance = IslamicUtils.calculateDistanceToKaaba(latitude, longitude);
        
        // Expected distance is approximately 11,000-12,000 km
        expect(distance, greaterThan(10500));
        expect(distance, lessThan(12500));
      });

      test('calculates zero distance for Kaaba coordinates', () {
        const latitude = 21.4225;
        const longitude = 39.8262;
        
        final distance = IslamicUtils.calculateDistanceToKaaba(latitude, longitude);
        
        // Should be very close to zero (within 1 km due to precision)
        expect(distance, lessThan(1));
      });

      test('calculates reasonable distances for various locations', () {
        const testLocations = [
          [51.5074, -0.1278],  // London
          [35.6762, 139.6503], // Tokyo
          [-33.8688, 151.2093], // Sydney
          [55.7558, 37.6176],  // Moscow
        ];

        for (final location in testLocations) {
          final distance = IslamicUtils.calculateDistanceToKaaba(
            location[0], 
            location[1],
          );
          
          // All distances should be reasonable (less than half Earth's circumference)
          expect(distance, greaterThan(0));
          expect(distance, lessThan(20000)); // Less than half Earth's circumference
        }
      });
    });

    group('Zakat Calculation Tests', () {
      test('calculates correct Zakat amount', () {
        const wealth = 10000.0;
        final zakatAmount = IslamicUtils.calculateZakat(wealth);
        
        expect(zakatAmount, equals(250.0)); // 2.5% of 10000
      });

      test('calculates Zakat for different wealth amounts', () {
        const testAmounts = [
          [1000.0, 25.0],
          [5000.0, 125.0],
          [50000.0, 1250.0],
          [100000.0, 2500.0],
        ];

        for (final test in testAmounts) {
          final zakatAmount = IslamicUtils.calculateZakat(test[0]);
          expect(zakatAmount, equals(test[1]));
        }
      });
    });

    group('Nisab Calculation Tests', () {
      test('correctly determines if wealth meets gold Nisab', () {
        const goldPrice = 60.0; // USD per gram
        const goldNisabValue = 87.48 * 60.0; // 5248.8
        
        expect(IslamicUtils.meetsGoldNisab(goldPrice, 6000), isTrue);
        expect(IslamicUtils.meetsGoldNisab(goldPrice, 5000), isFalse);
        expect(IslamicUtils.meetsGoldNisab(goldPrice, goldNisabValue), isTrue);
      });

      test('correctly determines if wealth meets silver Nisab', () {
        const silverPrice = 0.80; // USD per gram
        const silverNisabValue = 612.36 * 0.80; // 489.888
        
        expect(IslamicUtils.meetsSilverNisab(silverPrice, 500), isTrue);
        expect(IslamicUtils.meetsSilverNisab(silverPrice, 400), isFalse);
        expect(IslamicUtils.meetsSilverNisab(silverPrice, silverNisabValue), isTrue);
      });

      test('returns lower of gold and silver Nisab', () {
        const goldPrice = 60.0;  // Gold Nisab: 5248.8
        const silverPrice = 0.80; // Silver Nisab: 489.888
        
        final applicableNisab = IslamicUtils.getApplicableNisab(goldPrice, silverPrice);
        
        // Should return silver Nisab as it's lower
        expect(applicableNisab, equals(612.36 * silverPrice));
        expect(applicableNisab, lessThan(87.48 * goldPrice));
      });
    });

    group('Weight Conversion Tests', () {
      test('converts kilograms to grams correctly', () {
        expect(IslamicUtils.convertToGrams(1, WeightUnit.kilograms), equals(1000.0));
        expect(IslamicUtils.convertToGrams(2.5, WeightUnit.kilograms), equals(2500.0));
      });

      test('converts ounces to grams correctly', () {
        final result = IslamicUtils.convertToGrams(1, WeightUnit.ounces);
        expect(result, closeTo(28.3495, 0.001));
      });

      test('converts tola to grams correctly', () {
        final result = IslamicUtils.convertToGrams(1, WeightUnit.tola);
        expect(result, closeTo(11.664, 0.001));
      });

      test('returns same value for grams unit', () {
        expect(IslamicUtils.convertToGrams(100, WeightUnit.grams), equals(100.0));
      });
    });

    group('Hijri Date Tests', () {
      test('getCurrentHijriDate returns valid Hijri date', () {
        final hijriDate = IslamicUtils.getCurrentHijriDate();
        
        expect(hijriDate.hYear, greaterThan(1400)); // After Islamic calendar started
        expect(hijriDate.hMonth, greaterThanOrEqualTo(1));
        expect(hijriDate.hMonth, lessThanOrEqualTo(12));
        expect(hijriDate.hDay, greaterThanOrEqualTo(1));
        expect(hijriDate.hDay, lessThanOrEqualTo(30));
      });

      test('formatHijriDateEnglish returns proper format', () {
        final hijriDate = IslamicUtils.getCurrentHijriDate();
        final formatted = IslamicUtils.formatHijriDateEnglish(hijriDate);
        
        expect(formatted, contains('AH'));
        expect(formatted, contains(hijriDate.hDay.toString()));
        expect(formatted, contains(hijriDate.hYear.toString()));
      });

      test('formatHijriDateArabic returns Arabic format', () {
        final hijriDate = IslamicUtils.getCurrentHijriDate();
        final formatted = IslamicUtils.formatHijriDateArabic(hijriDate);
        
        expect(formatted, contains(hijriDate.hDay.toString()));
        expect(formatted, contains(hijriDate.hYear.toString()));
        // Should contain Arabic month names
        expect(formatted, matches(RegExp(r'[\u0600-\u06FF]+')));
      });
    });

    group('Islamic Greeting Tests', () {
      test('getIslamicGreeting returns appropriate greeting', () {
        final greeting = IslamicUtils.getIslamicGreeting();
        
        expect(greeting, isNotEmpty);
        // Should contain Arabic text
        expect(greeting, matches(RegExp(r'[\u0600-\u06FF]+')));
      });
    });

    group('Ramadan Tests', () {
      test('isRamadan returns boolean', () {
        final isRamadan = IslamicUtils.isRamadan();
        expect(isRamadan, isA<bool>());
      });

      test('getRamadanDaysRemaining returns null when not Ramadan', () {
        // Note: This test might need adjustment based on current date
        final daysRemaining = IslamicUtils.getRamadanDaysRemaining();
        if (!IslamicUtils.isRamadan()) {
          expect(daysRemaining, isNull);
        }
      });
    });

    group('Zakat al-Fitr Tests', () {
      test('calculates Zakat al-Fitr correctly', () {
        const ricePricePerKg = 2.0;
        final zakatAlFitr = IslamicUtils.calculateZakatAlFitr(ricePricePerKg);
        
        expect(zakatAlFitr, equals(5.0)); // 2.5 kg * 2.0 per kg
      });

      test('handles different rice prices', () {
        const testPrices = [
          [1.0, 2.5],
          [3.0, 7.5],
          [5.0, 12.5],
        ];

        for (final test in testPrices) {
          final zakatAlFitr = IslamicUtils.calculateZakatAlFitr(test[0]);
          expect(zakatAlFitr, equals(test[1]));
        }
      });
    });

    group('Currency Formatting Tests', () {
      test('formatCurrencyIslamic formats correctly', () {
        const amount = 1234.56;
        const currency = 'USD';
        
        final formatted = IslamicUtils.formatCurrencyIslamic(amount, currency);
        
        expect(formatted, contains('1234.56'));
        expect(formatted, contains(currency));
      });

      test('convertToArabicNumerals converts correctly', () {
        const westernText = '1234567890';
        final arabicText = IslamicUtils.convertToArabicNumerals(westernText);
        
        expect(arabicText, equals('١٢٣٤٥٦٧٨٩٠'));
      });

      test('convertToArabicNumerals handles mixed text', () {
        const mixedText = r'Price: $123.45';
        final converted = IslamicUtils.convertToArabicNumerals(mixedText);
        
        expect(converted, equals(r'Price: $١٢٣.٤٥'));
      });
    });

    group('Islamic Name Validation Tests', () {
      test('validates Arabic names correctly', () {
        expect(IslamicUtils.isValidIslamicName('محمد'), isTrue);
        expect(IslamicUtils.isValidIslamicName('عائشة'), isTrue);
        expect(IslamicUtils.isValidIslamicName('عبد الله'), isTrue);
      });

      test('validates English Islamic names correctly', () {
        expect(IslamicUtils.isValidIslamicName('Muhammad'), isTrue);
        expect(IslamicUtils.isValidIslamicName('Aisha'), isTrue);
        expect(IslamicUtils.isValidIslamicName('Abdullah'), isTrue);
        expect(IslamicUtils.isValidIslamicName('Ali Hassan'), isTrue);
      });

      test('rejects non-Islamic names', () {
        expect(IslamicUtils.isValidIslamicName('John'), isFalse);
        expect(IslamicUtils.isValidIslamicName('Mary'), isFalse);
        expect(IslamicUtils.isValidIslamicName('123'), isFalse);
      });
    });

    group('Date Validation Tests', () {
      test('isValidFastingDate correctly identifies valid dates', () {
        // Regular day should be valid
        final regularDay = DateTime(2024, 5, 15);
        expect(IslamicUtils.isValidFastingDate(regularDay), isTrue);
        
        // Ramadan day should be valid
        final ramadanDay = DateTime(2024, 3, 15); // Example Ramadan date
        expect(IslamicUtils.isValidFastingDate(ramadanDay), isTrue);
      });
    });

    group('Basic Inheritance Tests', () {
      test('calculates inheritance shares correctly', () {
        final shares = IslamicUtils.calculateBasicInheritanceShares(
          hasSpouse: true,
          numberOfSons: 1,
          numberOfDaughters: 1,
          hasParents: true,
        );

        expect(shares, isNotEmpty);
        expect(shares.containsKey('spouse'), isTrue);
        expect(shares.containsKey('sons'), isTrue);
        expect(shares.containsKey('daughters'), isTrue);
        expect(shares.containsKey('parents'), isTrue);

        // Verify shares add up to 1.0 (100%)
        final totalShares = shares.values.fold<double>(0, (sum, share) => sum + share);
        expect(totalShares, closeTo(1.0, 0.01));
      });

      test('spouse gets correct share with children', () {
        final shares = IslamicUtils.calculateBasicInheritanceShares(
          hasSpouse: true,
          numberOfSons: 1,
          numberOfDaughters: 0,
          hasParents: false,
        );

        // Spouse should get 1/8 (0.125) when there are children
        expect(shares['spouse'], equals(0.125));
      });

      test('spouse gets correct share without children', () {
        final shares = IslamicUtils.calculateBasicInheritanceShares(
          hasSpouse: true,
          numberOfSons: 0,
          numberOfDaughters: 0,
          hasParents: false,
        );

        // Spouse should get 1/4 (0.25) when there are no children
        expect(shares['spouse'], equals(0.25));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('handles zero wealth in Zakat calculation', () {
        final zakatAmount = IslamicUtils.calculateZakat(0);
        expect(zakatAmount, equals(0.0));
      });

      test('handles negative wealth gracefully', () {
        final zakatAmount = IslamicUtils.calculateZakat(-1000);
        expect(zakatAmount, equals(-25.0)); // Mathematical result
      });

      test('handles extreme coordinates in Qibla calculation', () {
        // Should not throw exception for extreme coordinates
        expect(() => IslamicUtils.calculateQiblaDirection(90, 180), returnsNormally);
        expect(() => IslamicUtils.calculateQiblaDirection(-90, -180), returnsNormally);
      });

      test('handles zero weight conversion', () {
        expect(IslamicUtils.convertToGrams(0, WeightUnit.kilograms), equals(0.0));
      });
    });
  });
}
