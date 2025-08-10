import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import 'zakat_result.dart';
import 'zakat_form_data.dart';
import 'zakat_recipient.dart';

part 'zakat_calculation.freezed.dart';
part 'zakat_calculation.g.dart';

/// Comprehensive Zakat calculation entity following Islamic principles
/// Represents a complete Zakat assessment for an individual
@freezed
class ZakatCalculation with _$ZakatCalculation {
  const factory ZakatCalculation({
    required String id,
    required DateTime calculationDate,
    required DateTime hawlStartDate, // Islamic lunar year start
    required String userId,
    required String currency,
    required PersonalInfo personalInfo,
    required ZakatableAssets assets,
    required Liabilities liabilities,
    @JsonKey(fromJson: _nisabInfoFromJson, toJson: _nisabInfoToJson)
    NisabInfo? nisabInfo,
    ZakatResult? result,
    String? notes,
    @Default(false) bool isPaid,
    DateTime? paidDate,
    @Default([]) List<ZakatDistribution> distributions,
    Map<String, dynamic>? metadata,
  }) = _ZakatCalculation;

  factory ZakatCalculation.fromJson(Map<String, dynamic> json) =>
      _$ZakatCalculationFromJson(json);
}

// Helper functions for NisabInfo serialization
NisabInfo? _nisabInfoFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return NisabInfo.fromJson(json);
}

Map<String, dynamic>? _nisabInfoToJson(NisabInfo? nisabInfo) {
  return nisabInfo?.toJson();
}

// Helper functions for ZakatResult serialization
ZakatResult _zakatResultFromJson(Map<String, dynamic> json) {
  return ZakatResult.fromJson(json);
}

Map<String, dynamic> _zakatResultToJson(ZakatResult result) {
  return result.toJson();
}

/// Personal information for Zakat calculation
@freezed
class PersonalInfo with _$PersonalInfo {
  const factory PersonalInfo({
    required String name,
    required String email,
    required String country, required String city, String? phone,
    String? address,
    @Default('Hanafi') String madhab, // Islamic school of thought
    @Default('individual') String calculationType, // individual, business, organization
  }) = _PersonalInfo;

  factory PersonalInfo.fromJson(Map<String, dynamic> json) =>
      _$PersonalInfoFromJson(json);
}

/// All Zakatable assets according to Islamic law
@freezed
class ZakatableAssets with _$ZakatableAssets {
  const factory ZakatableAssets({
    @Default(CashAssets()) CashAssets cash,
    @Default(PreciousMetals()) PreciousMetals preciousMetals,
    @Default(BusinessAssets()) BusinessAssets business,
    @Default(InvestmentAssets()) InvestmentAssets investments,
    @Default(RealEstateAssets()) RealEstateAssets realEstate,
    @Default(AgriculturalAssets()) AgriculturalAssets agricultural,
    @Default(LivestockAssets()) LivestockAssets livestock,
    @Default(OtherAssets()) OtherAssets other,
  }) = _ZakatableAssets;

  factory ZakatableAssets.fromJson(Map<String, dynamic> json) =>
      _$ZakatableAssetsFromJson(json);
}

/// Cash and cash equivalents
@freezed
class CashAssets with _$CashAssets {
  const factory CashAssets({
    @Default(0.0) double cashInHand,
    @Default(0.0) double bankSavings,
    @Default(0.0) double bankChecking,
    @Default(0.0) double fixedDeposits,
    @Default(0.0) double foreignCurrency,
    @Default(0.0) double digitalWallets,
    @Default(0.0) double cryptocurrencies, // If considered halal by scholar
    Map<String, double>? currencyBreakdown,
  }) = _CashAssets;

  factory CashAssets.fromJson(Map<String, dynamic> json) =>
      _$CashAssetsFromJson(json);
}

/// Gold, Silver and precious metals
@freezed
class PreciousMetals with _$PreciousMetals {
  const factory PreciousMetals({
    @Default(GoldHoldings()) GoldHoldings gold,
    @Default(SilverHoldings()) SilverHoldings silver,
    @Default(0.0) double otherPreciousMetals,
    @Default(0.0) double preciousStones, // If for investment
  }) = _PreciousMetals;

  factory PreciousMetals.fromJson(Map<String, dynamic> json) =>
      _$PreciousMetalsFromJson(json);
}

/// Detailed gold holdings
@freezed
class GoldHoldings with _$GoldHoldings {
  const factory GoldHoldings({
    @Default(0.0) double weightInGrams,
    @Default(0.0) double currentPricePerGram,
    @Default('24k') String purity,
    @Default(0.0) double jewelry, // Investment jewelry only
    @Default(0.0) double coins,
    @Default(0.0) double bars,
    @Default(0.0) double goldETFs, // Exchange-traded funds
    DateTime? lastPriceUpdate,
  }) = _GoldHoldings;

  factory GoldHoldings.fromJson(Map<String, dynamic> json) =>
      _$GoldHoldingsFromJson(json);
}

/// Detailed silver holdings
@freezed
class SilverHoldings with _$SilverHoldings {
  const factory SilverHoldings({
    @Default(0.0) double weightInGrams,
    @Default(0.0) double currentPricePerGram,
    @Default(0.0) double jewelry, // Investment jewelry only
    @Default(0.0) double coins,
    @Default(0.0) double bars,
    @Default(0.0) double silverETFs,
    DateTime? lastPriceUpdate,
  }) = _SilverHoldings;

  factory SilverHoldings.fromJson(Map<String, dynamic> json) =>
      _$SilverHoldingsFromJson(json);
}

/// Business and trade assets
@freezed
class BusinessAssets with _$BusinessAssets {
  const factory BusinessAssets({
    @Default(0.0) double inventory,
    @Default(0.0) double accountsReceivable,
    @Default(0.0) double rawMaterials,
    @Default(0.0) double finishedGoods,
    @Default(0.0) double workInProgress,
    @Default(0.0) double businessCash,
    @Default(0.0) double tradingStocks,
    String? businessType,
    DateTime? lastInventoryDate,
  }) = _BusinessAssets;

  factory BusinessAssets.fromJson(Map<String, dynamic> json) =>
      _$BusinessAssetsFromJson(json);
}

/// Investment portfolios and securities
@freezed
class InvestmentAssets with _$InvestmentAssets {
  const factory InvestmentAssets({
    @Default(0.0) double stocks,
    @Default(0.0) double bonds, // Halal bonds only
    @Default(0.0) double mutualFunds,
    @Default(0.0) double etfs,
    @Default(0.0) double commodities,
    @Default(0.0) double retirementFunds,
    @Default(0.0) double pensionFunds,
    @Default(0.0) double islamicBonds, // Sukuk
    Map<String, double>? portfolioBreakdown,
  }) = _InvestmentAssets;

  factory InvestmentAssets.fromJson(Map<String, dynamic> json) =>
      _$InvestmentAssetsFromJson(json);
}

/// Real estate investments (not primary residence)
@freezed
class RealEstateAssets with _$RealEstateAssets {
  const factory RealEstateAssets({
    @Default(0.0) double rentalProperties,
    @Default(0.0) double commercialProperties,
    @Default(0.0) double landForInvestment,
    @Default(0.0) double reitShares, // Real Estate Investment Trusts
    @Default(0.0) double annualRentalIncome,
    @Default([]) List<PropertyDetail> properties,
  }) = _RealEstateAssets;

  factory RealEstateAssets.fromJson(Map<String, dynamic> json) =>
      _$RealEstateAssetsFromJson(json);
}

/// Agricultural produce and assets
@freezed
class AgriculturalAssets with _$AgriculturalAssets {
  const factory AgriculturalAssets({
    @Default(0.0) double grains,
    @Default(0.0) double fruits,
    @Default(0.0) double vegetables,
    @Default(0.0) double dates,
    @Default(0.0) double olives,
    @Default(0.0) double farmingEquipment,
    @Default(0.0) double harvestValue,
    String? irrigationType, // Natural or artificial (affects Zakat rate)
  }) = _AgriculturalAssets;

  factory AgriculturalAssets.fromJson(Map<String, dynamic> json) =>
      _$AgriculturalAssetsFromJson(json);
}

/// Livestock according to Islamic categories
@freezed
class LivestockAssets with _$LivestockAssets {
  const factory LivestockAssets({
    @Default(0) int camels,
    @Default(0) int cattle,
    @Default(0) int buffalo,
    @Default(0) int sheep,
    @Default(0) int goats,
    @Default(0.0) double livestockValue,
    @Default(false) bool isGrazing, // Free grazing vs. fed livestock
  }) = _LivestockAssets;

  factory LivestockAssets.fromJson(Map<String, dynamic> json) =>
      _$LivestockAssetsFromJson(json);
}

/// Other miscellaneous assets
@freezed
class OtherAssets with _$OtherAssets {
  const factory OtherAssets({
    @Default(0.0) double loans_given,
    @Default(0.0) double security_deposits,
    @Default(0.0) double insurance_maturity,
    @Default(0.0) double intellectual_property,
    @Default(0.0) double other_investments,
    Map<String, double>? customAssets,
  }) = _OtherAssets;

  factory OtherAssets.fromJson(Map<String, dynamic> json) =>
      _$OtherAssetsFromJson(json);
}

/// Liabilities and debts (deductible from Zakat)
@freezed
class Liabilities with _$Liabilities {
  const factory Liabilities({
    @Default(0.0) double personalLoans,
    @Default(0.0) double creditCardDebt,
    @Default(0.0) double mortgageDebt, // Controversial - some scholars allow
    @Default(0.0) double businessLoans,
    @Default(0.0) double overdrafts,
    @Default(0.0) double accrued_expenses,
    @Default(0.0) double taxes_owed,
    @Default(0.0) double other_debts,
    @Default(false) bool includeMortgage, // User preference based on scholar opinion
  }) = _Liabilities;

  factory Liabilities.fromJson(Map<String, dynamic> json) =>
      _$LiabilitiesFromJson(json);
}

/// Nisab threshold information
class NisabInfo extends Equatable {
  const NisabInfo({
    required this.goldNisabValue,
    required this.silverNisabValue,
    required this.applicableNisab, // Lower of gold/silver
    required this.goldPricePerGram,
    required this.silverPricePerGram,
    required this.priceDate,
    required this.nisabBasis, // 'gold' or 'silver'
  });

  final double goldNisabValue;
  final double silverNisabValue;
  final double applicableNisab;
  final double goldPricePerGram;
  final double silverPricePerGram;
  final DateTime priceDate;
  final String nisabBasis;

  Map<String, dynamic> toJson() {
    return {
      'goldNisabValue': goldNisabValue,
      'silverNisabValue': silverNisabValue,
      'applicableNisab': applicableNisab,
      'goldPricePerGram': goldPricePerGram,
      'silverPricePerGram': silverPricePerGram,
      'priceDate': priceDate.toIso8601String(),
      'nisabBasis': nisabBasis,
    };
  }

  factory NisabInfo.fromJson(Map<String, dynamic> json) {
    return NisabInfo(
      goldNisabValue: json['goldNisabValue'] as double,
      silverNisabValue: json['silverNisabValue'] as double,
      applicableNisab: json['applicableNisab'] as double,
      goldPricePerGram: json['goldPricePerGram'] as double,
      silverPricePerGram: json['silverPricePerGram'] as double,
      priceDate: DateTime.parse(json['priceDate'] as String),
      nisabBasis: json['nisabBasis'] as String,
    );
  }

  @override
  List<Object?> get props => [
        goldNisabValue,
        silverNisabValue,
        applicableNisab,
        goldPricePerGram,
        silverPricePerGram,
        priceDate,
        nisabBasis,
      ];
}

/// Final Zakat calculation result
class ZakatResult extends Equatable {
  const ZakatResult({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.zakatableWealth,
    required this.zakatDue,
    required this.isZakatRequired,
    required this.nisabThreshold,
    required this.excessOverNisab,
    required this.zakatRate,
    required this.categoryBreakdown,
    required this.islamicReferences,
    required this.notes,
  });

  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final double zakatableWealth;
  final double zakatDue;
  final bool isZakatRequired;
  final double nisabThreshold;
  final double excessOverNisab;
  final double zakatRate;
  final Map<String, double> categoryBreakdown;
  final String islamicReferences;
  final List<String> notes;

  @override
  List<Object?> get props => [
        totalAssets,
        totalLiabilities,
        netWorth,
        zakatableWealth,
        zakatDue,
        isZakatRequired,
        nisabThreshold,
        excessOverNisab,
        zakatRate,
        categoryBreakdown,
        islamicReferences,
        notes,
      ];
}

/// Zakat distribution record
class ZakatDistribution extends Equatable {
  const ZakatDistribution({
    required this.category,
    required this.amount,
    required this.recipient,
  });

  final ZakatCategory category;
  final double amount;
  final String recipient;

  @override
  List<Object?> get props => [category, amount, recipient];
}

/// Property details for real estate
@freezed
class PropertyDetail with _$PropertyDetail {
  const factory PropertyDetail({
    required String address,
    required double currentValue,
    required double monthlyRent,
    required PropertyType type,
    DateTime? purchaseDate,
    double? purchasePrice,
  }) = _PropertyDetail;

  factory PropertyDetail.fromJson(Map<String, dynamic> json) =>
      _$PropertyDetailFromJson(json);
}

/// Property types for real estate categorization
enum PropertyType {
  residential,
  commercial,
  industrial,
  agricultural,
  land,
}

/// The eight categories of Zakat recipients mentioned in Quran (9:60)
enum ZakatCategory {
  fuqara,      // The poor
  masakin,     // The needy
  amilin,      // Those employed to collect Zakat
  muallafa,    // Those whose hearts are to be reconciled
  riqab,       // To free captives
  gharimin,    // Those in debt
  fisabilillah,// In the cause of Allah
  ibnsabil,    // The wayfarer
}

/// Extension methods for calculations
extension ZakatCalculationExtension on ZakatCalculation {
  /// Calculate total cash value
  double get totalCashValue {
    final cash = assets.cash;
    return cash.cashInHand +
           cash.bankSavings +
           cash.bankChecking +
           cash.fixedDeposits +
           cash.foreignCurrency +
           cash.digitalWallets +
           cash.cryptocurrencies;
  }

  /// Calculate total precious metals value
  double get totalPreciousMetalsValue {
    final metals = assets.preciousMetals;
    final goldValue = metals.gold.weightInGrams * metals.gold.currentPricePerGram +
                     metals.gold.jewelry + metals.gold.coins + metals.gold.bars + metals.gold.goldETFs;
    final silverValue = metals.silver.weightInGrams * metals.silver.currentPricePerGram +
                       metals.silver.jewelry + metals.silver.coins + metals.silver.bars + metals.silver.silverETFs;
    return goldValue + silverValue + metals.otherPreciousMetals + metals.preciousStones;
  }

  /// Calculate total business value
  double get totalBusinessValue {
    final business = assets.business;
    return business.inventory +
           business.accountsReceivable +
           business.rawMaterials +
           business.finishedGoods +
           business.workInProgress +
           business.businessCash +
           business.tradingStocks;
  }

  /// Calculate total investment value
  double get totalInvestmentValue {
    final investments = assets.investments;
    return investments.stocks +
           investments.bonds +
           investments.mutualFunds +
           investments.etfs +
           investments.commodities +
           investments.retirementFunds +
           investments.pensionFunds +
           investments.islamicBonds;
  }

  /// Check if calculation is valid for current Hijri year
  bool get isValidForCurrentYear {
    final currentHijri = DateTime.now();
    final calculationAge = currentHijri.difference(calculationDate).inDays;
    return calculationAge <= 365; // Valid for one Hijri year
  }

  /// Get formatted result summary
  String get resultSummary {
    if (result?.isZakatRequired == true) {
      return 'Zakat Due: ${result?.zakatDue.toStringAsFixed(2)} $currency\n'
             'Total Wealth: ${result?.zakatableWealth.toStringAsFixed(2)} $currency\n'
             'Nisab Threshold: ${result?.nisabThreshold.toStringAsFixed(2)} $currency';
    } else {
      return 'No Zakat due - wealth below Nisab threshold\n'
             'Current Wealth: ${result?.zakatableWealth.toStringAsFixed(2)} $currency\n'
             'Nisab Threshold: ${result?.nisabThreshold.toStringAsFixed(2)} $currency';
    }
  }
}

/// Validation error for Zakat calculation
class ValidationError extends Equatable {
  const ValidationError({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;

  @override
  List<Object?> get props => [field, message];
}

/// Validation result for Zakat calculation
class ValidationResult extends Equatable {
  const ValidationResult({
    required this.isValid,
    required this.errors,
    this.warnings = const [],
  });

  final bool isValid;
  final List<ValidationError> errors;
  final List<String> warnings;

  @override
  List<Object?> get props => [isValid, errors, warnings];
}