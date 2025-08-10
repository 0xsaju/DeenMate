import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import '../../../prayer_times/domain/entities/calculation_method.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

/// User preferences for the DeenMate app
@freezed
class UserPreferences with _$UserPreferences {
  @HiveType(typeId: 1)
  const factory UserPreferences({
    @HiveField(0) required String language,
    @HiveField(1) required double latitude,
    @HiveField(2) required double longitude,
    @HiveField(3) required String city,
    @HiveField(4) required String country,
    @HiveField(5) required String timezone,
    @HiveField(6) required String calculationMethodId,
    @HiveField(7) required String madhhab,
    @HiveField(8) required bool notificationsEnabled,
    @HiveField(9) required List<String> enabledPrayers,
    @HiveField(10) required String theme,
    @HiveField(11) required bool onboardingCompleted,
    @HiveField(12) DateTime? createdAt,
    @HiveField(13) DateTime? updatedAt,
    @HiveField(14) String? userName,
    @HiveField(15) Map<String, dynamic>? customCalculationParams,
    @HiveField(16) bool? locationPermissionGranted,
    @HiveField(17) String? notificationSound,
    @HiveField(18) bool? vibrationEnabled,
    @HiveField(19) int? notificationAdvanceMinutes,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

/// Language options
enum AppLanguage {
  english('en', 'English', 'English'),
  bengali('bn', 'বাংলা', 'Bengali'),
  urdu('ur', 'اردو', 'Urdu'),
  arabic('ar', 'العربية', 'Arabic');

  const AppLanguage(this.code, this.nativeName, this.englishName);
  
  final String code;
  final String nativeName;
  final String englishName;
  
  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Madhhab options
enum Madhhab {
  hanafi('Hanafi', 'حنفي', 'Most widely followed'),
  shafii("Shafi'i", 'شافعي', 'Popular in Southeast Asia'),
  maliki('Maliki', 'مالكي', 'North and West Africa'),
  hanbali('Hanbali', 'حنبلي', 'Arabian Peninsula');

  const Madhhab(this.name, this.arabicName, this.description);
  
  final String name;
  final String arabicName;
  final String description;
  
  static Madhhab fromName(String name) {
    return Madhhab.values.firstWhere(
      (madhhab) => madhhab.name == name,
      orElse: () => Madhhab.hanafi,
    );
  }
}

/// Theme options
enum AppTheme {
  light('light', 'Light Theme'),
  dark('dark', 'Dark Theme'),
  system('system', 'System Default');

  const AppTheme(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  static AppTheme fromValue(String value) {
    return AppTheme.values.firstWhere(
      (theme) => theme.value == value,
      orElse: () => AppTheme.system,
    );
  }
}

/// Prayer names for notifications
enum PrayerName {
  fajr('Fajr', 'الفجر', 'ফজর'),
  dhuhr('Dhuhr', 'الظهر', 'যুহর'),
  asr('Asr', 'العصر', 'আসর'),
  maghrib('Maghrib', 'المغرب', 'মাগরিব'),
  isha('Isha', 'العشاء', 'ইশা');

  const PrayerName(this.englishName, this.arabicName, this.bengaliName);
  
  final String englishName;
  final String arabicName;
  final String bengaliName;
  
  static PrayerName fromEnglishName(String name) {
    return PrayerName.values.firstWhere(
      (prayer) => prayer.englishName == name,
      orElse: () => PrayerName.fajr,
    );
  }
}

/// Default user preferences
class DefaultUserPreferences {
  static UserPreferences get defaultPreferences {
    return const UserPreferences(
      language: 'en',
      latitude: 23.8103, // Dhaka coordinates
      longitude: 90.4125,
      city: 'Dhaka',
      country: 'Bangladesh',
      timezone: 'Asia/Dhaka',
      calculationMethodId: 'MWL',
      madhhab: 'Hanafi',
      notificationsEnabled: true,
      enabledPrayers: ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'],
      theme: 'system',
      onboardingCompleted: false,
      locationPermissionGranted: false,
      notificationSound: 'azan_default',
      vibrationEnabled: true,
      notificationAdvanceMinutes: 5,
    );
  }

  static UserPreferences createWithDefaults() {
    final now = DateTime.now();
    return defaultPreferences.copyWith(
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// User preferences repository interface
abstract class UserPreferencesRepository {
  Future<UserPreferences?> getPreferences();
  Future<void> savePreferences(UserPreferences preferences);
  Future<void> updatePreferences(UserPreferences preferences);
  Future<void> clearPreferences();
  Future<bool> isOnboardingCompleted();
  Future<void> markOnboardingCompleted();
}

/// User preferences service
class UserPreferencesService {
  
  UserPreferencesService(this._repository);
  final UserPreferencesRepository _repository;

  /// Get current user preferences
  Future<UserPreferences> getPreferences() async {
    final preferences = await _repository.getPreferences();
    return preferences ?? DefaultUserPreferences.createWithDefaults();
  }

  /// Save user preferences
  Future<void> savePreferences(UserPreferences preferences) async {
    final updatedPreferences = preferences.copyWith(
      updatedAt: DateTime.now(),
    );
    await _repository.savePreferences(updatedPreferences);
  }

  /// Update specific preference fields
  Future<void> updatePreferences({
    String? language,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? timezone,
    String? calculationMethodId,
    String? madhhab,
    bool? notificationsEnabled,
    List<String>? enabledPrayers,
    String? theme,
    String? userName,
    Map<String, dynamic>? customCalculationParams,
    bool? locationPermissionGranted,
    String? notificationSound,
    bool? vibrationEnabled,
    int? notificationAdvanceMinutes,
  }) async {
    final currentPreferences = await getPreferences();
    
    final updatedPreferences = currentPreferences.copyWith(
      language: language ?? currentPreferences.language,
      latitude: latitude ?? currentPreferences.latitude,
      longitude: longitude ?? currentPreferences.longitude,
      city: city ?? currentPreferences.city,
      country: country ?? currentPreferences.country,
      timezone: timezone ?? currentPreferences.timezone,
      calculationMethodId: calculationMethodId ?? currentPreferences.calculationMethodId,
      madhhab: madhhab ?? currentPreferences.madhhab,
      notificationsEnabled: notificationsEnabled ?? currentPreferences.notificationsEnabled,
      enabledPrayers: enabledPrayers ?? currentPreferences.enabledPrayers,
      theme: theme ?? currentPreferences.theme,
      userName: userName ?? currentPreferences.userName,
      customCalculationParams: customCalculationParams ?? currentPreferences.customCalculationParams,
      locationPermissionGranted: locationPermissionGranted ?? currentPreferences.locationPermissionGranted,
      notificationSound: notificationSound ?? currentPreferences.notificationSound,
      vibrationEnabled: vibrationEnabled ?? currentPreferences.vibrationEnabled,
      notificationAdvanceMinutes: notificationAdvanceMinutes ?? currentPreferences.notificationAdvanceMinutes,
      updatedAt: DateTime.now(),
    );

    await _repository.updatePreferences(updatedPreferences);
  }

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    return _repository.isOnboardingCompleted();
  }

  /// Mark onboarding as completed
  Future<void> markOnboardingCompleted() async {
    final currentPreferences = await getPreferences();
    final updatedPreferences = currentPreferences.copyWith(
      onboardingCompleted: true,
      updatedAt: DateTime.now(),
    );
    await _repository.savePreferences(updatedPreferences);
  }

  /// Get calculation method from preferences
  static CalculationMethod getCalculationMethod(UserPreferences preferences) {
    return CalculationMethod.fromName(preferences.calculationMethodId) ?? 
           CalculationMethod.mwl;
  }

  /// Get madhhab from preferences
  Madhhab getMadhhab(UserPreferences preferences) {
    return Madhhab.fromName(preferences.madhhab);
  }

  /// Get app language from preferences
  AppLanguage getAppLanguage(UserPreferences preferences) {
    return AppLanguage.fromCode(preferences.language);
  }

  /// Get app theme from preferences
  AppTheme getAppTheme(UserPreferences preferences) {
    return AppTheme.fromValue(preferences.theme);
  }

  /// Get enabled prayers for notifications
  List<PrayerName> getEnabledPrayers(UserPreferences preferences) {
    return preferences.enabledPrayers
        .map(PrayerName.fromEnglishName)
        .toList();
  }
}
