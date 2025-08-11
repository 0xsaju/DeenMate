# DeenMate - Your Deen Companion

بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم

**The most comprehensive, user-friendly Islamic utility platform for the global Muslim community**

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart](https://img.shields.io/badge/Dart-3.x-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey)

## 🌙 About

DeenMate is a production-ready Islamic utility super-app built with Flutter 3.x following Clean Architecture principles. It provides essential Islamic tools and calculators with beautiful, accessible UI design following Islamic design principles.

### ✨ Features

- **🕐 Prayer Times** - Accurate prayer times with notifications and Azan
- **🧭 Qibla Finder** - GPS-based direction to Kaaba with compass
- **💰 Zakat Calculator** - Comprehensive Zakat calculation with multiple asset types
- **📖 Islamic Content** - Daily Quran verses, Hadith, and Duas
- **🌙 Sawm Tracker** - Ramadan fasting tracker (Coming Soon)
- **📜 Islamic Will** - Generate Islamic will according to Shariah (Coming Soon)
- **📱 Responsive Design** - Works on iOS, Android, and Web
- **🌍 Multi-language** - English, Bengali, Arabic support
- **🎨 Islamic UI** - Beautiful Islamic-themed Material 3 design

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

### 📁 Project Structure
```
lib/
├── core/                    # Core utilities and configurations
│   ├── constants/          # App-wide constants
│   ├── error/              # Error handling and failures
│   ├── theme/              # Islamic Material 3 theming
│   ├── utils/              # Islamic utility functions
│   └── routing/            # GoRouter configuration
│
├── features/               # Feature modules
│   ├── prayer_times/      # Prayer Times feature (Clean Architecture)
│   │   ├── domain/        # Business logic & entities
│   │   ├── data/          # Data sources & repositories
│   │   └── presentation/  # UI & state management
│   ├── salah_times/       # Alternative prayer times implementation
│   ├── qibla/             # Qibla Finder feature
│   ├── zakat/             # Zakat Calculator feature
│   ├── islamic_content/   # Islamic Content feature
│   ├── home/              # Home screen and navigation
│   ├── settings/          # App settings and preferences
│   └── onboarding/        # User onboarding flow
│
└── main.dart              # App entry point
```

### 🛠️ Tech Stack

- **Frontend**: Flutter 3.x with Material 3
- **State Management**: Riverpod 2.x + Provider pattern
- **Navigation**: GoRouter with type-safe routing
- **Local Storage**: Hive + SharedPreferences
- **HTTP Client**: Dio with interceptors
- **PDF Generation**: PDF package for reports
- **Testing**: Unit tests + Widget tests
- **Architecture**: Clean Architecture with SOLID principles

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/deenmate.git
   cd deenmate
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### 📱 Running on Different Platforms

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome

# Desktop (macOS)
flutter run -d macos
```

## 🕐 Prayer Times Features

### 🕌 Core Functionality
- **Real-time Prayer Times** - AlAdhan API integration with live data
- **Location-based Accuracy** - GPS-powered precise prayer times
- **Multiple Calculation Methods** - ISNA, MWL, Umm al-Qura, Egyptian, Karachi, etc.
- **Madhab Support** - Hanafi, Shafi'i, Maliki, Hanbali specific timings
- **Offline Caching** - Smart caching for reliability
- **Real-time Countdown** - Live countdown to next prayer
- **Prayer Status Tracking** - Mark prayers as completed with visual indicators
- **Hijri Date Integration** - Islamic calendar date alongside Gregorian
- **Sunrise Time Display** - Important for fasting and Ishraq timing
- **12/24 Hour Format** - User preference-based time display
- **Dark/Light Mode** - Automatic and manual theme switching
- **Responsive Design** - Mobile-first, tablet and desktop optimized
- **Bengali Localization** - Native Islamic terms and translations
- **Arabic Prayer Names** - Authentic Arabic names with transliterations

### 🔔 Notification System
- **Cross-platform Notifications** - Prayer time alerts for iOS, Android, Web
- **Pre-Prayer Reminders** - Configurable reminders (5, 10, 15 minutes before)
- **Custom Azan Audio** - Multiple traditional Azan recordings
- **Snooze Functionality** - Delay notifications with custom intervals
- **Do Not Disturb** - Smart scheduling around sleep hours
- **Silent Mode Options** - Respect device silent mode settings
- **Permission Handling** - Graceful notification permission management
- **Multiple Muadhin Voices** - Abdul Basit, Mishary Rashid, Sudais, etc.
- **Volume Control** - Adjustable Athan volume
- **Vibration Settings** - Customizable vibration patterns
- **Full Screen Notifications** - Optional full-screen Athan display
- **Auto-completion** - Automatically mark prayer as completed after Athan

## 🧭 Qibla Finder Features

### 🕋 Core Functionality
- **GPS-based Direction** - Accurate Qibla direction from anywhere
- **Beautiful Islamic UI** - Animated compass with Arabic design elements
- **Distance to Mecca** - Shows exact distance to Kaaba
- **Real-time Compass** - Live compass updates with device rotation
- **Permission Handling** - Graceful location permission management
- **Manual Location Input** - Enter location manually if GPS unavailable
- **Compass Calibration** - Device compass calibration guidance
- **Direction Accuracy** - High-precision Qibla calculation algorithms

## 💰 Zakat Calculator Features

### 📊 Comprehensive Asset Categories
- **Cash & Bank Balances** - All liquid assets
- **Precious Metals** - Gold and silver with live prices
- **Business Assets** - Inventory, receivables, stock
- **Investments** - Stocks, bonds, mutual funds, ETFs
- **Real Estate** - Investment properties only
- **Agricultural Produce** - Crops with different rates
- **Livestock** - According to Islamic guidelines
- **Other Assets** - Loans given, deposits, etc.

### 🔄 Advanced Calculations
- **Live Metal Prices** - Real-time gold/silver prices
- **Nisab Calculation** - Both gold and silver standards
- **Multiple Currencies** - USD, BDT, EUR, GBP, SAR, AED, etc.
- **Hawl Tracking** - Islamic lunar year calculation
- **Detailed Reports** - PDF generation with Islamic references
- **Debt Management** - Complete liability tracking and deduction
- **Data Persistence** - Save and resume calculations
- **Export & Share** - Share calculations and results
- **Islamic References** - Quran and Hadith citations in reports

## 📖 Islamic Content Features

### 📜 Daily Quranic Verses
- **Authentic Translations** - Arabic, English, Bengali
- **Transliteration** - Easy pronunciation guide
- **Thematic Organization** - Verses categorized by themes
- **Beautiful Typography** - Proper Arabic fonts (Amiri)
- **Copy & Share** - Easy sharing functionality

### 🗣️ Daily Hadith Collection
- **Authentic Sources** - Bukhari, Muslim, Tirmidhi, etc.
- **Complete Citations** - Narrator and source information
- **Multi-language** - Arabic, English, Bengali translations
- **Thematic Categories** - Organized by Islamic themes
- **Scholarly Accuracy** - Verified authentic hadith only

### 🤲 Daily Duas
- **Occasion-based** - Morning, evening, meals, sleep, etc.
- **Benefits Explained** - Spiritual benefits of each dua
- **Proper Pronunciation** - Transliteration included
- **Complete Collection** - Essential daily supplications

### 📅 Islamic Calendar
- **Hijri Dates** - Accurate Islamic calendar
- **Event Reminders** - Ramadan, Eid, Ashura, etc.
- **Dual Calendar** - Both Hijri and Gregorian display
- **Upcoming Events** - Smart event notifications

### ⭐ 99 Names of Allah
- **Asma ul-Husna** - Complete collection of divine names
- **Deep Meanings** - English and Bengali translations
- **Daily Contemplation** - Rotating display for reflection
- **Beautiful Presentation** - Gradient cards with Islamic styling

## 🎨 Islamic Design System

### 🌿 Color Palette
- **Primary Green**: `#2E7D32` - Traditional Islamic green
- **Secondary Gold**: `#FFD700` - Islamic calligraphy gold
- **Tertiary Blue**: `#1565C0` - Masjid dome blue
- **Cream White**: `#FAF9F6` - Prayer mat cream
- **Quran Purple**: `#7B1FA2` - Quranic content
- **Hadith Orange**: `#FF8F00` - Hadith content
- **Dua Brown**: `#5D4037` - Supplication content

### 🔤 Typography
- **Arabic Text**: Uthmanic Hafs & Noto Sans Arabic
- **English Text**: Roboto with proper scaling
- **Bengali Text**: Noto Sans Bengali
- **Islamic Headers**: Amiri for decorative Arabic

### 🕌 UI Components
- **Islamic Headers** - Bismillah and Quranic verses
- **Geometric Patterns** - Islamic art-inspired designs
- **Prayer Time Cards** - Beautiful time displays
- **Calculation Results** - Clear, accessible layouts

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Widget tests
flutter test test/widget_test/

# Unit tests
flutter test test/unit_test/

# Integration tests
flutter test integration_test/
```

## 📱 State Management

Uses **Riverpod 2.x** and **Provider pattern** for reactive state management:

### 🏗️ Provider Architecture
```dart
// Repository providers
final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>(...);

// Use case providers
final getPrayerTimesUsecaseProvider = Provider<GetPrayerTimesUsecase>(...);

// State notifiers
final prayerTimesNotifierProvider = 
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>(...);

// Future providers
final currentPrayerTimesProvider = FutureProvider<PrayerTimes>(...);
```

## 🌐 API Integration

### 📊 External APIs
- **AlAdhan API** - Live prayer times with multiple calculation methods
- **Metal Prices API** - Live gold/silver prices for Zakat calculations
- **Currency Conversion** - Multiple currency support
- **Location Services** - GPS for Qibla direction

### 🔄 Offline Support
- **Hive Database** - Local calculation storage
- **Cached Prayer Times** - Offline prayer time fallback
- **Local Data** - Islamic content and offline calculations

## 🌍 Internationalization

### 🗣️ Supported Languages
- **English** (en_US) - Primary language
- **Bengali** (bn_BD) - Bangladesh market
- **Arabic** (ar_SA) - Islamic content

### 📝 Localization Files
```
assets/translations/
├── en.json
├── bn.json
└── ar.json
```

## 📚 Islamic References

All calculations and guidelines are based on authentic Islamic sources:

### 📖 Quranic References
- **Prayer Times**: Quran 17:78, 11:114
- **Zakat Obligation**: Quran 2:110, 9:103
- **Eight Categories**: Quran 9:60
- **Nisab Guidelines**: Various Hadith

### 📜 Hadith Sources
- **Bukhari & Muslim** - Prayer time guidelines
- **Abu Dawud** - Agricultural Zakat
- **Tirmidhi** - Business asset guidelines

## 🤝 Contributing

We welcome contributions from the Muslim developer community!

### 📋 Guidelines
1. **Fork** the repository
2. **Create** a feature branch
3. **Follow** Islamic guidelines in features
4. **Test** thoroughly
5. **Submit** a pull request

### 🔍 Code Standards
- Follow **Clean Architecture**
- Use **Riverpod** for state management
- Include **Islamic references** where applicable
- Write **comprehensive tests**
- Follow **Flutter style guide**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤲 Acknowledgments

- **Allah (SWT)** for guidance and blessings
- **Islamic scholars** for authentic references
- **Flutter community** for excellent framework
- **Muslim developers** worldwide for inspiration

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/0xsaju/deenmate/issues)
- **Discussions**: [GitHub Discussions](https://github.com/0xsaju/deenmate/discussions)
- **Email**: support@deenmate.com

---

## 🌟 Roadmap

### 🔮 Upcoming Features
- [ ] **Sawm Tracker** - Complete Ramadan companion
- [ ] **Islamic Will** - Shariah-compliant will generator
- [ ] **Dhikr Counter** - Digital tasbih
- [ ] **Islamic Calendar** - Hijri calendar with events
- [ ] **Halal Scanner** - Ingredient checker
- [ ] **Mosque Finder** - Nearby mosque locator

### 🎯 Version 2.0 Goals
- [ ] **AI Islamic Chatbot** - Fiqh Q&A system
- [ ] **Community Features** - Connect with local Muslims
- [ ] **Islamic Learning** - Courses and content
- [ ] **Charity Platform** - Zakat distribution network

---

**May Allah accept our efforts and make this app beneficial for the Ummah. Ameen.**

جزاك الله خيراً (JazakAllahu Khairan) - May Allah reward you with goodness.