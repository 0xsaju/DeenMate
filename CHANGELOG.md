# DeenMate - Changelog

بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم

All notable changes to the DeenMate project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### In Progress
- Quran Phase 2 features (notes, tafsir, word-by-word)
- Continued Quran module development
- Testing theme persistence across app restarts

---

## [2024.12.2] - 2024-12-XX  

### 🚀 Fixed - Critical User Experience Issues
- **Manual Location System** - Fixed GPS permission loop when manual city is selected
- **Navigation Consolidation** - Removed duplicate Navigation button, made top navigation tabs functional
- **Offline Features** - Removed standalone Offline Mode button, integrated under cloud icon
- **Theme Settings** - Removed duplicate theme selector from More Features, unified under Settings
- **Dark Theme Integration** - Fixed prayer times screen colors for proper dark mode support
- **UI Overflow Errors** - Resolved "BOTTOM OVERFLOWED" errors visible in screenshots
- **Onboarding Integration** - Connected onboarding theme preferences with main app settings
- **Audio Widget Compilation** - Fixed AudioState enum conflicts and method references

### 🎨 Enhanced - Complete Theme Implementation
- **🌞 Light Serenity Theme** - Emerald Green & Gold palette fully implemented across all screens
- **🌙 Night Calm Theme** - Teal Green & Amber dark mode working perfectly across app
- **🍃 Heritage Sepia Theme** - Olive Green & Bronze scholarly mode for comfortable reading
- **Hardcoded Colors Fixed** - Replaced 100+ hardcoded Colors.* with theme-aware Material 3 colors
- **Shadow & Surface Colors** - Updated all shadows and surfaces to use theme-appropriate colors
- **Text & Icon Colors** - All text and icons now properly adapt to selected theme
- **Prayer Times Dark Mode** - Fixed "weird" dark theme appearance by removing hardcoded values
- **Audio Player Theming** - Fixed player colors to work correctly with all three themes

### 🔗 Improved - Navigation & User Flow
- **Quran Navigation** - Top tabs (Sura/Page/Juz/Hizb/Ruku) now properly route to respective screens
- **More Features Clean** - Streamlined More screen with proper settings organization
- **Cloud Icon Integration** - Offline status and management unified under single cloud icon

---

## [2024.12.1] - 2024-12-XX

### 🎨 Added - Islamic Theme System Implementation
- **Three New Theme Palettes** - Complete Material 3 theme system
  - 🌞 **Light Serenity** (Default) - Emerald Green (#2E7D32) + Gold (#C6A700)
  - 🌙 **Night Calm** (Dark Mode) - Teal Green (#26A69A) + Amber (#FFB300)
  - 🍃 **Heritage Sepia** (Scholarly) - Olive Green (#6B8E23) + Bronze (#8B6F47)

- **Islamic Typography System** - Google Fonts integration
  - **Arabic Text**: Amiri font for authentic Quranic styling
  - **Translation Text**: Crimson Text serif for optimal readability
  - **UI Text**: Inter for modern interface elements

- **ThemeSelectorWidget** - Interactive theme picker
  - Live Arabic and translation text previews
  - Visual theme selection with icons and descriptions
  - Integrated into More > Settings screen

- **Enhanced State Management**
  - Riverpod providers for theme state
  - Hive persistence for theme preferences
  - Theme metadata with preview colors and descriptions

### 🔧 Technical Implementation
- **Material 3 Compliance** - Full ColorScheme.fromSeed() implementation
- **Islamic Theme Extension** - Custom theme extension for Islamic-specific colors
- **Accessibility** - WCAG AA compliant contrast ratios across all themes
- **Performance** - Optimized theme switching with instant preview

### 📁 Files Added/Modified
```
lib/core/theme/
├── app_theme.dart           ✅ Complete rewrite with 3 palettes
├── theme_provider.dart      ✅ Enhanced Riverpod + Hive integration  
└── theme_selector_widget.dart ✅ New interactive theme picker

lib/features/settings/presentation/screens/
└── app_settings_screen.dart ✅ Integrated theme selector

docs/
├── SRS.md                   ✅ Updated with theme implementation
└── PROJECT_TRACKING.md      ✅ Updated progress tracking
```

### 🎯 User Experience
- **Instant Theme Switching** - Live preview and immediate application
- **Persistent Preferences** - Theme choice survives app restarts
- **Optimized Reading** - Each theme optimized for different reading conditions
- **Cultural Sensitivity** - Colors and typography chosen for Islamic content

---

## [2024.11.1] - Previous Release

### ✅ Completed Features (Previous Releases)
- Prayer Times system with AlAdhan API integration
- Robust Athan notification system with exact alarms
- Qibla Finder with GPS-based compass
- Zakat Calculator with live gold/silver prices
- Islamic Content system (daily verses, hadith, duas)
- Multi-language support (English, Bengali, Arabic, Urdu)
- Quran Reader Phase 1 (reading, audio, bookmarks)
- Complete Clean Architecture with Riverpod
- GoRouter navigation system
- Hive local storage with offline capability

### 🏗️ Technical Infrastructure
- Flutter 3.x with Material 3 base implementation
- Riverpod 2.x state management
- Clean Architecture (Domain/Data/Presentation)
- Cross-platform support (iOS, Android, Web)
- Comprehensive error handling and testing

---

## Development Guidelines

### 📋 Update Tracking Requirements
Whenever making changes to the project, the following documents MUST be updated:

1. **TODO List** - Mark completed tasks, add new ones
2. **SRS.md** - Update implementation status and technical details
3. **PROJECT_TRACKING.md** - Update feature completion status
4. **CHANGELOG.md** - Document all changes with technical details

### 🎯 Version Numbering
- **Major.Minor.Patch** format (YYYY.MM.Patch)
- **Major**: Year (e.g., 2024)
- **Minor**: Month (e.g., 12 for December)
- **Patch**: Increment for hotfixes within the month

### 📝 Commit Message Format
```
type(scope): brief description

- Detailed explanation
- Multiple bullet points for complex changes
- Reference to updated documentation

Updated: SRS.md, PROJECT_TRACKING.md, CHANGELOG.md
```

---

**May Allah (SWT) accept our efforts and make this project beneficial for the Ummah. Ameen.**

جزاك الله خيراً (JazakAllahu Khairan) - May Allah reward you with goodness.
