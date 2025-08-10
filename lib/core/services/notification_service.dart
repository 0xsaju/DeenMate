import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Islamic notification service for prayer times and reminders
class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Schedule prayer time notifications
  Future<void> schedulePrayerNotifications(Map<String, dynamic> prayerTimes) async {
    if (!_isInitialized) return;

    try {
      // Clear existing prayer notifications
      await cancelPrayerNotifications();

      final prayers = prayerTimes['prayers'] as Map<String, dynamic>;
      final prayerNames = {
        'fajr': {'name': 'Fajr', 'arabic': 'الفجر', 'bengali': 'ফজর'},
        'dhuhr': {'name': 'Dhuhr', 'arabic': 'الظهر', 'bengali': 'যুহর'},
        'asr': {'name': 'Asr', 'arabic': 'العصر', 'bengali': 'আসর'},
        'maghrib': {'name': 'Maghrib', 'arabic': 'المغرب', 'bengali': 'মাগরিব'},
        'isha': {'name': 'Isha', 'arabic': 'العشاء', 'bengali': 'ইশা'},
      };

      var notificationId = 1000;
      for (final entry in prayerNames.entries) {
        final prayerKey = entry.key;
        final prayerInfo = entry.value;
        final timeStr = prayers[prayerKey] as String?;
        
        if (timeStr != null) {
          await _schedulePrayerNotification(
            notificationId++,
            prayerInfo['name']!,
            prayerInfo['arabic']!,
            prayerInfo['bengali']!,
            timeStr,
          );
        }
      }
    } catch (e) {
      debugPrint('Error scheduling prayer notifications: $e');
    }
  }

  /// Schedule individual prayer notification
  Future<void> _schedulePrayerNotification(
    int id,
    String prayerName,
    String arabicName,
    String bengaliName,
    String timeStr,
  ) async {
    try {
      // Parse time string (e.g., "5:30 AM")
      final time = _parseTimeString(timeStr);
      if (time == null) return;

      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Main notification at prayer time
      await _scheduleNotification(
        id,
        '🕌 $prayerName Prayer Time | $bengaliName',
        "It's time for $prayerName prayer. $arabicName",
        scheduledDate,
        _getPrayerSound(),
      );

      // Reminder 10 minutes before (optional)
      final reminderEnabled = await _isReminderEnabled();
      if (reminderEnabled) {
        final reminderTime = scheduledDate.subtract(const Duration(minutes: 10));
        if (reminderTime.isAfter(now)) {
          await _scheduleNotification(
            id + 100,
            '⏰ $prayerName Prayer in 10 minutes',
            'Prepare for $prayerName prayer. $bengaliName এর নামাজের সময় ১০ মিনিট বাকি',
            reminderTime,
            'default',
          );
        }
      }
    } catch (e) {
      debugPrint('Error scheduling prayer notification for $prayerName: $e');
    }
  }

  /// Schedule a notification
  Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    String sound,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_times',
      'Prayer Times',
      channelDescription: 'Notifications for Islamic prayer times',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(sound),
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Show daily Islamic reminder
  Future<void> showDailyReminder() async {
    if (!_isInitialized) return;

    try {
      final reminders = [
        'Remember Allah throughout your day 🤲',
        'Send blessings upon Prophet Muhammad ﷺ',
        'Read a verse from the Quran today 📖',
        'Make dua for your loved ones 💚',
        "Be grateful for Allah's countless blessings 🌟",
      ];

      final now = DateTime.now();
      final randomIndex = now.day % reminders.length;
      final reminder = reminders[randomIndex];

      await _scheduleNotification(
        2000,
        'Daily Islamic Reminder',
        reminder,
        DateTime(now.year, now.month, now.day, 9), // 9 AM
        'default',
      );
    } catch (e) {
      debugPrint('Error showing daily reminder: $e');
    }
  }

  /// Show Quranic verse notification
  Future<void> showVerseOfTheDay(Map<String, dynamic> verse) async {
    if (!_isInitialized) return;

    try {
      const title = '📖 Verse of the Day | আজকের আয়াত';
      final body = '${verse['english']}\n\n${verse['reference']}';

      await _notifications.show(
        3000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_verse',
            'Daily Verse',
            channelDescription: 'Daily Quranic verses',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing verse notification: $e');
    }
  }

  /// Cancel all prayer notifications
  Future<void> cancelPrayerNotifications() async {
    try {
      // Cancel prayer time notifications (1000-1099)
      for (var i = 1000; i < 1100; i++) {
        await _notifications.cancel(i);
      }
      
      // Cancel reminder notifications (1100-1199)
      for (var i = 1100; i < 1200; i++) {
        await _notifications.cancel(i);
      }
    } catch (e) {
      debugPrint('Error canceling prayer notifications: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.id} - ${response.payload}');
    // TODO: Handle navigation based on notification type
  }

  /// Parse time string to DateTime
  DateTime? _parseTimeString(String timeStr) {
    try {
      // Handle formats like "5:30 AM", "17:30"
      final cleanTime = timeStr.trim();
      
      if (cleanTime.contains('AM') || cleanTime.contains('PM')) {
        final parts = cleanTime.split(' ');
        final timePart = parts[0];
        final period = parts[1];
        
        final timeComponents = timePart.split(':');
        var hour = int.parse(timeComponents[0]);
        final minute = int.parse(timeComponents[1]);
        
        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
        
        return DateTime(0, 1, 1, hour, minute);
      } else {
        // 24-hour format
        final timeComponents = cleanTime.split(':');
        final hour = int.parse(timeComponents[0]);
        final minute = int.parse(timeComponents[1]);
        
        return DateTime(0, 1, 1, hour, minute);
      }
    } catch (e) {
      debugPrint('Error parsing time string: $timeStr - $e');
      return null;
    }
  }

  /// Convert DateTime to TZDateTime (placeholder)
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // This would use timezone package in production
    return dateTime;
  }

  /// Get prayer sound file name
  String _getPrayerSound() {
    // Return appropriate sound file for Adhan
    return 'adhan'; // This would be a sound file in assets
  }

  /// Check if reminder is enabled
  Future<bool> _isReminderEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('prayer_reminders_enabled') ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Enable/disable prayer reminders
  Future<void> setPrayerRemindersEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('prayer_reminders_enabled', enabled);
      
      if (!enabled) {
        await cancelPrayerNotifications();
      }
    } catch (e) {
      debugPrint('Error setting prayer reminders: $e');
    }
  }

  /// Check notification permission status
  Future<bool> hasPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }
}
