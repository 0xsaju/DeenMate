import 'package:flutter/material.dart';

// Material 3 Theme definitions for DeenMate

enum AppTheme { light, sepia, dark }

class AppThemeData {
  // Light theme palette
  static const Color _lightBackground = Color(0xFFF5F8F7);
  static const Color _lightPrimary = Color(0xFF9BB6AB);
  static const Color _lightSecondary = Color(0xFF378E67);
  static const Color _lightOnSurface = Color(0xFF54655F);

  // Sepia theme palette
  static const Color _sepiaBackground = Color(0xFFF4E9D7);
  static const Color _sepiaPrimary = Color(0xFFC5B298);
  static const Color _sepiaSecondary = Color(0xFFA58C72);
  static const Color _sepiaOnSurface = Color(0xFF6B5F52);

  // Dark theme palette
  static const Color _darkBackground = Color(0xFF000B06);
  static const Color _darkPrimary = Color(0xFF07582C);
  static const Color _darkSecondary = Color(0xFF378E67);
  static const Color _darkOnSurfacePrimary = Color(0xFF9BB6AB);
  static const Color _darkOnSurfaceSecondary = Color(0xFF54655F);

  static ThemeData getTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return _buildTheme(
          brightness: Brightness.light,
          background: _lightBackground,
          primary: _lightPrimary,
          secondary: _lightSecondary,
          onSurface: _lightOnSurface,
        );
      case AppTheme.sepia:
        return _buildTheme(
          brightness: Brightness.light,
          background: _sepiaBackground,
          primary: _sepiaPrimary,
          secondary: _sepiaSecondary,
          onSurface: _sepiaOnSurface,
        );
      case AppTheme.dark:
        return _buildTheme(
          brightness: Brightness.dark,
          background: _darkBackground,
          primary: _darkPrimary,
          secondary: _darkSecondary,
          onSurface: _darkOnSurfacePrimary,
          onSurfaceVariant: _darkOnSurfaceSecondary,
        );
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color primary,
    required Color secondary,
    required Color onSurface,
    Color? onSurfaceVariant,
  }) {
    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: brightness == Brightness.dark ? Colors.white : Colors.black,
      secondary: secondary,
      onSecondary: brightness == Brightness.dark ? Colors.white : Colors.black,
      error: Colors.red.shade700,
      onError: Colors.white,
      background: background,
      onBackground: onSurface,
      surface: background,
      onSurface: onSurface,
      surfaceVariant: brightness == Brightness.dark
          ? const Color(0xFF0F1A15)
          : Colors.white,
      outline: (onSurfaceVariant ?? onSurface).withOpacity(0.3),
    );

    final TextTheme baseTextTheme = (brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light())
        .textTheme;

    final TextTheme textTheme = baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(height: 1.2),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(height: 1.2),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(height: 1.2),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.5),
      bodySmall: baseTextTheme.bodySmall?.copyWith(height: 1.5),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardTheme: const CardThemeData(
        margin: EdgeInsets.all(8),
        elevation: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: textTheme,
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.2),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static String getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.sepia:
        return 'Sepia';
      case AppTheme.dark:
        return 'Dark';
    }
  }

  static String getThemeDescription(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Calm, minimal look with soft greens';
      case AppTheme.sepia:
        return 'Warm, paper-like reading experience';
      case AppTheme.dark:
        return 'High-contrast, battery-friendly';
    }
  }
}


