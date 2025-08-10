import 'package:freezed_annotation/freezed_annotation.dart';

part 'zakat_form_data.freezed.dart';
part 'zakat_form_data.g.dart';

/// Form data model for Zakat calculation
@freezed
class ZakatFormData with _$ZakatFormData {
  const factory ZakatFormData({
    // Personal Information
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String country,
    required String currency,
    
    // Cash & Bank Assets
    @Default(0.0) double cashOnHand,
    @Default(0.0) double bankAccounts,
    @Default(0.0) double savingsAccounts,
    @Default(0.0) double fixedDeposits,
    @Default(0.0) double certificatesOfDeposit,
    
    // Precious Metals
    @Default(0.0) double goldWeight,
    @Default(0.0) double silverWeight,
    @Default(0.0) double platinumWeight,
    @Default(0.0) double palladiumWeight,
    
    // Business Assets
    @Default(0.0) double businessInventory,
    @Default(0.0) double accountsReceivable,
    @Default(0.0) double businessEquipment,
    @Default(0.0) double businessVehicles,
    @Default(0.0) double businessRealEstate,
    
    // Investment Assets
    @Default(0.0) double stocks,
    @Default(0.0) double bonds,
    @Default(0.0) double mutualFunds,
    @Default(0.0) double etfs,
    @Default(0.0) double retirementAccounts,
    @Default(0.0) double cryptocurrency,
    
    // Real Estate
    @Default(0.0) double investmentProperties,
    @Default(0.0) double rentalIncome,
    @Default(0.0) double landValue,
    
    // Agricultural Assets
    @Default(0.0) double agriculturalProduce,
    @Default(0.0) double livestock,
    @Default(0.0) double farmingEquipment,
    
    // Other Assets
    @Default(0.0) double loansGiven,
    @Default(0.0) double securityDeposits,
    @Default(0.0) double insuranceMaturity,
    @Default(0.0) double intellectualProperty,
    @Default(0.0) double otherInvestments,
    
    // Liabilities
    @Default(0.0) double personalLoans,
    @Default(0.0) double creditCardDebt,
    @Default(0.0) double mortgageDebt,
    @Default(0.0) double businessLoans,
    @Default(0.0) double accruedExpenses,
    @Default(0.0) double taxesOwed,
    @Default(0.0) double otherDebts,
    
    // Calculation Settings
    @Default('ISNA') String calculationMethod,
    @Default('Hanafi') String madhhab,
    @Default(1) int hawls,
    @Default(true) bool includeAgricultural,
    @Default(true) bool includeLivestock,
    
    // Metadata
    required DateTime calculationDate,
    @Default('') String notes,
  }) = _ZakatFormData;

  factory ZakatFormData.fromJson(Map<String, dynamic> json) => 
      _$ZakatFormDataFromJson(json);
}
