import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/zakat_calculation.dart';
import '../../domain/repositories/zakat_repository.dart';

part 'zakat_calculator_notifier.freezed.dart';
part 'zakat_calculator_notifier.g.dart';

/// State management for Zakat Calculator using Riverpod
/// Handles all calculator states and user interactions

@freezed
class ZakatCalculatorState with _$ZakatCalculatorState {
  const factory ZakatCalculatorState.initial() = _Initial;
  const factory ZakatCalculatorState.loading() = _Loading;
  const factory ZakatCalculatorState.calculated(ZakatResult result) = _Calculated;
  const factory ZakatCalculatorState.saved(ZakatCalculation calculation) = _Saved;
  const factory ZakatCalculatorState.generatingReport() = _GeneratingReport;
  const factory ZakatCalculatorState.reportGenerated(String filePath) = _ReportGenerated;
  const factory ZakatCalculatorState.metalPricesFetched(Map<String, double> prices) = _MetalPricesFetched;
  const factory ZakatCalculatorState.validationPassed() = _ValidationPassed;
  const factory ZakatCalculatorState.validationFailed(List<ValidationError> errors) = _ValidationFailed;
  const factory ZakatCalculatorState.error(Failure failure) = _Error;
}

/// Form data model for Zakat calculation
@freezed
class ZakatFormData with _$ZakatFormData {
  const factory ZakatFormData({
    // Calculation Settings
    required DateTime hawlStartDate, // Personal Information
    @Default('') String name,
    @Default('') String email,
    @Default('') String phone,
    @Default('') String country,
    @Default('') String city,
    @Default('') String address,
    @Default('Hanafi') String madhab,
    @Default('USD') String currency,
    
    // Cash Assets
    @Default(0.0) double cashInHand,
    @Default(0.0) double bankSavings,
    @Default(0.0) double bankChecking,
    @Default(0.0) double fixedDeposits,
    @Default(0.0) double foreignCurrency,
    @Default(0.0) double digitalWallets,
    @Default(0.0) double cryptocurrencies,
    
    // Gold Assets
    @Default(0.0) double goldWeightGrams,
    @Default(0.0) double goldCurrentPrice,
    @Default(0.0) double goldJewelry,
    @Default(0.0) double goldCoins,
    @Default(0.0) double goldBars,
    @Default(0.0) double goldETFs,
    
    // Silver Assets
    @Default(0.0) double silverWeightGrams,
    @Default(0.0) double silverCurrentPrice,
    @Default(0.0) double silverJewelry,
    @Default(0.0) double silverCoins,
    @Default(0.0) double silverBars,
    @Default(0.0) double silverETFs,
    
    // Business Assets
    @Default(0.0) double businessInventory,
    @Default(0.0) double accountsReceivable,
    @Default(0.0) double rawMaterials,
    @Default(0.0) double finishedGoods,
    @Default(0.0) double workInProgress,
    @Default(0.0) double businessCash,
    @Default(0.0) double tradingStocks,
    
    // Investment Assets
    @Default(0.0) double stocks,
    @Default(0.0) double bonds,
    @Default(0.0) double mutualFunds,
    @Default(0.0) double etfs,
    @Default(0.0) double commodities,
    @Default(0.0) double retirementFunds,
    @Default(0.0) double pensionFunds,
    @Default(0.0) double islamicBonds,
    
    // Real Estate Assets
    @Default(0.0) double rentalProperties,
    @Default(0.0) double commercialProperties,
    @Default(0.0) double landForInvestment,
    @Default(0.0) double reitShares,
    @Default(0.0) double annualRentalIncome,
    
    // Agricultural Assets
    @Default(0.0) double grains,
    @Default(0.0) double fruits,
    @Default(0.0) double vegetables,
    @Default(0.0) double dates,
    @Default(0.0) double olives,
    @Default(0.0) double farmingEquipment,
    @Default(0.0) double harvestValue,
    @Default('natural') String irrigationType,
    
    // Livestock Assets
    @Default(0) int camels,
    @Default(0) int cattle,
    @Default(0) int buffalo,
    @Default(0) int sheep,
    @Default(0) int goats,
    @Default(0.0) double livestockValue,
    @Default(true) bool isGrazing,
    
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
    @Default(0.0) double overdrafts,
    @Default(0.0) double accruedExpenses,
    @Default(0.0) double taxesOwed,
    @Default(0.0) double otherDebts,
    @Default(false) bool includeMortgage,
    
    // Metal Prices (fetched from API)
    @Default(0.0) double currentGoldPrice,
    @Default(0.0) double currentSilverPrice,
    DateTime? metalPricesUpdated,
    
    // Notes and Additional Info
    String? notes,
  }) = _ZakatFormData;

  factory ZakatFormData.fromJson(Map<String, dynamic> json) =>
      _$ZakatFormDataFromJson(json);
}

/// Extension methods for ZakatFormData
extension ZakatFormDataExtension on ZakatFormData {
  /// Convert form data to PersonalInfo entity
  PersonalInfo toPersonalInfo() {
    return PersonalInfo(
      name: name,
      email: email,
      phone: phone,
      country: country,
      city: city,
      address: address,
      madhab: madhab,
    );
  }

  /// Convert form data to ZakatableAssets entity
  ZakatableAssets toZakatableAssets() {
    return ZakatableAssets(
      cash: CashAssets(
        cashInHand: cashInHand,
        bankSavings: bankSavings,
        bankChecking: bankChecking,
        fixedDeposits: fixedDeposits,
        foreignCurrency: foreignCurrency,
        digitalWallets: digitalWallets,
        cryptocurrencies: cryptocurrencies,
      ),
      preciousMetals: PreciousMetals(
        gold: GoldHoldings(
          weightInGrams: goldWeightGrams,
          currentPricePerGram: goldCurrentPrice > 0 ? goldCurrentPrice : currentGoldPrice,
          jewelry: goldJewelry,
          coins: goldCoins,
          bars: goldBars,
          goldETFs: goldETFs,
          lastPriceUpdate: metalPricesUpdated,
        ),
        silver: SilverHoldings(
          weightInGrams: silverWeightGrams,
          currentPricePerGram: silverCurrentPrice > 0 ? silverCurrentPrice : currentSilverPrice,
          jewelry: silverJewelry,
          coins: silverCoins,
          bars: silverBars,
          silverETFs: silverETFs,
          lastPriceUpdate: metalPricesUpdated,
        ),
      ),
      business: BusinessAssets(
        inventory: businessInventory,
        accountsReceivable: accountsReceivable,
        rawMaterials: rawMaterials,
        finishedGoods: finishedGoods,
        workInProgress: workInProgress,
        businessCash: businessCash,
        tradingStocks: tradingStocks,
      ),
      investments: InvestmentAssets(
        stocks: stocks,
        bonds: bonds,
        mutualFunds: mutualFunds,
        etfs: etfs,
        commodities: commodities,
        retirementFunds: retirementFunds,
        pensionFunds: pensionFunds,
        islamicBonds: islamicBonds,
      ),
      realEstate: RealEstateAssets(
        rentalProperties: rentalProperties,
        commercialProperties: commercialProperties,
        landForInvestment: landForInvestment,
        reitShares: reitShares,
        annualRentalIncome: annualRentalIncome,
      ),
      agricultural: AgriculturalAssets(
        grains: grains,
        fruits: fruits,
        vegetables: vegetables,
        dates: dates,
        olives: olives,
        farmingEquipment: farmingEquipment,
        harvestValue: harvestValue,
        irrigationType: irrigationType,
      ),
      livestock: LivestockAssets(
        camels: camels,
        cattle: cattle,
        buffalo: buffalo,
        sheep: sheep,
        goats: goats,
        livestockValue: livestockValue,
        isGrazing: isGrazing,
      ),
      other: OtherAssets(
        loans_given: loansGiven,
        security_deposits: securityDeposits,
        insurance_maturity: insuranceMaturity,
        intellectual_property: intellectualProperty,
        other_investments: otherInvestments,
      ),
    );
  }

  /// Convert form data to Liabilities entity
  Liabilities toLiabilities() {
    return Liabilities(
      personalLoans: personalLoans,
      creditCardDebt: creditCardDebt,
      mortgageDebt: mortgageDebt,
      businessLoans: businessLoans,
      overdrafts: overdrafts,
      accrued_expenses: accruedExpenses,
      taxes_owed: taxesOwed,
      other_debts: otherDebts,
      includeMortgage: includeMortgage,
    );
  }

  /// Convert form data to NisabInfo entity
  NisabInfo toNisabInfo() {
    final goldNisabValue = 87.48 * currentGoldPrice;
    final silverNisabValue = 612.36 * currentSilverPrice;
    final applicableNisab = goldNisabValue < silverNisabValue ? goldNisabValue : silverNisabValue;

    return NisabInfo(
      goldNisabValue: goldNisabValue,
      silverNisabValue: silverNisabValue,
      applicableNisab: applicableNisab,
      goldPricePerGram: currentGoldPrice,
      silverPricePerGram: currentSilverPrice,
      priceDate: metalPricesUpdated ?? DateTime.now(),
      nisabBasis: goldNisabValue < silverNisabValue ? 'gold' : 'silver',
    );
  }

  /// Calculate total cash assets
  double get totalCashAssets {
    return cashInHand + bankSavings + bankChecking + fixedDeposits + 
           foreignCurrency + digitalWallets + cryptocurrencies;
  }

  /// Calculate total precious metals value
  double get totalPreciousMetalsValue {
    final goldValue = (goldWeightGrams * currentGoldPrice) + goldJewelry + goldCoins + goldBars + goldETFs;
    final silverValue = (silverWeightGrams * currentSilverPrice) + silverJewelry + silverCoins + silverBars + silverETFs;
    return goldValue + silverValue;
  }

  /// Calculate total business assets
  double get totalBusinessAssets {
    return businessInventory + accountsReceivable + rawMaterials + 
           finishedGoods + workInProgress + businessCash + tradingStocks;
  }

  /// Calculate total investment assets
  double get totalInvestmentAssets {
    return stocks + bonds + mutualFunds + etfs + commodities + 
           retirementFunds + pensionFunds + islamicBonds;
  }

  /// Calculate total real estate assets
  double get totalRealEstateAssets {
    return rentalProperties + commercialProperties + landForInvestment + reitShares;
  }

  /// Calculate total agricultural assets
  double get totalAgriculturalAssets {
    return grains + fruits + vegetables + dates + olives + farmingEquipment + harvestValue;
  }

  /// Calculate total other assets
  double get totalOtherAssets {
    return loansGiven + securityDeposits + insuranceMaturity + 
           intellectualProperty + otherInvestments;
  }

  /// Calculate total liabilities
  double get totalLiabilities {
    var total = personalLoans + creditCardDebt + businessLoans + 
                  overdrafts + accruedExpenses + taxesOwed + otherDebts;
    
    if (includeMortgage) {
      total += mortgageDebt;
    }
    
    return total;
  }

  /// Calculate total assets
  double get totalAssets {
    return totalCashAssets + totalPreciousMetalsValue + totalBusinessAssets + 
           totalInvestmentAssets + totalRealEstateAssets + totalAgriculturalAssets + 
           livestockValue + totalOtherAssets;
  }

  /// Calculate net worth
  double get netWorth {
    return totalAssets - totalLiabilities;
  }

  /// Check if form has any data entered
  bool get hasData {
    return totalAssets > 0 || totalLiabilities > 0;
  }

  /// Validate required fields
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (name.isEmpty) {
      errors.add('Name is required');
    }
    
    if (email.isEmpty) {
      errors.add('Email is required');
    }
    
    if (country.isEmpty) {
      errors.add('Country is required');
    }
    
    if (city.isEmpty) {
      errors.add('City is required');
    }
    
    if (currentGoldPrice <= 0 && goldWeightGrams > 0) {
      errors.add('Gold price is required when gold weight is specified');
    }
    
    if (currentSilverPrice <= 0 && silverWeightGrams > 0) {
      errors.add('Silver price is required when silver weight is specified');
    }
    
    // Validate negative values
    if (totalAssets < 0) {
      errors.add('Total assets cannot be negative');
    }
    
    if (totalLiabilities < 0) {
      errors.add('Total liabilities cannot be negative');
    }
    
    return errors;
  }

  /// Check if form is valid
  bool get isValid {
    return validationErrors.isEmpty;
  }

  /// Get form completion percentage
  double get completionPercentage {
    var completedSections = 0;
    const totalSections = 8;
    
    // Personal info
    if (name.isNotEmpty && email.isNotEmpty && country.isNotEmpty) {
      completedSections++;
    }
    
    // Cash assets
    if (totalCashAssets > 0) {
      completedSections++;
    }
    
    // Precious metals
    if (totalPreciousMetalsValue > 0) {
      completedSections++;
    }
    
    // Business assets
    if (totalBusinessAssets > 0) {
      completedSections++;
    }
    
    // Investments
    if (totalInvestmentAssets > 0) {
      completedSections++;
    }
    
    // Real estate
    if (totalRealEstateAssets > 0) {
      completedSections++;
    }
    
    // Agricultural/Livestock
    if (totalAgriculturalAssets > 0 || livestockValue > 0) {
      completedSections++;
    }
    
    // Liabilities
    if (totalLiabilities >= 0) { // Always count this as completed
      completedSections++;
    }
    
    return completedSections / totalSections;
  }
}