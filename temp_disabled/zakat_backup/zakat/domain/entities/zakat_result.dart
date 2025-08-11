import 'package:freezed_annotation/freezed_annotation.dart';

part 'zakat_result.freezed.dart';
part 'zakat_result.g.dart';

/// Zakat calculation result entity
@freezed
class ZakatResult with _$ZakatResult {
  const factory ZakatResult({
    required double totalZakatableWealth,
    required double zakatAmount,
    required double nisabValue,
    required bool isZakatable,
    required String currency,
    required DateTime calculationDate,
    required double goldNisab,
    required double silverNisab,
    required double goldPricePerGram,
    required double silverPricePerGram,
    @Default('') String notes,
    @Default({}) Map<String, double> breakdown,
    @Default([]) List<String> warnings,
    @Default([]) List<String> recommendations,
  }) = _ZakatResult;

  factory ZakatResult.fromJson(Map<String, dynamic> json) => 
      _$ZakatResultFromJson(json);
}

/// Zakat breakdown by category
@freezed
class ZakatBreakdown with _$ZakatBreakdown {
  const factory ZakatBreakdown({
    required String category,
    required double amount,
    required double zakatAmount,
    required double percentage,
    @Default('') String description,
  }) = _ZakatBreakdown;

  factory ZakatBreakdown.fromJson(Map<String, dynamic> json) => 
      _$ZakatBreakdownFromJson(json);
}

/// Zakat calculation summary
@freezed
class ZakatSummary with _$ZakatSummary {
  const factory ZakatSummary({
    required double totalAssets,
    required double totalLiabilities,
    required double netWealth,
    required double zakatAmount,
    required double nisabValue,
    required bool isZakatable,
    required String currency,
    required DateTime calculationDate,
    @Default('') String madhab,
    @Default('') String calculationMethod,
    @Default([]) List<ZakatBreakdown> breakdown,
    @Default([]) List<String> warnings,
    @Default([]) List<String> recommendations,
  }) = _ZakatSummary;

  factory ZakatSummary.fromJson(Map<String, dynamic> json) => 
      _$ZakatSummaryFromJson(json);
}
