import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../storage/hive_boxes.dart' as boxes;

/// Comprehensive accessibility service for the Quran app
/// Supports screen readers, high contrast, large text, voice commands, and more
class AccessibilityService extends ChangeNotifier {
  static const String _prefsKey = 'accessibility_preferences';
  
  AccessibilityPreferences _preferences = const AccessibilityPreferences();
  bool _isInitialized = false;

  AccessibilityPreferences get preferences => _preferences;
  bool get isInitialized => _isInitialized;

  /// Initialize accessibility service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadPreferences();
    await _setupSystemAccessibility();
    _isInitialized = true;
    
    notifyListeners();
  }

  /// Update accessibility preferences
  Future<void> updatePreferences(AccessibilityPreferences newPreferences) async {
    _preferences = newPreferences;
    await _savePreferences();
    await _applyAccessibilitySettings();
    notifyListeners();
  }

  /// Enable high contrast mode
  Future<void> enableHighContrast(bool enable) async {
    final newPrefs = _preferences.copyWith(highContrast: enable);
    await updatePreferences(newPrefs);
  }

  /// Set font scaling
  Future<void> setFontScale(double scale) async {
    final clampedScale = scale.clamp(0.8, 3.0);
    final newPrefs = _preferences.copyWith(fontScale: clampedScale);
    await updatePreferences(newPrefs);
  }

  /// Enable reduced motion
  Future<void> enableReducedMotion(bool enable) async {
    final newPrefs = _preferences.copyWith(reduceMotion: enable);
    await updatePreferences(newPrefs);
  }

  /// Set screen reader language
  Future<void> setScreenReaderLanguage(String languageCode) async {
    final newPrefs = _preferences.copyWith(screenReaderLanguage: languageCode);
    await updatePreferences(newPrefs);
  }

  /// Enable voice announcements
  Future<void> enableVoiceAnnouncements(bool enable) async {
    final newPrefs = _preferences.copyWith(enableVoiceAnnouncements: enable);
    await updatePreferences(newPrefs);
  }

  /// Announce text using TTS
  Future<void> announceText(String text, {AccessibilityAnnouncement? type}) async {
    if (!_preferences.enableVoiceAnnouncements) return;

    final announcement = type ?? AccessibilityAnnouncement.polite;
    
    SemanticsService.announce(
      text,
      announcement == AccessibilityAnnouncement.assertive 
        ? TextDirection.ltr 
        : TextDirection.ltr,
      assertiveness: announcement == AccessibilityAnnouncement.assertive 
        ? Assertiveness.assertive 
        : Assertiveness.polite,
    );
  }

  /// Get semantic label for Arabic text
  String getArabicSemanticLabel(String arabicText, {
    String? transliteration,
    String? translation,
    bool includeTransliteration = true,
    bool includeTranslation = true,
  }) {
    final parts = <String>[];
    
    // Add Arabic text description
    parts.add('Arabic text: $arabicText');
    
    // Add transliteration if available
    if (includeTransliteration && transliteration != null && transliteration.isNotEmpty) {
      parts.add('Pronunciation: $transliteration');
    }
    
    // Add translation if available
    if (includeTranslation && translation != null && translation.isNotEmpty) {
      parts.add('Translation: $translation');
    }
    
    return parts.join('. ');
  }

  /// Get semantic label for verse
  String getVerseSemanticLabel({
    required String verseKey,
    required String arabicText,
    String? translation,
    String? chapterName,
    int? verseNumber,
  }) {
    final parts = <String>[];
    
    // Verse identification
    if (chapterName != null && verseNumber != null) {
      parts.add('Verse $verseNumber from chapter $chapterName');
    } else {
      parts.add('Verse $verseKey');
    }
    
    // Arabic text
    parts.add('Arabic text: $arabicText');
    
    // Translation
    if (translation != null && translation.isNotEmpty) {
      parts.add('Translation: $translation');
    }
    
    return parts.join('. ');
  }

  /// Get navigation hint for complex widgets
  String getNavigationHint(AccessibilityNavigationContext context) {
    switch (context) {
      case AccessibilityNavigationContext.verseList:
        return 'Swipe up or down to navigate between verses. Double tap to read full verse.';
      case AccessibilityNavigationContext.chapterList:
        return 'Swipe up or down to navigate between chapters. Double tap to open chapter.';
      case AccessibilityNavigationContext.bookmarks:
        return 'Swipe up or down to navigate between bookmarks. Double tap to view bookmark.';
      case AccessibilityNavigationContext.search:
        return 'Swipe up or down to navigate between search results. Double tap to view result.';
      case AccessibilityNavigationContext.audioPlayer:
        return 'Use play, pause, next, and previous buttons to control audio playback.';
      case AccessibilityNavigationContext.readingPlan:
        return 'Swipe up or down to navigate between reading plan days. Double tap to view day details.';
    }
  }

  /// Create accessibility-enhanced widget
  Widget enhanceWidget({
    required Widget child,
    String? semanticLabel,
    String? hint,
    bool excludeSemantics = false,
    VoidCallback? onTap,
    bool isButton = false,
    bool isHeader = false,
    bool isSelected = false,
    String? value,
    String? increasedValue,
    String? decreasedValue,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
  }) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: isButton,
      header: isHeader,
      selected: isSelected,
      value: value,
      increasedValue: increasedValue,
      decreasedValue: decreasedValue,
      onTap: onTap,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: child,
    );
  }

  /// Create focus-aware widget
  Widget createFocusableWidget({
    required Widget child,
    required String semanticLabel,
    VoidCallback? onFocus,
    VoidCallback? onFocusLost,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    final focus = focusNode ?? FocusNode();
    
    return Focus(
      focusNode: focus,
      autofocus: autofocus,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          onFocus?.call();
          if (_preferences.enableVoiceAnnouncements) {
            announceText(semanticLabel);
          }
        } else {
          onFocusLost?.call();
        }
      },
      child: Semantics(
        label: semanticLabel,
        focusable: true,
        child: child,
      ),
    );
  }

  /// Get accessibility theme data
  ThemeData getAccessibilityTheme(ThemeData baseTheme) {
    if (!_preferences.highContrast && _preferences.fontScale == 1.0) {
      return baseTheme;
    }

    ColorScheme colorScheme = baseTheme.colorScheme;
    
    // Apply high contrast if enabled
    if (_preferences.highContrast) {
      colorScheme = _getHighContrastColorScheme(colorScheme);
    }

    // Apply font scaling
    final textTheme = _scaleFonts(baseTheme.textTheme, _preferences.fontScale);

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      // Increase touch targets for accessibility
      materialTapTargetSize: MaterialTapTargetSize.padded,
      // Increase button padding
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: baseTheme.elevatedButtonTheme.style?.copyWith(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          minimumSize: MaterialStateProperty.all(const Size(88, 48)),
        ),
      ),
    );
  }

  /// Check if system accessibility features are enabled
  Future<AccessibilityFeatures> getSystemAccessibilityFeatures() async {
    final mediaQuery = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    
    return AccessibilityFeatures(
      accessibleNavigation: mediaQuery.accessibleNavigation,
      boldText: mediaQuery.boldText,
      disableAnimations: mediaQuery.disableAnimations,
      highContrast: mediaQuery.highContrast,
      invertColors: mediaQuery.invertColors,
      reduceMotion: mediaQuery.disableAnimations,
      textScaleFactor: mediaQuery.textScaleFactor,
    );
  }

  /// Provide accessibility training/tutorial
  List<AccessibilityTutorialStep> getAccessibilityTutorial() {
    return [
      const AccessibilityTutorialStep(
        title: 'Welcome to DeenMate Accessibility',
        description: 'DeenMate is designed to be accessible for all users. This tutorial will help you navigate the app effectively.',
        action: 'Double tap to continue',
      ),
      const AccessibilityTutorialStep(
        title: 'Screen Reader Navigation',
        description: 'Swipe right to move to the next element, swipe left to go back. Double tap to activate buttons and links.',
        action: 'Practice swiping right and left',
      ),
      const AccessibilityTutorialStep(
        title: 'Reading Quran Verses',
        description: 'Each verse includes Arabic text, pronunciation, and translation. The screen reader will announce all parts.',
        action: 'Try reading a verse',
      ),
      const AccessibilityTutorialStep(
        title: 'Audio Features',
        description: 'Use audio recitation to listen to Quran verses. Audio controls are clearly labeled for easy navigation.',
        action: 'Explore audio features',
      ),
      const AccessibilityTutorialStep(
        title: 'Customization',
        description: 'Adjust font size, enable high contrast, and customize other accessibility settings in the app settings.',
        action: 'Visit accessibility settings',
      ),
    ];
  }

  // Private methods

  Future<void> _loadPreferences() async {
    try {
      final box = await Hive.openBox(boxes.Boxes.prefs);
      final data = box.get(_prefsKey) as Map<String, dynamic>?;
      
      if (data != null) {
        _preferences = AccessibilityPreferences.fromMap(data);
      }
    } catch (e) {
      // Use default preferences if loading fails
      _preferences = const AccessibilityPreferences();
    }
  }

  Future<void> _savePreferences() async {
    try {
      final box = await Hive.openBox(boxes.Boxes.prefs);
      await box.put(_prefsKey, _preferences.toMap());
    } catch (e) {
      // Handle save error gracefully
    }
  }

  Future<void> _setupSystemAccessibility() async {
    // Configure system accessibility settings
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  Future<void> _applyAccessibilitySettings() async {
    // Apply any system-level accessibility changes
    if (_preferences.reduceMotion) {
      // Disable or reduce animations
    }
  }

  ColorScheme _getHighContrastColorScheme(ColorScheme baseScheme) {
    if (baseScheme.brightness == Brightness.dark) {
      return baseScheme.copyWith(
        primary: Colors.cyan,
        onPrimary: Colors.black,
        secondary: Colors.yellow,
        onSecondary: Colors.black,
        surface: Colors.black,
        onSurface: Colors.white,
        background: Colors.black,
        onBackground: Colors.white,
        error: Colors.red.shade400,
        onError: Colors.black,
      );
    } else {
      return baseScheme.copyWith(
        primary: Colors.blue.shade900,
        onPrimary: Colors.white,
        secondary: Colors.orange.shade800,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        background: Colors.white,
        onBackground: Colors.black,
        error: Colors.red.shade800,
        onError: Colors.white,
      );
    }
  }

  TextTheme _scaleFonts(TextTheme baseTheme, double scale) {
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: (baseTheme.displayLarge?.fontSize ?? 57) * scale),
      displayMedium: baseTheme.displayMedium?.copyWith(fontSize: (baseTheme.displayMedium?.fontSize ?? 45) * scale),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: (baseTheme.displaySmall?.fontSize ?? 36) * scale),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: (baseTheme.headlineLarge?.fontSize ?? 32) * scale),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: (baseTheme.headlineMedium?.fontSize ?? 28) * scale),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: (baseTheme.headlineSmall?.fontSize ?? 24) * scale),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: (baseTheme.titleLarge?.fontSize ?? 22) * scale),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: (baseTheme.titleMedium?.fontSize ?? 16) * scale),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: (baseTheme.titleSmall?.fontSize ?? 14) * scale),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: (baseTheme.bodyLarge?.fontSize ?? 16) * scale),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: (baseTheme.bodyMedium?.fontSize ?? 14) * scale),
      bodySmall: baseTheme.bodySmall?.copyWith(fontSize: (baseTheme.bodySmall?.fontSize ?? 12) * scale),
      labelLarge: baseTheme.labelLarge?.copyWith(fontSize: (baseTheme.labelLarge?.fontSize ?? 14) * scale),
      labelMedium: baseTheme.labelMedium?.copyWith(fontSize: (baseTheme.labelMedium?.fontSize ?? 12) * scale),
      labelSmall: baseTheme.labelSmall?.copyWith(fontSize: (baseTheme.labelSmall?.fontSize ?? 11) * scale),
    );
  }
}

// Data classes

class AccessibilityPreferences {
  const AccessibilityPreferences({
    this.highContrast = false,
    this.fontScale = 1.0,
    this.reduceMotion = false,
    this.enableVoiceAnnouncements = false,
    this.screenReaderLanguage = 'en',
    this.tapToNavigate = true,
    this.extendedTimeouts = false,
    this.simplifiedInterface = false,
  });

  final bool highContrast;
  final double fontScale;
  final bool reduceMotion;
  final bool enableVoiceAnnouncements;
  final String screenReaderLanguage;
  final bool tapToNavigate;
  final bool extendedTimeouts;
  final bool simplifiedInterface;

  AccessibilityPreferences copyWith({
    bool? highContrast,
    double? fontScale,
    bool? reduceMotion,
    bool? enableVoiceAnnouncements,
    String? screenReaderLanguage,
    bool? tapToNavigate,
    bool? extendedTimeouts,
    bool? simplifiedInterface,
  }) {
    return AccessibilityPreferences(
      highContrast: highContrast ?? this.highContrast,
      fontScale: fontScale ?? this.fontScale,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      enableVoiceAnnouncements: enableVoiceAnnouncements ?? this.enableVoiceAnnouncements,
      screenReaderLanguage: screenReaderLanguage ?? this.screenReaderLanguage,
      tapToNavigate: tapToNavigate ?? this.tapToNavigate,
      extendedTimeouts: extendedTimeouts ?? this.extendedTimeouts,
      simplifiedInterface: simplifiedInterface ?? this.simplifiedInterface,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'highContrast': highContrast,
      'fontScale': fontScale,
      'reduceMotion': reduceMotion,
      'enableVoiceAnnouncements': enableVoiceAnnouncements,
      'screenReaderLanguage': screenReaderLanguage,
      'tapToNavigate': tapToNavigate,
      'extendedTimeouts': extendedTimeouts,
      'simplifiedInterface': simplifiedInterface,
    };
  }

  factory AccessibilityPreferences.fromMap(Map<String, dynamic> map) {
    return AccessibilityPreferences(
      highContrast: map['highContrast'] ?? false,
      fontScale: (map['fontScale'] ?? 1.0).toDouble(),
      reduceMotion: map['reduceMotion'] ?? false,
      enableVoiceAnnouncements: map['enableVoiceAnnouncements'] ?? false,
      screenReaderLanguage: map['screenReaderLanguage'] ?? 'en',
      tapToNavigate: map['tapToNavigate'] ?? true,
      extendedTimeouts: map['extendedTimeouts'] ?? false,
      simplifiedInterface: map['simplifiedInterface'] ?? false,
    );
  }
}

class AccessibilityFeatures {
  const AccessibilityFeatures({
    required this.accessibleNavigation,
    required this.boldText,
    required this.disableAnimations,
    required this.highContrast,
    required this.invertColors,
    required this.reduceMotion,
    required this.textScaleFactor,
  });

  final bool accessibleNavigation;
  final bool boldText;
  final bool disableAnimations;
  final bool highContrast;
  final bool invertColors;
  final bool reduceMotion;
  final double textScaleFactor;
}

class AccessibilityTutorialStep {
  const AccessibilityTutorialStep({
    required this.title,
    required this.description,
    required this.action,
  });

  final String title;
  final String description;
  final String action;
}

enum AccessibilityAnnouncement {
  polite,
  assertive,
}

enum AccessibilityNavigationContext {
  verseList,
  chapterList,
  bookmarks,
  search,
  audioPlayer,
  readingPlan,
}

// Providers
final accessibilityServiceProvider = ChangeNotifierProvider<AccessibilityService>((ref) {
  return AccessibilityService();
});

final accessibilityPreferencesProvider = Provider<AccessibilityPreferences>((ref) {
  final service = ref.watch(accessibilityServiceProvider);
  return service.preferences;
});

final accessibilityFeaturesProvider = FutureProvider<AccessibilityFeatures>((ref) async {
  final service = ref.watch(accessibilityServiceProvider);
  return service.getSystemAccessibilityFeatures();
});
