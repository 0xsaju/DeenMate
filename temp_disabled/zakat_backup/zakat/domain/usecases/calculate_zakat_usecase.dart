import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/islamic_utils.dart';
import '../entities/zakat_calculation.dart';
import '../repositories/zakat_repository.dart';

/// Use case for calculating Zakat according to Islamic principles
/// Implements comprehensive Zakat calculation with multiple asset types
class CalculateZakatUsecase {

  const CalculateZakatUsecase(this.repository);
  final ZakatRepository repository;

  /// Main Zakat calculation method
  Future<Either<Failure, ZakatResult>> call(CalculateZakatParams params) async {
    try {
      // 1. Validate inputs
      final validationResult = await repository.validateCalculationInputs(
        assets: params.assets,
        liabilities: params.liabilities,
      );

      return validationResult.fold(
        Left.new,
        (validation) async {
          if (!validation.isValid) {
            return Left(Failure.validationFailure(
              field: 'general',
              message: validation.errors.first.message,
            ),);
          }

          // 2. Get current metal prices
          final metalPricesResult = await repository.getCurrentMetalPrices(params.currency);
          
          return metalPricesResult.fold(
            Left.new,
            (prices) async {
              final goldPrice = prices['gold'] ?? 0.0;
              final silverPrice = prices['silver'] ?? 0.0;

              // 3. Calculate Nisab threshold
              final nisabInfo = _calculateNisab(goldPrice, silverPrice, params.currency);

              // 4. Calculate total assets
              final totalAssets = _calculateTotalAssets(params.assets, goldPrice, silverPrice);

              // 5. Calculate total liabilities
              final totalLiabilities = _calculateTotalLiabilities(params.liabilities);

              // 6. Calculate net worth and zakatable wealth
              final netWorth = totalAssets - totalLiabilities;
              final zakatableWealth = _calculateZakatableWealth(params.assets, params.liabilities, goldPrice, silverPrice);

              // 7. Determine if Zakat is due
              final isZakatRequired = zakatableWealth >= nisabInfo.applicableNisab;

              // 8. Calculate Zakat amount
              final zakatDue = isZakatRequired ? _calculateZakatAmount(zakatableWealth, params.assets) : 0.0;

              // 9. Create detailed breakdown
              final categoryBreakdown = _createCategoryBreakdown(params.assets, goldPrice, silverPrice);

              // 10. Generate Islamic references and notes
              final islamicReferences = _generateIslamicReferences();
              final notes = _generateCalculationNotes(params.assets, isZakatRequired);

              final result = ZakatResult(
                totalAssets: totalAssets,
                totalLiabilities: totalLiabilities,
                netWorth: netWorth,
                zakatableWealth: zakatableWealth,
                zakatDue: zakatDue,
                isZakatRequired: isZakatRequired,
                nisabThreshold: nisabInfo.applicableNisab,
                excessOverNisab: isZakatRequired ? zakatableWealth - nisabInfo.applicableNisab : 0.0,
                zakatRate: _getZakatRate(params.assets),
                categoryBreakdown: categoryBreakdown,
                islamicReferences: islamicReferences,
                notes: notes,
              );

              return Right(result);
            },
          );
        },
      );
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Unexpected error during Zakat calculation',
        details: e.toString(),
      ),);
    }
  }

  /// Calculate Nisab threshold
  NisabInfo _calculateNisab(double goldPrice, double silverPrice, String currency) {
    final goldNisabValue = IslamicUtils.getApplicableNisab(goldPrice, silverPrice);
    final silverNisabValue = 612.36 * silverPrice; // 52.5 tola of silver
    final applicableNisab = goldNisabValue < silverNisabValue ? goldNisabValue : silverNisabValue;

    return NisabInfo(
      goldNisabValue: 87.48 * goldPrice, // 7.5 tola of gold
      silverNisabValue: silverNisabValue,
      applicableNisab: applicableNisab,
      goldPricePerGram: goldPrice,
      silverPricePerGram: silverPrice,
      priceDate: DateTime.now(),
      nisabBasis: goldNisabValue < silverNisabValue ? 'gold' : 'silver',
    );
  }

  /// Calculate total assets value
  double _calculateTotalAssets(ZakatFormData formData) {
    double total = 0.0;
    
    final cash = formData.cashAssets;
    total += cash.cashInHand + cash.bankSavings + cash.bankChecking +
             cash.savingsAccount + cash.currentAccount + cash.otherCash;

    // Calculate precious metals value
    final metals = formData.preciousMetals;
    final goldValue = metals.goldWeight * formData.goldPricePerGram;
    final silverValue = metals.silverWeight * formData.silverPricePerGram;
    total += goldValue + silverValue + metals.otherPreciousMetals + metals.preciousStones;

    final business = formData.businessAssets;
    total += business.inventory + business.accountsReceivable + business.rawMaterials +
             business.finishedGoods + business.equipment + business.otherBusinessAssets;

    final investments = formData.investments;
    total += investments.stocks + investments.bonds + investments.mutualFunds +
             investments.providentFund + investments.retirementAccount + investments.otherInvestments;

    final realEstate = formData.realEstate;
    total += realEstate.rentalProperties + realEstate.commercialProperties +
             realEstate.landForInvestment;

    final agricultural = formData.agricultural;
    total += agricultural.grains + agricultural.fruits + agricultural.vegetables +
             agricultural.livestock;

    final livestock = formData.livestock;
    total += livestock.livestockValue;

    final other = formData.otherAssets;
    total += other.loans_given + other.security_deposits + other.insurance_maturity +
             other.valuable_items;
    
    return total;
  }

  /// Calculate total liabilities
  double _calculateTotalLiabilities(ZakatFormData formData) {
    double total = 0.0;
    
    final liabilities = formData.liabilities;
    total += liabilities.personalLoans + liabilities.creditCardDebt +
             liabilities.businessLoans + liabilities.otherDebts;
             
    // Only include mortgage if it's immediate (within one year)
    if (formData.includeMortgageInDebt) {
      total += liabilities.mortgageDebt;
    }
    
    return total;
  }

  /// Calculate immediate liabilities
  double _calculateImmediateLiabilities(ZakatFormData formData) {
    double immediate = 0.0;
    
    final liabilities = formData.liabilities;
    immediate += liabilities.personalLoans + liabilities.creditCardDebt +
                 liabilities.otherDebts;
                 
    if (formData.businessAssets.inventory > 0) {
      immediate += liabilities.businessLoans;
    }
    
    return immediate;
  }

  /// Calculate special category Zakat
  double _calculateSpecialCategoryZakat(ZakatFormData formData) {
    double totalZakat = 0.0;
    
    // Agricultural produce zakat (varies by irrigation method)
    final agricultural = formData.agricultural;
    final agriculturalTotal = agricultural.grains + agricultural.fruits + agricultural.vegetables;
    if (agriculturalTotal > 0) {
      final agriculturalRate = agricultural.isIrrigated ? 0.05 : 0.10; // 5% if irrigated, 10% if rain-fed
      totalZakat += agriculturalTotal * agriculturalRate;
    }
    
    // Livestock zakat (has its own nisab and rates)
    final livestock = formData.livestock;
    totalZakat += _calculateLivestockZakat(livestock);
    
    // Standard 2.5% for other wealth
    final standardZakatBase = _calculateTotalAssets(formData) - _calculateTotalLiabilities(formData) - agriculturalTotal - livestock.livestockValue;
    totalZakat += standardZakatBase * 0.025;
    
    return totalZakat;
  }

  /// Calculate Zakat on livestock according to Islamic law
  double _calculateLivestockZakat(LivestockAssets livestock) {
    var livestockZakat = 0;

    // Only free-grazing livestock are subject to Zakat
    if (!livestock.isGrazing) {
      return 0;
    }

    // Camels Zakat calculation
    if (livestock.camels >= 5) {
      if (livestock.camels <= 9) {
        livestockZakat += 1; // 1 goat/sheep
      } else if (livestock.camels <= 14) {
        livestockZakat += 2; // 2 goats/sheep
      }
      // ... more complex calculations for higher numbers
    }

    // Cattle Zakat calculation
    if (livestock.cattle >= 30) {
      final groupsOf30 = livestock.cattle ~/ 30;
      final remainder = livestock.cattle % 30;
      livestockZakat += groupsOf30; // 1 calf per 30 cattle
      
      if (remainder >= 40) {
        livestockZakat += 1; // Additional for remainder over 40
      }
    }

    // Sheep/Goats Zakat calculation
    final smallLivestock = livestock.sheep + livestock.goats;
    if (smallLivestock >= 40) {
      if (smallLivestock <= 120) {
        livestockZakat += 1;
      } else if (smallLivestock <= 200) {
        livestockZakat += 2;
      } else if (smallLivestock <= 399) {
        livestockZakat += 3;
      } else {
        livestockZakat += smallLivestock ~/ 100;
      }
    }

    // Convert to monetary value (simplified - normally given as animals)
    return livestockZakat * 100; // Placeholder value
  }

  /// Get appropriate Zakat rate based on asset composition
  double _getZakatRate(ZakatableAssets assets) {
    // Check if agricultural assets dominate
    final agricultural = assets.agricultural;
    final agriculturalTotal = agricultural.grains + agricultural.fruits + 
                             agricultural.vegetables + agricultural.dates + agricultural.olives;
    
    if (agriculturalTotal > 0) {
      return agricultural.irrigationType == 'natural' ? 0.10 : 0.05;
    }

    return 0.025; // Standard 2.5%
  }

  /// Create detailed breakdown by category
  Map<String, double> _createCategoryBreakdown(ZakatableAssets assets, double goldPrice, double silverPrice) {
    final breakdown = <String, double>{};

    // Cash breakdown
    final cash = assets.cash;
    final cashTotal = cash.cashInHand + cash.bankSavings + cash.bankChecking + 
                     cash.fixedDeposits + cash.foreignCurrency + cash.digitalWallets + 
                     cash.cryptocurrencies;
    if (cashTotal > 0) breakdown['Cash & Bank'] = cashTotal;

    // Precious metals breakdown
    final goldValue = (assets.preciousMetals.gold.weightInGrams * goldPrice) + 
                     assets.preciousMetals.gold.jewelry + assets.preciousMetals.gold.coins + 
                     assets.preciousMetals.gold.bars + assets.preciousMetals.gold.goldETFs;
    if (goldValue > 0) breakdown['Gold'] = goldValue;

    final silverValue = (assets.preciousMetals.silver.weightInGrams * silverPrice) + 
                       assets.preciousMetals.silver.jewelry + assets.preciousMetals.silver.coins + 
                       assets.preciousMetals.silver.bars + assets.preciousMetals.silver.silverETFs;
    if (silverValue > 0) breakdown['Silver'] = silverValue;

    // Business assets
    final business = assets.business;
    final businessTotal = business.inventory + business.accountsReceivable + business.rawMaterials + 
                         business.finishedGoods + business.workInProgress + business.businessCash + 
                         business.tradingStocks;
    if (businessTotal > 0) breakdown['Business Assets'] = businessTotal;

    // Investment assets
    final investments = assets.investments;
    final investmentTotal = investments.stocks + investments.bonds + investments.mutualFunds + 
                           investments.etfs + investments.commodities + investments.retirementFunds + 
                           investments.pensionFunds + investments.islamicBonds;
    if (investmentTotal > 0) breakdown['Investments'] = investmentTotal;

    // Real estate
    final realEstate = assets.realEstate;
    final realEstateTotal = realEstate.rentalProperties + realEstate.commercialProperties + 
                           realEstate.landForInvestment + realEstate.reitShares;
    if (realEstateTotal > 0) breakdown['Real Estate'] = realEstateTotal;

    // Agricultural
    final agricultural = assets.agricultural;
    final agriculturalTotal = agricultural.grains + agricultural.fruits + agricultural.vegetables + 
                             agricultural.dates + agricultural.olives + agricultural.farmingEquipment + 
                             agricultural.harvestValue;
    if (agriculturalTotal > 0) breakdown['Agricultural'] = agriculturalTotal;

    // Livestock
    if (assets.livestock.livestockValue > 0) {
      breakdown['Livestock'] = assets.livestock.livestockValue;
    }

    // Other assets
    final other = assets.other;
    final otherTotal = other.loans_given + other.security_deposits + other.insurance_maturity + 
                      other.intellectual_property + other.other_investments;
    if (otherTotal > 0) breakdown['Other Assets'] = otherTotal;

    return breakdown;
  }

  /// Generate Islamic references for the calculation
  String _generateIslamicReferences() {
    return '''
Quranic References:
• "And those in whose wealth there is a recognized right for the needy and deprived" (Quran 70:24-25)
• "Take from their wealth a charity to purify and sanctify them" (Quran 9:103)

Hadith References:
• "There is no Zakat on less than five ounces (of silver)" (Bukhari & Muslim)
• "There is no Zakat on gold less than twenty dinars" (Abu Dawud)

Calculation follows the methodology of classical Islamic jurisprudence with consideration for modern financial instruments.
    ''';
  }

  /// Generate calculation notes
  List<String> _generateCalculationNotes(ZakatableAssets assets, bool isZakatRequired) {
    final notes = <String>[];

    if (isZakatRequired) {
      notes.add('Zakat is obligatory on your wealth as it exceeds the Nisab threshold.');
      notes.add('Pay Zakat as soon as possible after your Hawl (Islamic year) completes.');
    } else {
      notes.add('Your wealth is below the Nisab threshold, so no Zakat is due this year.');
      notes.add('Continue monitoring your wealth and calculate again when it increases.');
    }

    // Asset-specific notes
    if (assets.preciousMetals.gold.weightInGrams > 0 || assets.preciousMetals.silver.weightInGrams > 0) {
      notes.add('Personal jewelry for regular use may be exempt from Zakat according to some scholars.');
    }

    if (assets.business.inventory > 0) {
      notes.add('Business inventory is valued at current market price for Zakat calculation.');
    }

    if (assets.agricultural.grains > 0 || assets.agricultural.fruits > 0) {
      notes.add('Agricultural produce has different Zakat rates: 10% for rain-fed, 5% for irrigated crops.');
    }

    if (assets.livestock.camels > 0 || assets.livestock.cattle > 0 || assets.livestock.sheep > 0) {
      notes.add('Livestock Zakat applies only to free-grazing animals and has specific calculation rules.');
    }

    notes.add('Consult with a qualified Islamic scholar for complex cases or religious guidance.');
    notes.add('This calculation is for guidance purposes. Individual circumstances may require scholarly consultation.');

    return notes;
  }
}

/// Parameters for Zakat calculation
class CalculateZakatParams {

  const CalculateZakatParams({
    required this.assets,
    required this.liabilities,
    required this.currency,
    required this.hawlDate,
    required this.userId, this.madhab,
  });
  final ZakatableAssets assets;
  final Liabilities liabilities;
  final String currency;
  final DateTime hawlDate;
  final String? madhab;
  final String userId;
}