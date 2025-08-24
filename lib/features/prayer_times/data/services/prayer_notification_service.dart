// duplicate removed
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:async'; // Added for Timer
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/error/failures.dart';

import '../../domain/entities/athan_settings.dart';
import '../../domain/entities/prayer_times.dart';

/// Comprehensive Prayer Notification Service
/// Handles local notifications, Athan audio, and prayer reminders
class PrayerNotificationService {
  factory PrayerNotificationService() => _instance;
  PrayerNotificationService._internal();
  static final PrayerNotificationService _instance =
      PrayerNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isInitialized = false;
  bool _isAthanPlaying = false;
  Timer? _volumeCheckTimer;
  Timer? _durationCutoffTimer;

  // Notification IDs
  static const int _prayerReminderBaseId = 1000;
  static const int _athanBaseId = 2000;
  static const int _qiyamReminderId = 3000;
  static const int _jumuahReminderId = 3001;
  static const int _islamicEventReminderId = 3002;

  // Prayer notification channels
  static const String _prayerReminderChannel = 'prayer_reminders';
  static const String _athanChannel = 'athan_notifications';
  static const String _islamicEventsChannel = 'islamic_events';

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeLocalNotifications();
      // Firebase Cloud Messaging not required for local Azan scheduling
      await _requestPermissions();
      
      _isInitialized = true;
    } catch (e) {
      throw Failure.notificationScheduleFailure(
        message: 'Failed to initialize notification service: $e',
      );
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization
    const androidInitialization =
        AndroidInitializationSettings('@drawable/ic_notification');
    
    // iOS initialization
    const iosInitialization = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels (Android)
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final plugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!;

    // Prayer Reminder Channel
    await plugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _prayerReminderChannel,
        'Prayer Reminders',
        description: 'Notifications for prayer time reminders',
        importance: Importance.high,
        playSound: true, // Use default system sound
      ),
    );

    // Athan Channel (enable sound by default; full Azan audio may be handled in-app)
    await plugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _athanChannel,
        'Athan (Call to Prayer)',
        description: 'Full Athan call to prayer notifications',
        importance: Importance.max,
        playSound: true,
      ),
    );

    // Islamic Events Channel
    await plugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _islamicEventsChannel,
        'Islamic Events',
        description: 'Notifications for special Islamic occasions',
        enableVibration: false,
      ),
    );
  }

  // Firebase messaging removed; local notifications are sufficient for Azan

  /// Request necessary permissions
  Future<void> _requestPermissions() async {
    // Request notification permission
    if (Platform.isAndroid) {
      final notificationStatus = await Permission.notification.request();
      if (notificationStatus.isDenied) {
        throw const Failure.notificationPermissionDenied();
      }
    }

    // Request exact alarm permission (Android 12+)
    if (Platform.isAndroid) {
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      if (alarmStatus.isDenied) {
        // This is not critical, app can still function
        print('Exact alarm permission denied - notifications may be delayed');
      }
    }
  }

  /// Schedule prayer notifications for the day
  Future<void> scheduleDailyPrayerNotifications(
    PrayerTimes prayerTimes,
    AthanSettings athanSettings,
  ) async {
    await _ensureInitialized();

    // Cancel existing notifications for the day to avoid duplicates
    try {
    await cancelDailyNotifications(prayerTimes.date);
    } catch (_) {}

    if (!athanSettings.isEnabled) return;

    final prayers = [
      prayerTimes.fajr,
      prayerTimes.dhuhr,
      prayerTimes.asr,
      prayerTimes.maghrib,
      prayerTimes.isha,
    ];

    for (var i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final prayerName = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'][i];
      
      // Check if this prayer is enabled in settings
      if (athanSettings.prayerSpecificSettings?[prayerName.toLowerCase()] ==
          false) {
        continue;
      }

      await _schedulePrayerNotification(
        prayer,
        prayerName,
        prayerTimes.date,
        athanSettings,
        i,
      );
    }

    // Schedule Qiyam reminder (optional)
    await _scheduleQiyamReminder(prayerTimes);

    // Start periodic check for Huawei compatibility
    _startPeriodicNotificationCheck(prayerTimes, athanSettings);
  }

  Timer? _periodicTimer;
  Map<int, bool> _notificationsShown = {};

  /// Start periodic notification check for Huawei compatibility
  void _startPeriodicNotificationCheck(
      PrayerTimes prayerTimes, AthanSettings settings) {
    _periodicTimer?.cancel();
    _notificationsShown.clear();

    _periodicTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndShowNotifications(prayerTimes, settings);
    });
  }

  /// Check if notifications should be shown and show them
  void _checkAndShowNotifications(
      PrayerTimes prayerTimes, AthanSettings settings) {
    final now = DateTime.now();
    final prayers = [
      (prayerTimes.fajr, 'Fajr', 0),
      (prayerTimes.dhuhr, 'Dhuhr', 1),
      (prayerTimes.asr, 'Asr', 2),
      (prayerTimes.maghrib, 'Maghrib', 3),
      (prayerTimes.isha, 'Isha', 4),
    ];

    for (final prayer in prayers) {
      final prayerTime = prayer.$1;
      final prayerName = prayer.$2;
      final prayerIndex = prayer.$3;

      // Check if this prayer is enabled
      if (settings.prayerSpecificSettings?[prayerName.toLowerCase()] == false) {
        continue;
      }

      final notificationId = _athanBaseId + prayerIndex;
      final reminderId = _prayerReminderBaseId + prayerIndex;

      // Check for reminder time (before prayer)
      if (settings.reminderMinutes > 0) {
        final reminderTime = prayerTime.time
            .subtract(Duration(minutes: settings.reminderMinutes));
        if (!(_notificationsShown[reminderId] ?? false) &&
            now.isAfter(reminderTime) &&
            now.isBefore(reminderTime.add(const Duration(minutes: 2)))) {
          _showNotificationImmediately(
            reminderId,
            '🕌 Prayer Reminder',
            '$prayerName prayer is in ${settings.reminderMinutes} minutes',
            _prayerReminderChannel,
            'prayer_reminder:$prayerName:${prayerTimes.date.toIso8601String()}',
          );
          _notificationsShown[reminderId] = true;
        }
      }

      // Check for prayer time
      if (!(_notificationsShown[notificationId] ?? false) &&
          now.isAfter(prayerTime.time) &&
          now.isBefore(prayerTime.time.add(const Duration(minutes: 2)))) {
        _showNotificationImmediately(
          notificationId,
          '🕌 $prayerName Prayer Time',
          _getPrayerMessage(prayerName),
          _athanChannel,
          'athan:$prayerName:${prayerTimes.date.toIso8601String()}',
          actions: [
            const AndroidNotificationAction('MARK_COMPLETED', 'Mark as Prayed'),
            const AndroidNotificationAction('SNOOZE_5', 'Remind in 5 min'),
          ],
        );
        _notificationsShown[notificationId] = true;

        // Play Azan
        try {
          playAthan(settings.muadhinVoice, settings.volume,
              durationSeconds: settings.durationSeconds);
        } catch (e) {
          // Failed to play Athan
        }
      }
    }
  }

  /// Show notification immediately (Huawei-compatible)
  Future<void> _showNotificationImmediately(
    int id,
    String title,
    String body,
    String channelId,
    String payload, {
    List<AndroidNotificationAction>? actions,
  }) async {
    try {
      await _localNotifications.show(
        id,
        title,
        body,
        _buildNotificationDetails(
          channelId: channelId,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          actions: actions,
        ),
        payload: payload,
      );
      // Showed immediate notification successfully
    } catch (e) {
      // Failed to show immediate notification
    }
  }

  /// Schedule a single prayer notification with robust Android compatibility
  Future<void> _schedulePrayerNotification(
    PrayerTime prayer,
    String prayerName,
    DateTime date,
    AthanSettings settings,
    int prayerIndex,
  ) async {
    final notificationId = _prayerReminderBaseId + prayerIndex;
    final athanId = _athanBaseId + prayerIndex;

    // Schedule reminder notification (before prayer time)
    if (settings.reminderMinutes > 0) {
      final reminderTime =
          prayer.time.subtract(Duration(minutes: settings.reminderMinutes));
      
      if (reminderTime.isAfter(DateTime.now())) {
        await _scheduleRobustNotification(
          notificationId,
          '🕌 Prayer Reminder',
          '$prayerName prayer is in ${settings.reminderMinutes} minutes',
          reminderTime,
          _prayerReminderChannel,
          'prayer_reminder:$prayerName:${date.toIso8601String()}',
            importance: Importance.high,
            priority: Priority.high,
        );
      }
    }

    // Schedule Athan notification (at prayer time) - This is the main Azan
    if (prayer.time.isAfter(DateTime.now())) {
      await _scheduleRobustNotification(
        athanId,
        '🕌 $prayerName Prayer Time',
        _getPrayerMessage(prayerName),
        prayer.time,
        _athanChannel,
        'athan:$prayerName:${date.toIso8601String()}',
          importance: Importance.max,
          priority: Priority.max,
          actions: [
            const AndroidNotificationAction(
              'MARK_COMPLETED',
              'Mark as Prayed',
            ),
            const AndroidNotificationAction(
              'SNOOZE_5',
              'Remind in 5 min',
          ),
        ],
        // This will trigger Azan audio playback
        onNotificationReceived: () async {
          try {
            await playAthan(settings.muadhinVoice, settings.volume,
                durationSeconds: settings.durationSeconds);
          } catch (e) {
            // Failed to play Athan
          }
        },
      );
    }
  }

  /// Robust notification scheduling with multiple fallback mechanisms
  Future<void> _scheduleRobustNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
    String channelId,
    String payload, {
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    List<AndroidNotificationAction>? actions,
    VoidCallback? onNotificationReceived,
  }) async {
    try {
      // Method 1: Primary scheduling with exact timing
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        _buildNotificationDetails(
          channelId: channelId,
          importance: importance,
          priority: priority,
          playSound: true,
          actions: actions,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      // Method 2: Backup notification 30 seconds later (for aggressive battery optimization)
      final backupTime = scheduledTime.add(const Duration(seconds: 30));
      await _localNotifications.zonedSchedule(
        id + 500, // Backup ID
        '$title (Backup)',
        body,
        tz.TZDateTime.from(backupTime, tz.local),
        _buildNotificationDetails(
          channelId: channelId,
          importance: importance,
          priority: priority,
          playSound: true,
          actions: actions,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '$payload:backup',
      );

      // Method 3: Additional backup 1 minute later (for very aggressive systems)
      final secondBackupTime = scheduledTime.add(const Duration(minutes: 1));
      await _localNotifications.zonedSchedule(
        id + 1000, // Second backup ID
        '$title (Final)',
        body,
        tz.TZDateTime.from(secondBackupTime, tz.local),
        _buildNotificationDetails(
          channelId: channelId,
          importance: importance,
          priority: priority,
          playSound: true,
          actions: actions,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '$payload:final',
      );

      // Notification scheduled successfully
    } catch (e) {
      // Failed to schedule notification, attempting fallback

      // Method 4: Immediate fallback if scheduling fails
      try {
        await _localNotifications.show(
          id,
          title,
          body,
          _buildNotificationDetails(
            channelId: channelId,
            importance: importance,
            priority: priority,
            playSound: true,
            actions: actions,
          ),
          payload: payload,
        );

        // Trigger Azan if this is a prayer time notification
        if (onNotificationReceived != null) {
          onNotificationReceived();
        }

        // Showed immediate fallback notification
      } catch (fallbackError) {
        // Fallback notification also failed
      }
    }
  }

  /// Schedule Qiyam (late night prayer) reminder
  Future<void> _scheduleQiyamReminder(PrayerTimes prayerTimes) async {
    // Calculate last third of the night
    final nightDuration =
        prayerTimes.fajr.time.difference(prayerTimes.isha.time);
    final lastThirdStart = prayerTimes.isha.time.add(
      Duration(milliseconds: (nightDuration.inMilliseconds * 2 / 3).round()),
    );

    if (lastThirdStart.isAfter(DateTime.now())) {
      await _localNotifications.zonedSchedule(
        _qiyamReminderId,
        '🌙 Qiyam al-Layl Time',
        'The blessed time for Tahajjud prayer has begun. The last third of the night is the most blessed time for prayer.',
        tz.TZDateTime.from(lastThirdStart, tz.local),
        _buildNotificationDetails(
          channelId: _islamicEventsChannel,
          importance: Importance.defaultImportance,
          sound: null, // Use default system sound
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'qiyam:${prayerTimes.date.toIso8601String()}',
      );
    }
  }

  /// Schedule Jumu'ah (Friday prayer) reminder
  Future<void> scheduleJumuahReminder(
      DateTime fridayDate, TimeOfDay jumuahTime) async {
    await _ensureInitialized();

    final jumuahDateTime = DateTime(
      fridayDate.year,
      fridayDate.month,
      fridayDate.day,
      jumuahTime.hour,
      jumuahTime.minute,
    );

    // Reminder 30 minutes before Jumu'ah
    final reminderTime = jumuahDateTime.subtract(const Duration(minutes: 30));

    if (reminderTime.isAfter(DateTime.now())) {
      await _localNotifications.zonedSchedule(
        _jumuahReminderId,
        "🕌 Jumu'ah Prayer Reminder",
        "Jumu'ah prayer is in 30 minutes. Prepare for the blessed Friday prayer.",
        tz.TZDateTime.from(reminderTime, tz.local),
        _buildNotificationDetails(
          channelId: _islamicEventsChannel,
          importance: Importance.high,
          sound: null, // Use default system sound
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'jumuah:${fridayDate.toIso8601String()}',
      );
    }
  }

  /// Schedule Islamic event notifications
  Future<void> scheduleIslamicEventNotifications(
      List<IslamicEvent> events) async {
    await _ensureInitialized();

    for (final event in events) {
      if (event.date.isAfter(DateTime.now())) {
        await _localNotifications.zonedSchedule(
          _islamicEventReminderId + event.hashCode,
          '⭐ ${event.name}',
          event.description,
          tz.TZDateTime.from(event.date, tz.local),
          _buildNotificationDetails(
            channelId: _islamicEventsChannel,
            importance: Importance.defaultImportance,
            sound: null, // Use default system sound
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload:
              'islamic_event:${event.name}:${event.date.toIso8601String()}',
        );
      }
    }
  }

  /// Play Athan audio with enhanced controls
  Future<void> playAthan(String muadhinVoice, double volume,
      {int? durationSeconds, bool fadeOut = true}) async {
    if (_isAthanPlaying) return;

    try {
      _isAthanPlaying = true;
      
      // Check if device is in silent/vibrate mode
      if (await _isDeviceInSilentMode()) {
        // Don't play audio if device is in silent mode
        _isAthanPlaying = false;
        return;
      }

      // Load asset via manifest resolution and play from temp file (robust on all platforms)
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest =
          jsonDecode(manifestJson) as Map<String, dynamic>;
      final wantedSuffix = '/${muadhinVoice}_athan.mp3';
      final matches =
          manifest.keys.where((k) => k.endsWith(wantedSuffix)).toList();
      ByteData? bytes;
      if (matches.isNotEmpty) {
        for (final k in matches) {
          try {
            bytes = await rootBundle.load(k);
            break;
          } catch (_) {}
        }
      }
      if (bytes == null) {
        for (final path in [
          'assets/audio/athan/${muadhinVoice}_athan.mp3',
          'audio/athan/${muadhinVoice}_athan.mp3'
        ]) {
          try {
            bytes = await rootBundle.load(path);
            break;
          } catch (_) {}
        }
      }
      if (bytes == null) {
        throw Failure.audioPlaybackFailure(
            message: 'Athan asset not found for $muadhinVoice');
      }
      final tmp = await getTemporaryDirectory();
      final f = File('${tmp.path}/${muadhinVoice}_athan.mp3');
      await f.writeAsBytes(bytes.buffer.asUint8List());

      // Ensure player stops when completed (no looping)
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);

      // Play directly with source + volume (correct flow for audioplayers 6.x)
      await _audioPlayer.play(
        DeviceFileSource(f.path),
        volume: volume,
      );

      // Start monitoring for volume/power button presses
      _startVolumeMonitoring();

      // Optional duration cutoff
      if (durationSeconds != null && durationSeconds > 0) {
        _durationCutoffTimer?.cancel();
        _durationCutoffTimer =
            Timer(Duration(seconds: durationSeconds), () async {
          try {
            if (fadeOut) {
              final currentVol = volume.clamp(0.0, 1.0);
              const steps = 6;
              for (int i = steps; i >= 1; i--) {
                await _audioPlayer.setVolume(currentVol * (i / steps));
                await Future.delayed(const Duration(milliseconds: 250));
              }
            }
            await _audioPlayer.stop();
          } catch (_) {}
        });
      }

      // Listen for completion
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          _stopVolumeMonitoring();
          _durationCutoffTimer?.cancel();
          _isAthanPlaying = false;
        }
      });
    } catch (e) {
      _stopVolumeMonitoring();
      _durationCutoffTimer?.cancel();
      _isAthanPlaying = false;
      throw Failure.audioPlaybackFailure(
        message: 'Failed to play Athan: $e',
      );
    }
  }

  /// Check if device is in silent/vibrate mode
  Future<bool> _isDeviceInSilentMode() async {
    try {
      // This is a simplified check - in a real app you might want to use
      // platform-specific APIs to check the actual ringer mode
      // For now, we'll assume it's not in silent mode
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Start monitoring for volume/power button presses
  void _startVolumeMonitoring() {
    _volumeCheckTimer?.cancel();
    _volumeCheckTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Check if user has pressed volume buttons or power button
      // This is a simplified implementation - in a real app you'd use
      // platform-specific APIs to detect button presses
      if (!_isAthanPlaying) {
        timer.cancel();
        return;
      }
    });
  }

  /// Stop volume monitoring
  void _stopVolumeMonitoring() {
    _volumeCheckTimer?.cancel();
    _volumeCheckTimer = null;
  }

  /// Stop Athan audio
  Future<void> stopAthan() async {
    if (_isAthanPlaying) {
      await _audioPlayer.stop();
      _stopVolumeMonitoring();
      _durationCutoffTimer?.cancel();
      _isAthanPlaying = false;
    }
  }

  /// Cancel all notifications for a specific date
  Future<void> cancelDailyNotifications(DateTime date) async {
    await _ensureInitialized();

    // Cancel prayer reminders and athan notifications
    for (var i = 0; i < 5; i++) {
      await _localNotifications.cancel(_prayerReminderBaseId + i);
      await _localNotifications.cancel(_athanBaseId + i);
    }

    // Cancel other daily notifications
    await _localNotifications.cancel(_qiyamReminderId);
  }

  /// Check if notifications are already scheduled for today
  Future<bool> hasNotificationsForToday() async {
    final pending = await getPendingNotifications();

    // Check if we have any Athan notifications scheduled for today
    return pending.any((notification) {
      final id = notification.id;
      // Check if it's an Athan notification (2000-2004 range)
      if (id >= _athanBaseId && id < _athanBaseId + 5) {
        return true;
      }
      return false;
    });
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await _localNotifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    await _ensureInitialized();
    return _localNotifications.pendingNotificationRequests();
  }

  /// Enhanced notification details with better Android compatibility
  NotificationDetails _buildNotificationDetails({
    required String channelId,
    required Importance importance,
    Priority priority = Priority.defaultPriority,
    String? sound,
    bool playSound = true,
    List<AndroidNotificationAction>? actions,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: importance,
        priority: priority,
        playSound: playSound,
        sound:
            sound != null ? RawResourceAndroidNotificationSound(sound) : null,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
        icon: '@drawable/ic_notification',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        actions: actions,
        styleInformation: const BigTextStyleInformation(''),
        when: DateTime.now().millisecondsSinceEpoch,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        // Enhanced settings for better reliability
        showWhen: true,
        enableVibration: true,
        enableLights: true,
        // Auto-cancel after 5 minutes
        autoCancel: true,
        // Allow notification to be persistent
        ongoing: false,
        // High priority for prayer notifications
        fullScreenIntent: importance == Importance.max ? true : false,
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: channelId,
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
        sound: sound != null ? '$sound.aiff' : null,
        threadIdentifier: channelId,
        subtitle: _getChannelName(channelId),
        interruptionLevel: importance == Importance.max
            ? InterruptionLevel.critical
            : InterruptionLevel.active,
      ),
    );
  }

  /// Get prayer message with Islamic context
  String _getPrayerMessage(String prayerName) {
    final messages = {
      'Fajr':
          "It's time for Fajr prayer. Begin your day with remembrance of Allah.",
      'Dhuhr':
          "It's time for Dhuhr prayer. Take a break and connect with Allah.",
      'Asr':
          "It's time for Asr prayer. The afternoon prayer brings peace to the soul.",
      'Maghrib':
          "It's time for Maghrib prayer. As the sun sets, remember Allah's blessings.",
      'Isha':
          "It's time for Isha prayer. End your day in gratitude and worship.",
    };
    
    return messages[prayerName] ?? "It's time for $prayerName prayer.";
  }

  /// Get channel name by ID
  String _getChannelName(String channelId) {
    switch (channelId) {
      case _prayerReminderChannel:
        return 'Prayer Reminders';
      case _athanChannel:
        return 'Athan (Call to Prayer)';
      case _islamicEventsChannel:
        return 'Islamic Events';
      default:
        return 'DeenMate';
    }
  }

  /// Get channel description by ID
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case _prayerReminderChannel:
        return 'Notifications to remind you before prayer times';
      case _athanChannel:
        return 'Call to prayer notifications when prayer time arrives';
      case _islamicEventsChannel:
        return 'Notifications for special Islamic occasions and events';
      default:
        return 'General notifications from DeenMate';
    }
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Get current Athan settings
  Future<AthanSettings> _getAthanSettings() async {
    try {
      // Use Hive directly to get settings
      final box = await Hive.openBox('athan_settings');
      final settingsMap = box.get('settings') as Map<String, dynamic>?;
      
      if (settingsMap != null) {
        return AthanSettings.fromJson(settingsMap);
      }
    } catch (e) {
      // Failed to get settings from Hive
    }
    
    // Return default settings if not found
    return const AthanSettings();
  }

  /// Handle local notification received (iOS)
  static void _onLocalNotificationReceived(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // Handle Azan playback for prayer notifications
    if (payload != null && payload.startsWith('athan:')) {
      _playAthanForNotification(payload);
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final parts = payload.split(':');
    if (parts.length < 2) return;

    final type = parts[0];

    switch (type) {
      case 'prayer_reminder':
      case 'athan':
        // Play Azan if this is a prayer notification
        if (type == 'athan') {
          _playAthanForNotification(payload);
        }
        // Navigate to prayer times screen
        // NavigationService.navigateTo('/prayer-times');
        break;
      case 'qiyam':
        // Show Qiyam guidance
        break;
      case 'jumuah':
        // Navigate to Jumu'ah information
        break;
      case 'islamic_event':
        // Show Islamic event details
        break;
    }

    // Handle action buttons
    if (response.actionId == 'MARK_COMPLETED') {
      // Mark prayer as completed
      // PrayerTrackingService.markCompleted(data);
    } else if (response.actionId == 'SNOOZE_5') {
      // Snooze notification for 5 minutes
      // _snoozeNotification(data, 5);
    }
  }

  /// Play Athan for notification
  static void _playAthanForNotification(String payload) async {
    try {
      final parts = payload.split(':');
      if (parts.length >= 2) {
        // Get the singleton instance and play Athan
        final service = PrayerNotificationService();

        // Get current Athan settings instead of using hardcoded values
        final settings = await service._getAthanSettings();
        
        await service.playAthan(
          settings.muadhinVoice, 
          settings.volume,
          durationSeconds: settings.durationSeconds,
        );
      }
    } catch (e) {
      // Failed to play Athan for notification
    }
  }

  /// Handle local notification received while app is in foreground (iOS)
  // iOS foreground local notification handler not used currently

  // Firebase message handlers removed

  /// Schedule Suhur notification for Ramadan
  Future<void> scheduleSuhurNotification(DateTime suhurTime) async {
    await _ensureInitialized();

    if (suhurTime.isAfter(DateTime.now())) {
      await _localNotifications.zonedSchedule(
        4000, // Suhur notification ID
        '🍽️ Suhur Time',
        "It's time for Suhur! Have your pre-dawn meal before Fajr.",
        tz.TZDateTime.from(suhurTime, tz.local),
        _buildNotificationDetails(
          channelId: _islamicEventsChannel,
          importance: Importance.high,
          sound: null, // Use default system sound
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'suhur:${suhurTime.toIso8601String()}',
      );
    }
  }

  /// Schedule Iftar notification for Ramadan
  Future<void> scheduleIftarNotification(DateTime iftarTime) async {
    await _ensureInitialized();

    if (iftarTime.isAfter(DateTime.now())) {
      await _localNotifications.zonedSchedule(
        4001, // Iftar notification ID
        '🌅 Iftar Time',
        'Get ready to break your fast! Maghrib is approaching.',
        tz.TZDateTime.from(iftarTime, tz.local),
        _buildNotificationDetails(
          channelId: _islamicEventsChannel,
          importance: Importance.high,
          sound: null, // Use default system sound
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'iftar:${iftarTime.toIso8601String()}',
      );
    }
  }

  /// Schedule a generic notification
  // generic scheduler reserved for future

  /// Schedule a Ramadan-specific notification
  // ramadan scheduler reserved for future

  /// Dispose resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    _periodicTimer?.cancel();
  }
}

/// Islamic Event class for scheduling special notifications
class IslamicEvent {
  const IslamicEvent({
    required this.name,
    required this.description,
    required this.date,
    this.arabicName,
  });
  final String name;
  final String description;
  final DateTime date;
  final String? arabicName;

  @override
  int get hashCode => name.hashCode ^ date.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is IslamicEvent &&
            runtimeType == other.runtimeType &&
            name == other.name &&
            date == other.date;
  }
}
