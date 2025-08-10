// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'athan_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AthanSettings _$AthanSettingsFromJson(Map<String, dynamic> json) {
  return _AthanSettings.fromJson(json);
}

/// @nodoc
mixin _$AthanSettings {
  /// Whether Athan notifications are enabled
  bool get isEnabled => throw _privateConstructorUsedError;

  /// Selected Muadhin voice for Athan
  String get muadhinVoice => throw _privateConstructorUsedError;

  /// Volume level for Athan (0.0 to 1.0)
  double get volume => throw _privateConstructorUsedError;

  /// Duration of Athan audio in seconds
  int get durationSeconds => throw _privateConstructorUsedError;

  /// Whether to vibrate device during Athan
  bool get vibrateEnabled => throw _privateConstructorUsedError;

  /// Reminder time before prayer (in minutes)
  int get reminderMinutes => throw _privateConstructorUsedError;

  /// Prayer-specific settings (prayer name -> enabled)
  Map<String, bool>? get prayerSpecificSettings =>
      throw _privateConstructorUsedError;

  /// Days when notifications are muted (e.g., 'monday', 'tuesday')
  List<String>? get mutedDays => throw _privateConstructorUsedError;

  /// Specific time ranges when notifications are muted
  List<MuteTimeRange>? get muteTimeRanges => throw _privateConstructorUsedError;

  /// Whether to show notification in Do Not Disturb mode
  bool get overrideDnd => throw _privateConstructorUsedError;

  /// Whether to show full screen notification for Athan
  bool get fullScreenNotification => throw _privateConstructorUsedError;

  /// Whether to automatically mark prayer as completed after Athan
  bool get autoMarkCompleted => throw _privateConstructorUsedError;

  /// Custom notification message for each prayer
  Map<String, String>? get customMessages => throw _privateConstructorUsedError;

  /// Whether to include Arabic text in notifications
  bool get includeArabicText => throw _privateConstructorUsedError;

  /// Whether to show Qibla direction in notification
  bool get showQiblaDirection => throw _privateConstructorUsedError;

  /// Whether to enable smart notifications (context-aware)
  bool get smartNotifications => throw _privateConstructorUsedError;

  /// Snooze duration options in minutes
  List<int> get snoozeDurations => throw _privateConstructorUsedError;

  /// Whether to play Athan for Jumu'ah prayer specifically
  bool get jumuahAthanEnabled => throw _privateConstructorUsedError;

  /// Special settings for Ramadan
  RamadanNotificationSettings? get ramadanSettings =>
      throw _privateConstructorUsedError;

  /// Last updated timestamp
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this AthanSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AthanSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AthanSettingsCopyWith<AthanSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AthanSettingsCopyWith<$Res> {
  factory $AthanSettingsCopyWith(
          AthanSettings value, $Res Function(AthanSettings) then) =
      _$AthanSettingsCopyWithImpl<$Res, AthanSettings>;
  @useResult
  $Res call(
      {bool isEnabled,
      String muadhinVoice,
      double volume,
      int durationSeconds,
      bool vibrateEnabled,
      int reminderMinutes,
      Map<String, bool>? prayerSpecificSettings,
      List<String>? mutedDays,
      List<MuteTimeRange>? muteTimeRanges,
      bool overrideDnd,
      bool fullScreenNotification,
      bool autoMarkCompleted,
      Map<String, String>? customMessages,
      bool includeArabicText,
      bool showQiblaDirection,
      bool smartNotifications,
      List<int> snoozeDurations,
      bool jumuahAthanEnabled,
      RamadanNotificationSettings? ramadanSettings,
      DateTime? lastUpdated});

  $RamadanNotificationSettingsCopyWith<$Res>? get ramadanSettings;
}

/// @nodoc
class _$AthanSettingsCopyWithImpl<$Res, $Val extends AthanSettings>
    implements $AthanSettingsCopyWith<$Res> {
  _$AthanSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AthanSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? muadhinVoice = null,
    Object? volume = null,
    Object? durationSeconds = null,
    Object? vibrateEnabled = null,
    Object? reminderMinutes = null,
    Object? prayerSpecificSettings = freezed,
    Object? mutedDays = freezed,
    Object? muteTimeRanges = freezed,
    Object? overrideDnd = null,
    Object? fullScreenNotification = null,
    Object? autoMarkCompleted = null,
    Object? customMessages = freezed,
    Object? includeArabicText = null,
    Object? showQiblaDirection = null,
    Object? smartNotifications = null,
    Object? snoozeDurations = null,
    Object? jumuahAthanEnabled = null,
    Object? ramadanSettings = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      muadhinVoice: null == muadhinVoice
          ? _value.muadhinVoice
          : muadhinVoice // ignore: cast_nullable_to_non_nullable
              as String,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      vibrateEnabled: null == vibrateEnabled
          ? _value.vibrateEnabled
          : vibrateEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderMinutes: null == reminderMinutes
          ? _value.reminderMinutes
          : reminderMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      prayerSpecificSettings: freezed == prayerSpecificSettings
          ? _value.prayerSpecificSettings
          : prayerSpecificSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>?,
      mutedDays: freezed == mutedDays
          ? _value.mutedDays
          : mutedDays // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      muteTimeRanges: freezed == muteTimeRanges
          ? _value.muteTimeRanges
          : muteTimeRanges // ignore: cast_nullable_to_non_nullable
              as List<MuteTimeRange>?,
      overrideDnd: null == overrideDnd
          ? _value.overrideDnd
          : overrideDnd // ignore: cast_nullable_to_non_nullable
              as bool,
      fullScreenNotification: null == fullScreenNotification
          ? _value.fullScreenNotification
          : fullScreenNotification // ignore: cast_nullable_to_non_nullable
              as bool,
      autoMarkCompleted: null == autoMarkCompleted
          ? _value.autoMarkCompleted
          : autoMarkCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      customMessages: freezed == customMessages
          ? _value.customMessages
          : customMessages // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      includeArabicText: null == includeArabicText
          ? _value.includeArabicText
          : includeArabicText // ignore: cast_nullable_to_non_nullable
              as bool,
      showQiblaDirection: null == showQiblaDirection
          ? _value.showQiblaDirection
          : showQiblaDirection // ignore: cast_nullable_to_non_nullable
              as bool,
      smartNotifications: null == smartNotifications
          ? _value.smartNotifications
          : smartNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      snoozeDurations: null == snoozeDurations
          ? _value.snoozeDurations
          : snoozeDurations // ignore: cast_nullable_to_non_nullable
              as List<int>,
      jumuahAthanEnabled: null == jumuahAthanEnabled
          ? _value.jumuahAthanEnabled
          : jumuahAthanEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      ramadanSettings: freezed == ramadanSettings
          ? _value.ramadanSettings
          : ramadanSettings // ignore: cast_nullable_to_non_nullable
              as RamadanNotificationSettings?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of AthanSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RamadanNotificationSettingsCopyWith<$Res>? get ramadanSettings {
    if (_value.ramadanSettings == null) {
      return null;
    }

    return $RamadanNotificationSettingsCopyWith<$Res>(_value.ramadanSettings!,
        (value) {
      return _then(_value.copyWith(ramadanSettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AthanSettingsImplCopyWith<$Res>
    implements $AthanSettingsCopyWith<$Res> {
  factory _$$AthanSettingsImplCopyWith(
          _$AthanSettingsImpl value, $Res Function(_$AthanSettingsImpl) then) =
      __$$AthanSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isEnabled,
      String muadhinVoice,
      double volume,
      int durationSeconds,
      bool vibrateEnabled,
      int reminderMinutes,
      Map<String, bool>? prayerSpecificSettings,
      List<String>? mutedDays,
      List<MuteTimeRange>? muteTimeRanges,
      bool overrideDnd,
      bool fullScreenNotification,
      bool autoMarkCompleted,
      Map<String, String>? customMessages,
      bool includeArabicText,
      bool showQiblaDirection,
      bool smartNotifications,
      List<int> snoozeDurations,
      bool jumuahAthanEnabled,
      RamadanNotificationSettings? ramadanSettings,
      DateTime? lastUpdated});

  @override
  $RamadanNotificationSettingsCopyWith<$Res>? get ramadanSettings;
}

/// @nodoc
class __$$AthanSettingsImplCopyWithImpl<$Res>
    extends _$AthanSettingsCopyWithImpl<$Res, _$AthanSettingsImpl>
    implements _$$AthanSettingsImplCopyWith<$Res> {
  __$$AthanSettingsImplCopyWithImpl(
      _$AthanSettingsImpl _value, $Res Function(_$AthanSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AthanSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? muadhinVoice = null,
    Object? volume = null,
    Object? durationSeconds = null,
    Object? vibrateEnabled = null,
    Object? reminderMinutes = null,
    Object? prayerSpecificSettings = freezed,
    Object? mutedDays = freezed,
    Object? muteTimeRanges = freezed,
    Object? overrideDnd = null,
    Object? fullScreenNotification = null,
    Object? autoMarkCompleted = null,
    Object? customMessages = freezed,
    Object? includeArabicText = null,
    Object? showQiblaDirection = null,
    Object? smartNotifications = null,
    Object? snoozeDurations = null,
    Object? jumuahAthanEnabled = null,
    Object? ramadanSettings = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$AthanSettingsImpl(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      muadhinVoice: null == muadhinVoice
          ? _value.muadhinVoice
          : muadhinVoice // ignore: cast_nullable_to_non_nullable
              as String,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      vibrateEnabled: null == vibrateEnabled
          ? _value.vibrateEnabled
          : vibrateEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderMinutes: null == reminderMinutes
          ? _value.reminderMinutes
          : reminderMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      prayerSpecificSettings: freezed == prayerSpecificSettings
          ? _value._prayerSpecificSettings
          : prayerSpecificSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>?,
      mutedDays: freezed == mutedDays
          ? _value._mutedDays
          : mutedDays // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      muteTimeRanges: freezed == muteTimeRanges
          ? _value._muteTimeRanges
          : muteTimeRanges // ignore: cast_nullable_to_non_nullable
              as List<MuteTimeRange>?,
      overrideDnd: null == overrideDnd
          ? _value.overrideDnd
          : overrideDnd // ignore: cast_nullable_to_non_nullable
              as bool,
      fullScreenNotification: null == fullScreenNotification
          ? _value.fullScreenNotification
          : fullScreenNotification // ignore: cast_nullable_to_non_nullable
              as bool,
      autoMarkCompleted: null == autoMarkCompleted
          ? _value.autoMarkCompleted
          : autoMarkCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      customMessages: freezed == customMessages
          ? _value._customMessages
          : customMessages // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      includeArabicText: null == includeArabicText
          ? _value.includeArabicText
          : includeArabicText // ignore: cast_nullable_to_non_nullable
              as bool,
      showQiblaDirection: null == showQiblaDirection
          ? _value.showQiblaDirection
          : showQiblaDirection // ignore: cast_nullable_to_non_nullable
              as bool,
      smartNotifications: null == smartNotifications
          ? _value.smartNotifications
          : smartNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      snoozeDurations: null == snoozeDurations
          ? _value._snoozeDurations
          : snoozeDurations // ignore: cast_nullable_to_non_nullable
              as List<int>,
      jumuahAthanEnabled: null == jumuahAthanEnabled
          ? _value.jumuahAthanEnabled
          : jumuahAthanEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      ramadanSettings: freezed == ramadanSettings
          ? _value.ramadanSettings
          : ramadanSettings // ignore: cast_nullable_to_non_nullable
              as RamadanNotificationSettings?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AthanSettingsImpl implements _AthanSettings {
  const _$AthanSettingsImpl(
      {this.isEnabled = true,
      this.muadhinVoice = 'abdulbasit',
      this.volume = 0.8,
      this.durationSeconds = 180,
      this.vibrateEnabled = true,
      this.reminderMinutes = 10,
      final Map<String, bool>? prayerSpecificSettings,
      final List<String>? mutedDays,
      final List<MuteTimeRange>? muteTimeRanges,
      this.overrideDnd = true,
      this.fullScreenNotification = false,
      this.autoMarkCompleted = false,
      final Map<String, String>? customMessages,
      this.includeArabicText = true,
      this.showQiblaDirection = true,
      this.smartNotifications = false,
      final List<int> snoozeDurations = const [5, 10, 15, 30],
      this.jumuahAthanEnabled = true,
      this.ramadanSettings,
      this.lastUpdated})
      : _prayerSpecificSettings = prayerSpecificSettings,
        _mutedDays = mutedDays,
        _muteTimeRanges = muteTimeRanges,
        _customMessages = customMessages,
        _snoozeDurations = snoozeDurations;

  factory _$AthanSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AthanSettingsImplFromJson(json);

  /// Whether Athan notifications are enabled
  @override
  @JsonKey()
  final bool isEnabled;

  /// Selected Muadhin voice for Athan
  @override
  @JsonKey()
  final String muadhinVoice;

  /// Volume level for Athan (0.0 to 1.0)
  @override
  @JsonKey()
  final double volume;

  /// Duration of Athan audio in seconds
  @override
  @JsonKey()
  final int durationSeconds;

  /// Whether to vibrate device during Athan
  @override
  @JsonKey()
  final bool vibrateEnabled;

  /// Reminder time before prayer (in minutes)
  @override
  @JsonKey()
  final int reminderMinutes;

  /// Prayer-specific settings (prayer name -> enabled)
  final Map<String, bool>? _prayerSpecificSettings;

  /// Prayer-specific settings (prayer name -> enabled)
  @override
  Map<String, bool>? get prayerSpecificSettings {
    final value = _prayerSpecificSettings;
    if (value == null) return null;
    if (_prayerSpecificSettings is EqualUnmodifiableMapView)
      return _prayerSpecificSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Days when notifications are muted (e.g., 'monday', 'tuesday')
  final List<String>? _mutedDays;

  /// Days when notifications are muted (e.g., 'monday', 'tuesday')
  @override
  List<String>? get mutedDays {
    final value = _mutedDays;
    if (value == null) return null;
    if (_mutedDays is EqualUnmodifiableListView) return _mutedDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Specific time ranges when notifications are muted
  final List<MuteTimeRange>? _muteTimeRanges;

  /// Specific time ranges when notifications are muted
  @override
  List<MuteTimeRange>? get muteTimeRanges {
    final value = _muteTimeRanges;
    if (value == null) return null;
    if (_muteTimeRanges is EqualUnmodifiableListView) return _muteTimeRanges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Whether to show notification in Do Not Disturb mode
  @override
  @JsonKey()
  final bool overrideDnd;

  /// Whether to show full screen notification for Athan
  @override
  @JsonKey()
  final bool fullScreenNotification;

  /// Whether to automatically mark prayer as completed after Athan
  @override
  @JsonKey()
  final bool autoMarkCompleted;

  /// Custom notification message for each prayer
  final Map<String, String>? _customMessages;

  /// Custom notification message for each prayer
  @override
  Map<String, String>? get customMessages {
    final value = _customMessages;
    if (value == null) return null;
    if (_customMessages is EqualUnmodifiableMapView) return _customMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Whether to include Arabic text in notifications
  @override
  @JsonKey()
  final bool includeArabicText;

  /// Whether to show Qibla direction in notification
  @override
  @JsonKey()
  final bool showQiblaDirection;

  /// Whether to enable smart notifications (context-aware)
  @override
  @JsonKey()
  final bool smartNotifications;

  /// Snooze duration options in minutes
  final List<int> _snoozeDurations;

  /// Snooze duration options in minutes
  @override
  @JsonKey()
  List<int> get snoozeDurations {
    if (_snoozeDurations is EqualUnmodifiableListView) return _snoozeDurations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_snoozeDurations);
  }

  /// Whether to play Athan for Jumu'ah prayer specifically
  @override
  @JsonKey()
  final bool jumuahAthanEnabled;

  /// Special settings for Ramadan
  @override
  final RamadanNotificationSettings? ramadanSettings;

  /// Last updated timestamp
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'AthanSettings(isEnabled: $isEnabled, muadhinVoice: $muadhinVoice, volume: $volume, durationSeconds: $durationSeconds, vibrateEnabled: $vibrateEnabled, reminderMinutes: $reminderMinutes, prayerSpecificSettings: $prayerSpecificSettings, mutedDays: $mutedDays, muteTimeRanges: $muteTimeRanges, overrideDnd: $overrideDnd, fullScreenNotification: $fullScreenNotification, autoMarkCompleted: $autoMarkCompleted, customMessages: $customMessages, includeArabicText: $includeArabicText, showQiblaDirection: $showQiblaDirection, smartNotifications: $smartNotifications, snoozeDurations: $snoozeDurations, jumuahAthanEnabled: $jumuahAthanEnabled, ramadanSettings: $ramadanSettings, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AthanSettingsImpl &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.muadhinVoice, muadhinVoice) ||
                other.muadhinVoice == muadhinVoice) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.vibrateEnabled, vibrateEnabled) ||
                other.vibrateEnabled == vibrateEnabled) &&
            (identical(other.reminderMinutes, reminderMinutes) ||
                other.reminderMinutes == reminderMinutes) &&
            const DeepCollectionEquality().equals(
                other._prayerSpecificSettings, _prayerSpecificSettings) &&
            const DeepCollectionEquality()
                .equals(other._mutedDays, _mutedDays) &&
            const DeepCollectionEquality()
                .equals(other._muteTimeRanges, _muteTimeRanges) &&
            (identical(other.overrideDnd, overrideDnd) ||
                other.overrideDnd == overrideDnd) &&
            (identical(other.fullScreenNotification, fullScreenNotification) ||
                other.fullScreenNotification == fullScreenNotification) &&
            (identical(other.autoMarkCompleted, autoMarkCompleted) ||
                other.autoMarkCompleted == autoMarkCompleted) &&
            const DeepCollectionEquality()
                .equals(other._customMessages, _customMessages) &&
            (identical(other.includeArabicText, includeArabicText) ||
                other.includeArabicText == includeArabicText) &&
            (identical(other.showQiblaDirection, showQiblaDirection) ||
                other.showQiblaDirection == showQiblaDirection) &&
            (identical(other.smartNotifications, smartNotifications) ||
                other.smartNotifications == smartNotifications) &&
            const DeepCollectionEquality()
                .equals(other._snoozeDurations, _snoozeDurations) &&
            (identical(other.jumuahAthanEnabled, jumuahAthanEnabled) ||
                other.jumuahAthanEnabled == jumuahAthanEnabled) &&
            (identical(other.ramadanSettings, ramadanSettings) ||
                other.ramadanSettings == ramadanSettings) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        isEnabled,
        muadhinVoice,
        volume,
        durationSeconds,
        vibrateEnabled,
        reminderMinutes,
        const DeepCollectionEquality().hash(_prayerSpecificSettings),
        const DeepCollectionEquality().hash(_mutedDays),
        const DeepCollectionEquality().hash(_muteTimeRanges),
        overrideDnd,
        fullScreenNotification,
        autoMarkCompleted,
        const DeepCollectionEquality().hash(_customMessages),
        includeArabicText,
        showQiblaDirection,
        smartNotifications,
        const DeepCollectionEquality().hash(_snoozeDurations),
        jumuahAthanEnabled,
        ramadanSettings,
        lastUpdated
      ]);

  /// Create a copy of AthanSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AthanSettingsImplCopyWith<_$AthanSettingsImpl> get copyWith =>
      __$$AthanSettingsImplCopyWithImpl<_$AthanSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AthanSettingsImplToJson(
      this,
    );
  }
}

abstract class _AthanSettings implements AthanSettings {
  const factory _AthanSettings(
      {final bool isEnabled,
      final String muadhinVoice,
      final double volume,
      final int durationSeconds,
      final bool vibrateEnabled,
      final int reminderMinutes,
      final Map<String, bool>? prayerSpecificSettings,
      final List<String>? mutedDays,
      final List<MuteTimeRange>? muteTimeRanges,
      final bool overrideDnd,
      final bool fullScreenNotification,
      final bool autoMarkCompleted,
      final Map<String, String>? customMessages,
      final bool includeArabicText,
      final bool showQiblaDirection,
      final bool smartNotifications,
      final List<int> snoozeDurations,
      final bool jumuahAthanEnabled,
      final RamadanNotificationSettings? ramadanSettings,
      final DateTime? lastUpdated}) = _$AthanSettingsImpl;

  factory _AthanSettings.fromJson(Map<String, dynamic> json) =
      _$AthanSettingsImpl.fromJson;

  /// Whether Athan notifications are enabled
  @override
  bool get isEnabled;

  /// Selected Muadhin voice for Athan
  @override
  String get muadhinVoice;

  /// Volume level for Athan (0.0 to 1.0)
  @override
  double get volume;

  /// Duration of Athan audio in seconds
  @override
  int get durationSeconds;

  /// Whether to vibrate device during Athan
  @override
  bool get vibrateEnabled;

  /// Reminder time before prayer (in minutes)
  @override
  int get reminderMinutes;

  /// Prayer-specific settings (prayer name -> enabled)
  @override
  Map<String, bool>? get prayerSpecificSettings;

  /// Days when notifications are muted (e.g., 'monday', 'tuesday')
  @override
  List<String>? get mutedDays;

  /// Specific time ranges when notifications are muted
  @override
  List<MuteTimeRange>? get muteTimeRanges;

  /// Whether to show notification in Do Not Disturb mode
  @override
  bool get overrideDnd;

  /// Whether to show full screen notification for Athan
  @override
  bool get fullScreenNotification;

  /// Whether to automatically mark prayer as completed after Athan
  @override
  bool get autoMarkCompleted;

  /// Custom notification message for each prayer
  @override
  Map<String, String>? get customMessages;

  /// Whether to include Arabic text in notifications
  @override
  bool get includeArabicText;

  /// Whether to show Qibla direction in notification
  @override
  bool get showQiblaDirection;

  /// Whether to enable smart notifications (context-aware)
  @override
  bool get smartNotifications;

  /// Snooze duration options in minutes
  @override
  List<int> get snoozeDurations;

  /// Whether to play Athan for Jumu'ah prayer specifically
  @override
  bool get jumuahAthanEnabled;

  /// Special settings for Ramadan
  @override
  RamadanNotificationSettings? get ramadanSettings;

  /// Last updated timestamp
  @override
  DateTime? get lastUpdated;

  /// Create a copy of AthanSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AthanSettingsImplCopyWith<_$AthanSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MuteTimeRange _$MuteTimeRangeFromJson(Map<String, dynamic> json) {
  return _MuteTimeRange.fromJson(json);
}

/// @nodoc
mixin _$MuteTimeRange {
  @TimeOfDayConverter()
  TimeOfDay get startTime => throw _privateConstructorUsedError;
  @TimeOfDayConverter()
  TimeOfDay get endTime => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this MuteTimeRange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MuteTimeRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MuteTimeRangeCopyWith<MuteTimeRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MuteTimeRangeCopyWith<$Res> {
  factory $MuteTimeRangeCopyWith(
          MuteTimeRange value, $Res Function(MuteTimeRange) then) =
      _$MuteTimeRangeCopyWithImpl<$Res, MuteTimeRange>;
  @useResult
  $Res call(
      {@TimeOfDayConverter() TimeOfDay startTime,
      @TimeOfDayConverter() TimeOfDay endTime,
      String? description});
}

/// @nodoc
class _$MuteTimeRangeCopyWithImpl<$Res, $Val extends MuteTimeRange>
    implements $MuteTimeRangeCopyWith<$Res> {
  _$MuteTimeRangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MuteTimeRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MuteTimeRangeImplCopyWith<$Res>
    implements $MuteTimeRangeCopyWith<$Res> {
  factory _$$MuteTimeRangeImplCopyWith(
          _$MuteTimeRangeImpl value, $Res Function(_$MuteTimeRangeImpl) then) =
      __$$MuteTimeRangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@TimeOfDayConverter() TimeOfDay startTime,
      @TimeOfDayConverter() TimeOfDay endTime,
      String? description});
}

/// @nodoc
class __$$MuteTimeRangeImplCopyWithImpl<$Res>
    extends _$MuteTimeRangeCopyWithImpl<$Res, _$MuteTimeRangeImpl>
    implements _$$MuteTimeRangeImplCopyWith<$Res> {
  __$$MuteTimeRangeImplCopyWithImpl(
      _$MuteTimeRangeImpl _value, $Res Function(_$MuteTimeRangeImpl) _then)
      : super(_value, _then);

  /// Create a copy of MuteTimeRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? description = freezed,
  }) {
    return _then(_$MuteTimeRangeImpl(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MuteTimeRangeImpl implements _MuteTimeRange {
  const _$MuteTimeRangeImpl(
      {@TimeOfDayConverter() required this.startTime,
      @TimeOfDayConverter() required this.endTime,
      this.description});

  factory _$MuteTimeRangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$MuteTimeRangeImplFromJson(json);

  @override
  @TimeOfDayConverter()
  final TimeOfDay startTime;
  @override
  @TimeOfDayConverter()
  final TimeOfDay endTime;
  @override
  final String? description;

  @override
  String toString() {
    return 'MuteTimeRange(startTime: $startTime, endTime: $endTime, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MuteTimeRangeImpl &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, startTime, endTime, description);

  /// Create a copy of MuteTimeRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MuteTimeRangeImplCopyWith<_$MuteTimeRangeImpl> get copyWith =>
      __$$MuteTimeRangeImplCopyWithImpl<_$MuteTimeRangeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MuteTimeRangeImplToJson(
      this,
    );
  }
}

abstract class _MuteTimeRange implements MuteTimeRange {
  const factory _MuteTimeRange(
      {@TimeOfDayConverter() required final TimeOfDay startTime,
      @TimeOfDayConverter() required final TimeOfDay endTime,
      final String? description}) = _$MuteTimeRangeImpl;

  factory _MuteTimeRange.fromJson(Map<String, dynamic> json) =
      _$MuteTimeRangeImpl.fromJson;

  @override
  @TimeOfDayConverter()
  TimeOfDay get startTime;
  @override
  @TimeOfDayConverter()
  TimeOfDay get endTime;
  @override
  String? get description;

  /// Create a copy of MuteTimeRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MuteTimeRangeImplCopyWith<_$MuteTimeRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RamadanNotificationSettings _$RamadanNotificationSettingsFromJson(
    Map<String, dynamic> json) {
  return _RamadanNotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$RamadanNotificationSettings {
  /// Whether to enable special Ramadan notifications
  bool get enabled => throw _privateConstructorUsedError;

  /// Suhur (pre-dawn meal) reminder time in minutes before Fajr
  int get suhurReminderMinutes => throw _privateConstructorUsedError;

  /// Iftar (breaking fast) reminder time in minutes before Maghrib
  int get iftarReminderMinutes => throw _privateConstructorUsedError;

  /// Whether to play special Ramadan Athan
  bool get specialRamadanAthan => throw _privateConstructorUsedError;

  /// Whether to include Ramadan duas in notifications
  bool get includeDuas => throw _privateConstructorUsedError;

  /// Whether to track fasting status
  bool get trackFasting => throw _privateConstructorUsedError;

  /// Custom Iftar message
  String? get customIftarMessage => throw _privateConstructorUsedError;

  /// Custom Suhur message
  String? get customSuhurMessage => throw _privateConstructorUsedError;

  /// Serializes this RamadanNotificationSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RamadanNotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RamadanNotificationSettingsCopyWith<RamadanNotificationSettings>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RamadanNotificationSettingsCopyWith<$Res> {
  factory $RamadanNotificationSettingsCopyWith(
          RamadanNotificationSettings value,
          $Res Function(RamadanNotificationSettings) then) =
      _$RamadanNotificationSettingsCopyWithImpl<$Res,
          RamadanNotificationSettings>;
  @useResult
  $Res call(
      {bool enabled,
      int suhurReminderMinutes,
      int iftarReminderMinutes,
      bool specialRamadanAthan,
      bool includeDuas,
      bool trackFasting,
      String? customIftarMessage,
      String? customSuhurMessage});
}

/// @nodoc
class _$RamadanNotificationSettingsCopyWithImpl<$Res,
        $Val extends RamadanNotificationSettings>
    implements $RamadanNotificationSettingsCopyWith<$Res> {
  _$RamadanNotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RamadanNotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? suhurReminderMinutes = null,
    Object? iftarReminderMinutes = null,
    Object? specialRamadanAthan = null,
    Object? includeDuas = null,
    Object? trackFasting = null,
    Object? customIftarMessage = freezed,
    Object? customSuhurMessage = freezed,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      suhurReminderMinutes: null == suhurReminderMinutes
          ? _value.suhurReminderMinutes
          : suhurReminderMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      iftarReminderMinutes: null == iftarReminderMinutes
          ? _value.iftarReminderMinutes
          : iftarReminderMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      specialRamadanAthan: null == specialRamadanAthan
          ? _value.specialRamadanAthan
          : specialRamadanAthan // ignore: cast_nullable_to_non_nullable
              as bool,
      includeDuas: null == includeDuas
          ? _value.includeDuas
          : includeDuas // ignore: cast_nullable_to_non_nullable
              as bool,
      trackFasting: null == trackFasting
          ? _value.trackFasting
          : trackFasting // ignore: cast_nullable_to_non_nullable
              as bool,
      customIftarMessage: freezed == customIftarMessage
          ? _value.customIftarMessage
          : customIftarMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      customSuhurMessage: freezed == customSuhurMessage
          ? _value.customSuhurMessage
          : customSuhurMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RamadanNotificationSettingsImplCopyWith<$Res>
    implements $RamadanNotificationSettingsCopyWith<$Res> {
  factory _$$RamadanNotificationSettingsImplCopyWith(
          _$RamadanNotificationSettingsImpl value,
          $Res Function(_$RamadanNotificationSettingsImpl) then) =
      __$$RamadanNotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enabled,
      int suhurReminderMinutes,
      int iftarReminderMinutes,
      bool specialRamadanAthan,
      bool includeDuas,
      bool trackFasting,
      String? customIftarMessage,
      String? customSuhurMessage});
}

/// @nodoc
class __$$RamadanNotificationSettingsImplCopyWithImpl<$Res>
    extends _$RamadanNotificationSettingsCopyWithImpl<$Res,
        _$RamadanNotificationSettingsImpl>
    implements _$$RamadanNotificationSettingsImplCopyWith<$Res> {
  __$$RamadanNotificationSettingsImplCopyWithImpl(
      _$RamadanNotificationSettingsImpl _value,
      $Res Function(_$RamadanNotificationSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of RamadanNotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? suhurReminderMinutes = null,
    Object? iftarReminderMinutes = null,
    Object? specialRamadanAthan = null,
    Object? includeDuas = null,
    Object? trackFasting = null,
    Object? customIftarMessage = freezed,
    Object? customSuhurMessage = freezed,
  }) {
    return _then(_$RamadanNotificationSettingsImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      suhurReminderMinutes: null == suhurReminderMinutes
          ? _value.suhurReminderMinutes
          : suhurReminderMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      iftarReminderMinutes: null == iftarReminderMinutes
          ? _value.iftarReminderMinutes
          : iftarReminderMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      specialRamadanAthan: null == specialRamadanAthan
          ? _value.specialRamadanAthan
          : specialRamadanAthan // ignore: cast_nullable_to_non_nullable
              as bool,
      includeDuas: null == includeDuas
          ? _value.includeDuas
          : includeDuas // ignore: cast_nullable_to_non_nullable
              as bool,
      trackFasting: null == trackFasting
          ? _value.trackFasting
          : trackFasting // ignore: cast_nullable_to_non_nullable
              as bool,
      customIftarMessage: freezed == customIftarMessage
          ? _value.customIftarMessage
          : customIftarMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      customSuhurMessage: freezed == customSuhurMessage
          ? _value.customSuhurMessage
          : customSuhurMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RamadanNotificationSettingsImpl
    implements _RamadanNotificationSettings {
  const _$RamadanNotificationSettingsImpl(
      {this.enabled = true,
      this.suhurReminderMinutes = 60,
      this.iftarReminderMinutes = 10,
      this.specialRamadanAthan = true,
      this.includeDuas = true,
      this.trackFasting = true,
      this.customIftarMessage,
      this.customSuhurMessage});

  factory _$RamadanNotificationSettingsImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$RamadanNotificationSettingsImplFromJson(json);

  /// Whether to enable special Ramadan notifications
  @override
  @JsonKey()
  final bool enabled;

  /// Suhur (pre-dawn meal) reminder time in minutes before Fajr
  @override
  @JsonKey()
  final int suhurReminderMinutes;

  /// Iftar (breaking fast) reminder time in minutes before Maghrib
  @override
  @JsonKey()
  final int iftarReminderMinutes;

  /// Whether to play special Ramadan Athan
  @override
  @JsonKey()
  final bool specialRamadanAthan;

  /// Whether to include Ramadan duas in notifications
  @override
  @JsonKey()
  final bool includeDuas;

  /// Whether to track fasting status
  @override
  @JsonKey()
  final bool trackFasting;

  /// Custom Iftar message
  @override
  final String? customIftarMessage;

  /// Custom Suhur message
  @override
  final String? customSuhurMessage;

  @override
  String toString() {
    return 'RamadanNotificationSettings(enabled: $enabled, suhurReminderMinutes: $suhurReminderMinutes, iftarReminderMinutes: $iftarReminderMinutes, specialRamadanAthan: $specialRamadanAthan, includeDuas: $includeDuas, trackFasting: $trackFasting, customIftarMessage: $customIftarMessage, customSuhurMessage: $customSuhurMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RamadanNotificationSettingsImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.suhurReminderMinutes, suhurReminderMinutes) ||
                other.suhurReminderMinutes == suhurReminderMinutes) &&
            (identical(other.iftarReminderMinutes, iftarReminderMinutes) ||
                other.iftarReminderMinutes == iftarReminderMinutes) &&
            (identical(other.specialRamadanAthan, specialRamadanAthan) ||
                other.specialRamadanAthan == specialRamadanAthan) &&
            (identical(other.includeDuas, includeDuas) ||
                other.includeDuas == includeDuas) &&
            (identical(other.trackFasting, trackFasting) ||
                other.trackFasting == trackFasting) &&
            (identical(other.customIftarMessage, customIftarMessage) ||
                other.customIftarMessage == customIftarMessage) &&
            (identical(other.customSuhurMessage, customSuhurMessage) ||
                other.customSuhurMessage == customSuhurMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enabled,
      suhurReminderMinutes,
      iftarReminderMinutes,
      specialRamadanAthan,
      includeDuas,
      trackFasting,
      customIftarMessage,
      customSuhurMessage);

  /// Create a copy of RamadanNotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RamadanNotificationSettingsImplCopyWith<_$RamadanNotificationSettingsImpl>
      get copyWith => __$$RamadanNotificationSettingsImplCopyWithImpl<
          _$RamadanNotificationSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RamadanNotificationSettingsImplToJson(
      this,
    );
  }
}

abstract class _RamadanNotificationSettings
    implements RamadanNotificationSettings {
  const factory _RamadanNotificationSettings(
      {final bool enabled,
      final int suhurReminderMinutes,
      final int iftarReminderMinutes,
      final bool specialRamadanAthan,
      final bool includeDuas,
      final bool trackFasting,
      final String? customIftarMessage,
      final String? customSuhurMessage}) = _$RamadanNotificationSettingsImpl;

  factory _RamadanNotificationSettings.fromJson(Map<String, dynamic> json) =
      _$RamadanNotificationSettingsImpl.fromJson;

  /// Whether to enable special Ramadan notifications
  @override
  bool get enabled;

  /// Suhur (pre-dawn meal) reminder time in minutes before Fajr
  @override
  int get suhurReminderMinutes;

  /// Iftar (breaking fast) reminder time in minutes before Maghrib
  @override
  int get iftarReminderMinutes;

  /// Whether to play special Ramadan Athan
  @override
  bool get specialRamadanAthan;

  /// Whether to include Ramadan duas in notifications
  @override
  bool get includeDuas;

  /// Whether to track fasting status
  @override
  bool get trackFasting;

  /// Custom Iftar message
  @override
  String? get customIftarMessage;

  /// Custom Suhur message
  @override
  String? get customSuhurMessage;

  /// Create a copy of RamadanNotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RamadanNotificationSettingsImplCopyWith<_$RamadanNotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
