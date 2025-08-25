import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Supported languages for DeenMate app
enum SupportedLanguage {
  english('en', 'English', 'English', true, 'Inter'),
  bangla('bn', 'বাংলা', 'Bengali', true, 'Noto Sans Bengali'),
  urdu('ur', 'اردو', 'Urdu', false, 'Jameel Noori Nastaleeq'),
  arabic('ar', 'العربية', 'Arabic', false, 'Noto Sans Arabic');

  const SupportedLanguage(
    this.code,
    this.nativeName,
    this.englishName,
    this.isFullySupported,
    this.fontFamily,
  );

  final String code;
  final String nativeName;
  final String englishName;
  final bool isFullySupported;
  final String fontFamily;

  /// Get SupportedLanguage from language code
  static SupportedLanguage fromCode(String code) {
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => SupportedLanguage.english,
    );
  }

  /// Get Locale for this language
  Locale get locale {
    switch (this) {
      case SupportedLanguage.english:
        return const Locale('en');
      case SupportedLanguage.bangla:
        return const Locale('bn');
      case SupportedLanguage.urdu:
        return const Locale('ur');
      case SupportedLanguage.arabic:
        return const Locale('ar');
    }
  }

  /// Check if language is RTL (Right-to-Left)
  bool get isRTL {
    return this == SupportedLanguage.arabic || this == SupportedLanguage.urdu;
  }

  /// Get text direction for this language
  TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get flag emoji for this language
  String get flagEmoji {
    switch (this) {
      case SupportedLanguage.english:
        return '🇺🇸';
      case SupportedLanguage.bangla:
        return '🇧🇩';
      case SupportedLanguage.urdu:
        return '🇵🇰';
      case SupportedLanguage.arabic:
        return '🇸🇦';
    }
  }

  /// Get status description for this language
  String get statusDescription {
    if (isFullySupported) {
      return 'Fully Supported';
    } else {
      return 'Coming Soon';
    }
  }
}

/// Language data model with additional metadata
class LanguageData {
  const LanguageData({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isFullySupported,
    required this.fontFamily,
    required this.isRTL,
    required this.flagEmoji,
    required this.statusDescription,
    this.description,
    this.metadata,
  });

  final String code;
  final String name;
  final String nativeName;
  final bool isFullySupported;
  final String fontFamily;
  final bool isRTL;
  final String flagEmoji;
  final String statusDescription;
  final String? description;
  final Map<String, dynamic>? metadata;

  factory LanguageData.fromSupportedLanguage(SupportedLanguage language) {
    return LanguageData(
      code: language.code,
      name: language.englishName,
      nativeName: language.nativeName,
      isFullySupported: language.isFullySupported,
      fontFamily: language.fontFamily,
      isRTL: language.isRTL,
      flagEmoji: language.flagEmoji,
      statusDescription: language.statusDescription,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'isFullySupported': isFullySupported,
      'fontFamily': fontFamily,
      'isRTL': isRTL,
      'flagEmoji': flagEmoji,
      'statusDescription': statusDescription,
      'description': description,
      'metadata': metadata,
    };
  }

  factory LanguageData.fromJson(Map<String, dynamic> json) {
    return LanguageData(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
      isFullySupported: json['isFullySupported'] as bool,
      fontFamily: json['fontFamily'] as String,
      isRTL: json['isRTL'] as bool,
      flagEmoji: json['flagEmoji'] as String,
      statusDescription: json['statusDescription'] as String,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Language preferences for Hive storage
@HiveType(typeId: 10)
class LanguagePreferences {
  @HiveField(0)
  final String selectedLanguageCode;
  
  @HiveField(1)
  final DateTime lastUpdated;
  
  @HiveField(2)
  final String? deviceLanguageCode;
  
  @HiveField(3)
  final bool? isFirstTimeSetup;
  
  @HiveField(4)
  final Map<String, dynamic>? customSettings;

  const LanguagePreferences({
    required this.selectedLanguageCode,
    required this.lastUpdated,
    this.deviceLanguageCode,
    this.isFirstTimeSetup,
    this.customSettings,
  });

  /// Create default language preferences
  factory LanguagePreferences.defaultPreferences() {
    return LanguagePreferences(
      selectedLanguageCode: 'en',
      lastUpdated: DateTime.now(),
      deviceLanguageCode: null,
      isFirstTimeSetup: true,
      customSettings: null,
    );
  }

  /// Get selected language
  SupportedLanguage get selectedLanguage {
    return SupportedLanguage.fromCode(selectedLanguageCode);
  }

  /// Get device language
  SupportedLanguage? get deviceLanguage {
    if (deviceLanguageCode == null) return null;
    return SupportedLanguage.fromCode(deviceLanguageCode!);
  }

  /// Check if language is fully supported
  bool get isSelectedLanguageFullySupported {
    return selectedLanguage.isFullySupported;
  }

  /// Get effective language (fallback to English if not supported)
  SupportedLanguage get effectiveLanguage {
    if (selectedLanguage.isFullySupported) {
      return selectedLanguage;
    }
    return SupportedLanguage.english;
  }

  /// Create a copy with updated values
  LanguagePreferences copyWith({
    String? selectedLanguageCode,
    DateTime? lastUpdated,
    String? deviceLanguageCode,
    bool? isFirstTimeSetup,
    Map<String, dynamic>? customSettings,
  }) {
    return LanguagePreferences(
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      deviceLanguageCode: deviceLanguageCode ?? this.deviceLanguageCode,
      isFirstTimeSetup: isFirstTimeSetup ?? this.isFirstTimeSetup,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedLanguageCode': selectedLanguageCode,
      'lastUpdated': lastUpdated.toIso8601String(),
      'deviceLanguageCode': deviceLanguageCode,
      'isFirstTimeSetup': isFirstTimeSetup,
      'customSettings': customSettings,
    };
  }

  factory LanguagePreferences.fromJson(Map<String, dynamic> json) {
    return LanguagePreferences(
      selectedLanguageCode: json['selectedLanguageCode'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      deviceLanguageCode: json['deviceLanguageCode'] as String?,
      isFirstTimeSetup: json['isFirstTimeSetup'] as bool?,
      customSettings: json['customSettings'] as Map<String, dynamic>?,
    );
  }
}

/// Language detection and fallback logic
class LanguageDetection {
  /// Detect device language and return supported language
  static SupportedLanguage detectDeviceLanguage() {
    final deviceLocale = WidgetsBinding.instance.window.locale;
    final deviceLanguageCode = deviceLocale.languageCode;
    
    // Try to match device language with supported languages
    for (final language in SupportedLanguage.values) {
      if (language.code == deviceLanguageCode) {
        return language;
      }
    }
    
    // Fallback to English
    return SupportedLanguage.english;
  }

  /// Get fallback chain for language selection
  static List<SupportedLanguage> getFallbackChain(SupportedLanguage primary) {
    final fallbackChain = <SupportedLanguage>[];
    
    // Add primary language if supported
    if (primary.isFullySupported) {
      fallbackChain.add(primary);
    }
    
    // Add English as final fallback
    if (primary != SupportedLanguage.english) {
      fallbackChain.add(SupportedLanguage.english);
    }
    
    return fallbackChain;
  }

  /// Validate if language code is supported
  static bool isLanguageCodeSupported(String code) {
    return SupportedLanguage.values.any((lang) => lang.code == code);
  }

  /// Get all fully supported languages
  static List<SupportedLanguage> getFullySupportedLanguages() {
    return SupportedLanguage.values
        .where((lang) => lang.isFullySupported)
        .toList();
  }

  /// Get all languages (including placeholders)
  static List<SupportedLanguage> getAllLanguages() {
    return SupportedLanguage.values.toList();
  }

  /// Get language data for all languages
  static List<LanguageData> getAllLanguageData() {
    return SupportedLanguage.values
        .map((lang) => LanguageData.fromSupportedLanguage(lang))
        .toList();
  }
}

/// Language migration utilities
class LanguageMigration {
  /// Migrate old language preferences to new format
  static LanguagePreferences migrateOldPreferences(Map<String, dynamic> oldData) {
    String languageCode = 'en';
    
    // Try to extract language from old format
    if (oldData.containsKey('language')) {
      final oldLanguage = oldData['language'];
      if (oldLanguage is String && LanguageDetection.isLanguageCodeSupported(oldLanguage)) {
        languageCode = oldLanguage;
      }
    }
    
    return LanguagePreferences(
      selectedLanguageCode: languageCode,
      lastUpdated: DateTime.now(),
      deviceLanguageCode: LanguageDetection.detectDeviceLanguage().code,
      isFirstTimeSetup: false,
      customSettings: oldData,
    );
  }

  /// Check if migration is needed
  static bool needsMigration(Map<String, dynamic> data) {
    return !data.containsKey('selectedLanguageCode') ||
           !data.containsKey('lastUpdated');
  }
}
