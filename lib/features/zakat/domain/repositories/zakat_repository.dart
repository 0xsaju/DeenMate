import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/zakat_calculation.dart';

/// Abstract repository interface for Zakat calculations
/// Follows Clean Architecture principles with Islamic business rules
abstract class ZakatRepository {
  /// Calculate Zakat based on provided assets and liabilities
  Future<Either<Failure, ZakatResult>> calculateZakat({
    required ZakatableAssets assets,
    required Liabilities liabilities,
    required String currency,
    required DateTime hawlDate,
    String? madhab,
  });

  /// Get current gold price per gram in specified currency
  Future<Either<Failure, double>> getCurrentGoldPrice(String currency);

  /// Get current silver price per gram in specified currency
  Future<Either<Failure, double>> getCurrentSilverPrice(String currency);

  /// Get both gold and silver prices
  Future<Either<Failure, Map<String, double>>> getCurrentMetalPrices(String currency);

  /// Save Zakat calculation to local storage
  Future<Either<Failure, void>> saveCalculation(ZakatCalculation calculation);

  /// Get saved Zakat calculations for a user
  Future<Either<Failure, List<ZakatCalculation>>> getUserCalculations(String userId);

  /// Get specific calculation by ID
  Future<Either<Failure, ZakatCalculation>> getCalculationById(String calculationId);

  /// Update existing calculation
  Future<Either<Failure, void>> updateCalculation(ZakatCalculation calculation);

  /// Delete calculation
  Future<Either<Failure, void>> deleteCalculation(String calculationId);

  /// Generate PDF report for Zakat calculation
  Future<Either<Failure, String>> generateZakatReport(ZakatCalculation calculation);

  /// Get Zakat distribution guidelines
  Future<Either<Failure, List<ZakatDistributionGuideline>>> getDistributionGuidelines();

  /// Save Zakat payment record
  Future<Either<Failure, void>> recordZakatPayment({
    required String calculationId,
    required DateTime paymentDate,
    required List<ZakatDistribution> distributions,
  });

  /// Get Nisab threshold for current date
  Future<Either<Failure, NisabInfo>> getCurrentNisab(String currency);

  /// Validate Zakat calculation inputs
  Future<Either<Failure, ValidationResult>> validateCalculationInputs({
    required ZakatableAssets assets,
    required Liabilities liabilities,
  });

  /// Get historical Zakat calculations for analytics
  Future<Either<Failure, List<ZakatCalculation>>> getZakatHistory({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Export Zakat data
  Future<Either<Failure, String>> exportZakatData({
    required String userId,
    required ExportFormat format,
  });

  /// Get Zakat reminders for upcoming due dates
  Future<Either<Failure, List<ZakatReminder>>> getZakatReminders(String userId);

  /// Calculate Zakat al-Fitr
  Future<Either<Failure, double>> calculateZakatAlFitr({
    required String currency,
    required String location,
  });

  /// Get local Zakat organizations for distribution
  Future<Either<Failure, List<ZakatOrganization>>> getLocalZakatOrganizations(String location);
}

/// Zakat distribution guidelines from Islamic sources
class ZakatDistributionGuideline {

  const ZakatDistributionGuideline({
    required this.category,
    required this.arabicName,
    required this.englishName,
    required this.description,
    required this.suggestedPercentage,
    required this.examples,
    required this.quranicReference,
  });
  final ZakatCategory category;
  final String arabicName;
  final String englishName;
  final String description;
  final double suggestedPercentage;
  final List<String> examples;
  final String quranicReference;
}

/// Validation result for Zakat inputs
class ValidationResult {

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
  final bool isValid;
  final List<ValidationError> errors;
  final List<String> warnings;
}

/// Individual validation error
class ValidationError {

  const ValidationError({
    required this.field,
    required this.message,
    this.islamicGuidance,
  });
  final String field;
  final String message;
  final String? islamicGuidance;
}

/// Zakat reminder for users
class ZakatReminder {

  const ZakatReminder({
    required this.id,
    required this.userId,
    required this.dueDate,
    required this.title,
    required this.description,
    required this.type,
    required this.isActive,
  });
  final String id;
  final String userId;
  final DateTime dueDate;
  final String title;
  final String description;
  final ReminderType type;
  final bool isActive;
}

/// Types of Zakat reminders
enum ReminderType {
  hawlDue,        // Islamic year completion
  calculationDue, // Annual calculation reminder
  paymentDue,     // Payment deadline
  fitrDue,        // Zakat al-Fitr due
}

/// Export formats for Zakat data
enum ExportFormat {
  pdf,
  excel,
  csv,
  json,
}

/// Local Zakat organizations
class ZakatOrganization {

  const ZakatOrganization({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.acceptedCategories,
    required this.rating,
    required this.isVerified,
    required this.description,
  });
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String website;
  final List<ZakatCategory> acceptedCategories;
  final double rating;
  final bool isVerified;
  final String description;
}