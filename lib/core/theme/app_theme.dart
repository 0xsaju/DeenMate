import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Central theme management for DeenMate app
/// Provides Material 3 compliant light and dark themes with Islamic design elements
class AppTheme {
  // Islamic Color Palette
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

  // Neutral Colors
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color darkSurface = Color(0xFF121212);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF1A1A1A);

  // Spacing Constants
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;

  // Border Radius Constants
  static const double smallRadius = 8;
  static const double mediumRadius = 12;
  static const double largeRadius = 16;
  static const double extraLargeRadius = 24;

  // Arabic Typography
  static TextStyle get arabicHeadline => GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      );

  static TextStyle get arabicBody => GoogleFonts.amiri(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1A1A1A),
      );

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: islamicGreen,
      primary: islamicGreen,
      secondary: prayerBlue,
      tertiary: zakatGold,
      surface: lightSurface,
      background: lightBackground,
      error: const Color(0xFFD32F2F),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: const Color(0xFF1A1A1A),
      onBackground: const Color(0xFF1A1A1A),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      brightness: Brightness.light,
      extensions: const <ThemeExtension<dynamic>>[AppColors.light],

      // Typography
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        displayLarge: GoogleFonts.amiri(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onSurface,
        ),
        displayMedium: GoogleFonts.amiri(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onSurface,
        ),
        headlineLarge: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onSurface,
        ),
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onSurface,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onSurface,
        ),
        titleMedium: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: lightColorScheme.onSurface,
        ),
        titleSmall: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: lightColorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: lightColorScheme.onSurface,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: lightColorScheme.onSurface,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: lightColorScheme.onSurface.withOpacity(0.7),
        ),
        labelLarge: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: lightColorScheme.onSurface,
        ),
        labelMedium: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: lightColorScheme.onSurface,
        ),
        labelSmall: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: lightColorScheme.onSurface.withOpacity(0.7),
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(
          color: lightColorScheme.onPrimary,
          size: 24,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: lightColorScheme.surface,
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColorScheme.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.notoSans(
          color: lightColorScheme.onSurface.withOpacity(0.6),
        ),
        labelStyle: GoogleFonts.notoSans(
          color: lightColorScheme.onSurface.withOpacity(0.8),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightColorScheme.surface,
        selectedItemColor: lightColorScheme.primary,
        unselectedItemColor: lightColorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightColorScheme.primary;
          }
          return lightColorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightColorScheme.primary.withOpacity(0.5);
          }
          return lightColorScheme.outline.withOpacity(0.5);
        }),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: lightColorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: lightColorScheme.onSurface,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: lightColorScheme.surface,
        selectedColor: lightColorScheme.primary.withOpacity(0.2),
        disabledColor: lightColorScheme.onSurface.withOpacity(0.1),
        labelStyle: GoogleFonts.notoSans(
          color: lightColorScheme.onSurface,
        ),
        secondaryLabelStyle: GoogleFonts.notoSans(
          color: lightColorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: islamicGreen,
      brightness: Brightness.dark,
      primary: lightIslamicGreen,
      secondary: lightPrayerBlue,
      tertiary: lightZakatGold,
      surface: darkSurface,
      background: darkBackground,
      error: const Color(0xFFCF6679),
      onPrimary: const Color(0xFF003300),
      onSecondary: const Color(0xFF001A33),
      onTertiary: const Color(0xFF331A00),
      onSurface: const Color(0xFFE0E0E0),
      onBackground: const Color(0xFFE0E0E0),
      onError: const Color(0xFF1A0000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      brightness: Brightness.dark,
      extensions: const <ThemeExtension<dynamic>>[AppColors.dark],

      // Typography (same structure but with dark colors)
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        displayLarge: GoogleFonts.amiri(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface,
        ),
        displayMedium: GoogleFonts.amiri(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface,
        ),
        headlineLarge: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface,
        ),
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface,
        ),
        titleMedium: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkColorScheme.onSurface,
        ),
        titleSmall: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkColorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface.withOpacity(0.7),
        ),
        labelLarge: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkColorScheme.onSurface,
        ),
        labelMedium: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkColorScheme.onSurface,
        ),
        labelSmall: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: darkColorScheme.onSurface.withOpacity(0.7),
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: darkColorScheme.onSurface,
          size: 24,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: darkColorScheme.surface,
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColorScheme.primary,
          foregroundColor: darkColorScheme.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkColorScheme.primary,
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.notoSans(
          color: darkColorScheme.onSurface.withOpacity(0.6),
        ),
        labelStyle: GoogleFonts.notoSans(
          color: darkColorScheme.onSurface.withOpacity(0.8),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkColorScheme.surface,
        selectedItemColor: darkColorScheme.primary,
        unselectedItemColor: darkColorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkColorScheme.primary,
        foregroundColor: darkColorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkColorScheme.primary;
          }
          return darkColorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkColorScheme.primary.withOpacity(0.5);
          }
          return darkColorScheme.outline.withOpacity(0.5);
        }),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: darkColorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkColorScheme.onSurface,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: darkColorScheme.surface,
        selectedColor: darkColorScheme.primary.withOpacity(0.2),
        disabledColor: darkColorScheme.onSurface.withOpacity(0.1),
        labelStyle: GoogleFonts.notoSans(
          color: darkColorScheme.onSurface,
        ),
        secondaryLabelStyle: GoogleFonts.notoSans(
          color: darkColorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Get appropriate color for prayer times based on prayer type
  static Color getPrayerColor(String prayer, {bool isDark = false}) {
    switch (prayer.toLowerCase()) {
      case 'fajr':
      case 'ফজর':
        return isDark ? const Color(0xFF7986CB) : const Color(0xFF3F51B5);
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

  /// Get appropriate background color for prayer time cards
  static Color getPrayerBackgroundColor(String prayer, {bool isDark = false}) {
    final baseColor = getPrayerColor(prayer, isDark: isDark);
    return baseColor.withOpacity(isDark ? 0.2 : 0.1);
  }

  /// Islamic feature color mapping
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

/// Extension for easy theme access
extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
