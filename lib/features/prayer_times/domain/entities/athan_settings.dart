import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/islamic_utils.dart';

part 'athan_settings.freezed.dart';
part 'athan_settings.g.dart';

/// JsonConverter for TimeOfDay
class TimeOfDayConverter implements JsonConverter<TimeOfDay, String> {
  const TimeOfDayConverter();

  @override
  TimeOfDay fromJson(String json) {
    final parts = json.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  String toJson(TimeOfDay timeOfDay) {
    return '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
  }
}

/// Athan (Call to Prayer) settings for customizing prayer notifications
@freezed
class AthanSettings with _$AthanSettings {
  const factory AthanSettings({
    /// Whether Athan notifications are enabled
    @Default(true) bool isEnabled,
    
    /// Selected Muadhin voice for Athan
    @Default('abdulbasit') String muadhinVoice,
    
    /// Volume level for Athan (0.0 to 1.0)
    @Default(0.8) double volume,
    
    /// Duration of Athan audio in seconds
    @Default(180) int durationSeconds,
    
    /// Whether to vibrate device during Athan
    @Default(true) bool vibrateEnabled,
    
    /// Reminder time before prayer (in minutes)
    @Default(10) int reminderMinutes,
    
    /// Prayer-specific settings (prayer name -> enabled)
    Map<String, bool>? prayerSpecificSettings,
    
    /// Days when notifications are muted (e.g., 'monday', 'tuesday')
    List<String>? mutedDays,
    
    /// Specific time ranges when notifications are muted
    List<MuteTimeRange>? muteTimeRanges,
    
    /// Whether to show notification in Do Not Disturb mode
    @Default(true) bool overrideDnd,
    
    /// Whether to show full screen notification for Athan
    @Default(false) bool fullScreenNotification,
    
    /// Whether to automatically mark prayer as completed after Athan
    @Default(false) bool autoMarkCompleted,
    
    /// Custom notification message for each prayer
    Map<String, String>? customMessages,
    
    /// Whether to include Arabic text in notifications
    @Default(true) bool includeArabicText,
    
    /// Whether to show Qibla direction in notification
    @Default(true) bool showQiblaDirection,
    
    /// Whether to enable smart notifications (context-aware)
    @Default(false) bool smartNotifications,
    
    /// Snooze duration options in minutes
    @Default([5, 10, 15, 30]) List<int> snoozeDurations,
    
    /// Whether to play Athan for Jumu'ah prayer specifically
    @Default(true) bool jumuahAthanEnabled,
    
    /// Special settings for Ramadan
    RamadanNotificationSettings? ramadanSettings,
    
    /// Last updated timestamp
    DateTime? lastUpdated,
  }) = _AthanSettings;

  factory AthanSettings.fromJson(Map<String, dynamic> json) =>
      _$AthanSettingsFromJson(json);
}

/// Time range for muting notifications
@freezed
class MuteTimeRange with _$MuteTimeRange {
  const factory MuteTimeRange({
    @TimeOfDayConverter() required TimeOfDay startTime,
    @TimeOfDayConverter() required TimeOfDay endTime,
    String? description,
  }) = _MuteTimeRange;

  factory MuteTimeRange.fromJson(Map<String, dynamic> json) =>
      _$MuteTimeRangeFromJson(json);
}

/// Special notification settings for Ramadan
@freezed
class RamadanNotificationSettings with _$RamadanNotificationSettings {
  const factory RamadanNotificationSettings({
    /// Whether to enable special Ramadan notifications
    @Default(true) bool enabled,
    
    /// Suhur (pre-dawn meal) reminder time in minutes before Fajr
    @Default(60) int suhurReminderMinutes,
    
    /// Iftar (breaking fast) reminder time in minutes before Maghrib
    @Default(10) int iftarReminderMinutes,
    
    /// Whether to play special Ramadan Athan
    @Default(true) bool specialRamadanAthan,
    
    /// Whether to include Ramadan duas in notifications
    @Default(true) bool includeDuas,
    
    /// Whether to track fasting status
    @Default(true) bool trackFasting,
    
    /// Custom Iftar message
    String? customIftarMessage,
    
    /// Custom Suhur message
    String? customSuhurMessage,
  }) = _RamadanNotificationSettings;

  factory RamadanNotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$RamadanNotificationSettingsFromJson(json);
}

/// Available Muadhin voices
enum MuadhinVoice {
  abdulBasit('Abdul Basit', 'abdulbasit', 'Reciter of Quran with beautiful voice'),
  misharyRashid('Mishary Rashid', 'mishary', 'Famous Imam from Kuwait'),
  sudais('Sheikh Sudais', 'sudais', 'Imam of Masjid al-Haram'),
  shuraim('Sheikh Shuraim', 'shuraim', 'Imam of Masjid al-Haram'),
  maherMuaiqly('Maher Muaiqly', 'maher', 'Imam of Masjid al-Haram'),
  yasserDossari('Yasser Dossari', 'yasser', 'Beautiful voice from Saudi Arabia'),
  ahmedAjmi('Ahmed Al-Ajmi', 'ajmi', 'Kuwaiti reciter'),
  saadGhamdi('Saad Ghamdi', 'ghamdi', 'Saudi reciter'),
  default_('Default', 'default', 'Default Islamic call to prayer');

  const MuadhinVoice(this.displayName, this.audioFileName, this.description);
  
  final String displayName;
  final String audioFileName;
  final String description;

  /// Get audio file path for this Muadhin
  String get audioPath => 'assets/audio/athan/${audioFileName}_athan.mp3';
  
  /// Get short audio path for notifications
  String get shortAudioPath => 'assets/audio/athan/${audioFileName}_short.mp3';
}

/// Notification action types
enum NotificationAction {
  markCompleted('Mark as Prayed', Icons.check_circle),
  snooze5('Snooze 5 min', Icons.snooze),
  snooze10('Snooze 10 min', Icons.snooze),
  openQibla('Show Qibla', Icons.explore),
  openPrayerTimes('Prayer Times', Icons.access_time),
  stopAthan('Stop Athan', Icons.stop);

  const NotificationAction(this.label, this.icon);
  
  final String label;
  final IconData icon;
}

/// Prayer notification priority levels
enum NotificationPriority {
  low('Low', 'Silent notification'),
  normal('Normal', 'Standard notification with sound'),
  high('High', 'Important notification with sound and vibration'),
  urgent('Urgent', 'Critical notification that overrides Do Not Disturb');

  const NotificationPriority(this.label, this.description);
  
  final String label;
  final String description;
}

/// Notification trigger types
enum NotificationTrigger {
  exact('Exact Time', 'Trigger at exact prayer time'),
  beforePrayer('Before Prayer', 'Trigger before prayer time'),
  afterAdhan('After Adhan', 'Trigger after Adhan call'),
  flexible('Flexible', 'Trigger when user is likely to see it');

  const NotificationTrigger(this.label, this.description);
  
  final String label;
  final String description;
}

/// Extensions for AthanSettings
extension AthanSettingsExtension on AthanSettings {
  /// Check if notifications are enabled for a specific prayer
  bool isPrayerEnabled(String prayerName) {
    if (!isEnabled) return false;
    return prayerSpecificSettings?[prayerName.toLowerCase()] ?? true;
  }

  /// Check if today is a muted day
  bool isTodayMuted() {
    if (mutedDays == null || mutedDays!.isEmpty) return false;
    
    final today = DateTime.now().weekday;
    final dayNames = {
      1: 'monday',
      2: 'tuesday', 
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday',
    };
    
    return mutedDays!.contains(dayNames[today]);
  }

  /// Check if current time is in a muted range
  bool isCurrentTimeMuted() {
    if (muteTimeRanges == null || muteTimeRanges!.isEmpty) return false;
    
    final now = TimeOfDay.now();
    
    for (final range in muteTimeRanges!) {
      if (_isTimeInRange(now, range.startTime, range.endTime)) {
        return true;
      }
    }
    
    return false;
  }

  /// Check if notifications should be shown
  bool shouldShowNotifications() {
    return isEnabled && !isTodayMuted() && !isCurrentTimeMuted();
  }

  /// Get appropriate Muadhin voice enum
  MuadhinVoice get muadhinVoiceEnum {
    return MuadhinVoice.values.firstWhere(
      (voice) => voice.audioFileName == muadhinVoice,
      orElse: () => MuadhinVoice.default_,
    );
  }

  /// Get custom message for a prayer or default
  String getMessageForPrayer(String prayerName) {
    if (customMessages?.containsKey(prayerName.toLowerCase()) == true) {
      return customMessages![prayerName.toLowerCase()]!;
    }
    
    // Default messages with Islamic context
    final defaultMessages = {
      'fajr': "It's time for Fajr prayer. Begin your day with Allah's remembrance.",
      'dhuhr': "It's time for Dhuhr prayer. Take a moment to connect with Allah.",
      'asr': "It's time for Asr prayer. Seek Allah's guidance in the afternoon.",
      'maghrib': "It's time for Maghrib prayer. Be grateful as the day concludes.",
      'isha': "It's time for Isha prayer. End your day in worship and gratitude.",
    };
    
    return defaultMessages[prayerName.toLowerCase()] ?? 
           "It's time for $prayerName prayer.";
  }

  /// Check if it's currently Ramadan and special settings should apply
  bool get shouldUseRamadanSettings {
    if (ramadanSettings?.enabled != true) return false;
    return IslamicUtils.isRamadan();
  }

  /// Get effective volume (considering time of day, etc.)
  double getEffectiveVolume() {
    // Reduce volume during late night hours
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour <= 5) {
      return volume * 0.7; // 30% reduction for night
    }
    return volume;
  }

  /// Helper method to check if time is in range
  bool _isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    if (startMinutes <= endMinutes) {
      // Same day range
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Overnight range
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }
}

/// Default Athan settings factory
class AthanSettingsDefaults {
  static AthanSettings get standard => const AthanSettings(
    
  );

  static AthanSettings get silent => const AthanSettings(
    muadhinVoice: 'default',
    volume: 0,
    durationSeconds: 0,
    vibrateEnabled: false,
    reminderMinutes: 15,
    overrideDnd: false,
  );

  static AthanSettings get minimal => const AthanSettings(
    muadhinVoice: 'default',
    volume: 0.5,
    durationSeconds: 60,
    reminderMinutes: 5,
  );

  static AthanSettings get ramadanSpecial => const AthanSettings(
    volume: 0.9,
    durationSeconds: 240,
    ramadanSettings: RamadanNotificationSettings(
      
    ),
  );
}
