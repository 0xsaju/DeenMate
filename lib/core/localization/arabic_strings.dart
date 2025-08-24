/// Arabic localization strings for DeenMate
/// Provides comprehensive Arabic translations for UI elements
class ArabicStrings {
  static const Map<String, String> strings = {
    // Navigation
    'home': 'الصفحة الرئيسية',
    'prayer': 'الصلاة',
    'zakat': 'الزكاة',
    'qibla': 'القبلة',
    'more': 'المزيد',
    
    // Common words
    'settings': 'الإعدادات',
    'profile': 'الملف الشخصي',
    'history': 'التاريخ',
    'reports': 'التقارير',
    'calculate': 'احسب',
    'save': 'حفظ',
    'share': 'مشاركة',
    'close': 'إغلاق',
    'ok': 'موافق',
    'cancel': 'إلغاء',
    'yes': 'نعم',
    'no': 'لا',
    'continue': 'متابعة',
    'back': 'رجوع',
    'next': 'التالي',
    'previous': 'السابق',
    'done': 'تم',
    'loading': 'جاري التحميل...',
    'error': 'خطأ',
    'success': 'نجح',
    
    // Islamic terms (kept in Arabic)
    'bismillah': 'بسم الله',
    'assalamualaikum': 'السلام عليكم',
    'inshallah': 'إن شاء الله',
    'mashallah': 'ما شاء الله',
    'subhanallah': 'سبحان الله',
    'alhamdulillah': 'الحمد لله',
    'allahu_akbar': 'الله أكبر',
    'astaghfirullah': 'أستغفر الله',
    'barakallahu_feek': 'بارك الله فيك',
    'jazakallahu_khairan': 'جزاك الله خيراً',
    
    // Prayer times
    'fajr': 'الفجر',
    'sunrise': 'الشروق',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
    'prayer_times': 'أوقات الصلاة',
    'next_prayer': 'الصلاة التالية',
    'current_prayer': 'الصلاة الحالية',
    'prayer_completed': 'تمت الصلاة',
    'time_remaining': 'الوقت المتبقي',
    'prayer_time': 'وقت الصلاة',
    'athan': 'الأذان',
    'iqamah': 'الإقامة',
    
    // Quran terms
    'quran': 'القرآن',
    'ayah': 'آية',
    'surah': 'سورة',
    'verse': 'آية',
    'chapter': 'سورة',
    'juz': 'جزء',
    'hizb': 'حزب',
    'ruku': 'ركوع',
    'page': 'صفحة',
    'translation': 'ترجمة',
    'tafsir': 'تفسير',
    'bookmark': 'إشارة مرجعية',
    'bookmarks': 'الإشارات المرجعية',
    'last_read': 'آخر قراءة',
    'search': 'بحث',
    
    // Audio terms
    'reciter': 'القارئ',
    'audio': 'الصوت',
    'play': 'تشغيل',
    'pause': 'إيقاف مؤقت',
    'stop': 'توقف',
    'download': 'تحميل',
    'offline': 'غير متصل',
    'online': 'متصل',
    
    // Zakat terms
    'zakat_calculator': 'حاسبة الزكاة',
    'zakat_due': 'الزكاة المستحقة',
    'zakat_amount': 'مبلغ الزكاة',
    'nisab': 'النصاب',
    'nisab_threshold': 'حد النصاب',
    'total_wealth': 'إجمالي الثروة',
    'zakatable_wealth': 'الثروة الخاضعة للزكاة',
    'gold': 'الذهب',
    'silver': 'الفضة',
    'cash': 'النقد',
    'savings': 'المدخرات',
    'business_assets': 'أصول تجارية',
    'investment': 'استثمار',
    'debt': 'دين',
    'loan': 'قرض',
    
    // Qibla terms
    'qibla_finder': 'محدد القبلة',
    'qibla_direction': 'اتجاه القبلة',
    'kaaba': 'الكعبة',
    'makkah': 'مكة',
    'direction_to_kaaba': 'الاتجاه إلى الكعبة',
    'compass': 'البوصلة',
    'location': 'الموقع',
    'latitude': 'خط العرض',
    'longitude': 'خط الطول',
  };

  /// Get Arabic translation for a key
  static String get(String key) {
    return strings[key] ?? key;
  }

  /// Get Arabic translation with fallback
  static String getWithFallback(String key, String fallback) {
    return strings[key] ?? fallback;
  }

  /// Check if translation exists
  static bool has(String key) {
    return strings.containsKey(key);
  }
}
