import 'package:freezed_annotation/freezed_annotation.dart';
import 'heir.dart';

part 'calculation_step.freezed.dart';
part 'calculation_step.g.dart';

/// Represents a step in the inheritance calculation process
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
    required String fiqhExplanation,
  }) = _CalculationStep;

  factory CalculationStep.fromJson(Map<String, dynamic> json) => _$CalculationStepFromJson(json);
}
