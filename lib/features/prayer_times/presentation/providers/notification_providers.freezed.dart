// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotificationPermissionsState {
  bool get notificationPermission => throw _privateConstructorUsedError;
  bool get exactAlarmPermission => throw _privateConstructorUsedError;
  bool get dndOverridePermission => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPermissionsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPermissionsStateCopyWith<NotificationPermissionsState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPermissionsStateCopyWith<$Res> {
  factory $NotificationPermissionsStateCopyWith(
          NotificationPermissionsState value,
          $Res Function(NotificationPermissionsState) then) =
      _$NotificationPermissionsStateCopyWithImpl<$Res,
          NotificationPermissionsState>;
  @useResult
  $Res call(
      {bool notificationPermission,
      bool exactAlarmPermission,
      bool dndOverridePermission});
}

/// @nodoc
class _$NotificationPermissionsStateCopyWithImpl<$Res,
        $Val extends NotificationPermissionsState>
    implements $NotificationPermissionsStateCopyWith<$Res> {
  _$NotificationPermissionsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPermissionsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationPermission = null,
    Object? exactAlarmPermission = null,
    Object? dndOverridePermission = null,
  }) {
    return _then(_value.copyWith(
      notificationPermission: null == notificationPermission
          ? _value.notificationPermission
          : notificationPermission // ignore: cast_nullable_to_non_nullable
              as bool,
      exactAlarmPermission: null == exactAlarmPermission
          ? _value.exactAlarmPermission
          : exactAlarmPermission // ignore: cast_nullable_to_non_nullable
              as bool,
      dndOverridePermission: null == dndOverridePermission
          ? _value.dndOverridePermission
          : dndOverridePermission // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationPermissionsStateImplCopyWith<$Res>
    implements $NotificationPermissionsStateCopyWith<$Res> {
  factory _$$NotificationPermissionsStateImplCopyWith(
          _$NotificationPermissionsStateImpl value,
          $Res Function(_$NotificationPermissionsStateImpl) then) =
      __$$NotificationPermissionsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool notificationPermission,
      bool exactAlarmPermission,
      bool dndOverridePermission});
}

/// @nodoc
class __$$NotificationPermissionsStateImplCopyWithImpl<$Res>
    extends _$NotificationPermissionsStateCopyWithImpl<$Res,
        _$NotificationPermissionsStateImpl>
    implements _$$NotificationPermissionsStateImplCopyWith<$Res> {
  __$$NotificationPermissionsStateImplCopyWithImpl(
      _$NotificationPermissionsStateImpl _value,
      $Res Function(_$NotificationPermissionsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationPermissionsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationPermission = null,
    Object? exactAlarmPermission = null,
    Object? dndOverridePermission = null,
  }) {
    return _then(_$NotificationPermissionsStateImpl(
      notificationPermission: null == notificationPermission
          ? _value.notificationPermission
          : notificationPermission // ignore: cast_nullable_to_non_nullable
              as bool,
      exactAlarmPermission: null == exactAlarmPermission
          ? _value.exactAlarmPermission
          : exactAlarmPermission // ignore: cast_nullable_to_non_nullable
              as bool,
      dndOverridePermission: null == dndOverridePermission
          ? _value.dndOverridePermission
          : dndOverridePermission // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$NotificationPermissionsStateImpl
    implements _NotificationPermissionsState {
  const _$NotificationPermissionsStateImpl(
      {this.notificationPermission = false,
      this.exactAlarmPermission = false,
      this.dndOverridePermission = false});

  @override
  @JsonKey()
  final bool notificationPermission;
  @override
  @JsonKey()
  final bool exactAlarmPermission;
  @override
  @JsonKey()
  final bool dndOverridePermission;

  @override
  String toString() {
    return 'NotificationPermissionsState(notificationPermission: $notificationPermission, exactAlarmPermission: $exactAlarmPermission, dndOverridePermission: $dndOverridePermission)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPermissionsStateImpl &&
            (identical(other.notificationPermission, notificationPermission) ||
                other.notificationPermission == notificationPermission) &&
            (identical(other.exactAlarmPermission, exactAlarmPermission) ||
                other.exactAlarmPermission == exactAlarmPermission) &&
            (identical(other.dndOverridePermission, dndOverridePermission) ||
                other.dndOverridePermission == dndOverridePermission));
  }

  @override
  int get hashCode => Object.hash(runtimeType, notificationPermission,
      exactAlarmPermission, dndOverridePermission);

  /// Create a copy of NotificationPermissionsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPermissionsStateImplCopyWith<
          _$NotificationPermissionsStateImpl>
      get copyWith => __$$NotificationPermissionsStateImplCopyWithImpl<
          _$NotificationPermissionsStateImpl>(this, _$identity);
}

abstract class _NotificationPermissionsState
    implements NotificationPermissionsState {
  const factory _NotificationPermissionsState(
      {final bool notificationPermission,
      final bool exactAlarmPermission,
      final bool dndOverridePermission}) = _$NotificationPermissionsStateImpl;

  @override
  bool get notificationPermission;
  @override
  bool get exactAlarmPermission;
  @override
  bool get dndOverridePermission;

  /// Create a copy of NotificationPermissionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPermissionsStateImplCopyWith<
          _$NotificationPermissionsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AthanAudioState {
  bool get isPlaying => throw _privateConstructorUsedError;
  Failure? get error => throw _privateConstructorUsedError;

  /// Create a copy of AthanAudioState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AthanAudioStateCopyWith<AthanAudioState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AthanAudioStateCopyWith<$Res> {
  factory $AthanAudioStateCopyWith(
          AthanAudioState value, $Res Function(AthanAudioState) then) =
      _$AthanAudioStateCopyWithImpl<$Res, AthanAudioState>;
  @useResult
  $Res call({bool isPlaying, Failure? error});

  $FailureCopyWith<$Res>? get error;
}

/// @nodoc
class _$AthanAudioStateCopyWithImpl<$Res, $Val extends AthanAudioState>
    implements $AthanAudioStateCopyWith<$Res> {
  _$AthanAudioStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AthanAudioState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as Failure?,
    ) as $Val);
  }

  /// Create a copy of AthanAudioState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FailureCopyWith<$Res>? get error {
    if (_value.error == null) {
      return null;
    }

    return $FailureCopyWith<$Res>(_value.error!, (value) {
      return _then(_value.copyWith(error: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AthanAudioStateImplCopyWith<$Res>
    implements $AthanAudioStateCopyWith<$Res> {
  factory _$$AthanAudioStateImplCopyWith(_$AthanAudioStateImpl value,
          $Res Function(_$AthanAudioStateImpl) then) =
      __$$AthanAudioStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isPlaying, Failure? error});

  @override
  $FailureCopyWith<$Res>? get error;
}

/// @nodoc
class __$$AthanAudioStateImplCopyWithImpl<$Res>
    extends _$AthanAudioStateCopyWithImpl<$Res, _$AthanAudioStateImpl>
    implements _$$AthanAudioStateImplCopyWith<$Res> {
  __$$AthanAudioStateImplCopyWithImpl(
      _$AthanAudioStateImpl _value, $Res Function(_$AthanAudioStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AthanAudioState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? error = freezed,
  }) {
    return _then(_$AthanAudioStateImpl(
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as Failure?,
    ));
  }
}

/// @nodoc

class _$AthanAudioStateImpl implements _AthanAudioState {
  const _$AthanAudioStateImpl({this.isPlaying = false, this.error});

  @override
  @JsonKey()
  final bool isPlaying;
  @override
  final Failure? error;

  @override
  String toString() {
    return 'AthanAudioState(isPlaying: $isPlaying, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AthanAudioStateImpl &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isPlaying, error);

  /// Create a copy of AthanAudioState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AthanAudioStateImplCopyWith<_$AthanAudioStateImpl> get copyWith =>
      __$$AthanAudioStateImplCopyWithImpl<_$AthanAudioStateImpl>(
          this, _$identity);
}

abstract class _AthanAudioState implements AthanAudioState {
  const factory _AthanAudioState({final bool isPlaying, final Failure? error}) =
      _$AthanAudioStateImpl;

  @override
  bool get isPlaying;
  @override
  Failure? get error;

  /// Create a copy of AthanAudioState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AthanAudioStateImplCopyWith<_$AthanAudioStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RamadanNotificationState {
  bool get isRamadan => throw _privateConstructorUsedError;
  int? get daysRemaining => throw _privateConstructorUsedError;
  DateTime? get nextSuhurTime => throw _privateConstructorUsedError;
  DateTime? get nextIftarTime => throw _privateConstructorUsedError;

  /// Create a copy of RamadanNotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RamadanNotificationStateCopyWith<RamadanNotificationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RamadanNotificationStateCopyWith<$Res> {
  factory $RamadanNotificationStateCopyWith(RamadanNotificationState value,
          $Res Function(RamadanNotificationState) then) =
      _$RamadanNotificationStateCopyWithImpl<$Res, RamadanNotificationState>;
  @useResult
  $Res call(
      {bool isRamadan,
      int? daysRemaining,
      DateTime? nextSuhurTime,
      DateTime? nextIftarTime});
}

/// @nodoc
class _$RamadanNotificationStateCopyWithImpl<$Res,
        $Val extends RamadanNotificationState>
    implements $RamadanNotificationStateCopyWith<$Res> {
  _$RamadanNotificationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RamadanNotificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRamadan = null,
    Object? daysRemaining = freezed,
    Object? nextSuhurTime = freezed,
    Object? nextIftarTime = freezed,
  }) {
    return _then(_value.copyWith(
      isRamadan: null == isRamadan
          ? _value.isRamadan
          : isRamadan // ignore: cast_nullable_to_non_nullable
              as bool,
      daysRemaining: freezed == daysRemaining
          ? _value.daysRemaining
          : daysRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
      nextSuhurTime: freezed == nextSuhurTime
          ? _value.nextSuhurTime
          : nextSuhurTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextIftarTime: freezed == nextIftarTime
          ? _value.nextIftarTime
          : nextIftarTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RamadanNotificationStateImplCopyWith<$Res>
    implements $RamadanNotificationStateCopyWith<$Res> {
  factory _$$RamadanNotificationStateImplCopyWith(
          _$RamadanNotificationStateImpl value,
          $Res Function(_$RamadanNotificationStateImpl) then) =
      __$$RamadanNotificationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isRamadan,
      int? daysRemaining,
      DateTime? nextSuhurTime,
      DateTime? nextIftarTime});
}

/// @nodoc
class __$$RamadanNotificationStateImplCopyWithImpl<$Res>
    extends _$RamadanNotificationStateCopyWithImpl<$Res,
        _$RamadanNotificationStateImpl>
    implements _$$RamadanNotificationStateImplCopyWith<$Res> {
  __$$RamadanNotificationStateImplCopyWithImpl(
      _$RamadanNotificationStateImpl _value,
      $Res Function(_$RamadanNotificationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RamadanNotificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRamadan = null,
    Object? daysRemaining = freezed,
    Object? nextSuhurTime = freezed,
    Object? nextIftarTime = freezed,
  }) {
    return _then(_$RamadanNotificationStateImpl(
      isRamadan: null == isRamadan
          ? _value.isRamadan
          : isRamadan // ignore: cast_nullable_to_non_nullable
              as bool,
      daysRemaining: freezed == daysRemaining
          ? _value.daysRemaining
          : daysRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
      nextSuhurTime: freezed == nextSuhurTime
          ? _value.nextSuhurTime
          : nextSuhurTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextIftarTime: freezed == nextIftarTime
          ? _value.nextIftarTime
          : nextIftarTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$RamadanNotificationStateImpl implements _RamadanNotificationState {
  const _$RamadanNotificationStateImpl(
      {this.isRamadan = false,
      this.daysRemaining,
      this.nextSuhurTime,
      this.nextIftarTime});

  @override
  @JsonKey()
  final bool isRamadan;
  @override
  final int? daysRemaining;
  @override
  final DateTime? nextSuhurTime;
  @override
  final DateTime? nextIftarTime;

  @override
  String toString() {
    return 'RamadanNotificationState(isRamadan: $isRamadan, daysRemaining: $daysRemaining, nextSuhurTime: $nextSuhurTime, nextIftarTime: $nextIftarTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RamadanNotificationStateImpl &&
            (identical(other.isRamadan, isRamadan) ||
                other.isRamadan == isRamadan) &&
            (identical(other.daysRemaining, daysRemaining) ||
                other.daysRemaining == daysRemaining) &&
            (identical(other.nextSuhurTime, nextSuhurTime) ||
                other.nextSuhurTime == nextSuhurTime) &&
            (identical(other.nextIftarTime, nextIftarTime) ||
                other.nextIftarTime == nextIftarTime));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, isRamadan, daysRemaining, nextSuhurTime, nextIftarTime);

  /// Create a copy of RamadanNotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RamadanNotificationStateImplCopyWith<_$RamadanNotificationStateImpl>
      get copyWith => __$$RamadanNotificationStateImplCopyWithImpl<
          _$RamadanNotificationStateImpl>(this, _$identity);
}

abstract class _RamadanNotificationState implements RamadanNotificationState {
  const factory _RamadanNotificationState(
      {final bool isRamadan,
      final int? daysRemaining,
      final DateTime? nextSuhurTime,
      final DateTime? nextIftarTime}) = _$RamadanNotificationStateImpl;

  @override
  bool get isRamadan;
  @override
  int? get daysRemaining;
  @override
  DateTime? get nextSuhurTime;
  @override
  DateTime? get nextIftarTime;

  /// Create a copy of RamadanNotificationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RamadanNotificationStateImplCopyWith<_$RamadanNotificationStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NotificationStatistics {
  int get pendingCount => throw _privateConstructorUsedError;
  int get enabledPrayers => throw _privateConstructorUsedError;
  DateTime? get nextNotificationTime => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;

  /// Create a copy of NotificationStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationStatisticsCopyWith<NotificationStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationStatisticsCopyWith<$Res> {
  factory $NotificationStatisticsCopyWith(NotificationStatistics value,
          $Res Function(NotificationStatistics) then) =
      _$NotificationStatisticsCopyWithImpl<$Res, NotificationStatistics>;
  @useResult
  $Res call(
      {int pendingCount,
      int enabledPrayers,
      DateTime? nextNotificationTime,
      bool isEnabled});
}

/// @nodoc
class _$NotificationStatisticsCopyWithImpl<$Res,
        $Val extends NotificationStatistics>
    implements $NotificationStatisticsCopyWith<$Res> {
  _$NotificationStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pendingCount = null,
    Object? enabledPrayers = null,
    Object? nextNotificationTime = freezed,
    Object? isEnabled = null,
  }) {
    return _then(_value.copyWith(
      pendingCount: null == pendingCount
          ? _value.pendingCount
          : pendingCount // ignore: cast_nullable_to_non_nullable
              as int,
      enabledPrayers: null == enabledPrayers
          ? _value.enabledPrayers
          : enabledPrayers // ignore: cast_nullable_to_non_nullable
              as int,
      nextNotificationTime: freezed == nextNotificationTime
          ? _value.nextNotificationTime
          : nextNotificationTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationStatisticsImplCopyWith<$Res>
    implements $NotificationStatisticsCopyWith<$Res> {
  factory _$$NotificationStatisticsImplCopyWith(
          _$NotificationStatisticsImpl value,
          $Res Function(_$NotificationStatisticsImpl) then) =
      __$$NotificationStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int pendingCount,
      int enabledPrayers,
      DateTime? nextNotificationTime,
      bool isEnabled});
}

/// @nodoc
class __$$NotificationStatisticsImplCopyWithImpl<$Res>
    extends _$NotificationStatisticsCopyWithImpl<$Res,
        _$NotificationStatisticsImpl>
    implements _$$NotificationStatisticsImplCopyWith<$Res> {
  __$$NotificationStatisticsImplCopyWithImpl(
      _$NotificationStatisticsImpl _value,
      $Res Function(_$NotificationStatisticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pendingCount = null,
    Object? enabledPrayers = null,
    Object? nextNotificationTime = freezed,
    Object? isEnabled = null,
  }) {
    return _then(_$NotificationStatisticsImpl(
      pendingCount: null == pendingCount
          ? _value.pendingCount
          : pendingCount // ignore: cast_nullable_to_non_nullable
              as int,
      enabledPrayers: null == enabledPrayers
          ? _value.enabledPrayers
          : enabledPrayers // ignore: cast_nullable_to_non_nullable
              as int,
      nextNotificationTime: freezed == nextNotificationTime
          ? _value.nextNotificationTime
          : nextNotificationTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$NotificationStatisticsImpl implements _NotificationStatistics {
  const _$NotificationStatisticsImpl(
      {required this.pendingCount,
      required this.enabledPrayers,
      this.nextNotificationTime,
      required this.isEnabled});

  @override
  final int pendingCount;
  @override
  final int enabledPrayers;
  @override
  final DateTime? nextNotificationTime;
  @override
  final bool isEnabled;

  @override
  String toString() {
    return 'NotificationStatistics(pendingCount: $pendingCount, enabledPrayers: $enabledPrayers, nextNotificationTime: $nextNotificationTime, isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationStatisticsImpl &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount) &&
            (identical(other.enabledPrayers, enabledPrayers) ||
                other.enabledPrayers == enabledPrayers) &&
            (identical(other.nextNotificationTime, nextNotificationTime) ||
                other.nextNotificationTime == nextNotificationTime) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pendingCount, enabledPrayers,
      nextNotificationTime, isEnabled);

  /// Create a copy of NotificationStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationStatisticsImplCopyWith<_$NotificationStatisticsImpl>
      get copyWith => __$$NotificationStatisticsImplCopyWithImpl<
          _$NotificationStatisticsImpl>(this, _$identity);
}

abstract class _NotificationStatistics implements NotificationStatistics {
  const factory _NotificationStatistics(
      {required final int pendingCount,
      required final int enabledPrayers,
      final DateTime? nextNotificationTime,
      required final bool isEnabled}) = _$NotificationStatisticsImpl;

  @override
  int get pendingCount;
  @override
  int get enabledPrayers;
  @override
  DateTime? get nextNotificationTime;
  @override
  bool get isEnabled;

  /// Create a copy of NotificationStatistics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationStatisticsImplCopyWith<_$NotificationStatisticsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
