import 'package:freezed_annotation/freezed_annotation.dart';

part 'heir.freezed.dart';
part 'heir.g.dart';

/// Islamic inheritance heir classification based on Shariah
@freezed
class Heir with _$Heir {
  const factory Heir({
    required String id,
    required String name,
    required String arabicName,
    required String bengaliName,
    required HeirType heirType,
    required Gender gender,
    required HeirCategory category,
    required List<QuranicReference> quranicReferences,
    required List<HadithReference> hadithReferences,
    required List<BlockingRule> blockingRules,
    required Map<String, dynamic> shareRules,
    String? description,
    String? fiqhExplanation,
  }) = _Heir;

  factory Heir.fromJson(Map<String, dynamic> json) => _$HeirFromJson(json);
}

/// Types of heirs in Islamic inheritance
enum HeirType {
  // Fixed Share Heirs (Zabiul Furuj)
  spouse,
  father,
  mother,
  daughter,
  sonDaughter,
  paternalGrandfather,
  maternalGrandmother,
  paternalGrandmother,
  fullSister,
  paternalHalfSister,
  maternalHalfSister,
  maternalHalfBrother,

  // Residue Heirs (Asaba)
  son,
  sonSon,
  fullBrother,
  paternalHalfBrother,
  fullBrotherSon,
  paternalHalfBrotherSon,
  paternalUncle,
  paternalUncleSon,

  // Distant Relatives (Dhawi al-Arham)
  maternalUncle,
  maternalAunt,
  cousin,
}

/// Gender classification for inheritance calculations
enum Gender {
  male,
  female,
}

/// Heir categories in Islamic inheritance
enum HeirCategory {
  zabiulFuruj, // Fixed share heirs
  asaba, // Residue heirs
  dhawiAlArham, // Distant relatives
}

/// Quranic references for inheritance rules
@freezed
class QuranicReference with _$QuranicReference {
  const factory QuranicReference({
    required String surah,
    required int ayah,
    required String arabicText,
    required String translation,
    required String explanation,
    required List<String> applicableHeirs,
  }) = _QuranicReference;

  factory QuranicReference.fromJson(Map<String, dynamic> json) =>
      _$QuranicReferenceFromJson(json);
}

/// Hadith references for inheritance rules
@freezed
class HadithReference with _$HadithReference {
  const factory HadithReference({
    required String hadithNumber,
    required String narrator,
    required String arabicText,
    required String translation,
    required String explanation,
    required HadithGrade grade,
    required String source,
    required List<String> applicableHeirs,
  }) = _HadithReference;

  factory HadithReference.fromJson(Map<String, dynamic> json) =>
      _$HadithReferenceFromJson(json);
}

/// Hadith authenticity grades
enum HadithGrade {
  sahih, // Authentic
  hasan, // Good
  daif, // Weak
  mawdu, // Fabricated
}

/// Blocking rules for inheritance
@freezed
class BlockingRule with _$BlockingRule {
  const factory BlockingRule({
    required String ruleName,
    required String description,
    required List<String> blockingHeirs,
    required List<String> blockedHeirs,
    required BlockingType type,
    required String quranicBasis,
    required String hadithBasis,
    required String fiqhExplanation,
  }) = _BlockingRule;

  factory BlockingRule.fromJson(Map<String, dynamic> json) =>
      _$BlockingRuleFromJson(json);
}

/// Types of blocking in inheritance
enum BlockingType {
  complete, // Heir receives nothing
  partial, // Heir's share is reduced
  descriptive, // Share type changes (fixed to residue)
}
