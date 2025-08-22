import 'package:freezed_annotation/freezed_annotation.dart';

part 'estate.freezed.dart';
part 'estate.g.dart';

/// Estate entity for Islamic inheritance calculation
@freezed
class Estate with _$Estate {
  const factory Estate({
    required String id,
    required double totalValue,
    required List<Asset> assets,
    required List<Liability> liabilities,
    required List<Expense> expenses,
    required Wasiyyah? wasiyyah,
    required DateTime dateOfDeath,
    required String deceasedName,
    required String deceasedGender,
    String? notes,
  }) = _Estate;

  factory Estate.fromJson(Map<String, dynamic> json) => _$EstateFromJson(json);
}

/// Asset types in Islamic inheritance
@freezed
class Asset with _$Asset {
  const factory Asset({
    required String id,
    required String name,
    required AssetType type,
    required double value,
    required String currency,
    String? description,
    String? location,
    Map<String, dynamic>? additionalInfo,
  }) = _Asset;

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
}

/// Types of assets in Islamic inheritance
enum AssetType {
  cash,
  bankAccount,
  gold,
  silver,
  jewelry,
  realEstate,
  vehicle,
  business,
  investment,
  livestock,
  agricultural,
  intellectualProperty,
  digitalAsset,
  other,
}

/// Liability types in Islamic inheritance
@freezed
class Liability with _$Liability {
  const factory Liability({
    required String id,
    required String name,
    required LiabilityType type,
    required double amount,
    required String currency,
    required String creditor,
    String? description,
    DateTime? dueDate,
    bool isSecured,
  }) = _Liability;

  factory Liability.fromJson(Map<String, dynamic> json) =>
      _$LiabilityFromJson(json);
}

/// Types of liabilities in Islamic inheritance
enum LiabilityType {
  personalLoan,
  businessLoan,
  mortgage,
  creditCard,
  utilityBill,
  taxObligation,
  zakatObligation,
  other,
}

/// Expense types in Islamic inheritance
@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String name,
    required ExpenseType type,
    required double amount,
    required String currency,
    String? description,
    DateTime? date,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}

/// Types of expenses in Islamic inheritance
enum ExpenseType {
  funeralExpense,
  burialExpense,
  medicalExpense,
  legalExpense,
  administrativeExpense,
  other,
}

/// Wasiyyah (bequest) in Islamic inheritance
@freezed
class Wasiyyah with _$Wasiyyah {
  const factory Wasiyyah({
    required String id,
    required String beneficiaryName,
    required double amount,
    required String currency,
    required String description,
    required bool isNonHeir, // Must be non-heir to receive wasiyyah
    String? relationship,
    DateTime? dateCreated,
  }) = _Wasiyyah;

  factory Wasiyyah.fromJson(Map<String, dynamic> json) =>
      _$WasiyyahFromJson(json);
}
