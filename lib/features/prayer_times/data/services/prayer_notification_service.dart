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
        AndroidInitializationSettings('@mipmap/ic_launcher');

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
  }

  /// Schedule a single prayer notification
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
        await _localNotifications.zonedSchedule(
          notificationId,
          '🕌 Prayer Reminder',
          '$prayerName prayer is in ${settings.reminderMinutes} minutes',
          tz.TZDateTime.from(reminderTime, tz.local),
          _buildNotificationDetails(
            channelId: _prayerReminderChannel,
            importance: Importance.high,
            priority: Priority.high,
            sound: null, // Use default system sound
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'prayer_reminder:$prayerName:${date.toIso8601String()}',
        );
      }
    }

    // Schedule Athan notification (at prayer time)
    if (prayer.time.isAfter(DateTime.now())) {
      await _localNotifications.zonedSchedule(
        athanId,
        '🕌 $prayerName Prayer Time',
        _getPrayerMessage(prayerName),
        tz.TZDateTime.from(prayer.time, tz.local),
        _buildNotificationDetails(
          channelId: _athanChannel,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true, // Ensure audible cue even if app is backgrounded
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
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'athan:$prayerName:${date.toIso8601String()}',
      );
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

  /// Play Athan audio
  Future<void> playAthan(String muadhinVoice, double volume) async {
    if (_isAthanPlaying) return;

    try {
      _isAthanPlaying = true;

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
      await _audioPlayer.setSource(DeviceFileSource(f.path));
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.resume();

      // Listen for completion
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          _isAthanPlaying = false;
        }
      });
    } catch (e) {
      _isAthanPlaying = false;
      throw Failure.audioPlaybackFailure(
        message: 'Failed to play Athan: $e',
      );
    }
  }

  /// Stop Athan audio
  Future<void> stopAthan() async {
    if (_isAthanPlaying) {
      await _audioPlayer.stop();
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

  /// Build notification details
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
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        icon: '@drawable/ic_notification',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        actions: actions,
        styleInformation: const BigTextStyleInformation(''),
        when: DateTime.now().millisecondsSinceEpoch,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
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
