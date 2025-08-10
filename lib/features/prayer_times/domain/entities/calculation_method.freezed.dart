// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calculation_method.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CalculationMethod _$CalculationMethodFromJson(Map<String, dynamic> json) {
  return _CalculationMethod.fromJson(json);
}

/// @nodoc
mixin _$CalculationMethod {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get fajrAngle => throw _privateConstructorUsedError;
  double get ishaAngle => throw _privateConstructorUsedError;
  String? get ishaInterval =>
      throw _privateConstructorUsedError; // For methods that use interval instead of angle
  String? get organization => throw _privateConstructorUsedError;
  String? get region => throw _privateConstructorUsedError;
  List<String> get supportedRegions => throw _privateConstructorUsedError;
  bool get isCustom => throw _privateConstructorUsedError;
  Map<String, dynamic> get additionalParams =>
      throw _privateConstructorUsedError;
  String get madhab =>
      throw _privateConstructorUsedError; // Hanafi, Shafi, Maliki, Hanbali
  String get highLatitudeMethod => throw _privateConstructorUsedError;

  /// Serializes this CalculationMethod to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalculationMethod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalculationMethodCopyWith<CalculationMethod> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalculationMethodCopyWith<$Res> {
  factory $CalculationMethodCopyWith(
          CalculationMethod value, $Res Function(CalculationMethod) then) =
      _$CalculationMethodCopyWithImpl<$Res, CalculationMethod>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      double fajrAngle,
      double ishaAngle,
      String? ishaInterval,
      String? organization,
      String? region,
      List<String> supportedRegions,
      bool isCustom,
      Map<String, dynamic> additionalParams,
      String madhab,
      String highLatitudeMethod});
}

/// @nodoc
class _$CalculationMethodCopyWithImpl<$Res, $Val extends CalculationMethod>
    implements $CalculationMethodCopyWith<$Res> {
  _$CalculationMethodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalculationMethod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? fajrAngle = null,
    Object? ishaAngle = null,
    Object? ishaInterval = freezed,
    Object? organization = freezed,
    Object? region = freezed,
    Object? supportedRegions = null,
    Object? isCustom = null,
    Object? additionalParams = null,
    Object? madhab = null,
    Object? highLatitudeMethod = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      fajrAngle: null == fajrAngle
          ? _value.fajrAngle
          : fajrAngle // ignore: cast_nullable_to_non_nullable
              as double,
      ishaAngle: null == ishaAngle
          ? _value.ishaAngle
          : ishaAngle // ignore: cast_nullable_to_non_nullable
              as double,
      ishaInterval: freezed == ishaInterval
          ? _value.ishaInterval
          : ishaInterval // ignore: cast_nullable_to_non_nullable
              as String?,
      organization: freezed == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      supportedRegions: null == supportedRegions
          ? _value.supportedRegions
          : supportedRegions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      additionalParams: null == additionalParams
          ? _value.additionalParams
          : additionalParams // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      madhab: null == madhab
          ? _value.madhab
          : madhab // ignore: cast_nullable_to_non_nullable
              as String,
      highLatitudeMethod: null == highLatitudeMethod
          ? _value.highLatitudeMethod
          : highLatitudeMethod // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalculationMethodImplCopyWith<$Res>
    implements $CalculationMethodCopyWith<$Res> {
  factory _$$CalculationMethodImplCopyWith(_$CalculationMethodImpl value,
          $Res Function(_$CalculationMethodImpl) then) =
      __$$CalculationMethodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      double fajrAngle,
      double ishaAngle,
      String? ishaInterval,
      String? organization,
      String? region,
      List<String> supportedRegions,
      bool isCustom,
      Map<String, dynamic> additionalParams,
      String madhab,
      String highLatitudeMethod});
}

/// @nodoc
class __$$CalculationMethodImplCopyWithImpl<$Res>
    extends _$CalculationMethodCopyWithImpl<$Res, _$CalculationMethodImpl>
    implements _$$CalculationMethodImplCopyWith<$Res> {
  __$$CalculationMethodImplCopyWithImpl(_$CalculationMethodImpl _value,
      $Res Function(_$CalculationMethodImpl) _then)
      : super(_value, _then);

  /// Create a copy of CalculationMethod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? fajrAngle = null,
    Object? ishaAngle = null,
    Object? ishaInterval = freezed,
    Object? organization = freezed,
    Object? region = freezed,
    Object? supportedRegions = null,
    Object? isCustom = null,
    Object? additionalParams = null,
    Object? madhab = null,
    Object? highLatitudeMethod = null,
  }) {
    return _then(_$CalculationMethodImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      fajrAngle: null == fajrAngle
          ? _value.fajrAngle
          : fajrAngle // ignore: cast_nullable_to_non_nullable
              as double,
      ishaAngle: null == ishaAngle
          ? _value.ishaAngle
          : ishaAngle // ignore: cast_nullable_to_non_nullable
              as double,
      ishaInterval: freezed == ishaInterval
          ? _value.ishaInterval
          : ishaInterval // ignore: cast_nullable_to_non_nullable
              as String?,
      organization: freezed == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      supportedRegions: null == supportedRegions
          ? _value._supportedRegions
          : supportedRegions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      additionalParams: null == additionalParams
          ? _value._additionalParams
          : additionalParams // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      madhab: null == madhab
          ? _value.madhab
          : madhab // ignore: cast_nullable_to_non_nullable
              as String,
      highLatitudeMethod: null == highLatitudeMethod
          ? _value.highLatitudeMethod
          : highLatitudeMethod // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalculationMethodImpl implements _CalculationMethod {
  const _$CalculationMethodImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.fajrAngle,
      required this.ishaAngle,
      this.ishaInterval,
      this.organization,
      this.region,
      final List<String> supportedRegions = const [],
      this.isCustom = false,
      final Map<String, dynamic> additionalParams = const {},
      this.madhab = 'Standard',
      this.highLatitudeMethod = 'AngleBased'})
      : _supportedRegions = supportedRegions,
        _additionalParams = additionalParams;

  factory _$CalculationMethodImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalculationMethodImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double fajrAngle;
  @override
  final double ishaAngle;
  @override
  final String? ishaInterval;
// For methods that use interval instead of angle
  @override
  final String? organization;
  @override
  final String? region;
  final List<String> _supportedRegions;
  @override
  @JsonKey()
  List<String> get supportedRegions {
    if (_supportedRegions is EqualUnmodifiableListView)
      return _supportedRegions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_supportedRegions);
  }

  @override
  @JsonKey()
  final bool isCustom;
  final Map<String, dynamic> _additionalParams;
  @override
  @JsonKey()
  Map<String, dynamic> get additionalParams {
    if (_additionalParams is EqualUnmodifiableMapView) return _additionalParams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_additionalParams);
  }

  @override
  @JsonKey()
  final String madhab;
// Hanafi, Shafi, Maliki, Hanbali
  @override
  @JsonKey()
  final String highLatitudeMethod;

  @override
  String toString() {
    return 'CalculationMethod(id: $id, name: $name, description: $description, fajrAngle: $fajrAngle, ishaAngle: $ishaAngle, ishaInterval: $ishaInterval, organization: $organization, region: $region, supportedRegions: $supportedRegions, isCustom: $isCustom, additionalParams: $additionalParams, madhab: $madhab, highLatitudeMethod: $highLatitudeMethod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalculationMethodImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.fajrAngle, fajrAngle) ||
                other.fajrAngle == fajrAngle) &&
            (identical(other.ishaAngle, ishaAngle) ||
                other.ishaAngle == ishaAngle) &&
            (identical(other.ishaInterval, ishaInterval) ||
                other.ishaInterval == ishaInterval) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.region, region) || other.region == region) &&
            const DeepCollectionEquality()
                .equals(other._supportedRegions, _supportedRegions) &&
            (identical(other.isCustom, isCustom) ||
                other.isCustom == isCustom) &&
            const DeepCollectionEquality()
                .equals(other._additionalParams, _additionalParams) &&
            (identical(other.madhab, madhab) || other.madhab == madhab) &&
            (identical(other.highLatitudeMethod, highLatitudeMethod) ||
                other.highLatitudeMethod == highLatitudeMethod));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      fajrAngle,
      ishaAngle,
      ishaInterval,
      organization,
      region,
      const DeepCollectionEquality().hash(_supportedRegions),
      isCustom,
      const DeepCollectionEquality().hash(_additionalParams),
      madhab,
      highLatitudeMethod);

  /// Create a copy of CalculationMethod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalculationMethodImplCopyWith<_$CalculationMethodImpl> get copyWith =>
      __$$CalculationMethodImplCopyWithImpl<_$CalculationMethodImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalculationMethodImplToJson(
      this,
    );
  }
}

abstract class _CalculationMethod implements CalculationMethod {
  const factory _CalculationMethod(
      {required final String id,
      required final String name,
      required final String description,
      required final double fajrAngle,
      required final double ishaAngle,
      final String? ishaInterval,
      final String? organization,
      final String? region,
      final List<String> supportedRegions,
      final bool isCustom,
      final Map<String, dynamic> additionalParams,
      final String madhab,
      final String highLatitudeMethod}) = _$CalculationMethodImpl;

  factory _CalculationMethod.fromJson(Map<String, dynamic> json) =
      _$CalculationMethodImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  double get fajrAngle;
  @override
  double get ishaAngle;
  @override
  String? get ishaInterval; // For methods that use interval instead of angle
  @override
  String? get organization;
  @override
  String? get region;
  @override
  List<String> get supportedRegions;
  @override
  bool get isCustom;
  @override
  Map<String, dynamic> get additionalParams;
  @override
  String get madhab; // Hanafi, Shafi, Maliki, Hanbali
  @override
  String get highLatitudeMethod;

  /// Create a copy of CalculationMethod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalculationMethodImplCopyWith<_$CalculationMethodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
