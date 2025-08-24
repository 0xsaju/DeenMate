import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/islamic_utils.dart';
import '../../data/services/prayer_notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

// Keep timezone local as UTC for now to avoid extra dependency issues;
// scheduling uses tz.local (default set by Flutter engine to device zone).
import '../../domain/entities/athan_settings.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import 'prayer_times_providers.dart';

part 'notification_providers.freezed.dart';

/// Prayer Notification Providers
/// Manages notification state and scheduling with Riverpod

// Core notification service provider
final notificationServiceProvider = Provider<PrayerNotificationService>((ref) {
  return PrayerNotificationService();
});

// Notification initialization provider
final notificationInitProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(notificationServiceProvider);
  try {
    // Ensure timezone database is ready for exact schedules
    try {
      tzdata.initializeTimeZones();
      // Rely on default local set by engine; fallback safe
    } catch (_) {}
    await service.initialize();
    return true;
  } catch (e) {
    return false;
  }
});

// Athan settings provider with state management
final athanSettingsProvider =
    StateNotifierProvider<AthanSettingsNotifier, AsyncValue<AthanSettings>>(
        (ref) {
  return AthanSettingsNotifier(
    ref.read(prayerTimesRepositoryProvider),
    ref.read(dailyNotificationSchedulerProvider),
  );
});

// Notification permissions provider
final notificationPermissionsProvider = StateNotifierProvider<
    NotificationPermissionsNotifier, NotificationPermissionsState>((ref) {
  return NotificationPermissionsNotifier();
});

// Pending notifications provider
final pendingNotificationsProvider =
    FutureProvider<List<PendingNotificationRequest>>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return service.getPendingNotifications();
});

// Daily notification scheduler provider
final dailyNotificationSchedulerProvider =
    Provider<DailyNotificationScheduler>((ref) {
  return DailyNotificationScheduler(
    ref.read(notificationServiceProvider),
    ref.read(prayerTimesRepositoryProvider),
  );
});

// Athan audio player provider
final athanAudioProvider =
    StateNotifierProvider<AthanAudioNotifier, AthanAudioState>((ref) {
  return AthanAudioNotifier(ref.read(notificationServiceProvider));
});

// Notification statistics provider
final notificationStatsProvider =
    FutureProvider<NotificationStatistics>((ref) async {
  final pending = await ref.read(pendingNotificationsProvider.future);
  // Use repository-backed current settings for stable snapshot
  final repo = ref.read(prayerTimesRepositoryProvider);
  final settingsEither = await repo.getAthanSettings();
  final settingsData = settingsEither.fold<AthanSettings>(
    (_) => const AthanSettings(isEnabled: false),
    (s) => s,
  );

  return NotificationStatistics(
    pendingCount: pending.length,
    enabledPrayers: _countEnabledPrayers(settingsData),
    nextNotificationTime: _getNextNotificationTime(pending),
    isEnabled: settingsData.isEnabled,
  );
});

// Auto-scheduler provider - automatically schedules notifications daily
final autoNotificationSchedulerProvider =
    Provider<AutoNotificationScheduler>((ref) {
  return AutoNotificationScheduler(
    ref.read(dailyNotificationSchedulerProvider),
    ref.read(currentPrayerTimesProvider.future),
    ref.read(athanSettingsFutureProvider.future),
  );
});

// Ramadan notification provider
final ramadanNotificationProvider = StateNotifierProvider<
    RamadanNotificationNotifier, RamadanNotificationState>((ref) {
  return RamadanNotificationNotifier(
    ref.read(notificationServiceProvider),
    ref.read(athanSettingsFutureProvider.future),
  );
});

// State Notifiers

class AthanSettingsNotifier extends StateNotifier<AsyncValue<AthanSettings>> {
  AthanSettingsNotifier(this._repository, this._scheduler)
      : super(const AsyncValue.loading()) {
    _loadSettings();
  }
  final PrayerTimesRepository _repository;
  final DailyNotificationScheduler _scheduler;
  Timer? _saveDebounce;

  Future<void> _loadSettings() async {
    try {
      final result = await _repository.getAthanSettings();
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (settings) => state = AsyncValue.data(settings),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSettings(AthanSettings settings) async {
    // Optimistic UI: update immediately without going to loading state
    state = AsyncValue.data(settings);

    // Debounce persistence to avoid frequent writes during sliders
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final result = await _repository.saveAthanSettings(settings);
        result.fold(
          (_) {
            // Keep current state; optionally could surface a toast via UI layer
          },
          (_) async {
            // On success, reschedule quietly
            await _rescheduleNotifications();
          },
        );
      } catch (_) {
        // Ignore persistence errors here to avoid UI flicker; next save will retry
      }
    });
  }

  Future<void> toggleEnabled() async {
    await state.when(
      data: (settings) =>
          updateSettings(settings.copyWith(isEnabled: !settings.isEnabled)),
      loading: Future.value,
      error: (_, __) => Future.value(),
    );
  }

  Future<void> updateMuadhinVoice(String voice) async {
    await state.when(
      data: (settings) =>
          updateSettings(settings.copyWith(muadhinVoice: voice)),
      loading: Future.value,
      error: (_, __) => Future.value(),
    );
  }

  Future<void> updateVolume(double volume) async {
    await state.when(
      data: (settings) => updateSettings(settings.copyWith(volume: volume)),
      loading: Future.value,
      error: (_, __) => Future.value(),
    );
  }

  Future<void> updateReminderMinutes(int minutes) async {
    await state.when(
      data: (settings) =>
          updateSettings(settings.copyWith(reminderMinutes: minutes)),
      loading: Future.value,
      error: (_, __) => Future.value(),
    );
  }

  Future<void> togglePrayerNotification(String prayerName, bool enabled) async {
    await state.when(
      data: (settings) {
        final prayerSettings =
            Map<String, bool>.from(settings.prayerSpecificSettings ?? {});
        prayerSettings[prayerName.toLowerCase()] = enabled;
        return updateSettings(
            settings.copyWith(prayerSpecificSettings: prayerSettings));
      },
      loading: Future.value,
      error: (_, __) => Future.value(),
    );
  }

  Future<void> updateRamadanSettings(
      RamadanNotificationSettings ramadanSettings) async {
    await state.when(
      data: (settings) =>
          updateSettings(settings.copyWith(ramadanSettings: ramadanSettings)),
      loading: Future.value,
      error: (_, __) => Future.value(),
    );
  }

  Future<void> _rescheduleNotifications() async {
    try {
      await _scheduler.scheduleToday();
    } catch (_) {
      // Ignore scheduling failures here; stats UI will reflect pending state
    }
  }
}

class NotificationPermissionsNotifier
    extends StateNotifier<NotificationPermissionsState> {
  NotificationPermissionsNotifier()
      : super(const NotificationPermissionsState()) {
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check notification permissions
    final notificationGranted = await _checkNotificationPermission();
    final exactAlarmGranted = await _checkExactAlarmPermission();
    final dndGranted = await _checkDndPermission();

    state = state.copyWith(
      notificationPermission: notificationGranted,
      exactAlarmPermission: exactAlarmGranted,
      dndOverridePermission: dndGranted,
    );

    // If permissions improved, attempt a quiet reschedule
    if (notificationGranted && exactAlarmGranted) {
      try {
        // Kick off a lightweight reschedule without UI noise
        final container = ProviderContainer();
        final scheduler = container.read(dailyNotificationSchedulerProvider);
        await scheduler.scheduleToday();
        container.dispose();
      } catch (_) {}
    }
  }

  Future<bool> requestNotificationPermission() async {
    // Request notification permission
    final granted = await Permission.notification.request().isGranted;
    state = state.copyWith(notificationPermission: granted);
    return granted;
  }

  Future<bool> requestExactAlarmPermission() async {
    // Request exact alarm permission (Android 12+)
    final granted = await Permission.scheduleExactAlarm.request().isGranted;
    state = state.copyWith(exactAlarmPermission: granted);
    return granted;
  }

  Future<bool> _checkNotificationPermission() async {
    return Permission.notification.isGranted;
  }

  Future<bool> _checkExactAlarmPermission() async {
    return Permission.scheduleExactAlarm.isGranted;
  }

  Future<bool> _checkDndPermission() async {
    // Check Do Not Disturb override permission
    return Permission.accessNotificationPolicy.isGranted;
  }
}

class AthanAudioNotifier extends StateNotifier<AthanAudioState> {
  AthanAudioNotifier(this._notificationService)
      : super(const AthanAudioState());
  final PrayerNotificationService _notificationService;

  Future<void> playAthan(String muadhinVoice, double volume,
      {int? durationSeconds}) async {
    if (state.isPlaying) return;

    state = state.copyWith(isPlaying: true, error: null);

    try {
      // Use provided duration or get from settings
      int finalDuration = durationSeconds ?? 180; // Default fallback
      if (durationSeconds == null) {
        final settings = await _settings();
        finalDuration = settings.durationSeconds;
      }

      await _notificationService.playAthan(
        muadhinVoice,
        volume,
        durationSeconds: finalDuration,
        fadeOut: true,
      );
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      state = state.copyWith(
        isPlaying: false,
        error: e is Failure
            ? e
            : Failure.audioPlaybackFailure(message: e.toString()),
      );
    }
  }

  Future<void> stopAthan() async {
    try {
      await _notificationService.stopAthan();
      state = state.copyWith(isPlaying: false, error: null);
    } catch (e) {
      state = state.copyWith(
        error: e is Failure
            ? e
            : Failure.audioPlaybackFailure(message: e.toString()),
      );
    }
  }

  Future<void> previewAthan(String muadhinVoice) async {
    // Keep using AthanAudioNotifier in UI. This is a safe no-op.
  }

  Future<AthanSettings> _settings() async {
    final container = ProviderContainer();
    try {
      final either = await container
          .read(prayerTimesRepositoryProvider)
          .getAthanSettings();
      return either.fold((_) => const AthanSettings(), (s) => s);
    } finally {
      container.dispose();
    }
  }
}

class RamadanNotificationNotifier
    extends StateNotifier<RamadanNotificationState> {
  RamadanNotificationNotifier(this._notificationService, this._settingsFuture)
      : super(const RamadanNotificationState()) {
    _checkRamadanStatus();
  }
  final PrayerNotificationService _notificationService;
  final Future<AthanSettings> _settingsFuture;

  Future<void> _checkRamadanStatus() async {
    final isRamadan = IslamicUtils.isRamadan();
    final daysRemaining = IslamicUtils.getRamadanDaysRemaining();

    state = state.copyWith(
      isRamadan: isRamadan,
      daysRemaining: daysRemaining,
    );

    if (isRamadan) {
      await _scheduleRamadanNotifications();
    }
  }

  Future<void> _scheduleRamadanNotifications() async {
    final settings = await _settingsFuture;
    if (settings.ramadanSettings?.enabled != true) return;

    // Schedule Suhur and Iftar reminders
    // This would integrate with the prayer times to schedule
    // appropriate notifications for Ramadan
  }

  Future<void> scheduleSuhurReminder(DateTime fajrTime) async {
    final settings = await _settingsFuture;
    final ramadanSettings = settings.ramadanSettings;

    if (ramadanSettings?.enabled == true) {
      final suhurTime = fajrTime.subtract(
        Duration(minutes: ramadanSettings!.suhurReminderMinutes),
      );

      // Schedule Suhur notification
      await _notificationService.scheduleSuhurNotification(suhurTime);

      state = state.copyWith(nextSuhurTime: suhurTime);
    }
  }

  Future<void> scheduleIftarReminder(DateTime maghribTime) async {
    final settings = await _settingsFuture;
    final ramadanSettings = settings.ramadanSettings;

    if (ramadanSettings?.enabled == true) {
      final iftarTime = maghribTime.subtract(
        Duration(minutes: ramadanSettings!.iftarReminderMinutes),
      );

      // Schedule Iftar notification
      await _notificationService.scheduleIftarNotification(iftarTime);

      state = state.copyWith(nextIftarTime: iftarTime);
    }
  }
}

// Service Classes

class DailyNotificationScheduler {
  DailyNotificationScheduler(this._notificationService, this._repository);
  final PrayerNotificationService _notificationService;
  final PrayerTimesRepository _repository;

  Future<void> scheduleToday({bool force = false}) async {
    // Always (re)schedule to ensure periodic checker starts and times are fresh
    final prayerTimesResult = await _repository.getCurrentPrayerTimes();
    final settingsResult = await _repository.getAthanSettings();

    final prayerTimes = prayerTimesResult.fold(
      (failure) => throw failure,
      (times) => times,
    );

    final settings = settingsResult.fold(
      (failure) => throw failure,
      (settings) => settings,
    );

    await _notificationService.scheduleDailyPrayerNotifications(
        prayerTimes, settings);
  }

  Future<void> scheduleWeek() async {
    final weeklyPrayerTimesResult = await _repository.getWeeklyPrayerTimes();
    final settingsResult = await _repository.getAthanSettings();

    final weeklyPrayerTimes = weeklyPrayerTimesResult.fold(
      (failure) => throw failure,
      (times) => times,
    );

    final settings = settingsResult.fold(
      (failure) => throw failure,
      (settings) => settings,
    );

    for (final prayerTimes in weeklyPrayerTimes) {
      await _notificationService.scheduleDailyPrayerNotifications(
          prayerTimes, settings);
    }
  }
}

class AutoNotificationScheduler {
  AutoNotificationScheduler(
    this._scheduler,
    this._prayerTimesFuture,
    this._settingsFuture,
  ) {
    _startAutoScheduling();
    // Also listen for connectivity-driven refresh to reschedule cleanly
    // (provider lives while app session is active)
  }
  final DailyNotificationScheduler _scheduler;
  // reserved for future hooks (kept referenced to avoid tree-shake during tests)
  // ignore: unused_field
  final Future<PrayerTimes> _prayerTimesFuture;
  // ignore: unused_field
  final Future<AthanSettings> _settingsFuture;

  Future<void> _startAutoScheduling() async {
    try {
      // Always schedule today; weekly scheduling can be heavy on some devices
      await _scheduler.scheduleToday();
    } catch (e) {
      // Handle scheduling error
      // Failed to auto-schedule notifications
    }
  }

  Future<void> rescheduleAll() async {
    await _startAutoScheduling();
  }
}

// State Classes

@freezed
class NotificationPermissionsState with _$NotificationPermissionsState {
  const factory NotificationPermissionsState({
    @Default(false) bool notificationPermission,
    @Default(false) bool exactAlarmPermission,
    @Default(false) bool dndOverridePermission,
  }) = _NotificationPermissionsState;
}

@freezed
class AthanAudioState with _$AthanAudioState {
  const factory AthanAudioState({
    @Default(false) bool isPlaying,
    Failure? error,
  }) = _AthanAudioState;
}

@freezed
class RamadanNotificationState with _$RamadanNotificationState {
  const factory RamadanNotificationState({
    @Default(false) bool isRamadan,
    int? daysRemaining,
    DateTime? nextSuhurTime,
    DateTime? nextIftarTime,
  }) = _RamadanNotificationState;
}

@freezed
class NotificationStatistics with _$NotificationStatistics {
  const factory NotificationStatistics({
    required int pendingCount,
    required int enabledPrayers,
    required bool isEnabled,
    DateTime? nextNotificationTime,
  }) = _NotificationStatistics;
}

// Helper functions

int _countEnabledPrayers(AthanSettings settings) {
  if (!settings.isEnabled) return 0;

  final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
  return prayers.where((prayer) => settings.isPrayerEnabled(prayer)).length;
}

DateTime? _getNextNotificationTime(List<PendingNotificationRequest> pending) {
  if (pending.isEmpty) return null;

  // Find the earliest notification time
  DateTime? earliest;
  for (final notification in pending) {
    // Heuristic: parse payload for ISO datetime suffix "YYYY-MM-DDTHH:mm:ss"
    // e.g., payload formats used: 'prayer_reminder:NAME:ISO', 'athan:NAME:ISO', 'qiyam:ISO'
    final payload = notification.payload;
    if (payload == null) continue;
    final parts = payload.split(':');
    if (parts.isEmpty) continue;
    // The last part is expected to be ISO datetime in our scheduler
    final last = parts.isNotEmpty ? parts.last : '';
    DateTime? scheduled;
    try {
      scheduled = DateTime.tryParse(last);
    } catch (_) {
      scheduled = null;
    }
    if (scheduled == null) continue;
    if (earliest == null || scheduled.isBefore(earliest)) {
      earliest = scheduled;
    }
  }

  return earliest;
}
