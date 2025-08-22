import 'package:flutter/material.dart';

// Legacy AppTheme class for backward compatibility during migration
class AppTheme {
  // Legacy color constants - now use ThemeHelper instead
  static const Color islamicGreen = Color(0xFF2E7D32);
  static const Color lightIslamicGreen = Color(0xFF4CAF50);
  static const Color prayerBlue = Color(0xFF1565C0);
  static const Color lightPrayerBlue = Color(0xFF42A5F5);
  static const Color zakatGold = Color(0xFFFF8F00);
  static const Color lightZakatGold = Color(0xFFFFB74D);
  static const Color duaBrown = Color(0xFF5D4037);
  static const Color lightDuaBrown = Color(0xFF8D6E63);
  static const Color quranPurple = Color(0xFF7B1FA2);
  static const Color lightQuranPurple = Color(0xFFBA68C8);

  // Legacy theme getters - now use ThemeHelper instead
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF9BB6AB),
          secondary: Color(0xFF378E67),
          surface: Color(0xFFFFFFFF),
          background: Color(0xFFF5F8F7),
          onPrimary: Color(0xFF000000),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: Color(0xFF54655F),
          onBackground: Color(0xFF54655F),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF07582C),
          secondary: Color(0xFF378E67),
          surface: Color(0xFF001A0F),
          background: Color(0xFF000B06),
          onPrimary: Color(0xFF9BB6AB),
          onSecondary: Color(0xFF9BB6AB),
          onSurface: Color(0xFF9BB6AB),
          onBackground: Color(0xFF9BB6AB),
        ),
      );

  // Legacy color methods - now use ThemeHelper instead
  static Color getPrayerColor(String prayer, {bool isDark = false}) {
    // This is a fallback - prefer using ThemeHelper.getPrayerColor(context, prayer)
    switch (prayer.toLowerCase()) {
      case 'fajr':
      case 'ফজর':
        return isDark ? lightIslamicGreen : islamicGreen;
      case 'dhuhr':
      case 'যুহর':
        return isDark ? lightZakatGold : zakatGold;
      case 'asr':
      case 'আসর':
        return isDark ? lightQuranPurple : quranPurple;
      case 'maghrib':
      case 'মাগরিব':
        return isDark ? const Color(0xFFEF5350) : const Color(0xFFD84315);
      case 'isha':
      case 'ইশা':
        return isDark ? lightDuaBrown : duaBrown;
      default:
        return isDark ? lightIslamicGreen : islamicGreen;
    }
  }

  static Color getPrayerBackgroundColor(String prayer, {bool isDark = false}) {
    final baseColor = getPrayerColor(prayer, isDark: isDark);
    return baseColor.withOpacity(isDark ? 0.2 : 0.1);
  }

  static Color getFeatureColor(String feature, {bool isDark = false}) {
    switch (feature.toLowerCase()) {
      case 'zakat':
      case 'যাকাত':
        return isDark ? lightIslamicGreen : islamicGreen;
      case 'prayer':
      case 'নামাজ':
        return isDark ? lightPrayerBlue : prayerBlue;
      case 'qibla':
      case 'কিবলা':
        return isDark ? lightZakatGold : zakatGold;
      case 'islamic':
      case 'ইসলামিক':
        return isDark ? lightQuranPurple : quranPurple;
      case 'dua':
      case 'দোয়া':
        return isDark ? lightDuaBrown : duaBrown;
      default:
        return isDark ? lightIslamicGreen : islamicGreen;
    }
  }
}

// Legacy AppColors class for backward compatibility
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color accent;
  final Color alertPill;
  final Color headerPrimary;
  final Color headerSecondary;

  const AppColors({
    required this.background,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.accent,
    required this.alertPill,
    required this.headerPrimary,
    required this.headerSecondary,
  });

  static const AppColors light = AppColors(
    background: Color(0xFFF5F8F7),
    card: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF54655F),
    textSecondary: Color(0xFF54655F),
    divider: Color(0xFFE8F2ED),
    accent: Color(0xFF9BB6AB),
    alertPill: Color(0xFFE8F2ED),
    headerPrimary: Color(0xFF54655F),
    headerSecondary: Color(0xFF54655F),
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF000B06),
    card: Color(0xFF001A0F),
    textPrimary: Color(0xFF9BB6AB),
    textSecondary: Color(0xFF54655F),
    divider: Color(0xFF1A4A2F),
    accent: Color(0xFF07582C),
    alertPill: Color(0xFF0A3D1F),
    headerPrimary: Color(0xFF9BB6AB),
    headerSecondary: Color(0xFF54655F),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? accent,
    Color? alertPill,
    Color? headerPrimary,
    Color? headerSecondary,
  }) {
    return AppColors(
      background: background ?? this.background,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      accent: accent ?? this.accent,
      alertPill: alertPill ?? this.alertPill,
      headerPrimary: headerPrimary ?? this.headerPrimary,
      headerSecondary: headerSecondary ?? this.headerSecondary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      alertPill: Color.lerp(alertPill, other.alertPill, t)!,
      headerPrimary: Color.lerp(headerPrimary, other.headerPrimary, t)!,
      headerSecondary: Color.lerp(headerSecondary, other.headerSecondary, t)!,
    );
  }
}
