import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/islamic_utils.dart';
import '../../data/services/prayer_notification_service.dart';
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
    await service.initialize();
    return true;
  } catch (e) {
    return false;
  }
});

// Athan settings provider with state management
final athanSettingsProvider = StateNotifierProvider<AthanSettingsNotifier, AsyncValue<AthanSettings>>((ref) {
  return AthanSettingsNotifier(
    ref.read(prayerTimesRepositoryProvider),
    ref.read(notificationServiceProvider),
  );
});

// Notification permissions provider
final notificationPermissionsProvider = StateNotifierProvider<NotificationPermissionsNotifier, NotificationPermissionsState>((ref) {
  return NotificationPermissionsNotifier();
});

// Pending notifications provider
final pendingNotificationsProvider = FutureProvider<List<PendingNotificationRequest>>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return service.getPendingNotifications();
});

// Daily notification scheduler provider
final dailyNotificationSchedulerProvider = Provider<DailyNotificationScheduler>((ref) {
  return DailyNotificationScheduler(
    ref.read(notificationServiceProvider),
    ref.read(prayerTimesRepositoryProvider),
  );
});

// Athan audio player provider
final athanAudioProvider = StateNotifierProvider<AthanAudioNotifier, AthanAudioState>((ref) {
  return AthanAudioNotifier(ref.read(notificationServiceProvider));
});

// Notification statistics provider
final notificationStatsProvider = FutureProvider<NotificationStatistics>((ref) async {
  final pending = await ref.read(pendingNotificationsProvider.future);
  final settings = await ref.read(athanSettingsProvider.future);
  
  return NotificationStatistics(
    pendingCount: pending.length,
    enabledPrayers: settings.when(
      data: _countEnabledPrayers,
      loading: () => 0,
      error: (_, __) => 0,
    ),
    nextNotificationTime: _getNextNotificationTime(pending),
    isEnabled: settings.when(
      data: (data) => data.isEnabled,
      loading: () => false,
      error: (_, __) => false,
    ),
  );
});

// Auto-scheduler provider - automatically schedules notifications daily
final autoNotificationSchedulerProvider = Provider<AutoNotificationScheduler>((ref) {
  return AutoNotificationScheduler(
    ref.read(dailyNotificationSchedulerProvider),
    ref.read(currentPrayerTimesProvider.future),
    ref.read(athanSettingsProvider.future),
  );
});

// Ramadan notification provider
final ramadanNotificationProvider = StateNotifierProvider<RamadanNotificationNotifier, RamadanNotificationState>((ref) {
  return RamadanNotificationNotifier(
    ref.read(notificationServiceProvider),
    ref.read(athanSettingsProvider.future),
  );
});

// State Notifiers

class AthanSettingsNotifier extends StateNotifier<AsyncValue<AthanSettings>> {

  AthanSettingsNotifier(this._repository, this._notificationService) 
      : super(const AsyncValue.loading()) {
    _loadSettings();
  }
  final PrayerTimesRepository _repository;
  final PrayerNotificationService _notificationService;

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
    state = const AsyncValue.loading();
    
    try {
      final result = await _repository.saveAthanSettings(settings);
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) {
          state = AsyncValue.data(settings);
          _rescheduleNotifications();
        },
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleEnabled() async {
    await state.when(
      data: (settings) => updateSettings(settings.copyWith(isEnabled: !settings.isEnabled)),
      loading: Future.value,
      error: (_, __) => Future.value(),
    );
  }

  Future<void> updateMuadhinVoice(String voice) async {
    await state.when(
      data: (settings) => updateSettings(settings.copyWith(muadhinVoice: voice)),
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
      data: (settings) => updateSettings(settings.copyWith(reminderMinutes: minutes)),
      loading: Future.value,
      error: (_, __) => Future.value(),
    );
  }

  Future<void> togglePrayerNotification(String prayerName, bool enabled) async {
    await state.when(
      data: (settings) {
        final prayerSettings = Map<String, bool>.from(settings.prayerSpecificSettings ?? {});
        prayerSettings[prayerName.toLowerCase()] = enabled;
        return updateSettings(settings.copyWith(prayerSpecificSettings: prayerSettings));
      },
      loading: Future.value,
      error: (_, __) => Future.value(),
    );
  }

  Future<void> updateRamadanSettings(RamadanNotificationSettings ramadanSettings) async {
    await state.when(
      data: (settings) => updateSettings(settings.copyWith(ramadanSettings: ramadanSettings)),
      loading: Future.value,
      error: (_, __) => Future.value(),
    );
  }

  Future<void> _rescheduleNotifications() async {
    // This will be handled by the auto-scheduler
    // when settings change
  }
}

class NotificationPermissionsNotifier extends StateNotifier<NotificationPermissionsState> {
  NotificationPermissionsNotifier() : super(const NotificationPermissionsState()) {
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

  AthanAudioNotifier(this._notificationService) : super(const AthanAudioState());
  final PrayerNotificationService _notificationService;

  Future<void> playAthan(String muadhinVoice, double volume) async {
    if (state.isPlaying) return;

    state = state.copyWith(isPlaying: true, error: null);

    try {
      await _notificationService.playAthan(muadhinVoice, volume);
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      state = state.copyWith(
        isPlaying: false,
        error: e is Failure ? e : Failure.audioPlaybackFailure(message: e.toString()),
      );
    }
  }

  Future<void> stopAthan() async {
    try {
      await _notificationService.stopAthan();
      state = state.copyWith(isPlaying: false, error: null);
    } catch (e) {
      state = state.copyWith(
        error: e is Failure ? e : Failure.audioPlaybackFailure(message: e.toString()),
      );
    }
  }

  Future<void> previewAthan(String muadhinVoice) async {
    await playAthan(muadhinVoice, 0.5); // Preview at 50% volume
  }
}

class RamadanNotificationNotifier extends StateNotifier<RamadanNotificationState> {

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

  Future<void> scheduleToday() async {
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

    await _notificationService.scheduleDailyPrayerNotifications(prayerTimes, settings);
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
      await _notificationService.scheduleDailyPrayerNotifications(prayerTimes, settings);
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
  }
  final DailyNotificationScheduler _scheduler;
  final Future<PrayerTimes> _prayerTimesFuture;
  final Future<AthanSettings> _settingsFuture;

  Future<void> _startAutoScheduling() async {
    try {
      await _scheduler.scheduleToday();
      
      // Schedule for the next few days as well
      await _scheduler.scheduleWeek();
    } catch (e) {
      // Handle scheduling error
      print('Failed to auto-schedule notifications: $e');
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
    required bool isEnabled, DateTime? nextNotificationTime,
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
    // This would need to be implemented based on the notification payload
    // to extract the scheduled time
  }
  
  return earliest;
}
