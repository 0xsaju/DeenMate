import 'package:freezed_annotation/freezed_annotation.dart';
import 'heir.dart';
import 'estate.dart';

part 'inheritance_result.freezed.dart';
part 'inheritance_result.g.dart';

/// Result of Islamic inheritance calculation
@freezed
class InheritanceResult with _$InheritanceResult {
  const factory InheritanceResult({
    required String id,
    required Estate estate,
    required List<HeirShare> heirShares,
    required List<CalculationStep> calculationSteps,
    required List<QuranicReference> quranicReferences,
    required List<HadithReference> hadithReferences,
    required CalculationMethod method,
    required DateTime calculationDate,
    required String scholarReference,
    String? notes,
    List<String>? warnings,
  }) = _InheritanceResult;

  factory InheritanceResult.fromJson(Map<String, dynamic> json) => 
      _$InheritanceResultFromJson(json);
}

/// Individual heir's share in inheritance
@freezed
class HeirShare with _$HeirShare {
  const factory HeirShare({
    required Heir heir,
    required double shareFraction,
    required double shareAmount,
    required String sharePercentage,
    required ShareType shareType,
    required List<String> calculationNotes,
    List<BlockingRule>? appliedBlockingRules,
  }) = _HeirShare;

  factory HeirShare.fromJson(Map<String, dynamic> json) => _$HeirShareFromJson(json);
}

/// Types of shares in Islamic inheritance
enum ShareType {
  fixedShare,    // Zabiul Furuj - Quranic fixed shares
  residueShare,  // Asaba - Residue after fixed shares
  wasiyyah,      // Bequest (max 1/3 to non-heirs)
  blocked,       // Heir is blocked from inheritance
}

/// Step-by-step calculation process
@freezed
class CalculationStep with _$CalculationStep {
  const factory CalculationStep({
    required int stepNumber,
    required String stepTitle,
    required String stepDescription,
    required String stepType,
    required Map<String, dynamic> stepData,
    required List<String> appliedRules,
    required List<QuranicReference> quranicBasis,
    required List<HadithReference> hadithBasis,
    String? fiqhExplanation,
  }) = _CalculationStep;

  factory CalculationStep.fromJson(Map<String, dynamic> json) => 
      _$CalculationStepFromJson(json);
}

/// Calculation methods used
enum CalculationMethod {
  hanafi,
  shafi,
  maliki,
  hanbali,
  consensus, // When all schools agree
}

/// Islamic inheritance calculation engine
class IslamicInheritanceCalculator {
  /// Calculate inheritance based on Shariah principles
  static InheritanceResult calculateInheritance({
    required Estate estate,
    required List<Heir> heirs,
    required CalculationMethod method,
  }) {
    // Step 1: Prepare estate (deduct expenses, debts, wasiyyah)
    final netEstate = _prepareEstate(estate);
    
    // Step 2: Apply blocking rules
    final eligibleHeirs = _applyBlockingRules(heirs);
    
    // Step 3: Calculate fixed shares
    final fixedShares = _calculateFixedShares(eligibleHeirs, netEstate);
    
    // Step 4: Check for Aul (excess) or Radd (shortfall)
    final adjustedShares = _applyAulOrRadd(fixedShares, netEstate);
    
    // Step 5: Distribute residue to Asaba
    final finalShares = _distributeResidue(adjustedShares, netEstate);
    
    // Step 6: Generate calculation steps and references
    final steps = _generateCalculationSteps(estate, heirs, finalShares);
    final quranicRefs = _getQuranicReferences(heirs);
    final hadithRefs = _getHadithReferences(heirs);
    
    return InheritanceResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      estate: estate,
      heirShares: finalShares,
      calculationSteps: steps,
      quranicReferences: quranicRefs,
      hadithReferences: hadithRefs,
      method: method,
      calculationDate: DateTime.now(),
      scholarReference: _getScholarReference(method),
    );
  }
  
  /// Prepare estate by deducting expenses, debts, and wasiyyah
  static double _prepareEstate(Estate estate) {
    double netEstate = estate.totalValue;
    
    // Deduct funeral and burial expenses (priority)
    for (final expense in estate.expenses) {
      if (expense.type == ExpenseType.funeralExpense || 
          expense.type == ExpenseType.burialExpense) {
        netEstate -= expense.amount;
      }
    }
    
    // Deduct all debts
    for (final liability in estate.liabilities) {
      netEstate -= liability.amount;
    }
    
    // Deduct other expenses
    for (final expense in estate.expenses) {
      if (expense.type != ExpenseType.funeralExpense && 
          expense.type != ExpenseType.burialExpense) {
        netEstate -= expense.amount;
      }
    }
    
    // Deduct wasiyyah (maximum 1/3 of remaining estate)
    if (estate.wasiyyah != null) {
      final maxWasiyyah = netEstate * (1/3);
      final actualWasiyyah = estate.wasiyyah!.amount > maxWasiyyah 
          ? maxWasiyyah 
          : estate.wasiyyah!.amount;
      netEstate -= actualWasiyyah;
    }
    
    return netEstate;
  }
  
  /// Apply blocking rules to determine eligible heirs
  static List<Heir> _applyBlockingRules(List<Heir> heirs) {
    // Implementation of blocking rules based on Shariah
    // This is a complex algorithm that needs detailed implementation
    return heirs.where((heir) => !_isBlocked(heir, heirs)).toList();
  }
  
  /// Check if an heir is blocked by other heirs
  static bool _isBlocked(Heir heir, List<Heir> allHeirs) {
    // Implementation of blocking logic
    // This requires detailed rules based on Quran and Hadith
    return false; // Placeholder
  }
  
  /// Calculate fixed shares for eligible heirs
  static List<HeirShare> _calculateFixedShares(List<Heir> heirs, double netEstate) {
    // Implementation of fixed share calculation
    // Based on Quranic verses and Hadith
    return []; // Placeholder
  }
  
  /// Apply Aul (excess) or Radd (shortfall) principles
  static List<HeirShare> _applyAulOrRadd(List<HeirShare> shares, double netEstate) {
    // Implementation of Aul and Radd principles
    return shares; // Placeholder
  }
  
  /// Distribute residue to Asaba heirs
  static List<HeirShare> _distributeResidue(List<HeirShare> shares, double netEstate) {
    // Implementation of residue distribution
    return shares; // Placeholder
  }
  
  /// Generate step-by-step calculation process
  static List<CalculationStep> _generateCalculationSteps(
    Estate estate, 
    List<Heir> heirs, 
    List<HeirShare> finalShares
  ) {
    // Implementation of step generation
    return []; // Placeholder
  }
  
  /// Get Quranic references for the calculation
  static List<QuranicReference> _getQuranicReferences(List<Heir> heirs) {
    // Implementation to get relevant Quranic verses
    return []; // Placeholder
  }
  
  /// Get Hadith references for the calculation
  static List<HadithReference> _getHadithReferences(List<Heir> heirs) {
    // Implementation to get relevant Hadith
    return []; // Placeholder
  }
  
  /// Get scholar reference for the calculation method
  static String _getScholarReference(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.hanafi:
        return "Based on Imam Abu Hanifa's methodology";
      case CalculationMethod.shafi:
        return "Based on Imam Shafi'i's methodology";
      case CalculationMethod.maliki:
        return "Based on Imam Malik's methodology";
      case CalculationMethod.hanbali:
        return "Based on Imam Ahmad ibn Hanbal's methodology";
      case CalculationMethod.consensus:
        return "Based on scholarly consensus (Ijma)";
    }
  }
}
