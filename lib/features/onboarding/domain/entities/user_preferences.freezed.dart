// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  @HiveField(0)
  String get language => throw _privateConstructorUsedError;
  @HiveField(1)
  double get latitude => throw _privateConstructorUsedError;
  @HiveField(2)
  double get longitude => throw _privateConstructorUsedError;
  @HiveField(3)
  String get city => throw _privateConstructorUsedError;
  @HiveField(4)
  String get country => throw _privateConstructorUsedError;
  @HiveField(5)
  String get timezone => throw _privateConstructorUsedError;
  @HiveField(6)
  String get calculationMethodId => throw _privateConstructorUsedError;
  @HiveField(7)
  String get madhhab => throw _privateConstructorUsedError;
  @HiveField(8)
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  @HiveField(9)
  List<String> get enabledPrayers => throw _privateConstructorUsedError;
  @HiveField(10)
  String get theme => throw _privateConstructorUsedError;
  @HiveField(11)
  bool get onboardingCompleted => throw _privateConstructorUsedError;
  @HiveField(12)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @HiveField(13)
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @HiveField(14)
  String? get userName => throw _privateConstructorUsedError;
  @HiveField(15)
  Map<String, dynamic>? get customCalculationParams =>
      throw _privateConstructorUsedError;
  @HiveField(16)
  bool? get locationPermissionGranted => throw _privateConstructorUsedError;
  @HiveField(17)
  String? get notificationSound => throw _privateConstructorUsedError;
  @HiveField(18)
  bool? get vibrationEnabled => throw _privateConstructorUsedError;
  @HiveField(19)
  int? get notificationAdvanceMinutes => throw _privateConstructorUsedError;

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
          UserPreferences value, $Res Function(UserPreferences) then) =
      _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call(
      {@HiveField(0) String language,
      @HiveField(1) double latitude,
      @HiveField(2) double longitude,
      @HiveField(3) String city,
      @HiveField(4) String country,
      @HiveField(5) String timezone,
      @HiveField(6) String calculationMethodId,
      @HiveField(7) String madhhab,
      @HiveField(8) bool notificationsEnabled,
      @HiveField(9) List<String> enabledPrayers,
      @HiveField(10) String theme,
      @HiveField(11) bool onboardingCompleted,
      @HiveField(12) DateTime? createdAt,
      @HiveField(13) DateTime? updatedAt,
      @HiveField(14) String? userName,
      @HiveField(15) Map<String, dynamic>? customCalculationParams,
      @HiveField(16) bool? locationPermissionGranted,
      @HiveField(17) String? notificationSound,
      @HiveField(18) bool? vibrationEnabled,
      @HiveField(19) int? notificationAdvanceMinutes});
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? language = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? city = null,
    Object? country = null,
    Object? timezone = null,
    Object? calculationMethodId = null,
    Object? madhhab = null,
    Object? notificationsEnabled = null,
    Object? enabledPrayers = null,
    Object? theme = null,
    Object? onboardingCompleted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? userName = freezed,
    Object? customCalculationParams = freezed,
    Object? locationPermissionGranted = freezed,
    Object? notificationSound = freezed,
    Object? vibrationEnabled = freezed,
    Object? notificationAdvanceMinutes = freezed,
  }) {
    return _then(_value.copyWith(
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      calculationMethodId: null == calculationMethodId
          ? _value.calculationMethodId
          : calculationMethodId // ignore: cast_nullable_to_non_nullable
              as String,
      madhhab: null == madhhab
          ? _value.madhhab
          : madhhab // ignore: cast_nullable_to_non_nullable
              as String,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      enabledPrayers: null == enabledPrayers
          ? _value.enabledPrayers
          : enabledPrayers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      onboardingCompleted: null == onboardingCompleted
          ? _value.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      customCalculationParams: freezed == customCalculationParams
          ? _value.customCalculationParams
          : customCalculationParams // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      locationPermissionGranted: freezed == locationPermissionGranted
          ? _value.locationPermissionGranted
          : locationPermissionGranted // ignore: cast_nullable_to_non_nullable
              as bool?,
      notificationSound: freezed == notificationSound
          ? _value.notificationSound
          : notificationSound // ignore: cast_nullable_to_non_nullable
              as String?,
      vibrationEnabled: freezed == vibrationEnabled
          ? _value.vibrationEnabled
          : vibrationEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      notificationAdvanceMinutes: freezed == notificationAdvanceMinutes
          ? _value.notificationAdvanceMinutes
          : notificationAdvanceMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(_$UserPreferencesImpl value,
          $Res Function(_$UserPreferencesImpl) then) =
      __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String language,
      @HiveField(1) double latitude,
      @HiveField(2) double longitude,
      @HiveField(3) String city,
      @HiveField(4) String country,
      @HiveField(5) String timezone,
      @HiveField(6) String calculationMethodId,
      @HiveField(7) String madhhab,
      @HiveField(8) bool notificationsEnabled,
      @HiveField(9) List<String> enabledPrayers,
      @HiveField(10) String theme,
      @HiveField(11) bool onboardingCompleted,
      @HiveField(12) DateTime? createdAt,
      @HiveField(13) DateTime? updatedAt,
      @HiveField(14) String? userName,
      @HiveField(15) Map<String, dynamic>? customCalculationParams,
      @HiveField(16) bool? locationPermissionGranted,
      @HiveField(17) String? notificationSound,
      @HiveField(18) bool? vibrationEnabled,
      @HiveField(19) int? notificationAdvanceMinutes});
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
      _$UserPreferencesImpl _value, $Res Function(_$UserPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? language = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? city = null,
    Object? country = null,
    Object? timezone = null,
    Object? calculationMethodId = null,
    Object? madhhab = null,
    Object? notificationsEnabled = null,
    Object? enabledPrayers = null,
    Object? theme = null,
    Object? onboardingCompleted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? userName = freezed,
    Object? customCalculationParams = freezed,
    Object? locationPermissionGranted = freezed,
    Object? notificationSound = freezed,
    Object? vibrationEnabled = freezed,
    Object? notificationAdvanceMinutes = freezed,
  }) {
    return _then(_$UserPreferencesImpl(
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      calculationMethodId: null == calculationMethodId
          ? _value.calculationMethodId
          : calculationMethodId // ignore: cast_nullable_to_non_nullable
              as String,
      madhhab: null == madhhab
          ? _value.madhhab
          : madhhab // ignore: cast_nullable_to_non_nullable
              as String,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      enabledPrayers: null == enabledPrayers
          ? _value._enabledPrayers
          : enabledPrayers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      onboardingCompleted: null == onboardingCompleted
          ? _value.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      customCalculationParams: freezed == customCalculationParams
          ? _value._customCalculationParams
          : customCalculationParams // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      locationPermissionGranted: freezed == locationPermissionGranted
          ? _value.locationPermissionGranted
          : locationPermissionGranted // ignore: cast_nullable_to_non_nullable
              as bool?,
      notificationSound: freezed == notificationSound
          ? _value.notificationSound
          : notificationSound // ignore: cast_nullable_to_non_nullable
              as String?,
      vibrationEnabled: freezed == vibrationEnabled
          ? _value.vibrationEnabled
          : vibrationEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      notificationAdvanceMinutes: freezed == notificationAdvanceMinutes
          ? _value.notificationAdvanceMinutes
          : notificationAdvanceMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 1)
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {@HiveField(0) required this.language,
      @HiveField(1) required this.latitude,
      @HiveField(2) required this.longitude,
      @HiveField(3) required this.city,
      @HiveField(4) required this.country,
      @HiveField(5) required this.timezone,
      @HiveField(6) required this.calculationMethodId,
      @HiveField(7) required this.madhhab,
      @HiveField(8) required this.notificationsEnabled,
      @HiveField(9) required final List<String> enabledPrayers,
      @HiveField(10) required this.theme,
      @HiveField(11) required this.onboardingCompleted,
      @HiveField(12) this.createdAt,
      @HiveField(13) this.updatedAt,
      @HiveField(14) this.userName,
      @HiveField(15) final Map<String, dynamic>? customCalculationParams,
      @HiveField(16) this.locationPermissionGranted,
      @HiveField(17) this.notificationSound,
      @HiveField(18) this.vibrationEnabled,
      @HiveField(19) this.notificationAdvanceMinutes})
      : _enabledPrayers = enabledPrayers,
        _customCalculationParams = customCalculationParams;

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  @override
  @HiveField(0)
  final String language;
  @override
  @HiveField(1)
  final double latitude;
  @override
  @HiveField(2)
  final double longitude;
  @override
  @HiveField(3)
  final String city;
  @override
  @HiveField(4)
  final String country;
  @override
  @HiveField(5)
  final String timezone;
  @override
  @HiveField(6)
  final String calculationMethodId;
  @override
  @HiveField(7)
  final String madhhab;
  @override
  @HiveField(8)
  final bool notificationsEnabled;
  final List<String> _enabledPrayers;
  @override
  @HiveField(9)
  List<String> get enabledPrayers {
    if (_enabledPrayers is EqualUnmodifiableListView) return _enabledPrayers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enabledPrayers);
  }

  @override
  @HiveField(10)
  final String theme;
  @override
  @HiveField(11)
  final bool onboardingCompleted;
  @override
  @HiveField(12)
  final DateTime? createdAt;
  @override
  @HiveField(13)
  final DateTime? updatedAt;
  @override
  @HiveField(14)
  final String? userName;
  final Map<String, dynamic>? _customCalculationParams;
  @override
  @HiveField(15)
  Map<String, dynamic>? get customCalculationParams {
    final value = _customCalculationParams;
    if (value == null) return null;
    if (_customCalculationParams is EqualUnmodifiableMapView)
      return _customCalculationParams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @HiveField(16)
  final bool? locationPermissionGranted;
  @override
  @HiveField(17)
  final String? notificationSound;
  @override
  @HiveField(18)
  final bool? vibrationEnabled;
  @override
  @HiveField(19)
  final int? notificationAdvanceMinutes;

  @override
  String toString() {
    return 'UserPreferences(language: $language, latitude: $latitude, longitude: $longitude, city: $city, country: $country, timezone: $timezone, calculationMethodId: $calculationMethodId, madhhab: $madhhab, notificationsEnabled: $notificationsEnabled, enabledPrayers: $enabledPrayers, theme: $theme, onboardingCompleted: $onboardingCompleted, createdAt: $createdAt, updatedAt: $updatedAt, userName: $userName, customCalculationParams: $customCalculationParams, locationPermissionGranted: $locationPermissionGranted, notificationSound: $notificationSound, vibrationEnabled: $vibrationEnabled, notificationAdvanceMinutes: $notificationAdvanceMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.calculationMethodId, calculationMethodId) ||
                other.calculationMethodId == calculationMethodId) &&
            (identical(other.madhhab, madhhab) || other.madhhab == madhhab) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            const DeepCollectionEquality()
                .equals(other._enabledPrayers, _enabledPrayers) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.onboardingCompleted, onboardingCompleted) ||
                other.onboardingCompleted == onboardingCompleted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            const DeepCollectionEquality().equals(
                other._customCalculationParams, _customCalculationParams) &&
            (identical(other.locationPermissionGranted,
                    locationPermissionGranted) ||
                other.locationPermissionGranted == locationPermissionGranted) &&
            (identical(other.notificationSound, notificationSound) ||
                other.notificationSound == notificationSound) &&
            (identical(other.vibrationEnabled, vibrationEnabled) ||
                other.vibrationEnabled == vibrationEnabled) &&
            (identical(other.notificationAdvanceMinutes,
                    notificationAdvanceMinutes) ||
                other.notificationAdvanceMinutes ==
                    notificationAdvanceMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        language,
        latitude,
        longitude,
        city,
        country,
        timezone,
        calculationMethodId,
        madhhab,
        notificationsEnabled,
        const DeepCollectionEquality().hash(_enabledPrayers),
        theme,
        onboardingCompleted,
        createdAt,
        updatedAt,
        userName,
        const DeepCollectionEquality().hash(_customCalculationParams),
        locationPermissionGranted,
        notificationSound,
        vibrationEnabled,
        notificationAdvanceMinutes
      ]);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(
      this,
    );
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences(
          {@HiveField(0) required final String language,
          @HiveField(1) required final double latitude,
          @HiveField(2) required final double longitude,
          @HiveField(3) required final String city,
          @HiveField(4) required final String country,
          @HiveField(5) required final String timezone,
          @HiveField(6) required final String calculationMethodId,
          @HiveField(7) required final String madhhab,
          @HiveField(8) required final bool notificationsEnabled,
          @HiveField(9) required final List<String> enabledPrayers,
          @HiveField(10) required final String theme,
          @HiveField(11) required final bool onboardingCompleted,
          @HiveField(12) final DateTime? createdAt,
          @HiveField(13) final DateTime? updatedAt,
          @HiveField(14) final String? userName,
          @HiveField(15) final Map<String, dynamic>? customCalculationParams,
          @HiveField(16) final bool? locationPermissionGranted,
          @HiveField(17) final String? notificationSound,
          @HiveField(18) final bool? vibrationEnabled,
          @HiveField(19) final int? notificationAdvanceMinutes}) =
      _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  @HiveField(0)
  String get language;
  @override
  @HiveField(1)
  double get latitude;
  @override
  @HiveField(2)
  double get longitude;
  @override
  @HiveField(3)
  String get city;
  @override
  @HiveField(4)
  String get country;
  @override
  @HiveField(5)
  String get timezone;
  @override
  @HiveField(6)
  String get calculationMethodId;
  @override
  @HiveField(7)
  String get madhhab;
  @override
  @HiveField(8)
  bool get notificationsEnabled;
  @override
  @HiveField(9)
  List<String> get enabledPrayers;
  @override
  @HiveField(10)
  String get theme;
  @override
  @HiveField(11)
  bool get onboardingCompleted;
  @override
  @HiveField(12)
  DateTime? get createdAt;
  @override
  @HiveField(13)
  DateTime? get updatedAt;
  @override
  @HiveField(14)
  String? get userName;
  @override
  @HiveField(15)
  Map<String, dynamic>? get customCalculationParams;
  @override
  @HiveField(16)
  bool? get locationPermissionGranted;
  @override
  @HiveField(17)
  String? get notificationSound;
  @override
  @HiveField(18)
  bool? get vibrationEnabled;
  @override
  @HiveField(19)
  int? get notificationAdvanceMinutes;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
