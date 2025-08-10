// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athan_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AthanSettingsImpl _$$AthanSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AthanSettingsImpl(
      isEnabled: json['isEnabled'] as bool? ?? true,
      muadhinVoice: json['muadhinVoice'] as String? ?? 'abdulbasit',
      volume: (json['volume'] as num?)?.toDouble() ?? 0.8,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 180,
      vibrateEnabled: json['vibrateEnabled'] as bool? ?? true,
      reminderMinutes: (json['reminderMinutes'] as num?)?.toInt() ?? 10,
      prayerSpecificSettings:
          (json['prayerSpecificSettings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ),
      mutedDays: (json['mutedDays'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      muteTimeRanges: (json['muteTimeRanges'] as List<dynamic>?)
          ?.map((e) => MuteTimeRange.fromJson(e as Map<String, dynamic>))
          .toList(),
      overrideDnd: json['overrideDnd'] as bool? ?? true,
      fullScreenNotification: json['fullScreenNotification'] as bool? ?? false,
      autoMarkCompleted: json['autoMarkCompleted'] as bool? ?? false,
      customMessages: (json['customMessages'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      includeArabicText: json['includeArabicText'] as bool? ?? true,
      showQiblaDirection: json['showQiblaDirection'] as bool? ?? true,
      smartNotifications: json['smartNotifications'] as bool? ?? false,
      snoozeDurations: (json['snoozeDurations'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [5, 10, 15, 30],
      jumuahAthanEnabled: json['jumuahAthanEnabled'] as bool? ?? true,
      ramadanSettings: json['ramadanSettings'] == null
          ? null
          : RamadanNotificationSettings.fromJson(
              json['ramadanSettings'] as Map<String, dynamic>),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$AthanSettingsImplToJson(_$AthanSettingsImpl instance) =>
    <String, dynamic>{
      'isEnabled': instance.isEnabled,
      'muadhinVoice': instance.muadhinVoice,
      'volume': instance.volume,
      'durationSeconds': instance.durationSeconds,
      'vibrateEnabled': instance.vibrateEnabled,
      'reminderMinutes': instance.reminderMinutes,
      'prayerSpecificSettings': instance.prayerSpecificSettings,
      'mutedDays': instance.mutedDays,
      'muteTimeRanges': instance.muteTimeRanges,
      'overrideDnd': instance.overrideDnd,
      'fullScreenNotification': instance.fullScreenNotification,
      'autoMarkCompleted': instance.autoMarkCompleted,
      'customMessages': instance.customMessages,
      'includeArabicText': instance.includeArabicText,
      'showQiblaDirection': instance.showQiblaDirection,
      'smartNotifications': instance.smartNotifications,
      'snoozeDurations': instance.snoozeDurations,
      'jumuahAthanEnabled': instance.jumuahAthanEnabled,
      'ramadanSettings': instance.ramadanSettings,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

_$MuteTimeRangeImpl _$$MuteTimeRangeImplFromJson(Map<String, dynamic> json) =>
    _$MuteTimeRangeImpl(
      startTime:
          const TimeOfDayConverter().fromJson(json['startTime'] as String),
      endTime: const TimeOfDayConverter().fromJson(json['endTime'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$MuteTimeRangeImplToJson(_$MuteTimeRangeImpl instance) =>
    <String, dynamic>{
      'startTime': const TimeOfDayConverter().toJson(instance.startTime),
      'endTime': const TimeOfDayConverter().toJson(instance.endTime),
      'description': instance.description,
    };

_$RamadanNotificationSettingsImpl _$$RamadanNotificationSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$RamadanNotificationSettingsImpl(
      enabled: json['enabled'] as bool? ?? true,
      suhurReminderMinutes:
          (json['suhurReminderMinutes'] as num?)?.toInt() ?? 60,
      iftarReminderMinutes:
          (json['iftarReminderMinutes'] as num?)?.toInt() ?? 10,
      specialRamadanAthan: json['specialRamadanAthan'] as bool? ?? true,
      includeDuas: json['includeDuas'] as bool? ?? true,
      trackFasting: json['trackFasting'] as bool? ?? true,
      customIftarMessage: json['customIftarMessage'] as String?,
      customSuhurMessage: json['customSuhurMessage'] as String?,
    );

Map<String, dynamic> _$$RamadanNotificationSettingsImplToJson(
        _$RamadanNotificationSettingsImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'suhurReminderMinutes': instance.suhurReminderMinutes,
      'iftarReminderMinutes': instance.iftarReminderMinutes,
      'specialRamadanAthan': instance.specialRamadanAthan,
      'includeDuas': instance.includeDuas,
      'trackFasting': instance.trackFasting,
      'customIftarMessage': instance.customIftarMessage,
      'customSuhurMessage': instance.customSuhurMessage,
    };
