// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zakat_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ZakatResult _$ZakatResultFromJson(Map<String, dynamic> json) {
  return _ZakatResult.fromJson(json);
}

/// @nodoc
mixin _$ZakatResult {
  double get totalZakatableAmount => throw _privateConstructorUsedError;
  double get totalZakat => throw _privateConstructorUsedError;
  double get nisabThreshold => throw _privateConstructorUsedError;
  bool get isZakatDue => throw _privateConstructorUsedError;
  Map<String, double> get breakdown => throw _privateConstructorUsedError;
  DateTime get calculationDate => throw _privateConstructorUsedError;

  /// Serializes this ZakatResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ZakatResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ZakatResultCopyWith<ZakatResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ZakatResultCopyWith<$Res> {
  factory $ZakatResultCopyWith(
          ZakatResult value, $Res Function(ZakatResult) then) =
      _$ZakatResultCopyWithImpl<$Res, ZakatResult>;
  @useResult
  $Res call(
      {double totalZakatableAmount,
      double totalZakat,
      double nisabThreshold,
      bool isZakatDue,
      Map<String, double> breakdown,
      DateTime calculationDate});
}

/// @nodoc
class _$ZakatResultCopyWithImpl<$Res, $Val extends ZakatResult>
    implements $ZakatResultCopyWith<$Res> {
  _$ZakatResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ZakatResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalZakatableAmount = null,
    Object? totalZakat = null,
    Object? nisabThreshold = null,
    Object? isZakatDue = null,
    Object? breakdown = null,
    Object? calculationDate = null,
  }) {
    return _then(_value.copyWith(
      totalZakatableAmount: null == totalZakatableAmount
          ? _value.totalZakatableAmount
          : totalZakatableAmount // ignore: cast_nullable_to_non_nullable
              as double,
      totalZakat: null == totalZakat
          ? _value.totalZakat
          : totalZakat // ignore: cast_nullable_to_non_nullable
              as double,
      nisabThreshold: null == nisabThreshold
          ? _value.nisabThreshold
          : nisabThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      isZakatDue: null == isZakatDue
          ? _value.isZakatDue
          : isZakatDue // ignore: cast_nullable_to_non_nullable
              as bool,
      breakdown: null == breakdown
          ? _value.breakdown
          : breakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      calculationDate: null == calculationDate
          ? _value.calculationDate
          : calculationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ZakatResultImplCopyWith<$Res>
    implements $ZakatResultCopyWith<$Res> {
  factory _$$ZakatResultImplCopyWith(
          _$ZakatResultImpl value, $Res Function(_$ZakatResultImpl) then) =
      __$$ZakatResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double totalZakatableAmount,
      double totalZakat,
      double nisabThreshold,
      bool isZakatDue,
      Map<String, double> breakdown,
      DateTime calculationDate});
}

/// @nodoc
class __$$ZakatResultImplCopyWithImpl<$Res>
    extends _$ZakatResultCopyWithImpl<$Res, _$ZakatResultImpl>
    implements _$$ZakatResultImplCopyWith<$Res> {
  __$$ZakatResultImplCopyWithImpl(
      _$ZakatResultImpl _value, $Res Function(_$ZakatResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ZakatResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalZakatableAmount = null,
    Object? totalZakat = null,
    Object? nisabThreshold = null,
    Object? isZakatDue = null,
    Object? breakdown = null,
    Object? calculationDate = null,
  }) {
    return _then(_$ZakatResultImpl(
      totalZakatableAmount: null == totalZakatableAmount
          ? _value.totalZakatableAmount
          : totalZakatableAmount // ignore: cast_nullable_to_non_nullable
              as double,
      totalZakat: null == totalZakat
          ? _value.totalZakat
          : totalZakat // ignore: cast_nullable_to_non_nullable
              as double,
      nisabThreshold: null == nisabThreshold
          ? _value.nisabThreshold
          : nisabThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      isZakatDue: null == isZakatDue
          ? _value.isZakatDue
          : isZakatDue // ignore: cast_nullable_to_non_nullable
              as bool,
      breakdown: null == breakdown
          ? _value._breakdown
          : breakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      calculationDate: null == calculationDate
          ? _value.calculationDate
          : calculationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ZakatResultImpl implements _ZakatResult {
  const _$ZakatResultImpl(
      {required this.totalZakatableAmount,
      required this.totalZakat,
      required this.nisabThreshold,
      required this.isZakatDue,
      required final Map<String, double> breakdown,
      required this.calculationDate})
      : _breakdown = breakdown;

  factory _$ZakatResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ZakatResultImplFromJson(json);

  @override
  final double totalZakatableAmount;
  @override
  final double totalZakat;
  @override
  final double nisabThreshold;
  @override
  final bool isZakatDue;
  final Map<String, double> _breakdown;
  @override
  Map<String, double> get breakdown {
    if (_breakdown is EqualUnmodifiableMapView) return _breakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_breakdown);
  }

  @override
  final DateTime calculationDate;

  @override
  String toString() {
    return 'ZakatResult(totalZakatableAmount: $totalZakatableAmount, totalZakat: $totalZakat, nisabThreshold: $nisabThreshold, isZakatDue: $isZakatDue, breakdown: $breakdown, calculationDate: $calculationDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ZakatResultImpl &&
            (identical(other.totalZakatableAmount, totalZakatableAmount) ||
                other.totalZakatableAmount == totalZakatableAmount) &&
            (identical(other.totalZakat, totalZakat) ||
                other.totalZakat == totalZakat) &&
            (identical(other.nisabThreshold, nisabThreshold) ||
                other.nisabThreshold == nisabThreshold) &&
            (identical(other.isZakatDue, isZakatDue) ||
                other.isZakatDue == isZakatDue) &&
            const DeepCollectionEquality()
                .equals(other._breakdown, _breakdown) &&
            (identical(other.calculationDate, calculationDate) ||
                other.calculationDate == calculationDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalZakatableAmount,
      totalZakat,
      nisabThreshold,
      isZakatDue,
      const DeepCollectionEquality().hash(_breakdown),
      calculationDate);

  /// Create a copy of ZakatResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ZakatResultImplCopyWith<_$ZakatResultImpl> get copyWith =>
      __$$ZakatResultImplCopyWithImpl<_$ZakatResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ZakatResultImplToJson(
      this,
    );
  }
}

abstract class _ZakatResult implements ZakatResult {
  const factory _ZakatResult(
      {required final double totalZakatableAmount,
      required final double totalZakat,
      required final double nisabThreshold,
      required final bool isZakatDue,
      required final Map<String, double> breakdown,
      required final DateTime calculationDate}) = _$ZakatResultImpl;

  factory _ZakatResult.fromJson(Map<String, dynamic> json) =
      _$ZakatResultImpl.fromJson;

  @override
  double get totalZakatableAmount;
  @override
  double get totalZakat;
  @override
  double get nisabThreshold;
  @override
  bool get isZakatDue;
  @override
  Map<String, double> get breakdown;
  @override
  DateTime get calculationDate;

  /// Create a copy of ZakatResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ZakatResultImplCopyWith<_$ZakatResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ZakatCalculation _$ZakatCalculationFromJson(Map<String, dynamic> json) {
  return _ZakatCalculation.fromJson(json);
}

/// @nodoc
mixin _$ZakatCalculation {
  String get id => throw _privateConstructorUsedError;
  ZakatResult get result => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this ZakatCalculation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ZakatCalculation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ZakatCalculationCopyWith<ZakatCalculation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ZakatCalculationCopyWith<$Res> {
  factory $ZakatCalculationCopyWith(
          ZakatCalculation value, $Res Function(ZakatCalculation) then) =
      _$ZakatCalculationCopyWithImpl<$Res, ZakatCalculation>;
  @useResult
  $Res call(
      {String id,
      ZakatResult result,
      DateTime createdAt,
      String userId,
      String? notes});

  $ZakatResultCopyWith<$Res> get result;
}

/// @nodoc
class _$ZakatCalculationCopyWithImpl<$Res, $Val extends ZakatCalculation>
    implements $ZakatCalculationCopyWith<$Res> {
  _$ZakatCalculationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ZakatCalculation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? result = null,
    Object? createdAt = null,
    Object? userId = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      result: null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ZakatResult,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of ZakatCalculation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ZakatResultCopyWith<$Res> get result {
    return $ZakatResultCopyWith<$Res>(_value.result, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ZakatCalculationImplCopyWith<$Res>
    implements $ZakatCalculationCopyWith<$Res> {
  factory _$$ZakatCalculationImplCopyWith(_$ZakatCalculationImpl value,
          $Res Function(_$ZakatCalculationImpl) then) =
      __$$ZakatCalculationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      ZakatResult result,
      DateTime createdAt,
      String userId,
      String? notes});

  @override
  $ZakatResultCopyWith<$Res> get result;
}

/// @nodoc
class __$$ZakatCalculationImplCopyWithImpl<$Res>
    extends _$ZakatCalculationCopyWithImpl<$Res, _$ZakatCalculationImpl>
    implements _$$ZakatCalculationImplCopyWith<$Res> {
  __$$ZakatCalculationImplCopyWithImpl(_$ZakatCalculationImpl _value,
      $Res Function(_$ZakatCalculationImpl) _then)
      : super(_value, _then);

  /// Create a copy of ZakatCalculation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? result = null,
    Object? createdAt = null,
    Object? userId = null,
    Object? notes = freezed,
  }) {
    return _then(_$ZakatCalculationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      result: null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ZakatResult,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ZakatCalculationImpl implements _ZakatCalculation {
  const _$ZakatCalculationImpl(
      {required this.id,
      required this.result,
      required this.createdAt,
      required this.userId,
      this.notes});

  factory _$ZakatCalculationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ZakatCalculationImplFromJson(json);

  @override
  final String id;
  @override
  final ZakatResult result;
  @override
  final DateTime createdAt;
  @override
  final String userId;
  @override
  final String? notes;

  @override
  String toString() {
    return 'ZakatCalculation(id: $id, result: $result, createdAt: $createdAt, userId: $userId, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ZakatCalculationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, result, createdAt, userId, notes);

  /// Create a copy of ZakatCalculation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ZakatCalculationImplCopyWith<_$ZakatCalculationImpl> get copyWith =>
      __$$ZakatCalculationImplCopyWithImpl<_$ZakatCalculationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ZakatCalculationImplToJson(
      this,
    );
  }
}

abstract class _ZakatCalculation implements ZakatCalculation {
  const factory _ZakatCalculation(
      {required final String id,
      required final ZakatResult result,
      required final DateTime createdAt,
      required final String userId,
      final String? notes}) = _$ZakatCalculationImpl;

  factory _ZakatCalculation.fromJson(Map<String, dynamic> json) =
      _$ZakatCalculationImpl.fromJson;

  @override
  String get id;
  @override
  ZakatResult get result;
  @override
  DateTime get createdAt;
  @override
  String get userId;
  @override
  String? get notes;

  /// Create a copy of ZakatCalculation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ZakatCalculationImplCopyWith<_$ZakatCalculationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ValidationError _$ValidationErrorFromJson(Map<String, dynamic> json) {
  return _ValidationError.fromJson(json);
}

/// @nodoc
mixin _$ValidationError {
  String get field => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this ValidationError to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValidationErrorCopyWith<ValidationError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidationErrorCopyWith<$Res> {
  factory $ValidationErrorCopyWith(
          ValidationError value, $Res Function(ValidationError) then) =
      _$ValidationErrorCopyWithImpl<$Res, ValidationError>;
  @useResult
  $Res call({String field, String message});
}

/// @nodoc
class _$ValidationErrorCopyWithImpl<$Res, $Val extends ValidationError>
    implements $ValidationErrorCopyWith<$Res> {
  _$ValidationErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ValidationErrorImplCopyWith<$Res>
    implements $ValidationErrorCopyWith<$Res> {
  factory _$$ValidationErrorImplCopyWith(_$ValidationErrorImpl value,
          $Res Function(_$ValidationErrorImpl) then) =
      __$$ValidationErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field, String message});
}

/// @nodoc
class __$$ValidationErrorImplCopyWithImpl<$Res>
    extends _$ValidationErrorCopyWithImpl<$Res, _$ValidationErrorImpl>
    implements _$$ValidationErrorImplCopyWith<$Res> {
  __$$ValidationErrorImplCopyWithImpl(
      _$ValidationErrorImpl _value, $Res Function(_$ValidationErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? message = null,
  }) {
    return _then(_$ValidationErrorImpl(
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidationErrorImpl implements _ValidationError {
  const _$ValidationErrorImpl({required this.field, required this.message});

  factory _$ValidationErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValidationErrorImplFromJson(json);

  @override
  final String field;
  @override
  final String message;

  @override
  String toString() {
    return 'ValidationError(field: $field, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationErrorImpl &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, field, message);

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      __$$ValidationErrorImplCopyWithImpl<_$ValidationErrorImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidationErrorImplToJson(
      this,
    );
  }
}

abstract class _ValidationError implements ValidationError {
  const factory _ValidationError(
      {required final String field,
      required final String message}) = _$ValidationErrorImpl;

  factory _ValidationError.fromJson(Map<String, dynamic> json) =
      _$ValidationErrorImpl.fromJson;

  @override
  String get field;
  @override
  String get message;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ZakatDistributionGuideline _$ZakatDistributionGuidelineFromJson(
    Map<String, dynamic> json) {
  return _ZakatDistributionGuideline.fromJson(json);
}

/// @nodoc
mixin _$ZakatDistributionGuideline {
  String get category => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;

  /// Serializes this ZakatDistributionGuideline to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ZakatDistributionGuideline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ZakatDistributionGuidelineCopyWith<ZakatDistributionGuideline>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ZakatDistributionGuidelineCopyWith<$Res> {
  factory $ZakatDistributionGuidelineCopyWith(ZakatDistributionGuideline value,
          $Res Function(ZakatDistributionGuideline) then) =
      _$ZakatDistributionGuidelineCopyWithImpl<$Res,
          ZakatDistributionGuideline>;
  @useResult
  $Res call({String category, String description, double percentage});
}

/// @nodoc
class _$ZakatDistributionGuidelineCopyWithImpl<$Res,
        $Val extends ZakatDistributionGuideline>
    implements $ZakatDistributionGuidelineCopyWith<$Res> {
  _$ZakatDistributionGuidelineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ZakatDistributionGuideline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? description = null,
    Object? percentage = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ZakatDistributionGuidelineImplCopyWith<$Res>
    implements $ZakatDistributionGuidelineCopyWith<$Res> {
  factory _$$ZakatDistributionGuidelineImplCopyWith(
          _$ZakatDistributionGuidelineImpl value,
          $Res Function(_$ZakatDistributionGuidelineImpl) then) =
      __$$ZakatDistributionGuidelineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String category, String description, double percentage});
}

/// @nodoc
class __$$ZakatDistributionGuidelineImplCopyWithImpl<$Res>
    extends _$ZakatDistributionGuidelineCopyWithImpl<$Res,
        _$ZakatDistributionGuidelineImpl>
    implements _$$ZakatDistributionGuidelineImplCopyWith<$Res> {
  __$$ZakatDistributionGuidelineImplCopyWithImpl(
      _$ZakatDistributionGuidelineImpl _value,
      $Res Function(_$ZakatDistributionGuidelineImpl) _then)
      : super(_value, _then);

  /// Create a copy of ZakatDistributionGuideline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? description = null,
    Object? percentage = null,
  }) {
    return _then(_$ZakatDistributionGuidelineImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ZakatDistributionGuidelineImpl implements _ZakatDistributionGuideline {
  const _$ZakatDistributionGuidelineImpl(
      {required this.category,
      required this.description,
      required this.percentage});

  factory _$ZakatDistributionGuidelineImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ZakatDistributionGuidelineImplFromJson(json);

  @override
  final String category;
  @override
  final String description;
  @override
  final double percentage;

  @override
  String toString() {
    return 'ZakatDistributionGuideline(category: $category, description: $description, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ZakatDistributionGuidelineImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, category, description, percentage);

  /// Create a copy of ZakatDistributionGuideline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ZakatDistributionGuidelineImplCopyWith<_$ZakatDistributionGuidelineImpl>
      get copyWith => __$$ZakatDistributionGuidelineImplCopyWithImpl<
          _$ZakatDistributionGuidelineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ZakatDistributionGuidelineImplToJson(
      this,
    );
  }
}

abstract class _ZakatDistributionGuideline
    implements ZakatDistributionGuideline {
  const factory _ZakatDistributionGuideline(
      {required final String category,
      required final String description,
      required final double percentage}) = _$ZakatDistributionGuidelineImpl;

  factory _ZakatDistributionGuideline.fromJson(Map<String, dynamic> json) =
      _$ZakatDistributionGuidelineImpl.fromJson;

  @override
  String get category;
  @override
  String get description;
  @override
  double get percentage;

  /// Create a copy of ZakatDistributionGuideline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ZakatDistributionGuidelineImplCopyWith<_$ZakatDistributionGuidelineImpl>
      get copyWith => throw _privateConstructorUsedError;
}
