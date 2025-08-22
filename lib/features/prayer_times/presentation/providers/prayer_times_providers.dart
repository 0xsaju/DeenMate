import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/network_providers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/network_providers.dart' as net_core;
import 'dart:async';

// import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../../../core/state/prayer_settings_state.dart';

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
// import '../../domain/usecases/get_prayer_times_usecase.dart';
import '../../domain/usecases/get_daily_prayer_times_usecase.dart';
import '../../domain/usecases/get_monthly_prayer_times_usecase.dart';
// import '../../domain/usecases/get_current_prayer_usecase.dart';
import '../../domain/usecases/get_current_and_next_prayer_usecase.dart';
import '../../domain/usecases/get_prayer_tracking_history_usecase.dart';
import '../../domain/usecases/mark_prayer_completed_usecase.dart';
// duplicate removed
// import '../../domain/usecases/track_prayer_usecase.dart';

/// Prayer Times Dependency Injection Providers
/// Following Clean Architecture with Riverpod 2.x

// Core Dependencies: reuse central Dio with interceptors
final dioProvider = Provider<Dio>((ref) {
  return ref.read(net_core.dioProvider);
});

// Data Sources
final aladhanApiProvider = Provider<AladhanApi>((ref) {
  final dio = ref.read(dioProvider);
  return AladhanApi(dio);
});

final prayerTimesLocalStorageProvider =
    Provider<PrayerTimesLocalStorage>((ref) {
  return PrayerTimesLocalStorage();
});

final locationServiceProvider =
    Provider<location_service.LocationService>((ref) {
  return location_service.LocationService();
});

// Repository
final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>((ref) {
  return PrayerTimesRepositoryImpl(
    aladhanApi: ref.read(aladhanApiProvider),
    localStorage: ref.read(prayerTimesLocalStorageProvider),
  );
});

/// App-start initializer: initialize local storage and prefetch today's prayer times.
/// Fire-and-forget; consumers can watch to ensure init has run.
final prayerLocalInitAndPrefetchProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(prayerTimesLocalStorageProvider);
  await storage.initialize();
  // Prefetch using preferred location if available to avoid GPS prompt
  final repo = ref.read(prayerTimesRepositoryProvider);
  final settings = await ref.read(prayerSettingsProvider.future);
  final preferredEither = await repo.getPreferredLocation();
  final preferred = preferredEither.fold<Location?>(
    (_) => null,
    (loc) => loc,
  );
  if (preferred != null) {
    await repo.getPrayerTimes(
      date: DateTime.now(),
      location: preferred,
      settings: settings,
    );
  } else {
    await repo.getCurrentPrayerTimes();
  }
});

// Use Cases
final getDailyPrayerTimesUsecaseProvider =
    Provider<GetDailyPrayerTimesUsecase>((ref) {
  return GetDailyPrayerTimesUsecase(ref.read(prayerTimesRepositoryProvider));
});

final getMonthlyPrayerTimesUsecaseProvider =
    Provider<GetMonthlyPrayerTimesUsecase>((ref) {
  return GetMonthlyPrayerTimesUsecase(ref.read(prayerTimesRepositoryProvider));
});

final getCurrentAndNextPrayerUsecaseProvider =
    Provider<GetCurrentAndNextPrayerUsecase>((ref) {
  return GetCurrentAndNextPrayerUsecase(
      ref.read(prayerTimesRepositoryProvider));
});

final markPrayerCompletedUsecaseProvider =
    Provider<MarkPrayerCompletedUsecase>((ref) {
  return MarkPrayerCompletedUsecase(ref.read(prayerTimesRepositoryProvider));
});

final getPrayerTrackingHistoryUsecaseProvider =
    Provider<GetPrayerTrackingHistoryUsecase>((ref) {
  return GetPrayerTrackingHistoryUsecase(
      ref.read(prayerTimesRepositoryProvider));
});

// Current Location Provider
final currentLocationProvider = FutureProvider<Location>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return locationService.getCurrentLocation();
});

/// Time format preference provider (true = 24h, false = 12h)
final timeFormat24hProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final fmt = prefs.getString('time_format');
  return fmt == '24h';
});

// Calculation Method Service Provider
final calculationMethodServiceProvider =
    Provider<CalculationMethodService>((ref) {
  return CalculationMethodService.instance;
});

// Available Calculation Methods Provider
final availableCalculationMethodsProvider =
    Provider<List<CalculationMethod>>((ref) {
  final service = ref.read(calculationMethodServiceProvider);
  return service.getAllMethods();
});

// Recommended Methods Provider (depends on location)
final recommendedCalculationMethodsProvider =
    Provider.family<List<CalculationMethod>, Location>((ref, location) {
  final service = ref.read(calculationMethodServiceProvider);
  return service.getRecommendedMethods(location);
});

// Prayer Settings Provider using global state
final prayerSettingsProvider =
    FutureProvider<PrayerCalculationSettings>((ref) async {
  print('=== PRAYER SETTINGS PROVIDER START ===');

  // Load settings from global state
  await PrayerSettingsState.instance.loadSettings();
  final method = PrayerSettingsState.instance.calculationMethod;
  final madhhabString = PrayerSettingsState.instance.madhhab;

  print('PrayerSettingsProvider: Using calculation method: $method');
  print('=== PRAYER SETTINGS PROVIDER END ===');

  return PrayerCalculationSettings(
    calculationMethod: method,
    madhab: PrayerTimesSettingsNotifier._madhabFromStringStatic(madhhabString),
    // No adjustments - use exact API times
    adjustments: const {},
  );
});

// Current Calculation Method Provider
final currentCalculationMethodProvider =
    FutureProvider<CalculationMethod>((ref) async {
  final settings = await ref.read(prayerSettingsProvider.future);
  final service = ref.read(calculationMethodServiceProvider);
  final result = service.getMethodById(settings.calculationMethod);
  if (result == null) {
    // Return default method if not found
    return CalculationMethod.mwl;
  }
  return result;
});

// Current Prayer Times Provider
final currentPrayerTimesProvider = FutureProvider<PrayerTimes>((ref) async {
  print('PrayerTimesProvider: Starting to fetch prayer times...');
  try {
    // Try preferred location first (manual city), then GPS fallback inside repo
    final repository = ref.read(prayerTimesRepositoryProvider);
    final preferred = await repository.getPreferredLocation();
    if (preferred.isRight() && preferred.getOrElse(() => null) != null) {
      // Use preferred location path with persisted madhab
      await PrayerSettingsState.instance.loadSettings();
      final method = PrayerSettingsState.instance.calculationMethod;
      final madhhabString = PrayerSettingsState.instance.madhhab;
      final settings = PrayerCalculationSettings(
        calculationMethod: method,
        madhab:
            PrayerTimesSettingsNotifier._madhabFromStringStatic(madhhabString),
        // No adjustments - use exact API times
        adjustments: const {},
      );
      final result = await repository.getPrayerTimes(
        date: DateTime.now(),
        location: preferred.getOrElse(() => null)!,
        settings: settings,
      );
      return result.fold((failure) => throw failure, (pt) => pt);
    }

    // No preferred location saved: fall back to repository's current flow
    await PrayerSettingsState.instance.loadSettings();
    final result = await repository.getCurrentPrayerTimes();

    return result.fold(
      (failure) {
        // If API fails, throw the failure instead of using mock data
        print('PrayerTimesProvider: API failed: ${failure.message}');
        throw failure;
      },
      (prayerTimes) {
        print('PrayerTimesProvider: Successfully got prayer times from API');
        return prayerTimes;
      },
    );
  } catch (e) {
    // If online fetch fails, try to serve cached data immediately
    print('PrayerTimesProvider: Error getting prayer times: $e');
    final repo = ref.read(prayerTimesRepositoryProvider);
    final preferred = await repo.getPreferredLocation();
    final preferredLoc = preferred.fold<Location?>(
      (_) => null,
      (loc) => loc,
    );
    if (preferredLoc != null) {
      final cachedEither = await repo.getCachedPrayerTimes(
          date: DateTime.now(), location: preferredLoc);
      final cached =
          cachedEither.fold<List<PrayerTimes>>((_) => const [], (list) => list);
      if (cached.isNotEmpty) {
        final today = DateTime.now();
        final match = cached.firstWhere(
          (pt) =>
              pt.date.year == today.year &&
              pt.date.month == today.month &&
              pt.date.day == today.day,
          orElse: () => cached.first,
        );
        return match;
      }
    }
    rethrow;
  }
});

/// Fast cached prayer times for instant boot (stale-while-revalidate UX)
final cachedCurrentPrayerTimesProvider =
    FutureProvider<PrayerTimes?>((ref) async {
  try {
    final repo = ref.read(prayerTimesRepositoryProvider);
    final preferredLocEither = await repo.getPreferredLocation();
    final preferredLoc = preferredLocEither.fold<Location?>(
      (_) => null,
      (loc) => loc,
    );
    if (preferredLoc == null) {
      // Fallback: return most recent cached day if no preferred location is set
      final storage = ref.read(prayerTimesLocalStorageProvider);
      await storage.initialize();
      final mostRecent = await storage.getMostRecentPrayerTimes();
      return mostRecent;
    }

    final now = DateTime.now();
    final cachedEither =
        await repo.getCachedPrayerTimes(date: now, location: preferredLoc);
    final storage = ref.read(prayerTimesLocalStorageProvider);
    await storage.initialize();
    final listOrNull = cachedEither.fold<List<PrayerTimes>?>(
      (_) => null,
      (list) => list,
    );
    if (listOrNull != null) {
      for (final pt in listOrNull) {
        if (pt.date.year == now.year &&
            pt.date.month == now.month &&
            pt.date.day == now.day) {
          return pt;
        }
      }
    }
    // If today's not cached, fall back to most recent cached day
    return await storage.getMostRecentPrayerTimes();
  } catch (_) {
    return null;
  }
});

// Current and Next Prayer Provider
final currentAndNextPrayerProvider = FutureProvider<PrayerDetail>((ref) async {
  try {
    print('=== CURRENT AND NEXT PRAYER PROVIDER START ===');

    // Ensure settings are fresh
    final settings = await ref.read(prayerSettingsProvider.future);
    print(
        'CurrentAndNextPrayer: Using calculation method: ${settings.calculationMethod}');

    final usecase = ref.read(getCurrentAndNextPrayerUsecaseProvider);
    final repo = ref.read(prayerTimesRepositoryProvider);

    // Prefer saved manual city to avoid GPS prompts
    final preferredEither = await repo.getPreferredLocation();
    final preferred = preferredEither.fold<Location?>(
      (_) => null,
      (loc) => loc,
    );

    final Location location =
        preferred ?? await ref.read(currentLocationProvider.future);
    print('CurrentAndNextPrayer: Location source = '
        '${preferred != null ? 'preferred' : 'gps'}, '
        'lat=${location.latitude}, lon=${location.longitude}');

    final result = await usecase(
      location: location,
      settings: settings,
    );

    return result.fold(
      (failure) {
        print('API failed for current/next prayer: ${failure.message}');
        throw failure;
      },
      (data) {
        final prayerTimes = data['prayerTimes'] as PrayerTimes;
        final nextPrayerName = data['nextPrayer'] as String?;
        final currentPrayerName = data['currentPrayer'] as String?;

        Duration timeUntilNextPrayer = const Duration(minutes: 30);
        if (nextPrayerName != null) {
          final nextPrayerTime =
              _getPrayerTimeByName(prayerTimes, nextPrayerName);
          if (nextPrayerTime != null) {
            final now = DateTime.now();
            timeUntilNextPrayer = nextPrayerTime.difference(now);
          }
        }

        return PrayerDetail(
          currentPrayer: currentPrayerName,
          nextPrayer: nextPrayerName,
          prayerTimes: prayerTimes,
          timeUntilNextPrayer: timeUntilNextPrayer.isNegative
              ? Duration.zero
              : timeUntilNextPrayer,
        );
      },
    );
  } catch (e) {
    print('Error getting current/next prayer: $e');
    throw e;
  }
});
DateTime _rolloverIfBefore(DateTime time, DateTime reference) {
  return time.isBefore(reference) ? time.add(const Duration(days: 1)) : time;
}

// Alert banner modeling for header pill
enum AlertKind {
  upcoming,
  remaining,
  forbiddenSunrise,
  forbiddenZenith,
  forbiddenSunset,
}

class AlertBannerState {
  const AlertBannerState({
    required this.kind,
    this.prayerName,
    this.remaining,
    this.message,
    this.targetTime,
  });

  final AlertKind kind;
  final String? prayerName;
  final Duration? remaining;
  final String? message;
  final DateTime? targetTime;
}

const Duration _kUpcomingLeadWindow = Duration(minutes: 15);
const Duration _kSunriseForbiddenWindow = Duration(minutes: 15);
const Duration _kZenithForbiddenWindow = Duration(minutes: 5);
const Duration _kSunsetForbiddenWindow = Duration(minutes: 15);

DateTime? _getPrayerEndTimeFor(PrayerTimes pt, String currentName) {
  switch (currentName.toLowerCase()) {
    case 'fajr':
      return pt.sunrise.time;
    case 'dhuhr':
      return pt.asr.time;
    case 'asr':
      return pt.maghrib.time;
    case 'maghrib':
      return pt.isha.time;
    case 'isha':
      // Isha ends at Islamic midnight, not at Fajr
      return pt.midnight.time;
    default:
      return null;
  }
}

// Stream provider that emits the current alert banner state once per second
final alertBannerStateProvider = StreamProvider<AlertBannerState>((ref) async* {
  final detailAsync = ref.watch(currentAndNextPrayerOfflineAwareProvider);
  final cachedDetail = ref.watch(cachedCurrentAndNextPrayerProvider);

  AlertBannerState compute() {
    return detailAsync.maybeWhen(
      data: (detail) {
        final pt = detail.prayerTimes as PrayerTimes;
        final now = DateTime.now();

        final DateTime sunrise = _rolloverIfBefore(pt.sunrise.time, now);
        final DateTime dhuhr = _rolloverIfBefore(pt.dhuhr.time, now);
        final DateTime maghrib = _rolloverIfBefore(pt.maghrib.time, now);

        final DateTime sunriseStart = sunrise;
        final DateTime sunriseEnd = sunrise.add(_kSunriseForbiddenWindow);

        final zenithHalf =
            Duration(minutes: _kZenithForbiddenWindow.inMinutes ~/ 2);
        // Extend the forbidden window check to include 2 minutes before for smooth UX
        final DateTime zenithStart =
            dhuhr.subtract(zenithHalf).subtract(const Duration(minutes: 2));
        final DateTime zenithEnd = dhuhr.add(zenithHalf);

        final DateTime sunsetStart = maghrib.subtract(_kSunsetForbiddenWindow);
        final DateTime sunsetEnd = maghrib;

        if (now.isAfter(sunriseStart) && now.isBefore(sunriseEnd)) {
          return const AlertBannerState(
            kind: AlertKind.forbiddenSunrise,
            message: 'Salah is forbidden during sunrise',
          );
        }
        if (now.isAfter(zenithStart) && now.isBefore(zenithEnd)) {
          // Check if we're in the pre-forbidden period (buffer zone)
          final actualZenithStart = dhuhr.subtract(zenithHalf);
          if (now.isBefore(actualZenithStart)) {
            return const AlertBannerState(
              kind: AlertKind.forbiddenZenith,
              message: 'Approaching prohibited prayer time around noon',
            );
          } else {
            return const AlertBannerState(
              kind: AlertKind.forbiddenZenith,
              message: 'Salah is forbidden during solar noon (zenith)',
            );
          }
        }
        if (now.isAfter(sunsetStart) && now.isBefore(sunsetEnd)) {
          return const AlertBannerState(
            kind: AlertKind.forbiddenSunset,
            message: 'Salah is forbidden during sunset',
          );
        }

        final String? currentName = detail.currentPrayer;
        final String? nextName = detail.nextPrayer;
        final DateTime? nextTime = nextName != null
            ? _rolloverIfBefore(_getPrayerTimeByName(pt, nextName)!, now)
            : null;

        if (nextName != null && nextTime != null) {
          final windowStart = nextTime.subtract(_kUpcomingLeadWindow);
          if (now.isAfter(windowStart) && now.isBefore(nextTime)) {
            final remaining = nextTime.difference(now);
            return AlertBannerState(
              kind: AlertKind.upcoming,
              prayerName: nextName,
              remaining: remaining.isNegative ? Duration.zero : remaining,
              targetTime: nextTime,
            );
          }
        }

        if (currentName != null) {
          final DateTime? rawEnd = _getPrayerEndTimeFor(pt, currentName);
          final DateTime? endTime =
              rawEnd == null ? null : _rolloverIfBefore(rawEnd, now);
          if (endTime != null && now.isBefore(endTime)) {
            final remaining = endTime.difference(now);
            return AlertBannerState(
              kind: AlertKind.remaining,
              prayerName: currentName,
              remaining: remaining.isNegative ? Duration.zero : remaining,
              targetTime: endTime,
            );
          }
        }

        // If no current prayer (No Active Prayer state), show countdown to next prayer
        if (currentName == null && nextName != null && nextTime != null) {
          final remaining = nextTime.difference(now);
          return AlertBannerState(
            kind: AlertKind.upcoming,
            prayerName: nextName,
            remaining: remaining.isNegative ? Duration.zero : remaining,
            targetTime: nextTime,
          );
        }

        // Outside the 15-min upcoming window and not inside a current prayer
        // Do not show long countdowns. Return an inert state.
        return const AlertBannerState(
          kind: AlertKind.upcoming,
          prayerName: null,
          remaining: Duration.zero,
        );
      },
      orElse: () {
        // Fallback to cached derivation for instant banner state
        if (cachedDetail != null) {
          final pt = cachedDetail.prayerTimes as PrayerTimes;
          final now = DateTime.now();

          final String? currentName = cachedDetail.currentPrayer;
          final String? nextName = cachedDetail.nextPrayer;
          final DateTime? nextTime =
              nextName != null ? _getPrayerTimeByName(pt, nextName) : null;

          // If within upcoming window → upcoming
          if (nextName != null && nextTime != null) {
            final windowStart = nextTime.subtract(_kUpcomingLeadWindow);
            if (now.isAfter(windowStart) && now.isBefore(nextTime)) {
              final remaining = nextTime.difference(now);
              return AlertBannerState(
                kind: AlertKind.upcoming,
                prayerName: nextName,
                remaining: remaining.isNegative ? Duration.zero : remaining,
                targetTime: nextTime,
              );
            }
          }

          // Otherwise, if we have a current prayer, show remaining
          if (currentName != null) {
            final DateTime? endTime = _getPrayerEndTimeFor(pt, currentName);
            if (endTime != null && now.isBefore(endTime)) {
              final remaining = endTime.difference(now);
              return AlertBannerState(
                kind: AlertKind.remaining,
                prayerName: currentName,
                remaining: remaining.isNegative ? Duration.zero : remaining,
                targetTime: endTime,
              );
            }
          }

          // If no current prayer (No Active Prayer state), show countdown to next prayer
          if (currentName == null && nextName != null && nextTime != null) {
            final remaining = nextTime.difference(now);
            return AlertBannerState(
              kind: AlertKind.upcoming,
              prayerName: nextName,
              remaining: remaining.isNegative ? Duration.zero : remaining,
              targetTime: nextTime,
            );
          }

          // Neutral fallback when neither upcoming nor remaining can be determined
          // During night hours (after Isha until Fajr), show Isha remaining until Fajr
          final DateTime fajr = _rolloverIfBefore(pt.fajr.time, now);
          final DateTime isha = pt.isha.time;

          // Check if we're in the night period (after Isha until Fajr)
          if (now.isAfter(isha) && now.isBefore(fajr)) {
            final remaining = fajr.difference(now);
            return AlertBannerState(
              kind: AlertKind.remaining,
              prayerName: 'Isha',
              remaining: remaining.isNegative ? Duration.zero : remaining,
              targetTime: fajr,
            );
          }
          return const AlertBannerState(
            kind: AlertKind.upcoming,
            prayerName: null,
            remaining: Duration.zero,
          );
        }

        return const AlertBannerState(
            kind: AlertKind.upcoming,
            prayerName: null,
            remaining: Duration.zero);
      },
    );
  }

  yield compute();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => compute());
});

/// Offline-first derived provider: computes current and next prayers from cached daily timings.
/// - If online: falls back to the existing usecase path (same behavior).
/// - If offline: uses currentPrayerTimesProvider (which returns cache) to compute values locally.
final currentAndNextPrayerOfflineAwareProvider =
    FutureProvider<PrayerDetail>((ref) async {
  try {
    // Always derive from currentPrayerTimesProvider which already prefers
    // preferred (manual) location and falls back appropriately. This avoids
    // triggering GPS prompts here.
    final pt = await ref.read(currentPrayerTimesProvider.future);
    final now = DateTime.now();

    // Prayer times are now handled by explicit state machine logic below

    // State machine logic for prayer times
    // If we are before Fajr (edge case after midnight), show "No Active Prayer"
    if (now.isBefore(pt.fajr.time)) {
      final remaining = pt.fajr.time.difference(now);
      return PrayerDetail(
        currentPrayer: null, // No active prayer
        nextPrayer: 'Fajr',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Fajr start and Sunrise → Current = Fajr, Next = Dhuhr
    if (now.isAfter(pt.fajr.time) && now.isBefore(pt.sunrise.time)) {
      final remaining = pt.dhuhr.time.difference(now);
      return PrayerDetail(
        currentPrayer: 'Fajr',
        nextPrayer: 'Dhuhr',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Sunrise and Dhuhr start → No Active Prayer, Next = Dhuhr
    if (now.isAfter(pt.sunrise.time) && now.isBefore(pt.dhuhr.time)) {
      final remaining = pt.dhuhr.time.difference(now);
      return PrayerDetail(
        currentPrayer: null, // No active prayer
        nextPrayer: 'Dhuhr',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Dhuhr start and Asr start → Current = Dhuhr, Next = Asr
    if (now.isAfter(pt.dhuhr.time) && now.isBefore(pt.asr.time)) {
      final remaining = pt.asr.time.difference(now);

      return PrayerDetail(
        currentPrayer: 'Dhuhr',
        nextPrayer: 'Asr',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Asr start and Maghrib start → Current = Asr, Next = Maghrib
    if (now.isAfter(pt.asr.time) && now.isBefore(pt.maghrib.time)) {
      final remaining = pt.maghrib.time.difference(now);
      return PrayerDetail(
        currentPrayer: 'Asr',
        nextPrayer: 'Maghrib',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Maghrib start and Isha start → Current = Maghrib, Next = Isha
    if (now.isAfter(pt.maghrib.time) && now.isBefore(pt.isha.time)) {
      final remaining = pt.isha.time.difference(now);
      return PrayerDetail(
        currentPrayer: 'Maghrib',
        nextPrayer: 'Isha',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Isha start and Islamic midnight → Current = Isha, Next = Fajr
    if (now.isAfter(pt.isha.time) && now.isBefore(pt.midnight.time)) {
      final nextFajr = pt.fajr.time.add(const Duration(days: 1));
      final remaining = nextFajr.difference(now);
      return PrayerDetail(
        currentPrayer: 'Isha',
        nextPrayer: 'Fajr',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is after Islamic midnight and before next day's Fajr → No Active Prayer, Next = Fajr
    if (now.isAfter(pt.midnight.time)) {
      final nextFajr = pt.fajr.time.add(const Duration(days: 1));
      final remaining = nextFajr.difference(now);
      return PrayerDetail(
        currentPrayer: null, // No active prayer after Islamic midnight
        nextPrayer: 'Fajr',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // All cases should be handled by the state machine above
    // If we reach here, something went wrong
    throw Exception('Prayer time logic error: no matching time range found');
  } catch (_) {
    // Fallback: derive from cached prayer times if available
    final cached = await ref.read(cachedCurrentPrayerTimesProvider.future);
    if (cached == null) {
      rethrow;
    }
    final now = DateTime.now();

    // State machine logic for cached prayer times (same as above)
    // If we are before Fajr (edge case after midnight), show "No Active Prayer"
    if (now.isBefore(cached.fajr.time)) {
      final remaining = cached.fajr.time.difference(now);
      return PrayerDetail(
        currentPrayer: null, // No active prayer
        nextPrayer: 'Fajr',
        prayerTimes: cached,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Fajr start and Sunrise → Current = Fajr, Next = Dhuhr
    if (now.isAfter(cached.fajr.time) && now.isBefore(cached.sunrise.time)) {
      final remaining = cached.dhuhr.time.difference(now);
      return PrayerDetail(
        currentPrayer: 'Fajr',
        nextPrayer: 'Dhuhr',
        prayerTimes: cached,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Sunrise and Dhuhr start → No Active Prayer, Next = Dhuhr
    if (now.isAfter(cached.sunrise.time) && now.isBefore(cached.dhuhr.time)) {
      final remaining = cached.dhuhr.time.difference(now);
      return PrayerDetail(
        currentPrayer: null, // No active prayer
        nextPrayer: 'Dhuhr',
        prayerTimes: cached,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Dhuhr start and Asr start → Current = Dhuhr, Next = Asr
    if (now.isAfter(cached.dhuhr.time) && now.isBefore(cached.asr.time)) {
      final remaining = cached.asr.time.difference(now);
      return PrayerDetail(
        currentPrayer: 'Dhuhr',
        nextPrayer: 'Asr',
        prayerTimes: cached,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Asr start and Maghrib start → Current = Asr, Next = Maghrib
    if (now.isAfter(cached.asr.time) && now.isBefore(cached.maghrib.time)) {
      final remaining = cached.maghrib.time.difference(now);
      return PrayerDetail(
        currentPrayer: 'Asr',
        nextPrayer: 'Maghrib',
        prayerTimes: cached,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Maghrib start and Isha start → Current = Maghrib, Next = Isha
    if (now.isAfter(cached.maghrib.time) && now.isBefore(cached.isha.time)) {
      final remaining = cached.isha.time.difference(now);
      return PrayerDetail(
        currentPrayer: 'Maghrib',
        nextPrayer: 'Isha',
        prayerTimes: cached,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is between Isha start and Islamic midnight → Current = Isha, Next = Fajr
    if (now.isAfter(cached.isha.time) && now.isBefore(cached.midnight.time)) {
      final nextFajr = cached.fajr.time.add(const Duration(days: 1));
      final remaining = nextFajr.difference(now);
      return PrayerDetail(
        currentPrayer: 'Isha',
        nextPrayer: 'Fajr',
        prayerTimes: cached,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // If now is after Islamic midnight and before next day's Fajr → No Active Prayer, Next = Fajr
    if (now.isAfter(cached.midnight.time)) {
      final nextFajr = cached.fajr.time.add(const Duration(days: 1));
      final remaining = nextFajr.difference(now);
      return PrayerDetail(
        currentPrayer: null, // No active prayer after Islamic midnight
        nextPrayer: 'Fajr',
        prayerTimes: cached,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    // All cases should be handled by the state machine above
    // If we reach here, something went wrong
    throw Exception(
        'Cached prayer time logic error: no matching time range found');
  }
});

/// Fast cached derivation of current/next prayer for instant header
final cachedCurrentAndNextPrayerProvider = Provider<PrayerDetail?>((ref) {
  final cached = ref.watch(cachedCurrentPrayerTimesProvider).value;
  if (cached == null) return null;
  // Derive current/next based on time ordering and now
  final now = DateTime.now();
  final list = [
    cached.fajr,
    cached.sunrise,
    cached.dhuhr,
    cached.asr,
    cached.maghrib,
    cached.isha,
  ];
  list.sort((a, b) => a.time.compareTo(b.time));
  String? current;
  String? next;
  for (var i = 0; i < list.length; i++) {
    final t = list[i].time;
    final name = list[i].name;
    final nextIndex = (i + 1 < list.length) ? i + 1 : null;
    if (now.isAfter(t) &&
        (nextIndex == null || now.isBefore(list[nextIndex].time))) {
      current = name;
      next = nextIndex != null ? list[nextIndex].name : null;
      break;
    }
    if (now.isBefore(t)) {
      current = null;
      next = name;
      break;
    }
  }
  final nextTime =
      next == null ? null : list.firstWhere((e) => e.name == next).time;
  final remaining = nextTime == null ? Duration.zero : nextTime.difference(now);
  return PrayerDetail(
    currentPrayer: current,
    nextPrayer: next,
    prayerTimes: cached,
    timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
  );
});

/// Lightweight ticker to trigger periodic rebuilds where needed
final timeTickerProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 15), (_) {
    final now = DateTime.now();
    print('TimeTicker: Tick at ${now.hour}:${now.minute}:${now.second}');
    return now;
  });
});

/// Live current/next prayer that recomputes periodically without requiring explicit invalidation
final currentAndNextPrayerLiveProvider =
    StreamProvider<PrayerDetail>((ref) async* {
  PrayerDetail _derive(PrayerTimes pt, DateTime now) {
    // before Fajr
    if (now.isBefore(pt.fajr.time)) {
      final remaining = pt.fajr.time.difference(now);
      return PrayerDetail(
        currentPrayer: null,
        nextPrayer: 'Fajr',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }
    // Fajr → Sunrise
    if (now.isAfter(pt.fajr.time) && now.isBefore(pt.sunrise.time)) {
      final remaining = pt.dhuhr.time.difference(now);
      return PrayerDetail(
        currentPrayer: 'Fajr',
        nextPrayer: 'Dhuhr',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }
    // Sunrise → Dhuhr
    if (now.isAfter(pt.sunrise.time) && now.isBefore(pt.dhuhr.time)) {
      final remaining = pt.dhuhr.time.difference(now);
      return PrayerDetail(
        currentPrayer: null,
        nextPrayer: 'Dhuhr',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }
    // Dhuhr → Asr
    if (now.isAfter(pt.dhuhr.time) && now.isBefore(pt.asr.time)) {
      final remaining = pt.asr.time.difference(now);
      return PrayerDetail(
        currentPrayer: 'Dhuhr',
        nextPrayer: 'Asr',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }
    // Asr → Maghrib
    if (now.isAfter(pt.asr.time) && now.isBefore(pt.maghrib.time)) {
      final remaining = pt.maghrib.time.difference(now);
      return PrayerDetail(
        currentPrayer: 'Asr',
        nextPrayer: 'Maghrib',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }
    // Maghrib → Isha
    if (now.isAfter(pt.maghrib.time) && now.isBefore(pt.isha.time)) {
      final remaining = pt.isha.time.difference(now);
      return PrayerDetail(
        currentPrayer: 'Maghrib',
        nextPrayer: 'Isha',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }
    // Isha → Islamic midnight
    if (now.isAfter(pt.isha.time) && now.isBefore(pt.midnight.time)) {
      final nextFajr = pt.fajr.time.add(const Duration(days: 1));
      final remaining = nextFajr.difference(now);
      return PrayerDetail(
        currentPrayer: 'Isha',
        nextPrayer: 'Fajr',
        prayerTimes: pt,
        timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
      );
    }
    // After Islamic midnight → next Fajr
    final nextFajr = pt.fajr.time.add(const Duration(days: 1));
    final remaining = nextFajr.difference(now);
    return PrayerDetail(
      currentPrayer: null, // No active prayer after Islamic midnight
      nextPrayer: 'Fajr',
      prayerTimes: pt,
      timeUntilNextPrayer: remaining.isNegative ? Duration.zero : remaining,
    );
  }

  try {
    final pt = await ref.read(currentPrayerTimesProvider.future);
    // initial
    final initial = _derive(pt, DateTime.now());
    yield initial;

    // periodic recompute
    yield* ref.watch(timeTickerProvider.stream).map((now) {
      final updated = _derive(pt, now);

      // Log prayer state changes
      if (updated.currentPrayer != initial.currentPrayer ||
          updated.nextPrayer != initial.nextPrayer) {
        print(
            'PrayerStateChange: ${initial.currentPrayer}->${updated.currentPrayer}, ${initial.nextPrayer}->${updated.nextPrayer}');
      }

      return updated;
    });
  } catch (_) {
    // fallback to cached if available
    final cached = await ref.read(cachedCurrentPrayerTimesProvider.future);
    if (cached != null) {
      final initial = _derive(cached, DateTime.now());
      yield initial;
      yield* ref
          .watch(timeTickerProvider.stream)
          .map((now) => _derive(cached, now));
    } else {
      rethrow;
    }
  }
});

// Helper method to get prayer time by name
DateTime? _getPrayerTimeByName(PrayerTimes prayerTimes, String prayerName) {
  switch (prayerName.toLowerCase()) {
    case 'fajr':
      return prayerTimes.fajr.time;
    case 'sunrise':
      return prayerTimes.sunrise.time;
    case 'dhuhr':
      return prayerTimes.dhuhr.time;
    case 'asr':
      return prayerTimes.asr.time;
    case 'maghrib':
      return prayerTimes.maghrib.time;
    case 'isha':
      return prayerTimes.isha.time;
    case 'midnight':
      return prayerTimes.midnight.time;
    default:
      return null;
  }
}

// Daily Prayer Times Provider
final dailyPrayerTimesProvider =
    FutureProvider.family<PrayerTimes, DateTime>((ref, date) async {
  try {
    final usecase = ref.read(getDailyPrayerTimesUsecaseProvider);
    final location = await ref.read(currentLocationProvider.future);

    final result = await usecase(
      date: date,
      location: location,
      settings: await ref.read(prayerSettingsProvider.future),
    );

    return result.fold(
      (failure) {
        // If API fails, throw the failure instead of using mock data
        print('API failed for daily prayer times: ${failure.message}');
        throw failure;
      },
      (prayerTimes) => prayerTimes,
    );
  } catch (e) {
    // If any error occurs, throw the error instead of using mock data
    print('Error getting daily prayer times: $e');
    throw e;
  }
});

// Weekly Prayer Times Provider
final weeklyPrayerTimesProvider =
    FutureProvider<List<PrayerTimes>>((ref) async {
  final repository = ref.read(prayerTimesRepositoryProvider);
  final result = await repository.getWeeklyPrayerTimes();

  return result.fold(
    (failure) => throw failure,
    (prayerTimesList) => prayerTimesList,
  );
});

// Monthly Prayer Times Provider
final monthlyPrayerTimesProvider =
    FutureProvider.family<List<PrayerTimes>, DateTime>((ref, date) async {
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
final prayerTrackingHistoryProvider =
    FutureProvider.family<List<PrayerTracking>, DateTime>((ref, date) async {
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
final prayerStatisticsProvider =
    FutureProvider.family<PrayerStatistics, DateTime>((ref, date) async {
  final repository = ref.read(prayerTimesRepositoryProvider);

  final startDate = DateTime(date.year, date.month, 1);
  final endDate = DateTime(date.year, date.month + 1, 0);

  final result = await repository.getPrayerStatistics(
    fromDate: startDate,
    toDate: endDate,
  );

  return result.fold(
    (failure) => throw failure,
    (statistics) => statistics,
  );
});

// Prayer Settings Provider (duplicate removed - defined above)

// Athan Settings Provider
final athanSettingsFutureProvider = FutureProvider<AthanSettings>((ref) async {
  final repository = ref.read(prayerTimesRepositoryProvider);
  final result = await repository.getAthanSettings();

  return result.fold(
    (failure) => throw failure,
    (settings) => settings,
  );
});

// Athan Settings Notifier for toggling per-prayer notifications
final athanSettingsNotifierProvider =
    StateNotifierProvider<AthanSettingsNotifier, AthanSettings?>((ref) {
  return AthanSettingsNotifier(ref.read(prayerTimesRepositoryProvider))..load();
});

class AthanSettingsNotifier extends StateNotifier<AthanSettings?> {
  AthanSettingsNotifier(this._repository) : super(null);
  final PrayerTimesRepository _repository;

  Future<void> load() async {
    final result = await _repository.getAthanSettings();
    result.fold((_) => null, (settings) => state = settings);
  }

  bool isPrayerEnabled(String prayerName) {
    final map = state?.prayerSpecificSettings ?? const {};
    return map[prayerName.toLowerCase()] ?? true;
  }

  Future<void> togglePrayer(String prayerName) async {
    final current = state ?? const AthanSettings();
    final map = {...(current.prayerSpecificSettings ?? const {})};
    final key = prayerName.toLowerCase();
    map[key] = !(map[key] ?? true);
    final updated = current.copyWith(
        prayerSpecificSettings: map, lastUpdated: DateTime.now());
    final saved = await _repository.saveAthanSettings(updated);
    saved.fold((_) => null, (_) => state = updated);
  }
}

// Jama'at offsets provider (minutes per prayer)
final jamaatOffsetsProvider = FutureProvider<Map<String, int>>((ref) async {
  final storage = ref.read(prayerTimesLocalStorageProvider);
  return storage.getJamaatOffsets();
});

// Islamic Events Provider
final islamicEventsProvider =
    FutureProvider.family<List<IslamicEvent>, DateTime>((ref, date) async {
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
final offlineStatusProvider =
    FutureProvider.family<bool, DateTime>((ref, date) async {
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
// Next prayer DateTime derived from currentAndNextPrayerProvider
final nextPrayerDateTimeProvider = Provider<DateTime?>((ref) {
  final asyncDetail = ref.watch(currentAndNextPrayerProvider);
  return asyncDetail.maybeWhen(
    data: (detail) {
      final pt = detail.prayerTimes as PrayerTimes;
      final nextName = detail.nextPrayer;
      if (nextName == null) return null;
      return _getPrayerTimeByName(pt, nextName);
    },
    orElse: () => null,
  );
});

// Live countdown recomputed every 15 seconds for prayer time switching
final timeUntilNextPrayerProvider = StreamProvider<Duration>((ref) async* {
  // Rebuild the stream when next prayer target changes
  final nextPrayerTime = ref.watch(nextPrayerDateTimeProvider);

  // Emit immediately then every 15 seconds
  Duration computeRemaining() {
    if (nextPrayerTime == null) return Duration.zero;
    final remaining = nextPrayerTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  yield computeRemaining();

  yield* Stream.periodic(
      const Duration(seconds: 15), (_) => computeRemaining());
});

// Auto-refresh 4 times per day for accurate prayer times
final prayerTimesScheduledRefreshProvider = Provider<void>((ref) {
  Timer? timer;

  void scheduleNextRefresh() {
    final now = DateTime.now();

    // Schedule refreshes at: 6 AM, 12 PM, 6 PM, 12 AM (every 6 hours)
    final refreshHours = [6, 12, 18, 0];
    DateTime nextRefresh = DateTime(now.year, now.month, now.day, 6);

    // Find the next refresh time
    for (final hour in refreshHours) {
      final candidate = DateTime(now.year, now.month, now.day, hour);
      if (candidate.isAfter(now)) {
        nextRefresh = candidate;
        break;
      }
    }

    // If no refresh time found today, schedule for tomorrow 6 AM
    if (nextRefresh.isBefore(now)) {
      nextRefresh = DateTime(now.year, now.month, now.day + 1, 6);
    }

    final delay = nextRefresh.difference(now);
    print(
        'ScheduledRefresh: Next refresh at ${nextRefresh.hour}:${nextRefresh.minute} (in ${delay.inHours}h ${delay.inMinutes.remainder(60)}m)');

    timer = Timer(delay, () {
      print(
          'ScheduledRefresh: Refreshing prayer times (${DateTime.now().hour}:${DateTime.now().minute})');
      ref.invalidate(currentPrayerTimesProvider);
      ref.invalidate(currentAndNextPrayerProvider);
      ref.invalidate(cachedCurrentPrayerTimesProvider);
      // Schedule next refresh
      scheduleNextRefresh();
    });
  }

  scheduleNextRefresh();

  ref.onDispose(() {
    timer?.cancel();
  });
});

/// Revalidate prayer times when network becomes available
final prayerTimesConnectivityRefreshProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<List<ConnectivityResult>>>(
    connectivityStreamProvider,
    (previous, next) {
      if (!next.hasValue) return;
      final results = next.value ?? const <ConnectivityResult>[];
      final hasNetwork = results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet);

      print(
          'ConnectivityRefresh: Network status changed - hasNetwork: $hasNetwork');

      if (hasNetwork) {
        print(
            'ConnectivityRefresh: Network available, refreshing prayer times');

        // Refresh prayer times when network becomes available
        ref.invalidate(currentPrayerTimesProvider);
        ref.invalidate(currentAndNextPrayerProvider);
        ref.invalidate(cachedCurrentPrayerTimesProvider);
      }
    },
  );
});

/// Provider to update last updated timestamp for prayer times
final updateLastUpdatedProvider = FutureProvider<void>((ref) async {
  try {
    // Get current prayer times and update the lastUpdated timestamp
    final currentTimes = await ref.read(currentPrayerTimesProvider.future);
    final updatedTimes = currentTimes.copyWith(lastUpdated: DateTime.now());

    // Update the cached data with new timestamp
    final repo = ref.read(prayerTimesRepositoryProvider);
    final preferred = await repo.getPreferredLocation();
    if (preferred.isRight() && preferred.getOrElse(() => null) != null) {
      await repo.cachePrayerTimes([updatedTimes]);
    }

    print('UpdateLastUpdated: Successfully updated last updated timestamp');
  } catch (e) {
    print('UpdateLastUpdated: Error updating last updated timestamp: $e');
  }
});

/// Refresh prayer times when settings change (calculation method, madhab, etc.)
final prayerTimesSettingsRefreshProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<PrayerCalculationSettings>>(
    prayerSettingsProvider,
    (previous, next) {
      if (next.hasValue && previous?.value != next.value) {
        print(
            'SettingsRefresh: Prayer settings changed, refreshing prayer times');
        ref.invalidate(currentPrayerTimesProvider);
        ref.invalidate(currentAndNextPrayerProvider);
        ref.invalidate(cachedCurrentPrayerTimesProvider);
      }
    },
  );
});

// Prayer Completion State Notifier
final prayerCompletionProvider =
    StateNotifierProvider<PrayerCompletionNotifier, Map<String, bool>>((ref) {
  return PrayerCompletionNotifier();
});

// Location State Notifier
final locationStateProvider =
    StateNotifierProvider<LocationStateNotifier, LocationState>((ref) {
  return LocationStateNotifier(ref.read(locationServiceProvider));
});

// Prayer Times Settings State Notifier
final prayerTimesSettingsProvider = StateNotifierProvider<
    PrayerTimesSettingsNotifier, PrayerCalculationSettings>((ref) {
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
  LocationStateNotifier(this._locationService)
      : super(const LocationState.loading());
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

class PrayerTimesSettingsNotifier
    extends StateNotifier<PrayerCalculationSettings> {
  PrayerTimesSettingsNotifier(this._repository)
      : super(
          PrayerCalculationSettings(
            calculationMethod: 'MWL',
            madhab: Madhab.shafi,
            adjustments: const {},
            highLatitudeRule: HighLatitudeRule.middleOfNight,
            isDST: false,
          ),
        ) {
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

  static Madhab _madhabFromStringStatic(String name) {
    switch (name.toLowerCase()) {
      case 'hanafi':
        return Madhab.hanafi;
      case 'maliki':
        return Madhab.maliki;
      case 'hanbali':
        return Madhab.hanbali;
      case 'shafi':
      default:
        return Madhab.shafi;
    }
  }

  Future<void> updateMadhab(String madhab) async {
    final newSettings = state.copyWith(
        madhab: Madhab.values.firstWhere((m) => m.name == madhab));
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
