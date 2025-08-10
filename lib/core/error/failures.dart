import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Base class for all failures in the application
/// Following Clean Architecture principles with Islamic context
@freezed
abstract class Failure with _$Failure {
  // Network Failures
  const factory Failure.networkFailure({
    required String message,
    String? details,
  }) = NetworkFailure;

  const factory Failure.serverFailure({
    required String message,
    required int statusCode,
    String? details,
  }) = ServerFailure;

  const factory Failure.timeoutFailure({
    @Default('Request timeout. Please check your connection.') String message,
  }) = TimeoutFailure;

  // Location & Permission Failures
  const factory Failure.locationPermissionDenied({
    @Default('Location permission is required for accurate Qibla and prayer times.')
    String message,
  }) = LocationPermissionDenied;

  const factory Failure.locationServiceDisabled({
    @Default('Location services are disabled. Please enable them in settings.')
    String message,
  }) = LocationServiceDisabled;

  const factory Failure.locationUnavailable({
    @Default('Unable to determine your location. Please try again.')
    String message,
  }) = LocationUnavailable;

  // Zakat Calculation Failures
  const factory Failure.invalidZakatInput({
    required String field,
    required String message,
  }) = InvalidZakatInput;

  const factory Failure.nisabCalculationFailure({
    @Default('Unable to calculate Nisab. Please check gold/silver prices.')
    String message,
  }) = NisabCalculationFailure;

  const factory Failure.metalPriceUnavailable({
    @Default('Current gold/silver prices are unavailable. Using cached values.')
    String message,
  }) = MetalPriceUnavailable;

  // Prayer Time Failures
  const factory Failure.prayerTimeCalculationFailure({
    @Default('Unable to calculate prayer times for your location.')
    String message,
  }) = PrayerTimeCalculationFailure;

  const factory Failure.invalidCalculationMethod({
    required String method,
    @Default('Invalid prayer time calculation method selected.')
    String message,
  }) = InvalidCalculationMethod;

  // Qibla Calculation Failures
  const factory Failure.qiblaCalculationFailure({
    @Default('Unable to calculate Qibla direction. Please check your location.')
    String message,
  }) = QiblaCalculationFailure;

  const factory Failure.compassUnavailable({
    @Default('Compass sensor is not available on this device.')
    String message,
  }) = CompassUnavailable;

  // Islamic Content Failures
  const factory Failure.quranApiFailure({
    @Default('Unable to fetch Quran content. Please try again later.')
    String message,
  }) = QuranApiFailure;

  const factory Failure.hadithDataFailure({
    @Default('Unable to load Hadith content. Please try again later.')
    String message,
  }) = HadithDataFailure;

  const factory Failure.islamicCalendarFailure({
    @Default('Unable to calculate Hijri date. Please try again.')
    String message,
  }) = IslamicCalendarFailure;

  // File & Storage Failures
  const factory Failure.fileWriteFailure({
    required String fileName,
    @Default('Unable to save file. Please check storage permissions.')
    String message,
  }) = FileWriteFailure;

  const factory Failure.fileReadFailure({
    required String fileName,
    @Default('Unable to read file. File may be corrupted or missing.')
    String message,
  }) = FileReadFailure;

  const factory Failure.pdfGenerationFailure({
    @Default('Unable to generate PDF report. Please try again.')
    String message,
  }) = PdfGenerationFailure;

  const factory Failure.storagePermissionDenied({
    @Default('Storage permission is required to save files.')
    String message,
  }) = StoragePermissionDenied;

  // Database Failures
  const factory Failure.databaseFailure({
    required String operation,
    required String message,
  }) = DatabaseFailure;

  const factory Failure.cacheFailure({
    @Default('Cache operation failed. Some data may not be available offline.')
    String message,
  }) = CacheFailure;

  // Authentication Failures
  const factory Failure.authenticationFailure({
    @Default('Authentication failed. Please check your credentials.')
    String message,
  }) = AuthenticationFailure;

  const factory Failure.unauthorizedAccess({
    @Default('You are not authorized to access this resource.')
    String message,
  }) = UnauthorizedAccess;

  // Validation Failures
  const factory Failure.validationFailure({
    required String field,
    required String message,
  }) = ValidationFailure;

  const factory Failure.islamicValidationFailure({
    required String field,
    required String message,
    String? islamicReference,
  }) = IslamicValidationFailure;

  // Will Generation Failures
  const factory Failure.willGenerationFailure({
    @Default('Unable to generate Islamic will. Please check your inputs.')
    String message,
  }) = WillGenerationFailure;

  const factory Failure.inheritanceCalculationFailure({
    @Default('Unable to calculate Islamic inheritance shares.')
    String message,
  }) = InheritanceCalculationFailure;

  // Notification Failures
  const factory Failure.notificationPermissionDenied({
    @Default('Notification permission is required for prayer reminders.')
    String message,
  }) = NotificationPermissionDenied;

  const factory Failure.notificationScheduleFailure({
    @Default('Unable to schedule notifications. Please try again.')
    String message,
  }) = NotificationScheduleFailure;

  // Audio Failures
  const factory Failure.audioPlaybackFailure({
    @Default('Unable to play audio. Please check your device settings.')
    String message,
  }) = AudioPlaybackFailure;

  const factory Failure.athanAudioUnavailable({
    @Default('Athan audio is not available. Please download audio files.')
    String message,
  }) = AthanAudioUnavailable;

  // Generic Failures
  const factory Failure.unknownFailure({
    @Default('An unexpected error occurred. Please try again.')
    String message,
    String? details,
  }) = UnknownFailure;

  const factory Failure.featureNotImplemented({
    required String feature,
    @Default('This feature is not yet implemented.')
    String message,
  }) = FeatureNotImplemented;

  // Parsing Failures
  const factory Failure.jsonParsingFailure({
    required String source,
    @Default('Failed to parse data. Please try again.')
    String message,
  }) = JsonParsingFailure;

  const factory Failure.dateParsingFailure({
    required String dateString,
    @Default('Invalid date format provided.')
    String message,
  }) = DateParsingFailure;

  // API Rate Limiting
  const factory Failure.rateLimitExceeded({
    @Default('Too many requests. Please wait before trying again.')
    String message,
    int? retryAfterSeconds,
  }) = RateLimitExceeded;

  // Offline Failures
  const factory Failure.offlineFailure({
    @Default('This feature requires internet connection.')
    String message,
  }) = OfflineFailure;

  const factory Failure.syncFailure({
    @Default('Unable to sync data. Will retry when connection is restored.')
    String message,
  }) = SyncFailure;
}

/// Extension to get user-friendly error messages
extension FailureExtension on Failure {
  String get userMessage => when(
    networkFailure: (message, details) => message,
    serverFailure: (message, statusCode, details) => message,
    timeoutFailure: (message) => message,
    locationPermissionDenied: (message) => message,
    locationServiceDisabled: (message) => message,
    locationUnavailable: (message) => message,
    invalidZakatInput: (field, message) => message,
    nisabCalculationFailure: (message) => message,
    metalPriceUnavailable: (message) => message,
    prayerTimeCalculationFailure: (message) => message,
    invalidCalculationMethod: (method, message) => message,
    qiblaCalculationFailure: (message) => message,
    compassUnavailable: (message) => message,
    quranApiFailure: (message) => message,
    hadithDataFailure: (message) => message,
    islamicCalendarFailure: (message) => message,
    fileWriteFailure: (fileName, message) => message,
    fileReadFailure: (fileName, message) => message,
    pdfGenerationFailure: (message) => message,
    storagePermissionDenied: (message) => message,
    databaseFailure: (operation, message) => message,
    cacheFailure: (message) => message,
    authenticationFailure: (message) => message,
    unauthorizedAccess: (message) => message,
    validationFailure: (field, message) => message,
    islamicValidationFailure: (field, message, islamicReference) => 
      islamicReference != null 
        ? '$message\n\nIslamic Reference: $islamicReference'
        : message,
    willGenerationFailure: (message) => message,
    inheritanceCalculationFailure: (message) => message,
    notificationPermissionDenied: (message) => message,
    notificationScheduleFailure: (message) => message,
    audioPlaybackFailure: (message) => message,
    athanAudioUnavailable: (message) => message,
    unknownFailure: (message, details) => message,
    featureNotImplemented: (feature, message) => message,
    jsonParsingFailure: (source, message) => message,
    dateParsingFailure: (dateString, message) => message,
    rateLimitExceeded: (message, retryAfterSeconds) => 
      retryAfterSeconds != null
        ? '$message Retry after $retryAfterSeconds seconds.'
        : message,
    offlineFailure: (message) => message,
    syncFailure: (message) => message,
  );

  bool get isNetworkFailure => this is NetworkFailure;
  bool get isServerFailure => this is ServerFailure;
  bool get isCacheFailure => this is CacheFailure;
  bool get isValidationFailure => this is ValidationFailure;

  bool get isNetworkRelated => when(
        serverFailure: (_, __, ___) => true,
        networkFailure: (_, __) => true,
        cacheFailure: (_) => false,
        locationPermissionDenied: (_) => false,
        locationServiceDisabled: (_) => false,
        locationUnavailable: (_) => false,
        athanAudioUnavailable: (_) => false,
        timeoutFailure: (_) => true,
        invalidZakatInput: (_, __) => false,
        nisabCalculationFailure: (_) => false,
        metalPriceUnavailable: (_) => false,
        prayerTimeCalculationFailure: (_) => false,
        invalidCalculationMethod: (_, __) => false,
        qiblaCalculationFailure: (_) => false,
        compassUnavailable: (_) => false,
        quranApiFailure: (_) => false,
        hadithDataFailure: (_) => false,
        islamicCalendarFailure: (_) => false,
        fileWriteFailure: (_, __) => false,
        fileReadFailure: (_, __) => false,
        pdfGenerationFailure: (_) => false,
        storagePermissionDenied: (_) => false,
        databaseFailure: (_, __) => false,
        authenticationFailure: (_) => false,
        unauthorizedAccess: (_) => false,
        validationFailure: (_, __) => false,
        islamicValidationFailure: (_, __, ___) => false,
        willGenerationFailure: (_) => false,
        inheritanceCalculationFailure: (_) => false,
        notificationPermissionDenied: (_) => false,
        notificationScheduleFailure: (_) => false,
        audioPlaybackFailure: (_) => false,
        unknownFailure: (_, __) => false,
        featureNotImplemented: (_, __) => false,
        jsonParsingFailure: (_, __) => false,
        dateParsingFailure: (_, __) => false,
        rateLimitExceeded: (_, __) => true,
        offlineFailure: (_) => true,
        syncFailure: (_) => true,
      );

  bool get isCacheRelated => when(
        serverFailure: (_, __, ___) => false,
        networkFailure: (_, __) => false,
        cacheFailure: (_) => true,
        locationPermissionDenied: (_) => false,
        locationServiceDisabled: (_) => false,
        locationUnavailable: (_) => false,
        athanAudioUnavailable: (_) => false,
        timeoutFailure: (_) => false,
        invalidZakatInput: (_, __) => false,
        nisabCalculationFailure: (_) => false,
        metalPriceUnavailable: (_) => false,
        prayerTimeCalculationFailure: (_) => false,
        invalidCalculationMethod: (_, __) => false,
        qiblaCalculationFailure: (_) => false,
        compassUnavailable: (_) => false,
        quranApiFailure: (_) => false,
        hadithDataFailure: (_) => false,
        islamicCalendarFailure: (_) => false,
        fileWriteFailure: (_, __) => false,
        fileReadFailure: (_, __) => false,
        pdfGenerationFailure: (_) => false,
        storagePermissionDenied: (_) => false,
        databaseFailure: (_, __) => false,
        authenticationFailure: (_) => false,
        unauthorizedAccess: (_) => false,
        validationFailure: (_, __) => false,
        islamicValidationFailure: (_, __, ___) => false,
        willGenerationFailure: (_) => false,
        inheritanceCalculationFailure: (_) => false,
        notificationPermissionDenied: (_) => false,
        notificationScheduleFailure: (_) => false,
        audioPlaybackFailure: (_) => false,
        unknownFailure: (_, __) => false,
        featureNotImplemented: (_, __) => false,
        jsonParsingFailure: (_, __) => false,
        dateParsingFailure: (_, __) => false,
        rateLimitExceeded: (_, __) => false,
        offlineFailure: (_) => false,
        syncFailure: (_) => false,
      );

  bool get isLocationRelated => when(
        serverFailure: (_, __, ___) => false,
        networkFailure: (_, __) => false,
        cacheFailure: (_) => false,
        locationPermissionDenied: (_) => true,
        locationServiceDisabled: (_) => true,
        locationUnavailable: (_) => true,
        athanAudioUnavailable: (_) => false,
        timeoutFailure: (_) => false,
        invalidZakatInput: (_, __) => false,
        nisabCalculationFailure: (_) => false,
        metalPriceUnavailable: (_) => false,
        prayerTimeCalculationFailure: (_) => false,
        invalidCalculationMethod: (_, __) => false,
        qiblaCalculationFailure: (_) => false,
        compassUnavailable: (_) => false,
        quranApiFailure: (_) => false,
        hadithDataFailure: (_) => false,
        islamicCalendarFailure: (_) => false,
        fileWriteFailure: (_, __) => false,
        fileReadFailure: (_, __) => false,
        pdfGenerationFailure: (_) => false,
        storagePermissionDenied: (_) => false,
        databaseFailure: (_, __) => false,
        authenticationFailure: (_) => false,
        unauthorizedAccess: (_) => false,
        validationFailure: (_, __) => false,
        islamicValidationFailure: (_, __, ___) => false,
        willGenerationFailure: (_) => false,
        inheritanceCalculationFailure: (_) => false,
        notificationPermissionDenied: (_) => false,
        notificationScheduleFailure: (_) => false,
        audioPlaybackFailure: (_) => false,
        unknownFailure: (_, __) => false,
        featureNotImplemented: (_, __) => false,
        jsonParsingFailure: (_, __) => false,
        dateParsingFailure: (_, __) => false,
        rateLimitExceeded: (_, __) => false,
        offlineFailure: (_) => false,
        syncFailure: (_) => false,
      );

  bool get isPermissionRelated => when(
        serverFailure: (_, __, ___) => false,
        networkFailure: (_, __) => false,
        cacheFailure: (_) => false,
        locationPermissionDenied: (_) => true,
        locationServiceDisabled: (_) => false,
        locationUnavailable: (_) => false,
        athanAudioUnavailable: (_) => false,
        timeoutFailure: (_) => false,
        invalidZakatInput: (_, __) => false,
        nisabCalculationFailure: (_) => false,
        metalPriceUnavailable: (_) => false,
        prayerTimeCalculationFailure: (_) => false,
        invalidCalculationMethod: (_, __) => false,
        qiblaCalculationFailure: (_) => false,
        compassUnavailable: (_) => false,
        quranApiFailure: (_) => false,
        hadithDataFailure: (_) => false,
        islamicCalendarFailure: (_) => false,
        fileWriteFailure: (_, __) => false,
        fileReadFailure: (_, __) => false,
        pdfGenerationFailure: (_) => false,
        storagePermissionDenied: (_) => true,
        databaseFailure: (_, __) => false,
        authenticationFailure: (_) => false,
        unauthorizedAccess: (_) => false,
        validationFailure: (_, __) => false,
        islamicValidationFailure: (_, __, ___) => false,
        willGenerationFailure: (_) => false,
        inheritanceCalculationFailure: (_) => false,
        notificationPermissionDenied: (_) => true,
        notificationScheduleFailure: (_) => false,
        audioPlaybackFailure: (_) => false,
        unknownFailure: (_, __) => false,
        featureNotImplemented: (_, __) => false,
        jsonParsingFailure: (_, __) => false,
        dateParsingFailure: (_, __) => false,
        rateLimitExceeded: (_, __) => false,
        offlineFailure: (_) => false,
        syncFailure: (_) => false,
      );

  bool get isUserInputRelated => when(
        serverFailure: (_, __, ___) => false,
        networkFailure: (_, __) => false,
        cacheFailure: (_) => false,
        locationPermissionDenied: (_) => false,
        locationServiceDisabled: (_) => false,
        locationUnavailable: (_) => false,
        athanAudioUnavailable: (_) => false,
        timeoutFailure: (_) => false,
        invalidZakatInput: (_, __) => true,
        nisabCalculationFailure: (_) => false,
        metalPriceUnavailable: (_) => false,
        prayerTimeCalculationFailure: (_) => false,
        invalidCalculationMethod: (_, __) => false,
        qiblaCalculationFailure: (_) => false,
        compassUnavailable: (_) => false,
        quranApiFailure: (_) => false,
        hadithDataFailure: (_) => false,
        islamicCalendarFailure: (_) => false,
        fileWriteFailure: (_, __) => false,
        fileReadFailure: (_, __) => false,
        pdfGenerationFailure: (_) => false,
        storagePermissionDenied: (_) => false,
        databaseFailure: (_, __) => false,
        authenticationFailure: (_) => false,
        unauthorizedAccess: (_) => false,
        validationFailure: (_, __) => true,
        islamicValidationFailure: (_, __, ___) => true,
        willGenerationFailure: (_) => false,
        inheritanceCalculationFailure: (_) => false,
        notificationPermissionDenied: (_) => false,
        notificationScheduleFailure: (_) => false,
        audioPlaybackFailure: (_) => false,
        unknownFailure: (_, __) => false,
        featureNotImplemented: (_, __) => false,
        jsonParsingFailure: (_, __) => false,
        dateParsingFailure: (_, __) => false,
        rateLimitExceeded: (_, __) => false,
        offlineFailure: (_) => false,
        syncFailure: (_) => false,
      );

  bool get requiresRetry => when(
        serverFailure: (_, statusCode, __) => statusCode >= 500,
        networkFailure: (_, __) => true,
        cacheFailure: (_) => false,
        locationPermissionDenied: (_) => false,
        locationServiceDisabled: (_) => false,
        locationUnavailable: (_) => false,
        athanAudioUnavailable: (_) => false,
        timeoutFailure: (_) => true,
        invalidZakatInput: (_, __) => false,
        nisabCalculationFailure: (_) => false,
        metalPriceUnavailable: (_) => false,
        prayerTimeCalculationFailure: (_) => false,
        invalidCalculationMethod: (_, __) => false,
        qiblaCalculationFailure: (_) => false,
        compassUnavailable: (_) => false,
        quranApiFailure: (_) => false,
        hadithDataFailure: (_) => false,
        islamicCalendarFailure: (_) => false,
        fileWriteFailure: (_, __) => false,
        fileReadFailure: (_, __) => false,
        pdfGenerationFailure: (_) => false,
        storagePermissionDenied: (_) => false,
        databaseFailure: (_, __) => false,
        authenticationFailure: (_) => false,
        unauthorizedAccess: (_) => false,
        validationFailure: (_, __) => false,
        islamicValidationFailure: (_, __, ___) => false,
        willGenerationFailure: (_) => false,
        inheritanceCalculationFailure: (_) => false,
        notificationPermissionDenied: (_) => false,
        notificationScheduleFailure: (_) => false,
        audioPlaybackFailure: (_) => false,
        unknownFailure: (_, __) => false,
        featureNotImplemented: (_, __) => false,
        jsonParsingFailure: (_, __) => false,
        dateParsingFailure: (_, __) => false,
        rateLimitExceeded: (_, __) => false,
        offlineFailure: (_) => false,
        syncFailure: (_) => true,
      );
}