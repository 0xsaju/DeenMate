// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zakat_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ZakatResultImpl _$$ZakatResultImplFromJson(Map<String, dynamic> json) =>
    _$ZakatResultImpl(
      totalZakatableAmount: (json['totalZakatableAmount'] as num).toDouble(),
      totalZakat: (json['totalZakat'] as num).toDouble(),
      nisabThreshold: (json['nisabThreshold'] as num).toDouble(),
      isZakatDue: json['isZakatDue'] as bool,
      breakdown: (json['breakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      calculationDate: DateTime.parse(json['calculationDate'] as String),
    );

Map<String, dynamic> _$$ZakatResultImplToJson(_$ZakatResultImpl instance) =>
    <String, dynamic>{
      'totalZakatableAmount': instance.totalZakatableAmount,
      'totalZakat': instance.totalZakat,
      'nisabThreshold': instance.nisabThreshold,
      'isZakatDue': instance.isZakatDue,
      'breakdown': instance.breakdown,
      'calculationDate': instance.calculationDate.toIso8601String(),
    };

_$ZakatCalculationImpl _$$ZakatCalculationImplFromJson(
        Map<String, dynamic> json) =>
    _$ZakatCalculationImpl(
      id: json['id'] as String,
      result: ZakatResult.fromJson(json['result'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ZakatCalculationImplToJson(
        _$ZakatCalculationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'result': instance.result,
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
      'notes': instance.notes,
    };

_$ValidationErrorImpl _$$ValidationErrorImplFromJson(
        Map<String, dynamic> json) =>
    _$ValidationErrorImpl(
      field: json['field'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$ValidationErrorImplToJson(
        _$ValidationErrorImpl instance) =>
    <String, dynamic>{
      'field': instance.field,
      'message': instance.message,
    };

_$ZakatDistributionGuidelineImpl _$$ZakatDistributionGuidelineImplFromJson(
        Map<String, dynamic> json) =>
    _$ZakatDistributionGuidelineImpl(
      category: json['category'] as String,
      description: json['description'] as String,
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$$ZakatDistributionGuidelineImplToJson(
        _$ZakatDistributionGuidelineImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'description': instance.description,
      'percentage': instance.percentage,
    };
