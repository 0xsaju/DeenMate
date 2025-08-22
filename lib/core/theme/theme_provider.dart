import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

const String _themeBoxName = 'theme_preferences';
const String _themeKey = 'selected_theme';

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      final themeIndex = box.get(_themeKey, defaultValue: 0) as int;
      state = AppTheme.values[themeIndex];
    } catch (e) {
      // Fallback to light theme if loading fails
      state = AppTheme.light;
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      await box.put(_themeKey, theme.index);
      state = theme;
    } catch (e) {
      // Handle error silently
    }
  }

  void toggleTheme() {
    final themes = AppTheme.values;
    final currentIndex = themes.indexOf(state);
    final nextIndex = (currentIndex + 1) % themes.length;
    setTheme(themes[nextIndex]);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final theme = ref.watch(themeProvider);
  return AppThemeData.getTheme(theme);
});

final isDarkModeProvider = Provider<bool>((ref) {
  final theme = ref.watch(themeProvider);
  return theme == AppTheme.dark;
});

final isSepiaModeProvider = Provider<bool>((ref) {
  final theme = ref.watch(themeProvider);
  return theme == AppTheme.sepia;
});
