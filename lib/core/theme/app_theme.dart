import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// DeenMate Material 3 Theme System
/// Implements three carefully designed theme palettes for optimal Islamic app experience

enum AppTheme { 
  lightSerenity, 
  nightCalm, 
  heritageSepia 
}

class AppThemeData {
  /// 🌞 Light Serenity Theme (Default / Day Reading)
  static const Color _lightSerenityPrimary = Color(0xFF2E7D32);      // Emerald Green
  static const Color _lightSerenitySecondary = Color(0xFFC6A700);    // Gold
  static const Color _lightSerenityBackground = Color(0xFFFAFAF7);   // Off-White
  static const Color _lightSerenitySurface = Color(0xFFFFFFFF);      // Ivory
  static const Color _lightSerenityArabicText = Color(0xFF1C1C1C);   // Dark Charcoal
  static const Color _lightSerenityTranslationText = Color(0xFF4A4A4A); // Neutral Gray

  /// 🌙 Night Calm Theme (Dark Mode)
  static const Color _nightCalmPrimary = Color(0xFF26A69A);          // Teal Green
  static const Color _nightCalmSecondary = Color(0xFFFFB300);        // Amber
  static const Color _nightCalmBackground = Color(0xFF121212);       // Deep Charcoal
  static const Color _nightCalmSurface = Color(0xFF1E1E1E);         // Slate Gray
  static const Color _nightCalmArabicText = Color(0xFFEAEAEA);      // Soft White
  static const Color _nightCalmTranslationText = Color(0xFFB0B0B0);  // Cool Gray

  /// 🍃 Heritage Sepia Theme (Scholarly / Classic Reading)
  static const Color _heritageSepiaPromary = Color(0xFF6B8E23);      // Olive Green
  static const Color _heritageSepiaSecondary = Color(0xFF8B6F47);    // Bronze
  static const Color _heritageSepiaBackground = Color(0xFFFDF6E3);   // Warm Parchment
  static const Color _heritageSepiaSurface = Color(0xFFF5EAD7);      // Light Beige
  static const Color _heritageSepiaArabicText = Color(0xFF000000);   // Deep Black
  static const Color _heritageSepiaTranslationText = Color(0xFF3E2C23); // Dark Brown

  /// Get theme data for specific theme
  static ThemeData getTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.lightSerenity:
        return _buildLightSerenityTheme();
      case AppTheme.nightCalm:
        return _buildNightCalmTheme();
      case AppTheme.heritageSepia:
        return _buildHeritageSepiaTheme();
    }
  }

  /// Get theme display name
  static String getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.lightSerenity:
        return 'Light Serenity';
      case AppTheme.nightCalm:
        return 'Night Calm';
      case AppTheme.heritageSepia:
        return 'Heritage Sepia';
    }
  }

  /// Get theme description
  static String getThemeDescription(AppTheme theme) {
    switch (theme) {
      case AppTheme.lightSerenity:
        return 'Default day reading mode with emerald and gold';
      case AppTheme.nightCalm:
        return 'Dark mode for comfortable night reading';
      case AppTheme.heritageSepia:
        return 'Classic scholarly reading with warm tones';
    }
  }

  /// Get Arabic text color for theme
  static Color getArabicTextColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.lightSerenity:
        return _lightSerenityArabicText;
      case AppTheme.nightCalm:
        return _nightCalmArabicText;
      case AppTheme.heritageSepia:
        return _heritageSepiaArabicText;
    }
  }

  /// Get translation text color for theme
  static Color getTranslationTextColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.lightSerenity:
        return _lightSerenityTranslationText;
      case AppTheme.nightCalm:
        return _nightCalmTranslationText;
      case AppTheme.heritageSepia:
        return _heritageSepiaTranslationText;
    }
  }

  /// 🌞 Build Light Serenity Theme
  static ThemeData _buildLightSerenityTheme() {
    const brightness = Brightness.light;
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _lightSerenityPrimary,
      brightness: brightness,
      primary: _lightSerenityPrimary,
      secondary: _lightSerenitySecondary,
      surface: _lightSerenitySurface,
      background: _lightSerenityBackground,
    );

        return _buildTheme(
      colorScheme: colorScheme,
      brightness: brightness,
      arabicTextColor: _lightSerenityArabicText,
      translationTextColor: _lightSerenityTranslationText,
    );
  }

  /// 🌙 Build Night Calm Theme
  static ThemeData _buildNightCalmTheme() {
    const brightness = Brightness.dark;
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _nightCalmPrimary,
      brightness: brightness,
      primary: _nightCalmPrimary,
      secondary: _nightCalmSecondary,
      surface: _nightCalmSurface,
      background: _nightCalmBackground,
    );

        return _buildTheme(
      colorScheme: colorScheme,
      brightness: brightness,
      arabicTextColor: _nightCalmArabicText,
      translationTextColor: _nightCalmTranslationText,
    );
  }

  /// 🍃 Build Heritage Sepia Theme
  static ThemeData _buildHeritageSepiaTheme() {
    const brightness = Brightness.light;
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _heritageSepiaPromary,
      brightness: brightness,
      primary: _heritageSepiaPromary,
      secondary: _heritageSepiaSecondary,
      surface: _heritageSepiaSurface,
      background: _heritageSepiaBackground,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      brightness: brightness,
      arabicTextColor: _heritageSepiaArabicText,
      translationTextColor: _heritageSepiaTranslationText,
    );
  }

  /// Build complete theme with Material 3 specifications
  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required Color arabicTextColor,
    required Color translationTextColor,
  }) {
    final isDark = brightness == Brightness.dark;

    // Custom text theme with Islamic fonts
    final textTheme = _buildTextTheme(
      brightness: brightness,
      arabicTextColor: arabicTextColor,
      translationTextColor: translationTextColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      
      // Text theme with Islamic fonts
      textTheme: textTheme,
      
      // App Bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: brightness,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      
      // Card theme with soft shadows
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: colorScheme.surface,
      ),
      
      // Bottom Navigation theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        fillColor: colorScheme.surface,
        filled: true,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.2),
        thickness: 0.5,
        space: 1,
      ),
      
      // Icon theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface.withOpacity(0.7),
        size: 24,
      ),
      
      // List tile theme
      listTileTheme: ListTileThemeData(
        tileColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Floating Action Button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  /// Build custom text theme with Islamic fonts
  static TextTheme _buildTextTheme({
    required Brightness brightness,
    required Color arabicTextColor,
    required Color translationTextColor,
  }) {
    // Base theme not needed since we're creating custom styles

    return TextTheme(
      // Display styles for large Arabic text (Quran verses)
      displayLarge: GoogleFonts.amiri(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: arabicTextColor,
        height: 1.8,
        letterSpacing: 0.5,
      ),
      displayMedium: GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: arabicTextColor,
        height: 1.8,
        letterSpacing: 0.5,
      ),
      displaySmall: GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: arabicTextColor,
        height: 1.8,
        letterSpacing: 0.5,
      ),
      
      // Headline styles for Arabic section headers
      headlineLarge: GoogleFonts.amiri(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: arabicTextColor,
        height: 1.6,
      ),
      headlineMedium: GoogleFonts.amiri(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: arabicTextColor,
        height: 1.6,
      ),
      headlineSmall: GoogleFonts.amiri(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: arabicTextColor,
        height: 1.6,
      ),
      
      // Title styles for UI headers
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: translationTextColor,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: translationTextColor,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: translationTextColor,
        height: 1.4,
      ),
      
      // Body styles for translations and general text
      bodyLarge: GoogleFonts.crimsonText(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: translationTextColor,
        height: 1.6,
        letterSpacing: 0.1,
      ),
      bodyMedium: GoogleFonts.crimsonText(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: translationTextColor,
        height: 1.6,
        letterSpacing: 0.1,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: translationTextColor.withOpacity(0.8),
        height: 1.5,
      ),
      
      // Label styles for small UI text
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: translationTextColor,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: translationTextColor,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: translationTextColor.withOpacity(0.8),
        height: 1.4,
      ),
    );
  }

  /// Create custom theme extension for Islamic-specific colors and styles
  static IslamicThemeExtension createIslamicExtension(AppTheme theme) {
    return IslamicThemeExtension(
      arabicTextColor: getArabicTextColor(theme),
      translationTextColor: getTranslationTextColor(theme),
      verseNumberColor: getArabicTextColor(theme).withOpacity(0.6),
      bookmarkColor: theme == AppTheme.nightCalm 
          ? const Color(0xFFFFB300) 
          : const Color(0xFFC6A700),
      highlightColor: theme == AppTheme.nightCalm
          ? const Color(0xFF26A69A).withOpacity(0.2)
          : const Color(0xFF2E7D32).withOpacity(0.1),
    );
  }
}

/// Islamic theme extension for additional colors and styles
class IslamicThemeExtension extends ThemeExtension<IslamicThemeExtension> {
  const IslamicThemeExtension({
    required this.arabicTextColor,
    required this.translationTextColor,
    required this.verseNumberColor,
    required this.bookmarkColor,
    required this.highlightColor,
  });

  final Color arabicTextColor;
  final Color translationTextColor;
  final Color verseNumberColor;
  final Color bookmarkColor;
  final Color highlightColor;

  @override
  IslamicThemeExtension copyWith({
    Color? arabicTextColor,
    Color? translationTextColor,
    Color? verseNumberColor,
    Color? bookmarkColor,
    Color? highlightColor,
  }) {
    return IslamicThemeExtension(
      arabicTextColor: arabicTextColor ?? this.arabicTextColor,
      translationTextColor: translationTextColor ?? this.translationTextColor,
      verseNumberColor: verseNumberColor ?? this.verseNumberColor,
      bookmarkColor: bookmarkColor ?? this.bookmarkColor,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }

  @override
  IslamicThemeExtension lerp(
    covariant ThemeExtension<IslamicThemeExtension>? other,
    double t,
  ) {
    if (other is! IslamicThemeExtension) {
      return this;
    }
    return IslamicThemeExtension(
      arabicTextColor: Color.lerp(arabicTextColor, other.arabicTextColor, t)!,
      translationTextColor: Color.lerp(translationTextColor, other.translationTextColor, t)!,
      verseNumberColor: Color.lerp(verseNumberColor, other.verseNumberColor, t)!,
      bookmarkColor: Color.lerp(bookmarkColor, other.bookmarkColor, t)!,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
    );
  }
}