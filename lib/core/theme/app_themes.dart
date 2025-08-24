import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Comprehensive theme system for the DeenMate app
/// Supports Light, Dark, Green (Islamic), and Sepia (Reading) themes
class AppThemes {
  // Theme identifiers
  static const String light = 'light';
  static const String dark = 'dark';
  static const String green = 'green';
  static const String sepia = 'sepia';

  // Available themes
  static Map<String, AppThemeData> get themes => {
    light: _lightTheme,
    dark: _darkTheme,
    green: _greenTheme,
    sepia: _sepiaTheme,
  };

  // Theme display names
  static Map<String, String> get themeNames => {
    light: 'Light',
    dark: 'Dark',
    green: 'Islamic Green',
    sepia: 'Sepia Reading',
  };

  // Theme descriptions
  static Map<String, String> get themeDescriptions => {
    light: 'Clean and bright interface',
    dark: 'Easy on the eyes in low light',
    green: 'Traditional Islamic colors',
    sepia: 'Comfortable for extended reading',
  };

  // Light Theme
  static final AppThemeData _lightTheme = AppThemeData(
    id: light,
    name: 'Light',
    brightness: Brightness.light,
    primaryColor: const Color(0xFF6200EE),
    primaryVariant: const Color(0xFF3700B3),
    secondary: const Color(0xFF03DAC6),
    secondaryVariant: const Color(0xFF018786),
    surface: const Color(0xFFFFFFFF),
    background: const Color(0xFFF5F5F5),
    error: const Color(0xFFB00020),
    onPrimary: const Color(0xFFFFFFFF),
    onSecondary: const Color(0xFF000000),
    onSurface: const Color(0xFF000000),
    onBackground: const Color(0xFF000000),
    onError: const Color(0xFFFFFFFF),
    textPrimary: const Color(0xFF212121),
    textSecondary: const Color(0xFF757575),
    divider: const Color(0xFFE0E0E0),
    arabicTextColor: const Color(0xFF1B1B1B),
    translationTextColor: const Color(0xFF424242),
    verseNumberColor: const Color(0xFF6200EE),
    bookmarkColor: const Color(0xFFFF6B35),
    systemNavigationBarColor: const Color(0xFFF5F5F5),
    statusBarColor: const Color(0xFFF5F5F5),
    statusBarIconBrightness: Brightness.dark,
  );

  // Dark Theme
  static final AppThemeData _darkTheme = AppThemeData(
    id: dark,
    name: 'Dark',
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFBB86FC),
    primaryVariant: const Color(0xFF6200EE),
    secondary: const Color(0xFF03DAC6),
    secondaryVariant: const Color(0xFF03A9F4),
    surface: const Color(0xFF1E1E1E),
    background: const Color(0xFF121212),
    error: const Color(0xFFCF6679),
    onPrimary: const Color(0xFF000000),
    onSecondary: const Color(0xFF000000),
    onSurface: const Color(0xFFFFFFFF),
    onBackground: const Color(0xFFFFFFFF),
    onError: const Color(0xFF000000),
    textPrimary: const Color(0xFFFFFFFF),
    textSecondary: const Color(0xFFB3B3B3),
    divider: const Color(0xFF424242),
    arabicTextColor: const Color(0xFFFFFFFF),
    translationTextColor: const Color(0xFFE0E0E0),
    verseNumberColor: const Color(0xFFBB86FC),
    bookmarkColor: const Color(0xFFFF8A65),
    systemNavigationBarColor: const Color(0xFF121212),
    statusBarColor: const Color(0xFF121212),
    statusBarIconBrightness: Brightness.light,
  );

  // Green Theme (Islamic)
  static final AppThemeData _greenTheme = AppThemeData(
    id: green,
    name: 'Islamic Green',
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2E7D32),
    primaryVariant: const Color(0xFF1B5E20),
    secondary: const Color(0xFF66BB6A),
    secondaryVariant: const Color(0xFF4CAF50),
    surface: const Color(0xFFF1F8E9),
    background: const Color(0xFFE8F5E8),
    error: const Color(0xFFD32F2F),
    onPrimary: const Color(0xFFFFFFFF),
    onSecondary: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF1B1B1B),
    onBackground: const Color(0xFF1B1B1B),
    onError: const Color(0xFFFFFFFF),
    textPrimary: const Color(0xFF1B1B1B),
    textSecondary: const Color(0xFF424242),
    divider: const Color(0xFFC8E6C9),
    arabicTextColor: const Color(0xFF1B5E20),
    translationTextColor: const Color(0xFF2E7D32),
    verseNumberColor: const Color(0xFF2E7D32),
    bookmarkColor: const Color(0xFFFF8F00),
    systemNavigationBarColor: const Color(0xFFE8F5E8),
    statusBarColor: const Color(0xFFE8F5E8),
    statusBarIconBrightness: Brightness.dark,
  );

  // Sepia Theme (Reading)
  static final AppThemeData _sepiaTheme = AppThemeData(
    id: sepia,
    name: 'Sepia Reading',
    brightness: Brightness.light,
    primaryColor: const Color(0xFF8D6E63),
    primaryVariant: const Color(0xFF5D4037),
    secondary: const Color(0xFFBCAAA4),
    secondaryVariant: const Color(0xFFA1887F),
    surface: const Color(0xFFF5F1E8),
    background: const Color(0xFFF0E9DC),
    error: const Color(0xFFD84315),
    onPrimary: const Color(0xFFFFFFFF),
    onSecondary: const Color(0xFF000000),
    onSurface: const Color(0xFF3E2723),
    onBackground: const Color(0xFF3E2723),
    onError: const Color(0xFFFFFFFF),
    textPrimary: const Color(0xFF3E2723),
    textSecondary: const Color(0xFF6D4C41),
    divider: const Color(0xFFD7CCC8),
    arabicTextColor: const Color(0xFF3E2723),
    translationTextColor: const Color(0xFF5D4037),
    verseNumberColor: const Color(0xFF8D6E63),
    bookmarkColor: const Color(0xFFFF8A65),
    systemNavigationBarColor: const Color(0xFFF0E9DC),
    statusBarColor: const Color(0xFFF0E9DC),
    statusBarIconBrightness: Brightness.dark,
  );

  /// Generate Material Theme from AppThemeData
  static ThemeData getMaterialTheme(AppThemeData appTheme) {
    final colorScheme = ColorScheme(
      brightness: appTheme.brightness,
      primary: appTheme.primaryColor,
      onPrimary: appTheme.onPrimary,
      secondary: appTheme.secondary,
      onSecondary: appTheme.onSecondary,
      error: appTheme.error,
      onError: appTheme.onError,
      background: appTheme.background,
      onBackground: appTheme.onBackground,
      surface: appTheme.surface,
      onSurface: appTheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: appTheme.brightness,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: appTheme.background,
        foregroundColor: appTheme.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: appTheme.statusBarColor,
          statusBarIconBrightness: appTheme.statusBarIconBrightness,
          systemNavigationBarColor: appTheme.systemNavigationBarColor,
        ),
      ),

      // Scaffold Theme
      scaffoldBackgroundColor: appTheme.background,

      // Card Theme
      cardTheme: CardThemeData(
        color: appTheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appTheme.primaryColor,
          foregroundColor: appTheme.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: appTheme.primaryColor,
          side: BorderSide(color: appTheme.primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: appTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: appTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: appTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: appTheme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: appTheme.primaryColor,
        unselectedLabelColor: appTheme.textSecondary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: appTheme.primaryColor, width: 3),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: appTheme.surface,
        selectedItemColor: appTheme.primaryColor,
        unselectedItemColor: appTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: appTheme.surface,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: appTheme.divider,
        thickness: 1,
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return appTheme.primaryColor;
          }
          return null;
        }),
        checkColor: MaterialStateProperty.all(appTheme.onPrimary),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return appTheme.primaryColor;
          }
          return appTheme.textSecondary;
        }),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return appTheme.primaryColor;
          }
          return appTheme.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return appTheme.primaryColor.withOpacity(0.5);
          }
          return appTheme.divider;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: appTheme.primaryColor,
        inactiveTrackColor: appTheme.divider,
        thumbColor: appTheme.primaryColor,
        overlayColor: appTheme.primaryColor.withOpacity(0.2),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: appTheme.primaryColor,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appTheme.primaryColor,
        foregroundColor: appTheme.onPrimary,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: appTheme.textSecondary,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(color: appTheme.textPrimary, fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: TextStyle(color: appTheme.textPrimary, fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(color: appTheme.textPrimary, fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(color: appTheme.textPrimary, fontSize: 32, fontWeight: FontWeight.w400),
        headlineMedium: TextStyle(color: appTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w400),
        headlineSmall: TextStyle(color: appTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w400),
        titleLarge: TextStyle(color: appTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: appTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: appTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: appTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: appTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(color: appTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: appTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: appTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: appTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: appTheme.textPrimary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: TextStyle(
          color: appTheme.background,
          fontSize: 12,
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: appTheme.textPrimary,
        contentTextStyle: TextStyle(color: appTheme.background),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Get theme by ID
  static AppThemeData? getTheme(String themeId) {
    return themes[themeId];
  }

  /// Get Material theme by ID
  static ThemeData? getMaterialThemeById(String themeId) {
    final appTheme = getTheme(themeId);
    return appTheme != null ? getMaterialTheme(appTheme) : null;
  }

  /// Get system navigation bar style for theme
  static SystemUiOverlayStyle getSystemUIOverlayStyle(AppThemeData theme) {
    return SystemUiOverlayStyle(
      statusBarColor: theme.statusBarColor,
      statusBarIconBrightness: theme.statusBarIconBrightness,
      systemNavigationBarColor: theme.systemNavigationBarColor,
      systemNavigationBarIconBrightness: theme.brightness == Brightness.dark 
        ? Brightness.light 
        : Brightness.dark,
    );
  }
}

/// Custom theme data class for the app
class AppThemeData {
  const AppThemeData({
    required this.id,
    required this.name,
    required this.brightness,
    required this.primaryColor,
    required this.primaryVariant,
    required this.secondary,
    required this.secondaryVariant,
    required this.surface,
    required this.background,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onSurface,
    required this.onBackground,
    required this.onError,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.arabicTextColor,
    required this.translationTextColor,
    required this.verseNumberColor,
    required this.bookmarkColor,
    required this.systemNavigationBarColor,
    required this.statusBarColor,
    required this.statusBarIconBrightness,
  });

  final String id;
  final String name;
  final Brightness brightness;
  
  // Material colors
  final Color primaryColor;
  final Color primaryVariant;
  final Color secondary;
  final Color secondaryVariant;
  final Color surface;
  final Color background;
  final Color error;
  final Color onPrimary;
  final Color onSecondary;
  final Color onSurface;
  final Color onBackground;
  final Color onError;
  
  // Custom semantic colors
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color arabicTextColor;
  final Color translationTextColor;
  final Color verseNumberColor;
  final Color bookmarkColor;
  
  // System UI colors
  final Color systemNavigationBarColor;
  final Color statusBarColor;
  final Brightness statusBarIconBrightness;

  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;

  AppThemeData copyWith({
    String? id,
    String? name,
    Brightness? brightness,
    Color? primaryColor,
    Color? primaryVariant,
    Color? secondary,
    Color? secondaryVariant,
    Color? surface,
    Color? background,
    Color? error,
    Color? onPrimary,
    Color? onSecondary,
    Color? onSurface,
    Color? onBackground,
    Color? onError,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? arabicTextColor,
    Color? translationTextColor,
    Color? verseNumberColor,
    Color? bookmarkColor,
    Color? systemNavigationBarColor,
    Color? statusBarColor,
    Brightness? statusBarIconBrightness,
  }) {
    return AppThemeData(
      id: id ?? this.id,
      name: name ?? this.name,
      brightness: brightness ?? this.brightness,
      primaryColor: primaryColor ?? this.primaryColor,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      secondary: secondary ?? this.secondary,
      secondaryVariant: secondaryVariant ?? this.secondaryVariant,
      surface: surface ?? this.surface,
      background: background ?? this.background,
      error: error ?? this.error,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      onSurface: onSurface ?? this.onSurface,
      onBackground: onBackground ?? this.onBackground,
      onError: onError ?? this.onError,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      arabicTextColor: arabicTextColor ?? this.arabicTextColor,
      translationTextColor: translationTextColor ?? this.translationTextColor,
      verseNumberColor: verseNumberColor ?? this.verseNumberColor,
      bookmarkColor: bookmarkColor ?? this.bookmarkColor,
      systemNavigationBarColor: systemNavigationBarColor ?? this.systemNavigationBarColor,
      statusBarColor: statusBarColor ?? this.statusBarColor,
      statusBarIconBrightness: statusBarIconBrightness ?? this.statusBarIconBrightness,
    );
  }
}
