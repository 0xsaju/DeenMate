import 'package:flutter/material.dart';

/// Cultural color palettes for DeenMate
/// Provides Bengali and South Asian Islamic color preferences
class CulturalColors {
  CulturalColors._();

  // Primary Islamic Colors (Traditional)
  static const Color islamicGreen = Color(0xFF2E7D32);
  static const Color islamicGold = Color(0xFFFFD700);
  static const Color islamicBlue = Color(0xFF1565C0);
  static const Color islamicWhite = Color(0xFFFAF9F6);

  // Bengali Cultural Colors
  static const Color bengaliGreen = Color(0xFF006A4E); // Bangladesh flag green
  static const Color bengaliRed = Color(0xFFF42A41);   // Bangladesh flag red (accent only)
  static const Color traditionalGold = Color(0xFFDAA520); // Traditional Bengali gold
  static const Color riverBlue = Color(0xFF4682B4);     // Padma river blue
  static const Color ricePearl = Color(0xFFF5F5DC);     // Rice pearl white
  static const Color hennaOrange = Color(0xFFCD853F);   // Henna/Mehendi orange

  // South Asian Islamic Colors
  static const Color mosqueBlue = Color(0xFF2E86C1);    // Masjid dome blue
  static const Color minaretWhite = Color(0xFFF8F9FA);  // Minaret white
  static const Color calligraphyBrown = Color(0xFF5D4037); // Arabic calligraphy
  static const Color carpetRed = Color(0xFFB71C1C);     // Prayer carpet red
  static const Color incenseGold = Color(0xFFB8860B);   // Incense gold
  static const Color jasmineCream = Color(0xFFFFF8DC);  // Jasmine cream

  // Regional Variations
  static const Color dhakaMuslin = Color(0xFFF0F8FF);   // Dhaka muslin white
  static const Color sundarbansGreen = Color(0xFF228B22); // Sundarbans mangrove
  static const Color coxsBazarSand = Color(0xFFFAEBD7); // Cox's Bazar sand
  static const Color chittagongHill = Color(0xFF8FBC8F); // Chittagong hills

  // Category-specific colors (inspired by Bengali Islamic apps)
  static const Color prayerBlue = Color(0xFF3498DB);
  static const Color zakatGreen = Color(0xFF27AE60);
  static const Color quranPurple = Color(0xFF9B59B6);
  static const Color hadithOrange = Color(0xFFE67E22);
  static const Color duaBrown = Color(0xFF8D6E63);
  static const Color fastingIndigo = Color(0xFF6C5CE7);
  static const Color hajjGold = Color(0xFFF39C12);
  static const Color charityTeal = Color(0xFF1ABC9C);

  // Semantic colors with cultural context
  static const Color successGreen = Color(0xFF2ECC71);  // Success/completion
  static const Color warningOrange = Color(0xFFE74C3C); // Warning/attention
  static const Color infoBlue = Color(0xFF3498DB);      // Information/neutral
  static const Color errorRed = Color(0xFFE74C3C);      // Error/danger

  // Time-based colors for prayer times
  static const Color fajrTwilight = Color(0xFF4A90E2);  // Dawn blue
  static const Color sunriseGold = Color(0xFFFFD700);   // Sunrise gold
  static const Color dhuhrBright = Color(0xFFFFA500);   // Midday orange
  static const Color asrAfternoon = Color(0xFFFF6347);  // Afternoon orange-red
  static const Color maghribSunset = Color(0xFFFF4500); // Sunset red-orange
  static const Color ishaNight = Color(0xFF2F4F4F);     // Night dark slate

  // Gradients for Bengali cultural aesthetic
  static List<Color> get bengaliFlagGradient => [
    bengaliGreen,
    bengaliGreen.withOpacity(0.8),
  ];

  static List<Color> get islamicGreenGradient => [
    islamicGreen,
    islamicGreen.withOpacity(0.7),
  ];

  static List<Color> get sunsetGradient => [
    maghribSunset,
    asrAfternoon,
    dhuhrBright,
  ];

  static List<Color> get riverGradient => [
    riverBlue,
    riverBlue.withOpacity(0.6),
    const Color(0xFFE3F2FD),
  ];

  static List<Color> get traditionGradient => [
    traditionalGold,
    incenseGold,
    jasmineCream,
  ];

  // Color schemes for different app themes
  static ColorScheme get bengaliLightScheme => ColorScheme.fromSeed(
    seedColor: bengaliGreen,
    primary: bengaliGreen,
    secondary: traditionalGold,
    tertiary: riverBlue,
    surface: ricePearl,
    background: Colors.white,
    error: const Color(0xFFD32F2F),
  );

  static ColorScheme get bengaliDarkScheme => ColorScheme.fromSeed(
    seedColor: bengaliGreen,
    brightness: Brightness.dark,
    primary: const Color(0xFF4CAF50),
    secondary: incenseGold,
    tertiary: const Color(0xFF42A5F5),
    surface: const Color(0xFF1E1E1E),
    background: const Color(0xFF121212),
    error: const Color(0xFFFF5449),
  );

  // Category color mapping for Islamic content
  static Map<String, Color> get categoryColors => {
    'prayer': prayerBlue,
    'zakat': zakatGreen,
    'quran': quranPurple,
    'hadith': hadithOrange,
    'dua': duaBrown,
    'fasting': fastingIndigo,
    'hajj': hajjGold,
    'charity': charityTeal,
    'general': islamicGreen,
  };

  // Prayer time specific colors
  static Map<String, Color> get prayerTimeColors => {
    'fajr': fajrTwilight,
    'sunrise': sunriseGold,
    'dhuhr': dhuhrBright,
    'asr': asrAfternoon,
    'maghrib': maghribSunset,
    'isha': ishaNight,
  };

  // Helper methods for color variations
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Get color by category
  static Color getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? islamicGreen;
  }

  // Get prayer time color
  static Color getPrayerTimeColor(String prayerName) {
    return prayerTimeColors[prayerName.toLowerCase()] ?? islamicBlue;
  }

  // Create material swatch from color
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (var i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }

  // Accessibility helpers
  static bool isColorAccessible(Color foreground, Color background) {
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    final contrast = (foregroundLuminance + 0.05) / (backgroundLuminance + 0.05);
    return contrast >= 4.5; // WCAG AA standard
  }

  static Color getAccessibleTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Extension to add cultural color utilities to Color class
extension CulturalColorExtension on Color {
  /// Get a culturally appropriate text color for this background
  Color get textColor => CulturalColors.getAccessibleTextColor(this);
  
  /// Lighten this color by amount (0.0 to 1.0)
  Color lighten([double amount = 0.1]) => CulturalColors.lighten(this, amount);
  
  /// Darken this color by amount (0.0 to 1.0)
  Color darken([double amount = 0.1]) => CulturalColors.darken(this, amount);
  
  /// Check if this color is accessible against another color
  bool isAccessibleAgainst(Color other) => CulturalColors.isColorAccessible(this, other);
}
