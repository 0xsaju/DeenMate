import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

const String _themeBoxName = 'deenmate_theme_preferences';
const String _themeKey = 'selected_theme';

/// Theme state notifier with Hive persistence
class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.lightSerenity) {
    _loadTheme();
  }

  /// Load saved theme from Hive storage
  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      final themeIndex = box.get(_themeKey, defaultValue: 0) as int;
      
      // Ensure theme index is valid
      if (themeIndex >= 0 && themeIndex < AppTheme.values.length) {
        state = AppTheme.values[themeIndex];
      } else {
        state = AppTheme.lightSerenity; // Default fallback
      }
    } catch (e) {
      // Fallback to Light Serenity theme if loading fails
      state = AppTheme.lightSerenity;
    }
  }

  /// Set new theme and persist to storage
  Future<void> setTheme(AppTheme theme) async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      await box.put(_themeKey, theme.index);
      state = theme;
    } catch (e) {
      // Handle error silently but still update state
      state = theme;
    }
  }

  /// Toggle between themes in sequence
  void toggleTheme() {
    final themes = AppTheme.values;
    final currentIndex = themes.indexOf(state);
    final nextIndex = (currentIndex + 1) % themes.length;
    setTheme(themes[nextIndex]);
  }

  /// Set specific theme by name
  void setThemeByName(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'lightserenity':
      case 'light_serenity':
      case 'light serenity':
        setTheme(AppTheme.lightSerenity);
        break;
      case 'nightcalm':
      case 'night_calm':
      case 'night calm':
        setTheme(AppTheme.nightCalm);
        break;
      case 'heritagesepia':
      case 'heritage_sepia':
      case 'heritage sepia':
        setTheme(AppTheme.heritageSepia);
        break;
      default:
        setTheme(AppTheme.lightSerenity);
    }
  }

  /// Get current theme name
  String get currentThemeName => AppThemeData.getThemeName(state);

  /// Get current theme description
  String get currentThemeDescription => AppThemeData.getThemeDescription(state);
}

/// Main theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

/// Theme data provider with Material 3 support
final themeDataProvider = Provider<ThemeData>((ref) {
  final theme = ref.watch(themeProvider);
  final themeData = AppThemeData.getTheme(theme);
  
  // Add Islamic theme extension
  final islamicExtension = AppThemeData.createIslamicExtension(theme);
  
  return themeData.copyWith(
    extensions: [islamicExtension],
  );
});

/// Islamic theme extension provider for easy access
final islamicThemeProvider = Provider<IslamicThemeExtension>((ref) {
  final theme = ref.watch(themeProvider);
  return AppThemeData.createIslamicExtension(theme);
});

/// Check if current theme is dark mode
final isDarkModeProvider = Provider<bool>((ref) {
  final theme = ref.watch(themeProvider);
  return theme == AppTheme.nightCalm;
});

/// Check if current theme is sepia mode
final isSepiaModeProvider = Provider<bool>((ref) {
  final theme = ref.watch(themeProvider);
  return theme == AppTheme.heritageSepia;
});

/// Check if current theme is light mode
final isLightModeProvider = Provider<bool>((ref) {
  final theme = ref.watch(themeProvider);
  return theme == AppTheme.lightSerenity;
});

/// Get all available themes with metadata
final availableThemesProvider = Provider<List<ThemeMetadata>>((ref) {
  return AppTheme.values.map((theme) => ThemeMetadata(
    theme: theme,
    name: AppThemeData.getThemeName(theme),
    description: AppThemeData.getThemeDescription(theme),
    arabicTextColor: AppThemeData.getArabicTextColor(theme),
    translationTextColor: AppThemeData.getTranslationTextColor(theme),
  )).toList();
});

/// Theme metadata class for UI display
class ThemeMetadata {
  const ThemeMetadata({
    required this.theme,
    required this.name,
    required this.description,
    required this.arabicTextColor,
    required this.translationTextColor,
  });

  final AppTheme theme;
  final String name;
  final String description;
  final Color arabicTextColor;
  final Color translationTextColor;

  /// Get theme icon based on theme type
  IconData get icon {
    switch (theme) {
      case AppTheme.lightSerenity:
        return Icons.wb_sunny;
      case AppTheme.nightCalm:
        return Icons.nights_stay;
      case AppTheme.heritageSepia:
        return Icons.auto_stories;
    }
  }

  /// Get preview color for theme selector
  Color get previewColor {
    switch (theme) {
      case AppTheme.lightSerenity:
        return const Color(0xFF2E7D32); // Emerald Green
      case AppTheme.nightCalm:
        return const Color(0xFF26A69A); // Teal Green
      case AppTheme.heritageSepia:
        return const Color(0xFF6B8E23); // Olive Green
    }
  }
}
