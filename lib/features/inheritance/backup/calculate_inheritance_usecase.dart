import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/heir.dart';
import '../entities/estate.dart';
import '../entities/inheritance_result.dart';
import '../entities/calculation_step.dart';
import '../entities/heir_share.dart';
import '../../data/sources/shariah_references.dart';

/// Main use case for calculating Islamic inheritance
class CalculateInheritanceUseCase {
  const CalculateInheritanceUseCase();

  /// Calculate inheritance based on Islamic principles
  Either<Failure, InheritanceResult> call({
    required Estate estate,
    required List<Heir> heirs,
    required CalculationMethod method,
  }) {
    try {
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
      
      return Right(InheritanceResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        estate: estate,
        heirShares: finalShares,
        calculationSteps: steps,
        quranicReferences: quranicRefs,
        hadithReferences: hadithRefs,
        method: method,
        calculationDate: DateTime.now(),
        scholarReference: _getScholarReference(method),
      ));
    } catch (e) {
      return Left(Failure.inheritanceCalculationFailure(
        message: 'Calculation failed: ${e.toString()}',
      ));
    }
  }
  
  /// Prepare estate by deducting expenses, debts, and wasiyyah
  double _prepareEstate(Estate estate) {
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
  List<Heir> _applyBlockingRules(List<Heir> heirs) {
    final eligibleHeirs = <Heir>[];
    
    for (final heir in heirs) {
      if (!_isBlocked(heir, heirs)) {
        eligibleHeirs.add(heir);
      }
    }
    
    return eligibleHeirs;
  }
  
  /// Check if an heir is blocked by other heirs
  bool _isBlocked(Heir heir, List<Heir> allHeirs) {
    // Children block siblings
    if (_hasChildren(allHeirs) && _isSibling(heir)) {
      return true;
    }
    
    // Father blocks grandfather
    if (_hasFather(allHeirs) && heir.heirType == HeirType.paternalGrandfather) {
      return true;
    }
    
    // Mother blocks grandmothers
    if (_hasMother(allHeirs) && 
        (heir.heirType == HeirType.paternalGrandmother || 
         heir.heirType == HeirType.maternalGrandmother)) {
      return true;
    }
    
    // Full siblings block paternal siblings
    if (_hasFullSiblings(allHeirs) && _isPaternalSibling(heir)) {
      return true;
    }
    
    return false;
  }
  
  /// Calculate fixed shares for eligible heirs
  List<HeirShare> _calculateFixedShares(List<Heir> heirs, double netEstate) {
    final shares = <HeirShare>[];
    
    for (final heir in heirs) {
      final shareFraction = _getFixedShareFraction(heir, heirs);
      
      if (shareFraction > 0) {
        final shareAmount = netEstate * shareFraction;
        final sharePercentage = (shareFraction * 100).toStringAsFixed(2);
        
        shares.add(HeirShare(
          heir: heir,
          shareFraction: shareFraction,
          shareAmount: shareAmount,
          sharePercentage: '$sharePercentage%',
          shareType: ShareType.fixedShare,
          calculationNotes: [_getShareExplanation(heir, shareFraction)],
        ));
      }
    }
    
    return shares;
  }
  
  /// Get fixed share fraction for an heir
  double _getFixedShareFraction(Heir heir, List<Heir> allHeirs) {
    switch (heir.heirType) {
      case HeirType.spouse:
        return _hasChildren(allHeirs) ? 1/8 : 1/4;
        
      case HeirType.father:
        return _hasChildren(allHeirs) ? 1/6 : 0; // Residue if no children
        
      case HeirType.mother:
        if (_hasChildren(allHeirs)) {
          return 1/6;
        } else if (_hasSiblings(allHeirs)) {
          return 1/6;
        } else {
          return 1/3;
        }
        
      case HeirType.daughter:
        if (_hasSons(allHeirs)) {
          return 0; // Residue when sons exist
        } else {
          final daughters = _countDaughters(allHeirs);
          return daughters == 1 ? 1/2 : 2/3;
        }
        
      case HeirType.son:
        return 0; // Always residue
        
      case HeirType.fullSister:
        if (_hasChildren(allHeirs) || _hasFather(allHeirs) || _hasSons(allHeirs)) {
          return 0; // Blocked
        } else {
          final sisters = _countFullSisters(allHeirs);
          return sisters == 1 ? 1/2 : 2/3;
        }
        
      case HeirType.fullBrother:
        return 0; // Always residue
        
      case HeirType.paternalHalfSister:
        if (_hasChildren(allHeirs) || _hasFather(allHeirs) || 
            _hasFullSiblings(allHeirs)) {
          return 0; // Blocked
        } else {
          final sisters = _countPaternalHalfSisters(allHeirs);
          return sisters == 1 ? 1/2 : 2/3;
        }
        
      case HeirType.paternalHalfBrother:
        return 0; // Always residue
        
      case HeirType.maternalHalfSister:
      case HeirType.maternalHalfBrother:
        if (_hasChildren(allHeirs) || _hasFather(allHeirs) || 
            _hasFullSiblings(allHeirs) || _hasPaternalHalfSiblings(allHeirs)) {
          return 0; // Blocked
        } else {
          final maternalSiblings = _countMaternalHalfSiblings(allHeirs);
          return maternalSiblings == 1 ? 1/6 : 1/3;
        }
        
      default:
        return 0; // No fixed share
    }
  }
  
  /// Apply Aul (excess) or Radd (shortfall) principles
  List<HeirShare> _applyAulOrRadd(List<HeirShare> shares, double netEstate) {
    final totalFixedShares = shares.fold<double>(0, (sum, share) => sum + share.shareFraction);
    
    if (totalFixedShares > 1.0) {
      // Aul (excess) - proportional reduction
      return _applyAul(shares, totalFixedShares);
    } else if (totalFixedShares < 1.0 && !_hasAsaba(shares)) {
      // Radd (shortfall) - proportional increase (exclude spouse)
      return _applyRadd(shares, totalFixedShares);
    }
    
    return shares;
  }
  
  /// Apply Aul (excess) principle
  List<HeirShare> _applyAul(List<HeirShare> shares, double totalShares) {
    final aulRatio = 1.0 / totalShares;
    
    return shares.map((share) {
      final adjustedFraction = share.shareFraction * aulRatio;
      final adjustedAmount = share.shareAmount * aulRatio;
      final adjustedPercentage = (adjustedFraction * 100).toStringAsFixed(2);
      
      return share.copyWith(
        shareFraction: adjustedFraction,
        shareAmount: adjustedAmount,
        sharePercentage: '$adjustedPercentage%',
        calculationNotes: [
          ...share.calculationNotes,
          'Aul applied: ${(aulRatio * 100).toStringAsFixed(1)}% reduction',
        ],
      );
    }).toList();
  }
  
  /// Apply Radd (shortfall) principle
  List<HeirShare> _applyRadd(List<HeirShare> shares, double totalShares) {
    final remaining = 1.0 - totalShares;
    final nonSpouseShares = shares.where((s) => s.heir.heirType != HeirType.spouse).toList();
    
    if (nonSpouseShares.isEmpty) return shares;
    
    final nonSpouseTotal = nonSpouseShares.fold<double>(0, (sum, s) => sum + s.shareFraction);
    final raddRatio = remaining / nonSpouseTotal;
    
    return shares.map((share) {
      if (share.heir.heirType == HeirType.spouse) {
        return share; // Spouse excluded from radd
      }
      
      final additionalFraction = share.shareFraction * raddRatio;
      final additionalAmount = share.shareAmount * raddRatio;
      final newFraction = share.shareFraction + additionalFraction;
      final newAmount = share.shareAmount + additionalAmount;
      final newPercentage = (newFraction * 100).toStringAsFixed(2);
      
      return share.copyWith(
        shareFraction: newFraction,
        shareAmount: newAmount,
        sharePercentage: '$newPercentage%',
        calculationNotes: [
          ...share.calculationNotes,
          'Radd applied: +${(additionalFraction * 100).toStringAsFixed(1)}%',
        ],
      );
    }).toList();
  }
  
  /// Distribute residue to Asaba heirs
  List<HeirShare> _distributeResidue(List<HeirShare> shares, double netEstate) {
    final totalFixedShares = shares.fold<double>(0, (sum, share) => sum + share.shareFraction);
    final residue = 1.0 - totalFixedShares;
    
    if (residue <= 0) return shares;
    
    final asabaHeirs = _getAsabaHeirs(shares);
    if (asabaHeirs.isEmpty) return shares;
    
    final residueAmount = netEstate * residue;
    final asabaShares = _calculateAsabaShares(asabaHeirs, residueAmount);
    
    return [...shares, ...asabaShares];
  }
  
  /// Get Asaba (residue) heirs
  List<Heir> _getAsabaHeirs(List<HeirShare> shares) {
    final asabaHeirs = <Heir>[];
    
    for (final share in shares) {
      if (_isAsaba(share.heir)) {
        asabaHeirs.add(share.heir);
      }
    }
    
    return asabaHeirs;
  }
  
  /// Calculate shares for Asaba heirs
  List<HeirShare> _calculateAsabaShares(List<Heir> asabaHeirs, double residueAmount) {
    final shares = <HeirShare>[];
    final totalUnits = _calculateAsabaUnits(asabaHeirs);
    
    for (final heir in asabaHeirs) {
      final units = _getAsabaUnits(heir);
      final shareFraction = units / totalUnits;
      final shareAmount = residueAmount * shareFraction;
      final sharePercentage = (shareFraction * 100).toStringAsFixed(2);
      
      shares.add(HeirShare(
        heir: heir,
        shareFraction: shareFraction,
        shareAmount: shareAmount,
        sharePercentage: '$sharePercentage%',
        shareType: ShareType.residueShare,
        calculationNotes: [
          'Asaba (residue) share: $units units',
        ],
      ));
    }
    
    return shares;
  }
  
  /// Calculate total units for Asaba distribution
  double _calculateAsabaUnits(List<Heir> asabaHeirs) {
    return asabaHeirs.fold<double>(0, (sum, heir) => sum + _getAsabaUnits(heir));
  }
  
  /// Get units for an Asaba heir (2:1 ratio for males:females)
  double _getAsabaUnits(Heir heir) {
    return heir.gender == Gender.male ? 2.0 : 1.0;
  }
  
  /// Check if heir is Asaba (residue heir)
  bool _isAsaba(Heir heir) {
    return heir.category == HeirCategory.asaba;
  }
  
  /// Check if there are Asaba heirs
  bool _hasAsaba(List<HeirShare> shares) {
    return shares.any((share) => _isAsaba(share.heir));
  }
  
  // Helper methods for heir analysis
  bool _hasChildren(List<Heir> heirs) => heirs.any((h) => h.heirType == HeirType.son || h.heirType == HeirType.daughter);
  bool _hasSons(List<Heir> heirs) => heirs.any((h) => h.heirType == HeirType.son);
  bool _hasDaughters(List<Heir> heirs) => heirs.any((h) => h.heirType == HeirType.daughter);
  bool _hasFather(List<Heir> heirs) => heirs.any((h) => h.heirType == HeirType.father);
  bool _hasMother(List<Heir> heirs) => heirs.any((h) => h.heirType == HeirType.mother);
  bool _hasSiblings(List<Heir> heirs) => heirs.any((h) => _isSibling(h));
  bool _hasFullSiblings(List<Heir> heirs) => heirs.any((h) => h.heirType == HeirType.fullBrother || h.heirType == HeirType.fullSister);
  bool _hasPaternalHalfSiblings(List<Heir> heirs) => heirs.any((h) => h.heirType == HeirType.paternalHalfBrother || h.heirType == HeirType.paternalHalfSister);
  
  bool _isSibling(Heir heir) => heir.heirType == HeirType.fullBrother || heir.heirType == HeirType.fullSister || 
                                heir.heirType == HeirType.paternalHalfBrother || heir.heirType == HeirType.paternalHalfSister ||
                                heir.heirType == HeirType.maternalHalfBrother || heir.heirType == HeirType.maternalHalfSister;
  
  bool _isPaternalSibling(Heir heir) => heir.heirType == HeirType.paternalHalfBrother || heir.heirType == HeirType.paternalHalfSister;
  
  int _countDaughters(List<Heir> heirs) => heirs.where((h) => h.heirType == HeirType.daughter).length;
  int _countFullSisters(List<Heir> heirs) => heirs.where((h) => h.heirType == HeirType.fullSister).length;
  int _countPaternalHalfSisters(List<Heir> heirs) => heirs.where((h) => h.heirType == HeirType.paternalHalfSister).length;
  int _countMaternalHalfSiblings(List<Heir> heirs) => heirs.where((h) => h.heirType == HeirType.maternalHalfBrother || h.heirType == HeirType.maternalHalfSister).length;
  
  String _getShareExplanation(Heir heir, double fraction) {
    final fractionText = _fractionToText(fraction);
    return '${heir.name}: $fractionText (${(fraction * 100).toStringAsFixed(1)}%)';
  }
  
  String _fractionToText(double fraction) {
    if (fraction == 1/2) return '1/2';
    if (fraction == 1/3) return '1/3';
    if (fraction == 1/4) return '1/4';
    if (fraction == 1/6) return '1/6';
    if (fraction == 1/8) return '1/8';
    if (fraction == 2/3) return '2/3';
    return fraction.toStringAsFixed(3);
  }
  
  List<CalculationStep> _generateCalculationSteps(Estate estate, List<Heir> heirs, List<HeirShare> finalShares) {
    final steps = <CalculationStep>[];
    
    // Step 1: Estate preparation
    steps.add(CalculationStep(
      stepNumber: 1,
      stepTitle: 'Estate Preparation',
      stepDescription: 'Deduct expenses, debts, and wasiyyah from total estate',
      stepType: 'estate_preparation',
      stepData: {
        'total_value': estate.totalValue,
        'expenses': estate.expenses.map((e) => e.amount).fold(0.0, (sum, amount) => sum + amount),
        'debts': estate.liabilities.map((l) => l.amount).fold(0.0, (sum, amount) => sum + amount),
        'wasiyyah': estate.wasiyyah?.amount ?? 0.0,
      },
      appliedRules: ['Funeral expenses first', 'All debts must be paid', 'Wasiyyah maximum 1/3'],
      quranicBasis: [],
      hadithBasis: [],
      fiqhExplanation: 'Estate must be prepared before inheritance distribution',
    ));
    
    // Step 2: Heir identification
    steps.add(CalculationStep(
      stepNumber: 2,
      stepTitle: 'Heir Identification',
      stepDescription: 'Identify eligible heirs and apply blocking rules',
      stepType: 'heir_identification',
      stepData: {
        'total_heirs': heirs.length,
        'eligible_heirs': finalShares.length,
        'blocked_heirs': heirs.length - finalShares.length,
      },
      appliedRules: ['Children block siblings', 'Father blocks grandfather', 'Mother blocks grandmothers'],
      quranicBasis: [],
      hadithBasis: [],
      fiqhExplanation: 'Closer relatives block more distant ones',
    ));
    
    // Step 3: Fixed share calculation
    final fixedShares = finalShares.where((s) => s.shareType == ShareType.fixedShare).toList();
    steps.add(CalculationStep(
      stepNumber: 3,
      stepTitle: 'Fixed Share Calculation',
      stepDescription: 'Calculate Quranic fixed shares for eligible heirs',
      stepType: 'fixed_share_calculation',
      stepData: {
        'fixed_shares_count': fixedShares.length,
        'total_fixed_fraction': fixedShares.fold(0.0, (sum, s) => sum + s.shareFraction),
      },
      appliedRules: ['Spouse: 1/4 or 1/8', 'Children: 1/2, 2/3, or residue', 'Parents: 1/6 or 1/3'],
      quranicBasis: ShariahReferences.quranicVerses,
      hadithBasis: ShariahReferences.hadithReferences,
      fiqhExplanation: 'Fixed shares are determined by Quran and Hadith',
    ));
    
    return steps;
  }
  
  List<QuranicReference> _getQuranicReferences(List<Heir> heirs) {
    final heirTypes = heirs.map((h) => h.heirType.name).toList();
    return ShariahReferences.getQuranicReferencesForHeirs(heirTypes);
  }
  
  List<HadithReference> _getHadithReferences(List<Heir> heirs) {
    final heirTypes = heirs.map((h) => h.heirType.name).toList();
    return ShariahReferences.getHadithReferencesForHeirs(heirTypes);
  }
  
  String _getScholarReference(CalculationMethod method) {
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
