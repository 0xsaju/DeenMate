import 'package:freezed_annotation/freezed_annotation.dart';
import 'heir.dart';

part 'heir_share.freezed.dart';
part 'heir_share.g.dart';

/// Represents the calculated share for an heir
@freezed
class HeirShare with _$HeirShare {
  const factory HeirShare({
    required Heir heir,
    required double shareFraction,
    required double shareAmount,
    required String sharePercentage,
    required ShareType shareType,
    required List<String> calculationNotes,
  }) = _HeirShare;

  factory HeirShare.fromJson(Map<String, dynamic> json) => _$HeirShareFromJson(json);
}

/// Types of shares in Islamic inheritance
enum ShareType {
  fixedShare,    // Quranic fixed shares
  residueShare,  // Asaba (residue) shares
  blockedShare,  // Blocked heirs (0 share)
}
