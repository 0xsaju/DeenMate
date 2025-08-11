import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_tracking.dart';
import '../../domain/entities/prayer_calculation_settings.dart';
import '../../domain/entities/athan_settings.dart';
import '../../domain/entities/calculation_method.dart';
import '../../domain/entities/prayer_statistics.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import '../../data/datasources/location_service.dart' as location_service;
import '../../data/datasources/aladhan_api.dart';
import '../../data/datasources/prayer_times_local_storage.dart';
import '../../data/repositories/prayer_times_repository_impl.dart';
import '../../data/services/calculation_method_service.dart';
import '../../domain/usecases/get_prayer_times_usecase.dart';
import '../../domain/usecases/get_daily_prayer_times_usecase.dart';
import '../../domain/usecases/get_monthly_prayer_times_usecase.dart';
import '../../domain/usecases/get_current_prayer_usecase.dart';
import '../../domain/usecases/get_current_and_next_prayer_usecase.dart';
import '../../domain/usecases/get_prayer_tracking_history_usecase.dart';
import '../../domain/usecases/mark_prayer_completed_usecase.dart';
import '../../domain/usecases/track_prayer_usecase.dart';


/// Prayer Times Dependency Injection Providers
/// Following Clean Architecture with Riverpod 2.x

// Core Dependencies
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.headers = {
    'Accept': 'application/json',
    'User-Agent': 'DeenMate/1.0.0',
  };
  return dio;
});

// Data Sources
final aladhanApiProvider = Provider<AladhanApi>((ref) {
  final dio = ref.read(dioProvider);
  return AladhanApi(dio);
});

final prayerTimesLocalStorageProvider = Provider<PrayerTimesLocalStorage>((ref) {
  return PrayerTimesLocalStorage();
});

final locationServiceProvider = Provider<location_service.LocationService>((ref) {
  return location_service.LocationService();
});

// Repository
final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>((ref) {
  return PrayerTimesRepositoryImpl(
    aladhanApi: ref.read(aladhanApiProvider),
    localStorage: ref.read(prayerTimesLocalStorageProvider),
  );
});

// Use Cases
final getDailyPrayerTimesUsecaseProvider = Provider<GetDailyPrayerTimesUsecase>((ref) {
  return GetDailyPrayerTimesUsecase(ref.read(prayerTimesRepositoryProvider));
});

final getMonthlyPrayerTimesUsecaseProvider = Provider<GetMonthlyPrayerTimesUsecase>((ref) {
  return GetMonthlyPrayerTimesUsecase(ref.read(prayerTimesRepositoryProvider));
});

final getCurrentAndNextPrayerUsecaseProvider = Provider<GetCurrentAndNextPrayerUsecase>((ref) {
  return GetCurrentAndNextPrayerUsecase(ref.read(prayerTimesRepositoryProvider));
});

final markPrayerCompletedUsecaseProvider = Provider<MarkPrayerCompletedUsecase>((ref) {
  return MarkPrayerCompletedUsecase(ref.read(prayerTimesRepositoryProvider));
});

final getPrayerTrackingHistoryUsecaseProvider = Provider<GetPrayerTrackingHistoryUsecase>((ref) {
  return GetPrayerTrackingHistoryUsecase(ref.read(prayerTimesRepositoryProvider));
});

// Current Location Provider
final currentLocationProvider = FutureProvider<Location>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return locationService.getCurrentLocation();
});

// Calculation Method Service Provider
final calculationMethodServiceProvider = Provider<CalculationMethodService>((ref) {
  return CalculationMethodService.instance;
});

// Available Calculation Methods Provider
final availableCalculationMethodsProvider = Provider<List<CalculationMethod>>((ref) {
  final service = ref.read(calculationMethodServiceProvider);
  return service.getAllMethods();
});

// Recommended Methods Provider (depends on location)
final recommendedCalculationMethodsProvider = Provider.family<List<CalculationMethod>, Location>((ref, location) {
  final service = ref.read(calculationMethodServiceProvider);
  return service.getRecommendedMethods(location);
});

// Current Calculation Method Provider
final currentCalculationMethodProvider = FutureProvider<CalculationMethod>((ref) async {
  final settings = await ref.read(prayerSettingsProvider.future);
  final service = ref.read(calculationMethodServiceProvider);
  final result = service.getMethodById(settings.calculationMethod);
  if (result == null) {
    throw const Failure.invalidCalculationMethod(
      method: 'Unknown',
      message: 'Calculation method not found',
    );
  }
  return result;
});

// Current Prayer Times Provider
final currentPrayerTimesProvider = FutureProvider<PrayerTimes>((ref) async {
  final repository = ref.read(prayerTimesRepositoryProvider);
  final result = await repository.getCurrentPrayerTimes();
  
  return result.fold(
    (failure) => throw failure,
    (prayerTimes) => prayerTimes,
  );
});

// Current and Next Prayer Provider
final currentAndNextPrayerProvider = FutureProvider<PrayerDetail>((ref) async {
  final usecase = ref.read(getCurrentAndNextPrayerUsecaseProvider);
  final location = await ref.read(currentLocationProvider.future);
  
  final result = await usecase(
    location: location,
    settings: await ref.read(prayerSettingsProvider.future),
  );
  
  return result.fold(
    (failure) => throw failure,
    (data) => PrayerDetail(
      currentPrayer: data['currentPrayer'] as String?,
      nextPrayer: data['nextPrayer'] as String?,
      prayerTimes: data['prayerTimes'] as PrayerTimes,
      timeUntilNextPrayer: const Duration(minutes: 30), // TODO: Calculate actual time
    ),
  );
});

// Daily Prayer Times Provider
final dailyPrayerTimesProvider = FutureProvider.family<PrayerTimes, DateTime>((ref, date) async {
  final usecase = ref.read(getDailyPrayerTimesUsecaseProvider);
  final location = await ref.read(currentLocationProvider.future);
  
  final result = await usecase(
    date: date,
    location: location,
    settings: await ref.read(prayerSettingsProvider.future),
  );
  
  return result.fold(
    (failure) => throw failure,
    (prayerTimes) => prayerTimes,
  );
});

// Weekly Prayer Times Provider
final weeklyPrayerTimesProvider = FutureProvider<List<PrayerTimes>>((ref) async {
  final repository = ref.read(prayerTimesRepositoryProvider);
  final result = await repository.getWeeklyPrayerTimes();
  
  return result.fold(
    (failure) => throw failure,
    (prayerTimesList) => prayerTimesList,
  );
});

// Monthly Prayer Times Provider
final monthlyPrayerTimesProvider = FutureProvider.family<List<PrayerTimes>, DateTime>((ref, date) async {
  final usecase = ref.read(getMonthlyPrayerTimesUsecaseProvider);
  final location = await ref.read(currentLocationProvider.future);
  
  final startDate = DateTime(date.year, date.month, 1);
  final endDate = DateTime(date.year, date.month + 1, 0);
  
  final result = await usecase(
    startDate: startDate,
    endDate: endDate,
    location: location,
    settings: await ref.read(prayerSettingsProvider.future),
  );
  
  return result.fold(
    (failure) => throw failure,
    (prayerTimesList) => prayerTimesList,
  );
});

// Prayer Tracking History Provider
final prayerTrackingHistoryProvider = FutureProvider.family<List<PrayerTracking>, DateTime>((ref, date) async {
  final usecase = ref.read(getPrayerTrackingHistoryUsecaseProvider);
  
  final startDate = DateTime(date.year, date.month, 1);
  final endDate = DateTime(date.year, date.month + 1, 0);
  final location = await ref.read(currentLocationProvider.future);
  
  final result = await usecase(
    startDate: startDate,
    endDate: endDate,
    location: location,
  );
  
  return result.fold(
    (failure) => throw failure,
    (trackingList) => trackingList,
  );
});

// Prayer Statistics Provider
final prayerStatisticsProvider = FutureProvider.family<PrayerStatistics, DateTime>((ref, date) async {
  final repository = ref.read(prayerTimesRepositoryProvider);
  
  final startDate = DateTime(date.year, date.month, 1);
  final endDate = DateTime(date.year, date.month + 1, 0);
  
  final result = await repository.getPrayerStatistics(
    fromDate: startDate,
    toDate: endDate,
  );
  
  return result.fold(
    (failure) => throw failure,
    (statistics) => statistics as PrayerStatistics,
  );
});

// Prayer Settings Provider
final prayerSettingsProvider = FutureProvider<PrayerCalculationSettings>((ref) async {
  final repository = ref.read(prayerTimesRepositoryProvider);
  final result = await repository.getPrayerSettings();
  
  return result.fold(
    (failure) => throw failure,
    (settings) => settings,
  );
});

// Athan Settings Provider
final athanSettingsFutureProvider = FutureProvider<AthanSettings>((ref) async {
  final repository = ref.read(prayerTimesRepositoryProvider);
  final result = await repository.getAthanSettings();
  
  return result.fold(
    (failure) => throw failure,
    (settings) => settings,
  );
});

// Islamic Events Provider
final islamicEventsProvider = FutureProvider.family<List<IslamicEvent>, DateTime>((ref, date) async {
  final repository = ref.read(prayerTimesRepositoryProvider);
  final result = await repository.getIslamicEvents(date: date);
  
  return result.fold(
    (failure) => throw failure,
    (events) => events,
  );
});

// Qibla Direction Provider
final qiblaDirectionProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(prayerTimesRepositoryProvider);
  final location = await ref.read(currentLocationProvider.future);
  
  final result = await repository.getQiblaDirection(location);
  return result.fold(
    (failure) => throw failure,
    (direction) => direction,
  );
});

// Offline Status Provider
final offlineStatusProvider = FutureProvider.family<bool, DateTime>((ref, date) async {
  final repository = ref.read(prayerTimesRepositoryProvider);
  final result = await repository.arePrayerTimesAvailableOffline(date: date);
  
  return result.fold(
    (failure) => false,
    (isAvailable) => isAvailable,
  );
});

// Location Context Provider
final locationContextProvider = FutureProvider<LocationContext>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  final location = await ref.read(currentLocationProvider.future);
  
  return locationService.getIslamicLocationContext(location);
});

// Time Until Next Prayer Provider
final timeUntilNextPrayerProvider = StreamProvider<Duration>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (count) {
    return ref.watch(currentAndNextPrayerProvider).when(
      data: (prayerDetail) => prayerDetail.timeUntilNextPrayer,
      loading: () => Duration.zero,
      error: (_, __) => Duration.zero,
    );
  });
});

// Prayer Completion State Notifier
final prayerCompletionProvider = StateNotifierProvider<PrayerCompletionNotifier, Map<String, bool>>((ref) {
  return PrayerCompletionNotifier();
});

// Location State Notifier
final locationStateProvider = StateNotifierProvider<LocationStateNotifier, LocationState>((ref) {
  return LocationStateNotifier(ref.read(locationServiceProvider));
});

// Prayer Times Settings State Notifier
final prayerTimesSettingsProvider = StateNotifierProvider<PrayerTimesSettingsNotifier, PrayerCalculationSettings>((ref) {
  return PrayerTimesSettingsNotifier(ref.read(prayerTimesRepositoryProvider));
});

// State Notifiers

class PrayerCompletionNotifier extends StateNotifier<Map<String, bool>> {
  PrayerCompletionNotifier() : super({});

  void markPrayerCompleted(
    String prayerName,
    DateTime date,
    bool isOnTime,
  ) {
    // For now we only keep daily completion state in-memory.
    // Persisting and on-time tracking is handled by repository elsewhere.
    state = {...state, prayerName.toLowerCase(): true};
  }

  void markPrayerIncomplete(String prayerName) {
    state = {...state, prayerName.toLowerCase(): false};
  }

  bool isPrayerCompleted(String prayerName) {
    return state[prayerName.toLowerCase()] ?? false;
  }

  Map<String, bool> get completedPrayers => state;

  Future<void> loadTodaysPrayerStatus() async {
    // TODO: Integrate with repository/local storage to load persisted status
    // For now, no-op to satisfy refresh flow
    return;
  }
}

class LocationStateNotifier extends StateNotifier<LocationState> {
  LocationStateNotifier(this._locationService) : super(const LocationState.loading());
  final location_service.LocationService _locationService;

  Future<void> getCurrentLocation() async {
    try {
      state = const LocationState.loading();
      final location = await _locationService.getCurrentLocation();
      state = LocationState.loaded(location);
    } catch (e) {
      state = LocationState.error(Failure.locationUnavailable(
        message: 'Unable to get current location',
      ));
    }
  }

  Future<void> searchLocations(String query) async {
    try {
      state = const LocationState.loading();
      final locations = await _locationService.searchLocations(query);
      if (locations.isNotEmpty) {
        state = LocationState.loaded(locations.first);
      } else {
        state = LocationState.error(Failure.locationUnavailable(
          message: 'No locations found for "$query"',
        ));
      }
    } catch (e) {
      state = LocationState.error(Failure.locationUnavailable(
        message: 'Error searching locations',
      ));
    }
  }
}

class PrayerTimesSettingsNotifier extends StateNotifier<PrayerCalculationSettings> {
  
  PrayerTimesSettingsNotifier(this._repository) : super(PrayerCalculationSettings(
    calculationMethod: 'MWL',
    madhab: Madhab.shafi,
    adjustments: const {},
    highLatitudeRule: HighLatitudeRule.middleOfNight,
    isDST: false,
  ),) {
    _loadSettings();
  }

  final PrayerTimesRepository _repository;

  Future<void> _loadSettings() async {
    final result = await _repository.getPrayerSettings();
    result.fold(
      (failure) => null, // Keep default settings on failure
      (settings) => state = settings,
    );
  }

  Future<void> _saveSettings(PrayerCalculationSettings settings) async {
    final result = await _repository.savePrayerSettings(settings);
    result.fold(
      (failure) => null, // Handle error appropriately
      (_) => state = settings,
    );
  }

  Future<void> updateCalculationMethod(String method) async {
    final newSettings = state.copyWith(calculationMethod: method);
    await _saveSettings(newSettings);
  }

  Future<void> updateMadhab(String madhab) async {
    final newSettings = state.copyWith(madhab: Madhab.values.firstWhere((m) => m.name == madhab));
    await _saveSettings(newSettings);
  }

  Future<void> updateAdjustments(Map<String, double> newAdjustments) async {
    final newSettings = state.copyWith(adjustments: newAdjustments);
    await _saveSettings(newSettings);
  }

  Future<void> updateHighLatitudeRule(HighLatitudeRule rule) async {
    final newSettings = state.copyWith(highLatitudeRule: rule);
    await _saveSettings(newSettings);
  }

  Future<void> updateDST(bool isDST) async {
    final newSettings = state.copyWith(isDST: isDST);
    await _saveSettings(newSettings);
  }
}

// State Classes

sealed class LocationState {
  const LocationState();
  
  const factory LocationState.loading() = LocationLoading;
  const factory LocationState.loaded(Location location) = LocationLoaded;
  const factory LocationState.error(Failure failure) = LocationError;
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  const LocationLoaded(this.location);
  final Location location;
}

class LocationError extends LocationState {
  const LocationError(this.failure);
  final Failure failure;
}

// Parameter Classes

class MonthlyParams {
  
  const MonthlyParams({required this.year, required this.month});
  final int year;
  final int month;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyParams &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month;
  
  @override
  int get hashCode => year.hashCode ^ month.hashCode;
}

class DateRangeParams {
  
  const DateRangeParams({required this.fromDate, required this.toDate});
  final DateTime fromDate;
  final DateTime toDate;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRangeParams &&
          runtimeType == other.runtimeType &&
          fromDate == other.fromDate &&
          toDate == other.toDate;
  
  @override
  int get hashCode => fromDate.hashCode ^ toDate.hashCode;
}
