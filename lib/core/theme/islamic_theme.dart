import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Islamic design system matching the app-screens design
class IslamicTheme {
  // Color palette from SVG designs
  static const Color islamicGreen = Color(0xFF2E7D32);
  static const Color islamicGreenLight = Color(0xFF4CAF50);
  static const Color prayerBlue = Color(0xFF1565C0);
  static const Color prayerBlueLight = Color(0xFF42A5F5);
  static const Color zakatGold = Color(0xFFFFD700);
  static const Color zakatGoldDark = Color(0xFFFFA000);
  static const Color quranPurple = Color(0xFF7B1FA2);
  static const Color quranPurpleLight = Color(0xFFBA68C8);
  static const Color hadithOrange = Color(0xFFFF8F00);
  static const Color hadithOrangeLight = Color(0xFFFFB74D);
  static const Color duaBrown = Color(0xFF5D4037);
  static const Color duaBrownLight = Color(0xFF8D6E63);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  
  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  
  // Gradients from SVG designs
  static const LinearGradient islamicGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [islamicGreen, islamicGreenLight],
  );
  
  static const LinearGradient prayerBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [prayerBlue, prayerBlueLight],
  );
  
  static const LinearGradient zakatGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [zakatGold, zakatGoldDark],
  );
  
  static const LinearGradient quranPurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [quranPurple, quranPurpleLight],
  );
  
  static const LinearGradient hadithOrangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [hadithOrange, hadithOrangeLight],
  );
  
  static const LinearGradient duaBrownGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [duaBrown, duaBrownLight],
  );

  // Typography system
  static TextTheme get textTheme {
    return TextTheme(
      // Headers
      displayLarge: GoogleFonts.notoSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.notoSans(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displaySmall: GoogleFonts.notoSans(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      // Headlines
      headlineLarge: GoogleFonts.notoSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      // Body text
      bodyLarge: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
      // Labels
      labelLarge: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelMedium: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: GoogleFonts.notoSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textHint,
      ),
    );
  }

  // Arabic text styles
  static TextStyle arabicLarge = const TextStyle(
    fontFamily: 'Amiri',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.5,
  );
  
  static TextStyle arabicMedium = const TextStyle(
    fontFamily: 'Amiri',
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.4,
  );
  
  static TextStyle arabicSmall = const TextStyle(
    fontFamily: 'Amiri',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.3,
  );

  // Bengali text styles
  static TextStyle bengaliLarge = const TextStyle(
    fontFamily: 'NotoSansBengali',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle bengaliMedium = const TextStyle(
    fontFamily: 'NotoSansBengali',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );
  
  static TextStyle bengaliSmall = const TextStyle(
    fontFamily: 'NotoSansBengali',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  // Card styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration gradientCardDecoration(Gradient gradient) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Material Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: islamicGreen,
        primary: islamicGreen,
        onPrimary: Colors.white,
        primaryContainer: islamicGreenLight,
        secondary: prayerBlue,
        onSecondary: Colors.white,
        surface: cardBackground,
        onSurface: textPrimary,
        background: backgroundLight,
        onBackground: textPrimary,
      ),
      textTheme: textTheme,
      fontFamily: 'NotoSans',
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardBackground,
      ),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: islamicGreen,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: islamicGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: islamicGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// Islamic text style extensions
extension IslamicTextStyles on BuildContext {
  TextStyle get arabicHeading => IslamicTheme.arabicLarge;
  TextStyle get arabicBody => IslamicTheme.arabicMedium;
  TextStyle get arabicCaption => IslamicTheme.arabicSmall;
  
  TextStyle get bengaliHeading => IslamicTheme.bengaliLarge;
  TextStyle get bengaliBody => IslamicTheme.bengaliMedium;
  TextStyle get bengaliCaption => IslamicTheme.bengaliSmall;
}
