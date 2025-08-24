import 'package:flutter/widgets.dart';

import 'bengali_strings.dart';
import 'arabic_strings.dart';
import 'urdu_strings.dart';

/// Comprehensive localization helper for DeenMate
/// Supports English (default), Bengali, Arabic, and Urdu
class S {
  /// Translate a key using current locale. Falls back to provided fallback.
  static String t(BuildContext context, String key, String fallback) {
    final locale = Localizations.localeOf(context);
    
    switch (locale.languageCode) {
      case 'bn':
        return BengaliStrings.getWithFallback(key, fallback);
      case 'ar':
        return ArabicStrings.getWithFallback(key, fallback);
      case 'ur':
        return UrduStrings.getWithFallback(key, fallback);
      default:
        return fallback;
    }
  }

  /// Get translation without context (for providers/services)
  static String translate(String languageCode, String key, String fallback) {
    switch (languageCode) {
      case 'bn':
        return BengaliStrings.getWithFallback(key, fallback);
      case 'ar':
        return ArabicStrings.getWithFallback(key, fallback);
      case 'ur':
        return UrduStrings.getWithFallback(key, fallback);
      default:
        return fallback;
    }
  }

  /// Check if a language is supported
  static bool isLanguageSupported(String languageCode) {
    return ['en', 'bn', 'ar', 'ur'].contains(languageCode);
  }

  /// Get list of supported languages
  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
      {'code': 'ur', 'name': 'Urdu', 'nativeName': 'اردو'},
      {'code': 'bn', 'name': 'Bengali', 'nativeName': 'বাংলা'},
    ];
  }

  /// Check if language is RTL (Right-to-Left)
  static bool isRTL(String languageCode) {
    return ['ar', 'ur'].contains(languageCode);
  }
}


