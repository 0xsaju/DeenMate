/// Urdu localization strings for DeenMate
/// Provides comprehensive Urdu translations for UI elements
class UrduStrings {
  static const Map<String, String> strings = {
    // Navigation
    'home': 'گھر',
    'prayer': 'نماز',
    'zakat': 'زکوٰة',
    'qibla': 'قبلہ',
    'more': 'مزید',
    
    // Common words
    'settings': 'سیٹنگز',
    'profile': 'پروفائل',
    'history': 'تاریخ',
    'reports': 'رپورٹس',
    'calculate': 'حساب لگائیں',
    'save': 'محفوظ کریں',
    'share': 'شیئر کریں',
    'close': 'بند کریں',
    'ok': 'ٹھیک ہے',
    'cancel': 'منسوخ',
    'yes': 'ہاں',
    'no': 'نہیں',
    'continue': 'جاری رکھیں',
    'back': 'واپس',
    'next': 'اگلا',
    'previous': 'پچھلا',
    'done': 'مکمل',
    'loading': 'لوڈ ہو رہا ہے...',
    'error': 'خرابی',
    'success': 'کامیاب',
    
    // Islamic terms
    'bismillah': 'بسم اللہ',
    'assalamualaikum': 'السلام علیکم',
    'inshallah': 'انشاء اللہ',
    'mashallah': 'ماشاء اللہ',
    'subhanallah': 'سبحان اللہ',
    'alhamdulillah': 'الحمد للہ',
    'allahu_akbar': 'اللہ اکبر',
    'astaghfirullah': 'استغفراللہ',
    'barakallahu_feek': 'بارک اللہ فیک',
    'jazakallahu_khairan': 'جزاک اللہ خیر',
    
    // Prayer times
    'fajr': 'فجر',
    'sunrise': 'طلوع آفتاب',
    'dhuhr': 'ظہر',
    'asr': 'عصر',
    'maghrib': 'مغرب',
    'isha': 'عشاء',
    'prayer_times': 'نماز کے اوقات',
    'next_prayer': 'اگلی نماز',
    'current_prayer': 'موجودہ نماز',
    'prayer_completed': 'نماز مکمل',
    'time_remaining': 'باقی وقت',
    'prayer_time': 'نماز کا وقت',
    'athan': 'اذان',
    'iqamah': 'اقامت',
    
    // Quran terms
    'quran': 'قرآن',
    'ayah': 'آیت',
    'surah': 'سورہ',
    'verse': 'آیت',
    'chapter': 'سورہ',
    'juz': 'پارہ',
    'hizb': 'حزب',
    'ruku': 'رکوع',
    'page': 'صفحہ',
    'translation': 'ترجمہ',
    'tafsir': 'تفسیر',
    'bookmark': 'بک مارک',
    'bookmarks': 'بک مارکس',
    'last_read': 'آخری بار پڑھا',
    'search': 'تلاش',
    
    // Audio terms
    'reciter': 'قاری',
    'audio': 'آڈیو',
    'play': 'چلائیں',
    'pause': 'روکیں',
    'stop': 'بند کریں',
    'download': 'ڈاؤن لوڈ',
    'offline': 'آف لائن',
    'online': 'آن لائن',
    
    // Zakat terms
    'zakat_calculator': 'زکوٰة کیلکولیٹر',
    'zakat_due': 'واجب زکوٰة',
    'zakat_amount': 'زکوٰة کی رقم',
    'nisab': 'نصاب',
    'nisab_threshold': 'نصاب کی حد',
    'total_wealth': 'کل دولت',
    'zakatable_wealth': 'زکوٰة کے قابل دولت',
    'gold': 'سونا',
    'silver': 'چاندی',
    'cash': 'نقد',
    'savings': 'بچت',
    'business_assets': 'کاروباری اثاثے',
    'investment': 'سرمایہ کاری',
    'debt': 'قرض',
    'loan': 'قرضہ',
  };

  /// Get Urdu translation for a key
  static String get(String key) {
    return strings[key] ?? key;
  }

  /// Get Urdu translation with fallback
  static String getWithFallback(String key, String fallback) {
    return strings[key] ?? fallback;
  }

  /// Check if translation exists
  static bool has(String key) {
    return strings.containsKey(key);
  }
}
