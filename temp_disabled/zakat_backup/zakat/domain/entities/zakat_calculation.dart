import 'package:equatable/equatable.dart';

/// Comprehensive Zakat calculation entity following Islamic principles
/// Represents a complete Zakat assessment for an individual
class ZakatCalculation extends Equatable {
  final String id;
  final DateTime calculationDate;
  final DateTime hawlStartDate; // Islamic lunar year start
  final String userId;
  final String currency;
  final PersonalInfo personalInfo;
  final ZakatableAssets assets;
  final Liabilities liabilities;
  final NisabInfo? nisabInfo;
  final ZakatResult? result;
  final String? notes;
  final bool isPaid;
  final DateTime? paidDate;
  final List<ZakatDistribution> distributions;
  final Map<String, dynamic>? metadata;

  const ZakatCalculation({
    required this.id,
    required this.calculationDate,
    required this.hawlStartDate,
    required this.userId,
    required this.currency,
    required this.personalInfo,
    required this.assets,
    required this.liabilities,
    this.nisabInfo,
    this.result,
    this.notes,
    this.isPaid = false,
    this.paidDate,
    this.distributions = const [],
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calculationDate': calculationDate.toIso8601String(),
      'hawlStartDate': hawlStartDate.toIso8601String(),
      'userId': userId,
      'currency': currency,
      'personalInfo': personalInfo.toJson(),
      'assets': assets.toJson(),
      'liabilities': liabilities.toJson(),
      'nisabInfo': nisabInfo?.toJson(),
      'result': result?.toJson(),
      'notes': notes,
      'isPaid': isPaid,
      'paidDate': paidDate?.toIso8601String(),
      'distributions': distributions.map((d) => d.toJson()).toList(),
      'metadata': metadata,
    };
  }

  factory ZakatCalculation.fromJson(Map<String, dynamic> json) {
    return ZakatCalculation(
      id: json['id'] as String,
      calculationDate: DateTime.parse(json['calculationDate'] as String),
      hawlStartDate: DateTime.parse(json['hawlStartDate'] as String),
      userId: json['userId'] as String,
      currency: json['currency'] as String,
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] as Map<String, dynamic>),
      assets: ZakatableAssets.fromJson(json['assets'] as Map<String, dynamic>),
      liabilities: Liabilities.fromJson(json['liabilities'] as Map<String, dynamic>),
      nisabInfo: json['nisabInfo'] != null ? NisabInfo.fromJson(json['nisabInfo'] as Map<String, dynamic>) : null,
      result: json['result'] != null ? ZakatResult.fromJson(json['result'] as Map<String, dynamic>) : null,
      notes: json['notes'] as String?,
      isPaid: json['isPaid'] as bool? ?? false,
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate'] as String) : null,
      distributions: (json['distributions'] as List<dynamic>?)
          ?.map((d) => ZakatDistribution.fromJson(d as Map<String, dynamic>))
          .toList() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    calculationDate,
    hawlStartDate,
    userId,
    currency,
    personalInfo,
    assets,
    liabilities,
    nisabInfo,
    result,
    notes,
    isPaid,
    paidDate,
    distributions,
    metadata,
  ];
}



/// Personal information for Zakat calculation
class PersonalInfo extends Equatable {
  final String name;
  final String email;
  final String country;
  final String city;
  final String? phone;
  final String? address;
  final String madhab; // Islamic school of thought
  final String calculationType; // individual, business, organization

  const PersonalInfo({
    required this.name,
    required this.email,
    required this.country,
    required this.city,
    this.phone,
    this.address,
    this.madhab = 'Hanafi',
    this.calculationType = 'individual',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'country': country,
      'city': city,
      'phone': phone,
      'address': address,
      'madhab': madhab,
      'calculationType': calculationType,
    };
  }

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      name: json['name'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      madhab: json['madhab'] as String? ?? 'Hanafi',
      calculationType: json['calculationType'] as String? ?? 'individual',
    );
  }

  @override
  List<Object?> get props => [name, email, country, city, phone, address, madhab, calculationType];
}

/// All Zakatable assets according to Islamic law
class ZakatableAssets extends Equatable {
  final CashAssets cash;
  final PreciousMetals preciousMetals;
  final BusinessAssets business;
  final InvestmentAssets investments;
  final RealEstateAssets realEstate;
  final AgriculturalAssets agricultural;
  final LivestockAssets livestock;
  final OtherAssets other;

  const ZakatableAssets({
    this.cash = const CashAssets(),
    this.preciousMetals = const PreciousMetals(),
    this.business = const BusinessAssets(),
    this.investments = const InvestmentAssets(),
    this.realEstate = const RealEstateAssets(),
    this.agricultural = const AgriculturalAssets(),
    this.livestock = const LivestockAssets(),
    this.other = const OtherAssets(),
  });

  Map<String, dynamic> toJson() {
    return {
      'cash': cash.toJson(),
      'preciousMetals': preciousMetals.toJson(),
      'business': business.toJson(),
      'investments': investments.toJson(),
      'realEstate': realEstate.toJson(),
      'agricultural': agricultural.toJson(),
      'livestock': livestock.toJson(),
      'other': other.toJson(),
    };
  }

  factory ZakatableAssets.fromJson(Map<String, dynamic> json) {
    return ZakatableAssets(
      cash: CashAssets.fromJson(json['cash'] as Map<String, dynamic>),
      preciousMetals: PreciousMetals.fromJson(json['preciousMetals'] as Map<String, dynamic>),
      business: BusinessAssets.fromJson(json['business'] as Map<String, dynamic>),
      investments: InvestmentAssets.fromJson(json['investments'] as Map<String, dynamic>),
      realEstate: RealEstateAssets.fromJson(json['realEstate'] as Map<String, dynamic>),
      agricultural: AgriculturalAssets.fromJson(json['agricultural'] as Map<String, dynamic>),
      livestock: LivestockAssets.fromJson(json['livestock'] as Map<String, dynamic>),
      other: OtherAssets.fromJson(json['other'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [cash, preciousMetals, business, investments, realEstate, agricultural, livestock, other];
}

/// Cash and cash equivalents
class CashAssets extends Equatable {
  final double cashInHand;
  final double bankSavings;
  final double bankChecking;
  final double fixedDeposits;
  final double foreignCurrency;
  final double digitalWallets;
  final double cryptocurrencies; // If considered halal by scholar
  final Map<String, double>? currencyBreakdown;

  const CashAssets({
    this.cashInHand = 0.0,
    this.bankSavings = 0.0,
    this.bankChecking = 0.0,
    this.fixedDeposits = 0.0,
    this.foreignCurrency = 0.0,
    this.digitalWallets = 0.0,
    this.cryptocurrencies = 0.0,
    this.currencyBreakdown,
  });

  Map<String, dynamic> toJson() {
    return {
      'cashInHand': cashInHand,
      'bankSavings': bankSavings,
      'bankChecking': bankChecking,
      'fixedDeposits': fixedDeposits,
      'foreignCurrency': foreignCurrency,
      'digitalWallets': digitalWallets,
      'cryptocurrencies': cryptocurrencies,
      'currencyBreakdown': currencyBreakdown,
    };
  }

  factory CashAssets.fromJson(Map<String, dynamic> json) {
    return CashAssets(
      cashInHand: json['cashInHand'] as double? ?? 0.0,
      bankSavings: json['bankSavings'] as double? ?? 0.0,
      bankChecking: json['bankChecking'] as double? ?? 0.0,
      fixedDeposits: json['fixedDeposits'] as double? ?? 0.0,
      foreignCurrency: json['foreignCurrency'] as double? ?? 0.0,
      digitalWallets: json['digitalWallets'] as double? ?? 0.0,
      cryptocurrencies: json['cryptocurrencies'] as double? ?? 0.0,
      currencyBreakdown: (json['currencyBreakdown'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as double),
      ),
    );
  }

  @override
  List<Object?> get props => [cashInHand, bankSavings, bankChecking, fixedDeposits, foreignCurrency, digitalWallets, cryptocurrencies, currencyBreakdown];
}

/// Gold, Silver and precious metals
class PreciousMetals extends Equatable {
  final GoldHoldings gold;
  final SilverHoldings silver;
  final double otherPreciousMetals;
  final double preciousStones; // If for investment

  const PreciousMetals({
    this.gold = const GoldHoldings(),
    this.silver = const SilverHoldings(),
    this.otherPreciousMetals = 0.0,
    this.preciousStones = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'gold': gold.toJson(),
      'silver': silver.toJson(),
      'otherPreciousMetals': otherPreciousMetals,
      'preciousStones': preciousStones,
    };
  }

  factory PreciousMetals.fromJson(Map<String, dynamic> json) {
    return PreciousMetals(
      gold: GoldHoldings.fromJson(json['gold'] as Map<String, dynamic>),
      silver: SilverHoldings.fromJson(json['silver'] as Map<String, dynamic>),
      otherPreciousMetals: json['otherPreciousMetals'] as double? ?? 0.0,
      preciousStones: json['preciousStones'] as double? ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [gold, silver, otherPreciousMetals, preciousStones];
}

/// Detailed gold holdings
class GoldHoldings extends Equatable {
  final double weightInGrams;
  final double currentPricePerGram;
  final String purity;
  final double jewelry; // Investment jewelry only
  final double coins;
  final double bars;
  final double goldETFs; // Exchange-traded funds
  final DateTime? lastPriceUpdate;

  const GoldHoldings({
    this.weightInGrams = 0.0,
    this.currentPricePerGram = 0.0,
    this.purity = '24k',
    this.jewelry = 0.0,
    this.coins = 0.0,
    this.bars = 0.0,
    this.goldETFs = 0.0,
    this.lastPriceUpdate,
  });

  Map<String, dynamic> toJson() {
    return {
      'weightInGrams': weightInGrams,
      'currentPricePerGram': currentPricePerGram,
      'purity': purity,
      'jewelry': jewelry,
      'coins': coins,
      'bars': bars,
      'goldETFs': goldETFs,
      'lastPriceUpdate': lastPriceUpdate?.toIso8601String(),
    };
  }

  factory GoldHoldings.fromJson(Map<String, dynamic> json) {
    return GoldHoldings(
      weightInGrams: json['weightInGrams'] as double? ?? 0.0,
      currentPricePerGram: json['currentPricePerGram'] as double? ?? 0.0,
      purity: json['purity'] as String? ?? '24k',
      jewelry: json['jewelry'] as double? ?? 0.0,
      coins: json['coins'] as double? ?? 0.0,
      bars: json['bars'] as double? ?? 0.0,
      goldETFs: json['goldETFs'] as double? ?? 0.0,
      lastPriceUpdate: json['lastPriceUpdate'] != null ? DateTime.parse(json['lastPriceUpdate'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [weightInGrams, currentPricePerGram, purity, jewelry, coins, bars, goldETFs, lastPriceUpdate];
}

/// Detailed silver holdings
class SilverHoldings extends Equatable {
  final double weightInGrams;
  final double currentPricePerGram;
  final double jewelry; // Investment jewelry only
  final double coins;
  final double bars;
  final double silverETFs;
  final DateTime? lastPriceUpdate;

  const SilverHoldings({
    this.weightInGrams = 0.0,
    this.currentPricePerGram = 0.0,
    this.jewelry = 0.0,
    this.coins = 0.0,
    this.bars = 0.0,
    this.silverETFs = 0.0,
    this.lastPriceUpdate,
  });

  Map<String, dynamic> toJson() {
    return {
      'weightInGrams': weightInGrams,
      'currentPricePerGram': currentPricePerGram,
      'jewelry': jewelry,
      'coins': coins,
      'bars': bars,
      'silverETFs': silverETFs,
      'lastPriceUpdate': lastPriceUpdate?.toIso8601String(),
    };
  }

  factory SilverHoldings.fromJson(Map<String, dynamic> json) {
    return SilverHoldings(
      weightInGrams: json['weightInGrams'] as double? ?? 0.0,
      currentPricePerGram: json['currentPricePerGram'] as double? ?? 0.0,
      jewelry: json['jewelry'] as double? ?? 0.0,
      coins: json['coins'] as double? ?? 0.0,
      bars: json['bars'] as double? ?? 0.0,
      silverETFs: json['silverETFs'] as double? ?? 0.0,
      lastPriceUpdate: json['lastPriceUpdate'] != null ? DateTime.parse(json['lastPriceUpdate'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [weightInGrams, currentPricePerGram, jewelry, coins, bars, silverETFs, lastPriceUpdate];
}

/// Business and trade assets
class BusinessAssets extends Equatable {
  final double inventory;
  final double accountsReceivable;
  final double rawMaterials;
  final double finishedGoods;
  final double workInProgress;
  final double businessCash;
  final double tradingStocks;
  final String? businessType;
  final DateTime? lastInventoryDate;

  const BusinessAssets({
    this.inventory = 0.0,
    this.accountsReceivable = 0.0,
    this.rawMaterials = 0.0,
    this.finishedGoods = 0.0,
    this.workInProgress = 0.0,
    this.businessCash = 0.0,
    this.tradingStocks = 0.0,
    this.businessType,
    this.lastInventoryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'inventory': inventory,
      'accountsReceivable': accountsReceivable,
      'rawMaterials': rawMaterials,
      'finishedGoods': finishedGoods,
      'workInProgress': workInProgress,
      'businessCash': businessCash,
      'tradingStocks': tradingStocks,
      'businessType': businessType,
      'lastInventoryDate': lastInventoryDate?.toIso8601String(),
    };
  }

  factory BusinessAssets.fromJson(Map<String, dynamic> json) {
    return BusinessAssets(
      inventory: json['inventory'] as double? ?? 0.0,
      accountsReceivable: json['accountsReceivable'] as double? ?? 0.0,
      rawMaterials: json['rawMaterials'] as double? ?? 0.0,
      finishedGoods: json['finishedGoods'] as double? ?? 0.0,
      workInProgress: json['workInProgress'] as double? ?? 0.0,
      businessCash: json['businessCash'] as double? ?? 0.0,
      tradingStocks: json['tradingStocks'] as double? ?? 0.0,
      businessType: json['businessType'] as String?,
      lastInventoryDate: json['lastInventoryDate'] != null ? DateTime.parse(json['lastInventoryDate'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [inventory, accountsReceivable, rawMaterials, finishedGoods, workInProgress, businessCash, tradingStocks, businessType, lastInventoryDate];
}

/// Investment portfolios and securities
class InvestmentAssets extends Equatable {
  final double stocks;
  final double bonds; // Halal bonds only
  final double mutualFunds;
  final double etfs;
  final double commodities;
  final double retirementFunds;
  final double pensionFunds;
  final double islamicBonds; // Sukuk
  final Map<String, double>? portfolioBreakdown;

  const InvestmentAssets({
    this.stocks = 0.0,
    this.bonds = 0.0,
    this.mutualFunds = 0.0,
    this.etfs = 0.0,
    this.commodities = 0.0,
    this.retirementFunds = 0.0,
    this.pensionFunds = 0.0,
    this.islamicBonds = 0.0,
    this.portfolioBreakdown,
  });

  Map<String, dynamic> toJson() {
    return {
      'stocks': stocks,
      'bonds': bonds,
      'mutualFunds': mutualFunds,
      'etfs': etfs,
      'commodities': commodities,
      'retirementFunds': retirementFunds,
      'pensionFunds': pensionFunds,
      'islamicBonds': islamicBonds,
      'portfolioBreakdown': portfolioBreakdown,
    };
  }

  factory InvestmentAssets.fromJson(Map<String, dynamic> json) {
    return InvestmentAssets(
      stocks: json['stocks'] as double? ?? 0.0,
      bonds: json['bonds'] as double? ?? 0.0,
      mutualFunds: json['mutualFunds'] as double? ?? 0.0,
      etfs: json['etfs'] as double? ?? 0.0,
      commodities: json['commodities'] as double? ?? 0.0,
      retirementFunds: json['retirementFunds'] as double? ?? 0.0,
      pensionFunds: json['pensionFunds'] as double? ?? 0.0,
      islamicBonds: json['islamicBonds'] as double? ?? 0.0,
      portfolioBreakdown: (json['portfolioBreakdown'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as double),
      ),
    );
  }

  @override
  List<Object?> get props => [stocks, bonds, mutualFunds, etfs, commodities, retirementFunds, pensionFunds, islamicBonds, portfolioBreakdown];
}

/// Real estate investments (not primary residence)
class RealEstateAssets extends Equatable {
  final double rentalProperties;
  final double commercialProperties;
  final double landForInvestment;
  final double reitShares; // Real Estate Investment Trusts
  final double annualRentalIncome;
  final List<PropertyDetail> properties;

  const RealEstateAssets({
    this.rentalProperties = 0.0,
    this.commercialProperties = 0.0,
    this.landForInvestment = 0.0,
    this.reitShares = 0.0,
    this.annualRentalIncome = 0.0,
    this.properties = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'rentalProperties': rentalProperties,
      'commercialProperties': commercialProperties,
      'landForInvestment': landForInvestment,
      'reitShares': reitShares,
      'annualRentalIncome': annualRentalIncome,
      'properties': properties.map((p) => p.toJson()).toList(),
    };
  }

  factory RealEstateAssets.fromJson(Map<String, dynamic> json) {
    return RealEstateAssets(
      rentalProperties: json['rentalProperties'] as double? ?? 0.0,
      commercialProperties: json['commercialProperties'] as double? ?? 0.0,
      landForInvestment: json['landForInvestment'] as double? ?? 0.0,
      reitShares: json['reitShares'] as double? ?? 0.0,
      annualRentalIncome: json['annualRentalIncome'] as double? ?? 0.0,
      properties: (json['properties'] as List<dynamic>?)
          ?.map((p) => PropertyDetail.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [rentalProperties, commercialProperties, landForInvestment, reitShares, annualRentalIncome, properties];
}

/// Agricultural produce and assets
class AgriculturalAssets extends Equatable {
  final double grains;
  final double fruits;
  final double vegetables;
  final double dates;
  final double olives;
  final double farmingEquipment;
  final double harvestValue;
  final String? irrigationType; // Natural or artificial (affects Zakat rate)

  const AgriculturalAssets({
    this.grains = 0.0,
    this.fruits = 0.0,
    this.vegetables = 0.0,
    this.dates = 0.0,
    this.olives = 0.0,
    this.farmingEquipment = 0.0,
    this.harvestValue = 0.0,
    this.irrigationType,
  });

  Map<String, dynamic> toJson() {
    return {
      'grains': grains,
      'fruits': fruits,
      'vegetables': vegetables,
      'dates': dates,
      'olives': olives,
      'farmingEquipment': farmingEquipment,
      'harvestValue': harvestValue,
      'irrigationType': irrigationType,
    };
  }

  factory AgriculturalAssets.fromJson(Map<String, dynamic> json) {
    return AgriculturalAssets(
      grains: json['grains'] as double? ?? 0.0,
      fruits: json['fruits'] as double? ?? 0.0,
      vegetables: json['vegetables'] as double? ?? 0.0,
      dates: json['dates'] as double? ?? 0.0,
      olives: json['olives'] as double? ?? 0.0,
      farmingEquipment: json['farmingEquipment'] as double? ?? 0.0,
      harvestValue: json['harvestValue'] as double? ?? 0.0,
      irrigationType: json['irrigationType'] as String?,
    );
  }

  @override
  List<Object?> get props => [grains, fruits, vegetables, dates, olives, farmingEquipment, harvestValue, irrigationType];
}

/// Livestock according to Islamic categories
class LivestockAssets extends Equatable {
  final int camels;
  final int cattle;
  final int buffalo;
  final int sheep;
  final int goats;
  final double livestockValue;
  final bool isGrazing; // Free grazing vs. fed livestock

  const LivestockAssets({
    this.camels = 0,
    this.cattle = 0,
    this.buffalo = 0,
    this.sheep = 0,
    this.goats = 0,
    this.livestockValue = 0.0,
    this.isGrazing = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'camels': camels,
      'cattle': cattle,
      'buffalo': buffalo,
      'sheep': sheep,
      'goats': goats,
      'livestockValue': livestockValue,
      'isGrazing': isGrazing,
    };
  }

  factory LivestockAssets.fromJson(Map<String, dynamic> json) {
    return LivestockAssets(
      camels: json['camels'] as int? ?? 0,
      cattle: json['cattle'] as int? ?? 0,
      buffalo: json['buffalo'] as int? ?? 0,
      sheep: json['sheep'] as int? ?? 0,
      goats: json['goats'] as int? ?? 0,
      livestockValue: json['livestockValue'] as double? ?? 0.0,
      isGrazing: json['isGrazing'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [camels, cattle, buffalo, sheep, goats, livestockValue, isGrazing];
}

/// Other miscellaneous assets
class OtherAssets extends Equatable {
  final double loans_given;
  final double security_deposits;
  final double insurance_maturity;
  final double intellectual_property;
  final double other_investments;
  final Map<String, double>? customAssets;

  const OtherAssets({
    this.loans_given = 0.0,
    this.security_deposits = 0.0,
    this.insurance_maturity = 0.0,
    this.intellectual_property = 0.0,
    this.other_investments = 0.0,
    this.customAssets,
  });

  Map<String, dynamic> toJson() {
    return {
      'loans_given': loans_given,
      'security_deposits': security_deposits,
      'insurance_maturity': insurance_maturity,
      'intellectual_property': intellectual_property,
      'other_investments': other_investments,
      'customAssets': customAssets,
    };
  }

  factory OtherAssets.fromJson(Map<String, dynamic> json) {
    return OtherAssets(
      loans_given: json['loans_given'] as double? ?? 0.0,
      security_deposits: json['security_deposits'] as double? ?? 0.0,
      insurance_maturity: json['insurance_maturity'] as double? ?? 0.0,
      intellectual_property: json['intellectual_property'] as double? ?? 0.0,
      other_investments: json['other_investments'] as double? ?? 0.0,
      customAssets: (json['customAssets'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as double),
      ),
    );
  }

  @override
  List<Object?> get props => [loans_given, security_deposits, insurance_maturity, intellectual_property, other_investments, customAssets];
}

/// Liabilities and debts (deductible from Zakat)
class Liabilities extends Equatable {
  final double personalLoans;
  final double creditCardDebt;
  final double mortgageDebt; // Controversial - some scholars allow
  final double businessLoans;
  final double overdrafts;
  final double accrued_expenses;
  final double taxes_owed;
  final double other_debts;
  final bool includeMortgage; // User preference based on scholar opinion

  const Liabilities({
    this.personalLoans = 0.0,
    this.creditCardDebt = 0.0,
    this.mortgageDebt = 0.0,
    this.businessLoans = 0.0,
    this.overdrafts = 0.0,
    this.accrued_expenses = 0.0,
    this.taxes_owed = 0.0,
    this.other_debts = 0.0,
    this.includeMortgage = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'personalLoans': personalLoans,
      'creditCardDebt': creditCardDebt,
      'mortgageDebt': mortgageDebt,
      'businessLoans': businessLoans,
      'overdrafts': overdrafts,
      'accrued_expenses': accrued_expenses,
      'taxes_owed': taxes_owed,
      'other_debts': other_debts,
      'includeMortgage': includeMortgage,
    };
  }

  factory Liabilities.fromJson(Map<String, dynamic> json) {
    return Liabilities(
      personalLoans: json['personalLoans'] as double? ?? 0.0,
      creditCardDebt: json['creditCardDebt'] as double? ?? 0.0,
      mortgageDebt: json['mortgageDebt'] as double? ?? 0.0,
      businessLoans: json['businessLoans'] as double? ?? 0.0,
      overdrafts: json['overdrafts'] as double? ?? 0.0,
      accrued_expenses: json['accrued_expenses'] as double? ?? 0.0,
      taxes_owed: json['taxes_owed'] as double? ?? 0.0,
      other_debts: json['other_debts'] as double? ?? 0.0,
      includeMortgage: json['includeMortgage'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [personalLoans, creditCardDebt, mortgageDebt, businessLoans, overdrafts, accrued_expenses, taxes_owed, other_debts, includeMortgage];
}

/// Nisab threshold information
class NisabInfo extends Equatable {
  final double goldNisabValue;
  final double silverNisabValue;
  final double applicableNisab; // Lower of gold/silver
  final double goldPricePerGram;
  final double silverPricePerGram;
  final DateTime priceDate;
  final String nisabBasis; // 'gold' or 'silver'

  const NisabInfo({
    required this.goldNisabValue,
    required this.silverNisabValue,
    required this.applicableNisab,
    required this.goldPricePerGram,
    required this.silverPricePerGram,
    required this.priceDate,
    required this.nisabBasis,
  });

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
  List<Object?> get props => [goldNisabValue, silverNisabValue, applicableNisab, goldPricePerGram, silverPricePerGram, priceDate, nisabBasis];
}

/// Final Zakat calculation result
class ZakatResult extends Equatable {
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

  Map<String, dynamic> toJson() {
    return {
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
      'netWorth': netWorth,
      'zakatableWealth': zakatableWealth,
      'zakatDue': zakatDue,
      'isZakatRequired': isZakatRequired,
      'nisabThreshold': nisabThreshold,
      'excessOverNisab': excessOverNisab,
      'zakatRate': zakatRate,
      'categoryBreakdown': categoryBreakdown,
      'islamicReferences': islamicReferences,
      'notes': notes,
    };
  }

  factory ZakatResult.fromJson(Map<String, dynamic> json) {
    return ZakatResult(
      totalAssets: json['totalAssets'] as double,
      totalLiabilities: json['totalLiabilities'] as double,
      netWorth: json['netWorth'] as double,
      zakatableWealth: json['zakatableWealth'] as double,
      zakatDue: json['zakatDue'] as double,
      isZakatRequired: json['isZakatRequired'] as bool,
      nisabThreshold: json['nisabThreshold'] as double,
      excessOverNisab: json['excessOverNisab'] as double,
      zakatRate: json['zakatRate'] as double,
      categoryBreakdown: (json['categoryBreakdown'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as double),
      ) ?? {},
      islamicReferences: json['islamicReferences'] as String,
      notes: (json['notes'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  List<Object?> get props => [totalAssets, totalLiabilities, netWorth, zakatableWealth, zakatDue, isZakatRequired, nisabThreshold, excessOverNisab, zakatRate, categoryBreakdown, islamicReferences, notes];
}

/// Zakat distribution record
class ZakatDistribution extends Equatable {
  final ZakatCategory category;
  final double amount;
  final String recipient;

  const ZakatDistribution({
    required this.category,
    required this.amount,
    required this.recipient,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'amount': amount,
      'recipient': recipient,
    };
  }

  factory ZakatDistribution.fromJson(Map<String, dynamic> json) {
    return ZakatDistribution(
      category: ZakatCategory.values.firstWhere((e) => e.name == json['category'] as String),
      amount: json['amount'] as double,
      recipient: json['recipient'] as String,
    );
  }

  @override
  List<Object?> get props => [category, amount, recipient];
}

/// Property details for real estate
class PropertyDetail extends Equatable {
  final String address;
  final double currentValue;
  final double monthlyRent;
  final PropertyType type;
  final DateTime? purchaseDate;
  final double? purchasePrice;

  const PropertyDetail({
    required this.address,
    required this.currentValue,
    required this.monthlyRent,
    required this.type,
    this.purchaseDate,
    this.purchasePrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'currentValue': currentValue,
      'monthlyRent': monthlyRent,
      'type': type.name,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'purchasePrice': purchasePrice,
    };
  }

  factory PropertyDetail.fromJson(Map<String, dynamic> json) {
    return PropertyDetail(
      address: json['address'] as String,
      currentValue: json['currentValue'] as double,
      monthlyRent: json['monthlyRent'] as double,
      type: PropertyType.values.firstWhere((e) => e.name == json['type'] as String),
      purchaseDate: json['purchaseDate'] != null ? DateTime.parse(json['purchaseDate'] as String) : null,
      purchasePrice: json['purchasePrice'] as double?,
    );
  }

  @override
  List<Object?> get props => [address, currentValue, monthlyRent, type, purchaseDate, purchasePrice];
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
  final String field;
  final String message;

  const ValidationError({
    required this.field,
    required this.message,
  });

  @override
  List<Object?> get props => [field, message];
}

/// Validation result for Zakat calculation
class ValidationResult extends Equatable {
  final bool isValid;
  final List<ValidationError> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    this.warnings = const [],
  });

  @override
  List<Object?> get props => [isValid, errors, warnings];
}