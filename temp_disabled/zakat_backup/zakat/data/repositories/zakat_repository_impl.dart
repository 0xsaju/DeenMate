import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../../core/utils/islamic_utils.dart';
import '../../domain/entities/zakat_calculation.dart' as entities;
import '../../domain/entities/zakat_form_data.dart';
import '../../domain/entities/zakat_recipient.dart';
import '../../domain/repositories/zakat_repository.dart';
import '../../domain/usecases/calculate_zakat_usecase.dart';
import '../datasources/metal_prices_api.dart';
import '../datasources/zakat_local_storage.dart';

/// Implementation of ZakatRepository following Clean Architecture
/// Handles both online and offline Zakat calculations with Islamic principles
class ZakatRepositoryImpl implements ZakatRepository {
  ZakatRepositoryImpl({
    required MetalPricesApi metalPricesApi,
    required ZakatLocalStorage localStorage,
    required PdfGeneratorService pdfGenerator,
    required Connectivity connectivity,
    required Uuid uuid,
  })  : _metalPricesApi = metalPricesApi,
        _localStorage = localStorage,
        _pdfGenerator = pdfGenerator,
        _connectivity = connectivity,
        _uuid = uuid;

  final MetalPricesApi _metalPricesApi;
  final ZakatLocalStorage _localStorage;
  final PdfGeneratorService _pdfGenerator;
  final Connectivity _connectivity;
  final Uuid _uuid;

  @override
  Future<Either<Failure, ZakatResult>> calculateZakat({
    required ZakatableAssets assets,
    required Liabilities liabilities,
    required String currency,
    required DateTime hawlDate,
    String? madhab,
  }) async {
    try {
      // First validate inputs
      final validationResult = await validateCalculationInputs(
        assets: assets,
        liabilities: liabilities,
      );

      return await validationResult.fold(
        Left.new,
        (validation) async {
          if (!validation.isValid) {
            return Left(Failure.validationFailure(
              field: 'general',
              message: validation.errors.first.message,
            ),);
          }

          // Get metal prices
          final metalPricesResult = await getCurrentMetalPrices(currency);
          
          return await metalPricesResult.fold(
            Left.new,
            (prices) async {
              final goldPrice = prices['gold']!;
              final silverPrice = prices['silver']!;

              // Use the calculation use case
              final usecase = CalculateZakatUsecase(this);
              final params = CalculateZakatParams(
                assets: assets,
                liabilities: liabilities,
                currency: currency,
                hawlDate: hawlDate,
                madhab: madhab,
                userId: 'current_user', // This should come from auth service
              );

              return usecase(params);
            },
          );
        },
      );
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to calculate Zakat',
        details: e.toString(),
      ),);
    }
  }

  @override
  Future<Either<Failure, double>> getCurrentGoldPrice(String currency) async {
    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.none) {
        // Try to get cached price
        final cachedPrices = await _localStorage.getCachedMetalPrices(currency);
        if (cachedPrices != null && cachedPrices.containsKey('gold')) {
          return Right(cachedPrices['gold']!);
        }
        
        return const Left(Failure.offlineFailure(
          message: 'No internet connection and no cached gold price available',
        ),);
      }

      // Fetch current price from API
      final goldPrice = await _metalPricesApi.getGoldPrice(currency);
      
      // Cache the price for offline use
      await _localStorage.cacheMetalPrices(
        currency: currency,
        goldPrice: goldPrice,
        silverPrice: 0, // Will be updated when silver price is fetched
      );
      
      return Right(goldPrice);
    } on Failure catch (failure) {
      // Try to get cached price on API failure
      final cachedPrices = await _localStorage.getCachedMetalPrices(currency);
      if (cachedPrices != null && cachedPrices.containsKey('gold')) {
        return Right(cachedPrices['gold']!);
      }
      
      return Left(failure);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get gold price',
        details: e.toString(),
      ),);
    }
  }

  @override
  Future<Either<Failure, double>> getCurrentSilverPrice(String currency) async {
    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.none) {
        // Try to get cached price
        final cachedPrices = await _localStorage.getCachedMetalPrices(currency);
        if (cachedPrices != null && cachedPrices.containsKey('silver')) {
          return Right(cachedPrices['silver']!);
        }
        
        return const Left(Failure.offlineFailure(
          message: 'No internet connection and no cached silver price available',
        ),);
      }

      // Fetch current price from API
      final silverPrice = await _metalPricesApi.getSilverPrice(currency);
      
      // Cache the price for offline use
      await _localStorage.cacheMetalPrices(
        currency: currency,
        goldPrice: 0, // Will be updated when gold price is fetched
        silverPrice: silverPrice,
      );
      
      return Right(silverPrice);
    } on Failure catch (failure) {
      // Try to get cached price on API failure
      final cachedPrices = await _localStorage.getCachedMetalPrices(currency);
      if (cachedPrices != null && cachedPrices.containsKey('silver')) {
        return Right(cachedPrices['silver']!);
      }
      
      return Left(failure);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get silver price',
        details: e.toString(),
      ),);
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getCurrentMetalPrices(String currency) async {
    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.none) {
        // Try to get cached prices
        final cachedPrices = await _localStorage.getCachedMetalPrices(currency);
        if (cachedPrices != null) {
          return Right(cachedPrices);
        }
        
        return const Left(Failure.offlineFailure(
          message: 'No internet connection and no cached prices available',
        ),);
      }

      // Fetch both prices from API
      final prices = await _metalPricesApi.getBothMetalPrices(currency);
      
      // Cache the prices for offline use
      await _localStorage.cacheMetalPrices(
        currency: currency,
        goldPrice: prices['gold']!,
        silverPrice: prices['silver']!,
      );
      
      return Right(prices);
    } on Failure catch (failure) {
      // Try to get cached prices on API failure
      final cachedPrices = await _localStorage.getCachedMetalPrices(currency);
      if (cachedPrices != null) {
        return Right(cachedPrices);
      }
      
      return Left(failure);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get metal prices',
        details: e.toString(),
      ),);
    }
  }

  @override
  Future<Either<Failure, void>> saveCalculation(ZakatCalculation calculation) async {
    try {
      await _localStorage.saveCalculation(calculation);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure.databaseFailure(
        operation: 'save_calculation',
        message: 'Failed to save calculation: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, List<ZakatCalculation>>> getUserCalculations(String userId) async {
    try {
      final calculations = await _localStorage.getUserCalculations(userId);
      return Right(calculations);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure.databaseFailure(
        operation: 'get_user_calculations',
        message: 'Failed to retrieve calculations: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, ZakatCalculation>> getCalculationById(String calculationId) async {
    try {
      final calculation = await _localStorage.getCalculationById(calculationId);
      if (calculation == null) {
        return const Left(Failure.databaseFailure(
          operation: 'get_calculation',
          message: 'Calculation not found',
        ),);
      }
      return Right(calculation);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure.databaseFailure(
        operation: 'get_calculation_by_id',
        message: 'Failed to retrieve calculation: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, void>> updateCalculation(ZakatCalculation calculation) async {
    try {
      await _localStorage.updateCalculation(calculation);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure.databaseFailure(
        operation: 'update_calculation',
        message: 'Failed to update calculation: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, void>> deleteCalculation(String calculationId) async {
    try {
      await _localStorage.deleteCalculation(calculationId);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure.databaseFailure(
        operation: 'delete_calculation',
        message: 'Failed to delete calculation: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, String>> generateZakatReport(ZakatCalculation calculation) async {
    try {
      final filePath = await _pdfGenerator.generateZakatReport(calculation);
      return Right(filePath);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure.pdfGenerationFailure(
        message: 'Failed to generate Zakat report: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, List<ZakatDistributionGuideline>>> getDistributionGuidelines() async {
    try {
      // Return the 8 categories from Quran 9:60
      final guidelines = [
        const ZakatDistributionGuideline(
          category: entities.ZakatCategory.fuqara,
          arabicName: 'الفقراء',
          englishName: 'The Poor (Al-Fuqara)',
          description: 'Those who have no wealth or income to meet their basic needs',
          suggestedPercentage: 0.125, // 12.5%
          examples: ['Homeless individuals', 'Unemployed families', 'Low-income households'],
          quranicReference: 'Quran 9:60',
        ),
        const ZakatDistributionGuideline(
          category: entities.ZakatCategory.masakin,
          arabicName: 'المساكين',
          englishName: 'The Needy (Al-Masakin)',
          description: 'Those who have some wealth but not enough to meet their needs',
          suggestedPercentage: 0.125, // 12.5%
          examples: ['Underemployed workers', 'Small-scale farmers', 'Struggling students'],
          quranicReference: 'Quran 9:60',
        ),
        const ZakatDistributionGuideline(
          category: entities.ZakatCategory.amilin,
          arabicName: 'العاملين عليها',
          englishName: 'Zakat Administrators (Al-Amilin)',
          description: 'Those employed to collect and distribute Zakat',
          suggestedPercentage: 0.125, // 12.5%
          examples: ['Zakat collection agencies', 'Islamic organizations', 'Administrative costs'],
          quranicReference: 'Quran 9:60',
        ),
        const ZakatDistributionGuideline(
          category: entities.ZakatCategory.muallafa,
          arabicName: 'المؤلفة قلوبهم',
          englishName: 'Those Inclined to Islam (Al-Muallafa)',
          description: 'New Muslims or those whose hearts are to be won over to Islam',
          suggestedPercentage: 0.125, // 12.5%
          examples: ['New converts to Islam', 'Those interested in Islam', 'Community outreach'],
          quranicReference: 'Quran 9:60',
        ),
        const ZakatDistributionGuideline(
          category: entities.ZakatCategory.riqab,
          arabicName: 'في الرقاب',
          englishName: 'Freeing Captives (Fi Ar-Riqab)',
          description: 'To free slaves, captives, or those in bondage',
          suggestedPercentage: 0.125, // 12.5%
          examples: ['Human trafficking victims', 'Debt bondage relief', 'Prison reform'],
          quranicReference: 'Quran 9:60',
        ),
        const ZakatDistributionGuideline(
          category: entities.ZakatCategory.gharimin,
          arabicName: 'الغارمين',
          englishName: 'Those in Debt (Al-Gharimin)',
          description: 'Those burdened with debt and unable to pay',
          suggestedPercentage: 0.125, // 12.5%
          examples: ['Medical debt relief', 'Educational loan assistance', 'Emergency debt help'],
          quranicReference: 'Quran 9:60',
        ),
        const ZakatDistributionGuideline(
          category: entities.ZakatCategory.fisabilillah,
          arabicName: 'في سبيل الله',
          arabicName: 'في سبيل الله',
          englishName: 'In the Cause of Allah (Fi Sabilillah)',
          description: 'For the cause of Allah, including Islamic education and dawah',
          suggestedPercentage: 0.125, // 12.5%
          examples: ['Islamic schools', 'Mosques', 'Dawah activities', 'Religious education'],
          quranicReference: 'Quran 9:60',
        ),
        const ZakatDistributionGuideline(
          category: ZakatCategory.ibnsabil,
          arabicName: 'ابن السبيل',
          englishName: 'The Wayfarer (Ibn As-Sabil)',
          description: 'Travelers who are stranded and in need of assistance',
          suggestedPercentage: 0.125, // 12.5%
          examples: ['Stranded travelers', 'Refugees', 'Migrant assistance', 'Emergency travel help'],
          quranicReference: 'Quran 9:60',
        ),
      ];

      return Right(guidelines);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get distribution guidelines',
        details: e.toString(),
      ),);
    }
  }

  @override
  Future<Either<Failure, void>> recordZakatPayment({
    required String calculationId,
    required DateTime paymentDate,
    required List<ZakatDistribution> distributions,
  }) async {
    try {
      // Get the calculation
      final calculationResult = await getCalculationById(calculationId);
      
      return await calculationResult.fold(
        Left.new,
        (calculation) async {
          // Update calculation with payment information
          final updatedCalculation = calculation.copyWith(
            isPaid: true,
            paidDate: paymentDate,
            distributions: distributions,
          );

          await _localStorage.updateCalculation(updatedCalculation);
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(Failure.databaseFailure(
        operation: 'record_payment',
        message: 'Failed to record Zakat payment: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, NisabInfo>> getCurrentNisab(String currency) async {
    try {
      final metalPricesResult = await getCurrentMetalPrices(currency);
      
      return metalPricesResult.fold(
        Left.new,
        (prices) {
          final goldPrice = prices['gold']!;
          final silverPrice = prices['silver']!;
          
          final goldNisabValue = 87.48 * goldPrice; // 7.5 tola of gold
          final silverNisabValue = 612.36 * silverPrice; // 52.5 tola of silver
          final applicableNisab = goldNisabValue < silverNisabValue ? goldNisabValue : silverNisabValue;

          final nisabInfo = NisabInfo(
            goldNisabValue: goldNisabValue,
            silverNisabValue: silverNisabValue,
            applicableNisab: applicableNisab,
            goldPricePerGram: goldPrice,
            silverPricePerGram: silverPrice,
            priceDate: DateTime.now(),
            nisabBasis: goldNisabValue < silverNisabValue ? 'gold' : 'silver',
          );

          return Right(nisabInfo);
        },
      );
    } catch (e) {
      return Left(Failure.nisabCalculationFailure(
        message: 'Failed to calculate Nisab: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, ValidationResult>> validateCalculationInputs({
    required ZakatableAssets assets,
    required Liabilities liabilities,
  }) async {
    try {
      final errors = <ValidationError>[];
      final warnings = <String>[];

      // Validate cash assets
      if (assets.cash.cashInHand < 0) {
        errors.add(const ValidationError(
          field: 'cashInHand',
          message: 'Cash in hand cannot be negative',
        ),);
      }

      // Validate precious metals
      if (assets.preciousMetals.gold.weightInGrams < 0) {
        errors.add(const ValidationError(
          field: 'goldWeight',
          message: 'Gold weight cannot be negative',
        ),);
      }

      if (assets.preciousMetals.gold.currentPricePerGram <= 0 && 
          assets.preciousMetals.gold.weightInGrams > 0) {
        errors.add(const ValidationError(
          field: 'goldPrice',
          message: 'Gold price must be greater than zero when gold weight is specified',
        ),);
      }

      // Validate business assets
      if (assets.business.inventory < 0) {
        errors.add(const ValidationError(
          field: 'inventory',
          message: 'Business inventory cannot be negative',
        ),);
      }

      // Validate liabilities
      if (liabilities.personalLoans < 0) {
        errors.add(const ValidationError(
          field: 'personalLoans',
          message: 'Personal loans cannot be negative',
        ),);
      }

      // Add warnings
      if (assets.preciousMetals.gold.weightInGrams > 1000) {
        warnings.add('Large gold holdings detected. Please verify the weight is in grams.');
      }

      if (liabilities.mortgageDebt > 0 && !liabilities.includeMortgage) {
        warnings.add('Mortgage debt specified but not included in calculation. This is a matter of scholarly difference.');
      }

      final validationResult = ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );

      return Right(validationResult);
    } catch (e) {
      return Left(Failure.validationFailure(
        field: 'general',
        message: 'Validation failed: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, List<ZakatCalculation>>> getZakatHistory({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      if (fromDate != null && toDate != null) {
        final calculations = await _localStorage.getCalculationsInRange(
          userId: userId,
          startDate: fromDate,
          endDate: toDate,
        );
        return Right(calculations);
      } else {
        final calculations = await _localStorage.getUserCalculations(userId);
        return Right(calculations);
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure.databaseFailure(
        operation: 'get_zakat_history',
        message: 'Failed to get Zakat history: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, String>> exportZakatData({
    required String userId,
    required ExportFormat format,
  }) async {
    try {
      switch (format) {
        case ExportFormat.json:
          final jsonData = await _localStorage.exportCalculationsAsJson(userId);
          return Right(jsonData);
        
        case ExportFormat.pdf:
          // This would require a comprehensive PDF generator
          return const Left(Failure.featureNotImplemented(
            feature: 'PDF export',
            message: 'PDF export is not yet implemented',
          ),);
        
        case ExportFormat.excel:
        case ExportFormat.csv:
          return const Left(Failure.featureNotImplemented(
            feature: 'Excel/CSV export',
            message: 'Excel/CSV export is not yet implemented',
          ),);
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(Failure.fileWriteFailure(
        fileName: 'zakat_export',
        message: 'Failed to export Zakat data: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, List<ZakatReminder>>> getZakatReminders(String userId) async {
    try {
      final calculations = await _localStorage.getUserCalculations(userId);
      final reminders = <ZakatReminder>[];

      for (final calculation in calculations) {
        // Check if Hawl is due
        final hawlEndDate = calculation.hawlStartDate.add(const Duration(days: 354));
        final daysUntilHawl = hawlEndDate.difference(DateTime.now()).inDays;

        if (daysUntilHawl <= 30 && daysUntilHawl >= 0) {
          reminders.add(ZakatReminder(
            id: _uuid.v4(),
            userId: userId,
            dueDate: hawlEndDate,
            title: 'Hawl Completion Reminder',
            description: 'Your Islamic year (Hawl) will complete in $daysUntilHawl days.',
            type: ReminderType.hawlDue,
            isActive: true,
          ),);
        }

        // Check for unpaid Zakat
        if (calculation.result.isZakatRequired && !calculation.isPaid) {
          reminders.add(ZakatReminder(
            id: _uuid.v4(),
            userId: userId,
            dueDate: calculation.calculationDate.add(const Duration(days: 30)),
            title: 'Unpaid Zakat Reminder',
            description: 'You have unpaid Zakat of ${calculation.result.zakatDue.toStringAsFixed(2)} ${calculation.currency}',
            type: ReminderType.paymentDue,
            isActive: true,
          ),);
        }
      }

      return Right(reminders);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get Zakat reminders: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, double>> calculateZakatAlFitr({
    required String currency,
    required String location,
  }) async {
    try {
      // This is a simplified implementation
      // In a real app, you'd fetch local rice/wheat prices
      const basePriceUSD = 5.0; // Approximate price for 2.5kg of rice in USD
      
      if (currency == 'USD') {
        return const Right(basePriceUSD);
      }
      
      // Convert to local currency
      final conversionResult = await _metalPricesApi.convertCurrency(
        amount: basePriceUSD,
        fromCurrency: 'USD',
        toCurrency: currency,
      );
      
      return Right(conversionResult);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to calculate Zakat al-Fitr: ${e.toString()}',
      ),);
    }
  }

  @override
  Future<Either<Failure, List<ZakatOrganization>>> getLocalZakatOrganizations(String location) async {
    try {
      // This would typically fetch from a database or API
      // For now, return some sample organizations
      final organizations = [
        const ZakatOrganization(
          id: '1',
          name: 'Local Islamic Center',
          address: '123 Main St, City',
          phone: '+1-234-567-8900',
          email: 'zakat@islamiccenter.org',
          website: 'https://islamiccenter.org',
          acceptedCategories: [
            ZakatCategory.fuqara,
            ZakatCategory.masakin,
            ZakatCategory.fisabilillah,
          ],
          rating: 4.8,
          isVerified: true,
          description: 'Trusted local Islamic center accepting Zakat for various categories',
        ),
      ];

      return Right(organizations);
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get local organizations: ${e.toString()}',
      ),);
    }
  }

  List<ZakatRecipient> _getDefaultRecipients() {
    return [
      const ZakatRecipient(
        id: '1',
        name: 'Poor and Needy (Fuqara)',
        description: 'Those who have no income or whose income is below the nisab threshold',
        category: zakat_entities.ZakatCategory.fuqara,
        percentage: 25.0,
        priority: 1,
      ),
      const ZakatRecipient(
        id: '2',
        name: 'Destitute (Masakin)',
        description: 'Those in extreme poverty with no means of livelihood',
        category: zakat_entities.ZakatCategory.masakin,
        percentage: 25.0,
        priority: 2,
      ),
      // ...existing code for other recipients using zakat_entities.ZakatCategory...
    ];
  }

  List<zakat_entities.ZakatCategory> _getRecommendedCategories() {
    return [
      zakat_entities.ZakatCategory.fuqara,
      zakat_entities.ZakatCategory.masakin,
      zakat_entities.ZakatCategory.fisabilillah,
    ];
  }
}