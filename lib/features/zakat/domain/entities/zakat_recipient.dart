import 'package:freezed_annotation/freezed_annotation.dart';

part 'zakat_recipient.freezed.dart';
part 'zakat_recipient.g.dart';

/// Zakat recipient entity
@freezed
class ZakatRecipient with _$ZakatRecipient {
  const factory ZakatRecipient({
    required String id,
    required String name,
    required String category,
    required String description,
    required double percentage,
    required bool isRecommended,
    @Default('') String contactInfo,
    @Default('') String address,
    @Default('') String website,
    @Default('') String phone,
    @Default('') String email,
    @Default(false) bool isVerified,
    @Default('') String verificationSource,
    @Default('') String notes,
  }) = _ZakatRecipient;

  factory ZakatRecipient.fromJson(Map<String, dynamic> json) => 
      _$ZakatRecipientFromJson(json);
}

/// Zakat distribution entity
@freezed
class ZakatDistribution with _$ZakatDistribution {
  const factory ZakatDistribution({
    required String recipientId,
    required String recipientName,
    required String category,
    required double amount,
    required double percentage,
    @Default('') String notes,
    @Default('') String receiptNumber,
    required DateTime distributionDate,
  }) = _ZakatDistribution;

  factory ZakatDistribution.fromJson(Map<String, dynamic> json) => 
      _$ZakatDistributionFromJson(json);
}

/// Zakat category enum
enum ZakatCategory {
  fuqara,        // Poor
  masakin,       // Needy
  amil,          // Zakat collectors
  muallaf,       // New Muslims
  riqab,         // Slaves
  gharim,        // Debtors
  fisabilillah,  // In the way of Allah
  ibnsabil,      // Travelers
}

/// Nisab information entity
@freezed
class NisabInfo with _$NisabInfo {
  const factory NisabInfo({
    required double goldNisab,
    required double silverNisab,
    required String currency,
    required DateTime lastUpdated,
    required String source,
    @Default('') String notes,
  }) = _NisabInfo;

  factory NisabInfo.fromJson(Map<String, dynamic> json) => 
      _$NisabInfoFromJson(json);
}

/// Zakatable assets entity
@freezed
class ZakatableAssets with _$ZakatableAssets {
  const factory ZakatableAssets({
    @Default(0.0) double cashAndBank,
    @Default(0.0) double preciousMetals,
    @Default(0.0) double businessAssets,
    @Default(0.0) double investments,
    @Default(0.0) double realEstate,
    @Default(0.0) double agricultural,
    @Default(0.0) double otherAssets,
    @Default(0.0) double totalAssets,
  }) = _ZakatableAssets;

  factory ZakatableAssets.fromJson(Map<String, dynamic> json) => 
      _$ZakatableAssetsFromJson(json);
}

/// Liabilities entity
@freezed
class Liabilities with _$Liabilities {
  const factory Liabilities({
    @Default(0.0) double personalLoans,
    @Default(0.0) double creditCardDebt,
    @Default(0.0) double mortgageDebt,
    @Default(0.0) double businessLoans,
    @Default(0.0) double accruedExpenses,
    @Default(0.0) double taxesOwed,
    @Default(0.0) double otherDebts,
    @Default(0.0) double totalLiabilities,
  }) = _Liabilities;

  factory Liabilities.fromJson(Map<String, dynamic> json) => 
      _$LiabilitiesFromJson(json);
}
