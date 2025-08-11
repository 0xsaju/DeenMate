import 'package:flutter/widgets.dart';

import 'bengali_strings.dart';

/// Simple localization helper bridging existing Bengali strings
class S {
  /// Translate a key using current locale. Falls back to provided fallback.
  static String t(BuildContext context, String key, String fallback) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'bn':
        return BengaliStrings.getWithFallback(key, fallback);
      default:
        return fallback;
    }
  }
}


