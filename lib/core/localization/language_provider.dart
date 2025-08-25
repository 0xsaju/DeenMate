import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'language_models.dart';

/// Provider for language preferences storage
final languagePreferencesBoxProvider = StateProvider<Box<LanguagePreferences>?>((ref) => null);

/// Provider for current language preferences
final languagePreferencesProvider = StateNotifierProvider<LanguagePreferencesNotifier, AsyncValue<LanguagePreferences>>((ref) {
  final box = ref.watch(languagePreferencesBoxProvider);
  if (box == null) {
    return LanguagePreferencesNotifier(null);
  }
  return LanguagePreferencesNotifier(box);
});

/// Provider for current locale
final currentLocaleProvider = Provider<Locale>((ref) {
  final preferencesAsync = ref.watch(languagePreferencesProvider);
  return preferencesAsync.when(
    data: (preferences) => preferences.effectiveLanguage.locale,
    loading: () => const Locale('en'),
    error: (_, __) => const Locale('en'),
  );
});

/// Provider for current language
final currentLanguageProvider = Provider<SupportedLanguage>((ref) {
  final preferencesAsync = ref.watch(languagePreferencesProvider);
  return preferencesAsync.when(
    data: (preferences) => preferences.effectiveLanguage,
    loading: () => SupportedLanguage.english,
    error: (_, __) => SupportedLanguage.english,
  );
});

/// Provider for all available languages
final availableLanguagesProvider = Provider<List<LanguageData>>((ref) {
  return LanguageDetection.getAllLanguageData();
});

/// Provider for fully supported languages
final fullySupportedLanguagesProvider = Provider<List<SupportedLanguage>>((ref) {
  return LanguageDetection.getFullySupportedLanguages();
});

/// Notifier for managing language preferences
class LanguagePreferencesNotifier extends StateNotifier<AsyncValue<LanguagePreferences>> {
  final Box<LanguagePreferences>? _box;
  static const String _key = 'language_preferences';

  LanguagePreferencesNotifier(this._box) : super(const AsyncValue.loading()) {
    if (_box != null) {
      _loadPreferences();
    } else {
      state = AsyncValue.data(LanguagePreferences.defaultPreferences());
    }
  }

  /// Load language preferences from storage
  Future<void> _loadPreferences() async {
    if (_box == null) return;
    
    try {
      state = const AsyncValue.loading();
      
      // Check if preferences exist
      if (_box!.containsKey(_key)) {
        final preferences = _box!.get(_key);
        if (preferences != null) {
          state = AsyncValue.data(preferences);
          return;
        }
      }

      // Create default preferences
      final defaultPreferences = LanguagePreferences.defaultPreferences();
      await _box!.put(_key, defaultPreferences);
      state = AsyncValue.data(defaultPreferences);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update selected language
  Future<void> updateLanguage(SupportedLanguage language) async {
    if (_box == null) return;
    
    try {
      final currentPreferences = state.value;
      if (currentPreferences == null) return;

      final updatedPreferences = currentPreferences.copyWith(
        selectedLanguageCode: language.code,
        lastUpdated: DateTime.now(),
        isFirstTimeSetup: false,
      );

      await _box!.put(_key, updatedPreferences);
      state = AsyncValue.data(updatedPreferences);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update device language
  Future<void> updateDeviceLanguage(SupportedLanguage deviceLanguage) async {
    if (_box == null) return;
    
    try {
      final currentPreferences = state.value;
      if (currentPreferences == null) return;

      final updatedPreferences = currentPreferences.copyWith(
        deviceLanguageCode: deviceLanguage.code,
        lastUpdated: DateTime.now(),
      );

      await _box!.put(_key, updatedPreferences);
      state = AsyncValue.data(updatedPreferences);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Reset to default preferences
  Future<void> resetToDefault() async {
    if (_box == null) return;
    
    try {
      final defaultPreferences = LanguagePreferences.defaultPreferences();
      await _box!.put(_key, defaultPreferences);
      state = AsyncValue.data(defaultPreferences);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Migrate old preferences format
  Future<void> migrateOldPreferences(Map<String, dynamic> oldData) async {
    if (_box == null) return;
    
    try {
      final migratedPreferences = LanguageMigration.migrateOldPreferences(oldData);
      await _box!.put(_key, migratedPreferences);
      state = AsyncValue.data(migratedPreferences);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for language initialization
final languageInitializationProvider = FutureProvider<void>((ref) async {
  // Initialize Hive box for language preferences
  if (!Hive.isBoxOpen('language_preferences')) {
    await Hive.openBox<LanguagePreferences>('language_preferences');
  }
  
  // Set the box in the provider
  final box = Hive.box<LanguagePreferences>('language_preferences');
  ref.read(languagePreferencesBoxProvider.notifier).state = box;
});

/// Provider for language detection and setup
final languageDetectionProvider = FutureProvider<SupportedLanguage>((ref) async {
  // Wait for initialization
  await ref.read(languageInitializationProvider.future);
  
  // Detect device language
  final deviceLanguage = LanguageDetection.detectDeviceLanguage();
  
  // Update device language in preferences
  final notifier = ref.read(languagePreferencesProvider.notifier);
  await notifier.updateDeviceLanguage(deviceLanguage);
  
  return deviceLanguage;
});

/// Provider for language switching with validation
final languageSwitcherProvider = Provider<LanguageSwitcher>((ref) {
  final notifier = ref.read(languagePreferencesProvider.notifier);
  return LanguageSwitcher(notifier);
});

/// Helper class for language switching operations
class LanguageSwitcher {
  final LanguagePreferencesNotifier _notifier;

  LanguageSwitcher(this._notifier);

  /// Switch to a specific language with validation
  Future<bool> switchLanguage(SupportedLanguage language) async {
    try {
      // Validate language is supported
      if (!LanguageDetection.isLanguageCodeSupported(language.code)) {
        throw Exception('Unsupported language: ${language.code}');
      }

      await _notifier.updateLanguage(language);
      return true;
    } catch (error) {
      // Log error and return false
      debugPrint('Failed to switch language: $error');
      return false;
    }
  }

  /// Switch to device language
  Future<bool> switchToDeviceLanguage() async {
    try {
      final deviceLanguage = LanguageDetection.detectDeviceLanguage();
      return await switchLanguage(deviceLanguage);
    } catch (error) {
      debugPrint('Failed to switch to device language: $error');
      return false;
    }
  }

  /// Get fallback chain for a language
  List<SupportedLanguage> getFallbackChain(SupportedLanguage language) {
    return LanguageDetection.getFallbackChain(language);
  }
}

/// Provider for text direction based on current language
final textDirectionProvider = Provider<TextDirection>((ref) {
  final language = ref.watch(currentLanguageProvider);
  return language.textDirection;
});

/// Provider for font family based on current language
final fontFamilyProvider = Provider<String>((ref) {
  final language = ref.watch(currentLanguageProvider);
  return language.fontFamily;
});

/// Provider for RTL status based on current language
final isRTLProvider = Provider<bool>((ref) {
  final language = ref.watch(currentLanguageProvider);
  return language.isRTL;
});

/// Provider for language status (fully supported or coming soon)
final languageStatusProvider = Provider<String>((ref) {
  final language = ref.watch(currentLanguageProvider);
  return language.statusDescription;
});

/// Provider for localized strings with fallback
final localizedStringsProvider = Provider<LocalizedStrings>((ref) {
  final locale = ref.watch(currentLocaleProvider);
  return LocalizedStrings(locale);
});

/// Helper class for accessing localized strings
class LocalizedStrings {
  final Locale _locale;

  LocalizedStrings(this._locale);

  /// Get localized string with fallback
  String get(String key, {String fallback = ''}) {
    // For now, return the key as fallback
    // This will be replaced with actual localization when the system is fully integrated
    return fallback.isNotEmpty ? fallback : key;
  }

  /// Get current locale
  Locale get locale => _locale;

  /// Get language code
  String get languageCode => _locale.languageCode;
}
