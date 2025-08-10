/// Core application constants for DeenMate
/// Contains Islamic-specific constants and app-wide values
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'DeenMate';
  static const String appVersion = '1.0.0';
  static const String appSlogan = 'Your Complete Islamic Companion';

  // Islamic Constants
  static const double zakatPercentage = 2.5; // 2.5% Zakat rate
  static const int hijriMonths = 12;
  static const int lunarYearDays = 354; // Approximate lunar year days
  static const int solarYearDays = 365;

  // Kaaba Coordinates (for Qibla calculation)
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  // Nisab Values (in grams)
  static const double goldNisabGrams = 87.48; // 7.5 tola of gold
  static const double silverNisabGrams = 612.36; // 52.5 tola of silver

  // Prayer Calculation Methods
  static const Map<String, String> calculationMethods = {
    'MWL': 'Muslim World League',
    'ISNA': 'Islamic Society of North America',
    'Egypt': 'Egyptian General Authority of Survey',
    'Makkah': 'Umm Al-Qura University, Makkah',
    'Karachi': 'University of Islamic Sciences, Karachi',
    'Tehran': 'Institute of Geophysics, University of Tehran',
    'Jafari': 'Shia Ithna-Ashari, Leva Institute, Qum',
  };

  // API Endpoints
  static const String aladhanBaseUrl = 'https://api.aladhan.com/v1';
  static const String quranApiBaseUrl = 'https://api.quran.com/v4';
  static const String metalsApiBaseUrl = 'https://api.metals.live/v1';

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'bn', 'ar'];
  static const String defaultLanguage = 'en';

  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String zakatHistoryKey = 'zakat_history';
  static const String prayerTrackingKey = 'prayer_tracking';
  static const String fastingDataKey = 'fasting_data';
  static const String islamicContentKey = 'islamic_content_cache';

  // Notification Channels
  static const String prayerNotificationChannel = 'prayer_notifications';
  static const String zakatReminderChannel = 'zakat_reminders';
  static const String fastingReminderChannel = 'fasting_reminders';

  // File Extensions
  static const String pdfExtension = '.pdf';
  static const String jsonExtension = '.json';

  // Islamic Greetings by Time
  static const Map<String, String> islamicGreetings = {
    'fajr': 'بارك الله في صباحك', // Barakallahu fi sabahik
    'morning': 'صباح الخير', // Sabah al-khayr
    'afternoon': 'طاب مساؤك', // Tab masa\'uk
    'maghrib': 'مساء الخير', // Masa\' al-khayr
    'isha': 'تصبح على خير', // Tusbih ala khayr
  };

  // Zakat Categories
  static const List<String> zakatCategories = [
    'Cash & Bank Balance',
    'Gold & Silver',
    'Business Assets',
    'Investment Portfolio',
    'Rental Income',
    'Agricultural Produce',
    'Livestock',
    'Precious Stones',
  ];

  // Islamic Months (Arabic)
  static const List<String> hijriMonthNames = [
    'محرم', // Muharram
    'صفر', // Safar
    'ربيع الأول', // Rabi' al-awwal
    'ربيع الثاني', // Rabi' al-thani
    'جمادى الأولى', // Jumada al-awwal
    'جمادى الثانية', // Jumada al-thani
    'رجب', // Rajab
    'شعبان', // Sha'ban
    'رمضان', // Ramadan
    'شوال', // Shawwal
    'ذو القعدة', // Dhu al-Qi'dah
    'ذو الحجة', // Dhu al-Hijjah
  ];

  // Islamic Months (English)
  static const List<String> hijriMonthNamesEn = [
    'Muharram',
    'Safar',
    "Rabi' al-awwal",
    "Rabi' al-thani",
    'Jumada al-awwal',
    'Jumada al-thani',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhu al-Qi'dah",
    'Dhu al-Hijjah',
  ];

  // Prayer Names
  static const List<String> prayerNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  // Currency Codes
  static const List<String> supportedCurrencies = [
    'USD', // US Dollar
    'BDT', // Bangladeshi Taka
    'EUR', // Euro
    'GBP', // British Pound
    'SAR', // Saudi Riyal
    'AED', // UAE Dirham
    'INR', // Indian Rupee
    'PKR', // Pakistani Rupee
    'MYR', // Malaysian Ringgit
    'IDR', // Indonesian Rupiah
  ];

  // Error Messages
  static const String networkError = 'Network connection failed. Please check your internet connection.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String locationPermissionDenied = 'Location permission is required for accurate calculations.';
  static const String invalidInputError = 'Please enter valid input values.';

  // Success Messages
  static const String calculationSaved = 'Calculation saved successfully!';
  static const String reportGenerated = 'Report generated successfully!';
  static const String dataExported = 'Data exported successfully!';

  // Islamic Duas (Keys for localization)
  static const String bismillah = 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم';
  static const String alhamdulillah = 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِين';
  static const String subhanallah = 'سُبْحَانَ اللَّه';
  static const String allahummaBaarik = 'اللَّهُمَّ بَارِك';
}