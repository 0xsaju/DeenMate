import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('bn'),
    Locale('ur'),
    Locale('ar')
  ];

  /// The main app title
  ///
  /// In en, this message translates to:
  /// **'DeenMate'**
  String get appTitle;

  /// Title for the welcome onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to DeenMate'**
  String get onboardingWelcomeTitle;

  /// Subtitle for the welcome onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Your Complete Islamic Companion'**
  String get onboardingWelcomeSubtitle;

  /// Title for language selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get onboardingLanguageTitle;

  /// Subtitle for language selection screen
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the app'**
  String get onboardingLanguageSubtitle;

  /// Title for username input screen
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get onboardingUsernameTitle;

  /// Subtitle for username input screen
  ///
  /// In en, this message translates to:
  /// **'Enter your name or preferred nickname'**
  String get onboardingUsernameSubtitle;

  /// Title for location setup screen
  ///
  /// In en, this message translates to:
  /// **'Set Your Location'**
  String get onboardingLocationTitle;

  /// Subtitle for location setup screen
  ///
  /// In en, this message translates to:
  /// **'This helps us provide accurate prayer times'**
  String get onboardingLocationSubtitle;

  /// Title for calculation method screen
  ///
  /// In en, this message translates to:
  /// **'Prayer Time Calculation'**
  String get onboardingCalculationTitle;

  /// Subtitle for calculation method screen
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred calculation method'**
  String get onboardingCalculationSubtitle;

  /// Title for madhhab selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Your Madhhab'**
  String get onboardingMadhhabTitle;

  /// Subtitle for madhhab selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose your Islamic school of thought'**
  String get onboardingMadhhabSubtitle;

  /// Title for notifications setup screen
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get onboardingNotificationsTitle;

  /// Subtitle for notifications setup screen
  ///
  /// In en, this message translates to:
  /// **'Stay connected with prayer reminders'**
  String get onboardingNotificationsSubtitle;

  /// Title for theme selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Your Theme'**
  String get onboardingThemeTitle;

  /// Subtitle for theme selection screen
  ///
  /// In en, this message translates to:
  /// **'Select your preferred visual style'**
  String get onboardingThemeSubtitle;

  /// Title for completion screen
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get onboardingCompleteTitle;

  /// Subtitle for completion screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to DeenMate. Let\'s begin your journey.'**
  String get onboardingCompleteSubtitle;

  /// Navigation label for home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// Navigation label for Quran screen
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get navigationQuran;

  /// Navigation label for Hadith screen
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get navigationHadith;

  /// Navigation label for more options screen
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navigationMore;

  /// Title for prayer times section
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimesTitle;

  /// Fajr prayer name
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// Sunrise time label
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// Dhuhr prayer name
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// Asr prayer name
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// Maghrib prayer name
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// Isha prayer name
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// Label for next prayer
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayer;

  /// Label for current prayer
  ///
  /// In en, this message translates to:
  /// **'Current Prayer'**
  String get currentPrayer;

  /// Label for time remaining
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// Title for Quran section
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranTitle;

  /// Label for last read section
  ///
  /// In en, this message translates to:
  /// **'Last Read'**
  String get quranLastRead;

  /// Button text to continue reading
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get quranContinue;

  /// Search placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get quranSearch;

  /// Navigation section title
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get quranNavigation;

  /// Surah navigation tab
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get quranSurah;

  /// Page navigation tab
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get quranPage;

  /// Juz navigation tab
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get quranJuz;

  /// Hizb navigation tab
  ///
  /// In en, this message translates to:
  /// **'Hizb'**
  String get quranHizb;

  /// Ruku navigation tab
  ///
  /// In en, this message translates to:
  /// **'Ruku'**
  String get quranRuku;

  /// Title for settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Language setting option
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Theme setting option
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Notifications setting option
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Prayer times setting option
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get settingsPrayerTimes;

  /// Quran setting option
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get settingsQuran;

  /// About setting option
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Common continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Common back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Common next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// Common save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Common cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Common done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Common loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Common error text
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// Common success text
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// Common yes text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// Common no text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// Common OK text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Bengali language name
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get languageBengali;

  /// Urdu language name
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get languageUrdu;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// Language status - fully supported
  ///
  /// In en, this message translates to:
  /// **'Fully Supported'**
  String get languageFullySupported;

  /// Language status - coming soon
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get languageComingSoon;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Light Serenity theme option
  ///
  /// In en, this message translates to:
  /// **'Light Serenity'**
  String get themeLightSerenity;

  /// Night Calm theme option
  ///
  /// In en, this message translates to:
  /// **'Night Calm'**
  String get themeNightCalm;

  /// Heritage Sepia theme option
  ///
  /// In en, this message translates to:
  /// **'Heritage Sepia'**
  String get themeHeritageSepia;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// Location error message
  ///
  /// In en, this message translates to:
  /// **'Location access is required for accurate prayer times.'**
  String get errorLocation;

  /// Permission error message
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get errorPermission;

  /// Information about location requirement
  ///
  /// In en, this message translates to:
  /// **'Location access helps provide accurate prayer times for your area.'**
  String get infoLocationRequired;

  /// Information about notifications
  ///
  /// In en, this message translates to:
  /// **'Get notified before each prayer time.'**
  String get infoNotificationsHelp;

  /// Information about theme selection
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred visual style for the app.'**
  String get infoThemeDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'bn', 'en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
