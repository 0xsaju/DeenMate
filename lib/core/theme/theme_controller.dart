import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum for theme modes
enum AppThemeMode {
  light('light', 'Light', '🌞'),
  dark('dark', 'Dark', '🌙'),
  system('system', 'System', '🖥️');

  const AppThemeMode(this.value, this.label, this.icon);

  final String value;
  final String label;
  final String icon;

  /// Get Bengali label for theme mode
  String get bengaliLabel {
    switch (this) {
      case AppThemeMode.light:
        return 'আলো';
      case AppThemeMode.dark:
        return 'অন্ধকার';
      case AppThemeMode.system:
        return 'সিস্টেম';
    }
  }

  /// Convert to Flutter ThemeMode
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Create from string value
  static AppThemeMode fromValue(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.system;
    }
  }
}

/// Theme controller state
class ThemeState {
  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.isLoading = false,
  });

  final AppThemeMode themeMode;
  final bool isLoading;

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.themeMode == themeMode &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => themeMode.hashCode ^ isLoading.hashCode;
}

/// Theme controller for managing app theme state
class ThemeController extends StateNotifier<ThemeState> {
  ThemeController() : super(const ThemeState()) {
    _loadTheme();
  }

  static const String _themeKey = 'app_theme_mode';

  /// Load theme from shared preferences
  Future<void> _loadTheme() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final prefs = await SharedPreferences.getInstance();
      final themeValue = prefs.getString(_themeKey) ?? 'system';
      final themeMode = AppThemeMode.fromValue(themeValue);
      
      state = state.copyWith(
        themeMode: themeMode,
        isLoading: false,
      );
    } catch (e) {
      // If loading fails, use system default
      state = state.copyWith(
        themeMode: AppThemeMode.system,
        isLoading: false,
      );
    }
  }

  /// Change theme mode and persist to storage
  Future<void> setThemeMode(AppThemeMode newThemeMode) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, newThemeMode.value);
      
      state = state.copyWith(
        themeMode: newThemeMode,
        isLoading: false,
      );
    } catch (e) {
      // If saving fails, still update the state
      state = state.copyWith(
        themeMode: newThemeMode,
        isLoading: false,
      );
    }
  }

  /// Toggle between light and dark theme (excluding system)
  Future<void> toggleTheme() async {
    final newTheme = state.themeMode == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    await setThemeMode(newTheme);
  }

  /// Reset to system theme
  Future<void> resetToSystemTheme() async {
    await setThemeMode(AppThemeMode.system);
  }

  /// Get current theme mode as Flutter ThemeMode
  ThemeMode get currentThemeMode => state.themeMode.themeMode;

  /// Check if current theme is system
  bool get isSystemTheme => state.themeMode == AppThemeMode.system;

  /// Check if app is currently in dark mode
  bool isDarkMode(BuildContext context) {
    switch (state.themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}

/// Provider for theme controller
final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeState>(
  (ref) => ThemeController(),
);

/// Provider for current theme mode (convenience)
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(themeControllerProvider);
  return themeState.themeMode.themeMode;
});

/// Provider to check if theme is loading
final isThemeLoadingProvider = Provider<bool>((ref) {
  final themeState = ref.watch(themeControllerProvider);
  return themeState.isLoading;
});

/// Provider to get current theme mode enum
final currentAppThemeModeProvider = Provider<AppThemeMode>((ref) {
  final themeState = ref.watch(themeControllerProvider);
  return themeState.themeMode;
});

/// Provider to check if current effective theme is dark
/// This takes into account system theme and device brightness
final isEffectiveDarkThemeProvider = Provider<bool>((ref) {
  // Note: This provider needs BuildContext to determine system brightness
  // Use isDarkMode method on controller with context instead
  final themeState = ref.watch(themeControllerProvider);
  return themeState.themeMode == AppThemeMode.dark;
});

/// Extension for easy theme controller access
extension ThemeControllerExtension on WidgetRef {
  ThemeController get themeController => read(themeControllerProvider.notifier);
  ThemeState get themeState => watch(themeControllerProvider);
  ThemeMode get themeMode => watch(currentThemeModeProvider);
  AppThemeMode get appThemeMode => watch(currentAppThemeModeProvider);
  bool get isThemeLoading => watch(isThemeLoadingProvider);
}
