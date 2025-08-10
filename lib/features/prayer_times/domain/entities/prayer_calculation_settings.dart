import 'package:equatable/equatable.dart';

class PrayerCalculationSettings extends Equatable {
  const PrayerCalculationSettings({
    required this.calculationMethod,
    required this.madhab,
    this.adjustments = const {},
    this.highLatitudeRule = HighLatitudeRule.middleOfNight,
    this.isDST = false,
    this.timeFormat,
    this.language,
  });

  final String calculationMethod;
  final Madhab madhab;
  final Map<String, double> adjustments;
  final HighLatitudeRule highLatitudeRule;
  final bool isDST;
  final String? timeFormat;
  final String? language;

  @override
  List<Object?> get props => [
        calculationMethod,
        madhab,
        adjustments,
        highLatitudeRule,
        isDST,
        timeFormat,
        language,
      ];

  PrayerCalculationSettings copyWith({
    String? calculationMethod,
    Madhab? madhab,
    Map<String, double>? adjustments,
    HighLatitudeRule? highLatitudeRule,
    bool? isDST,
    String? timeFormat,
    String? language,
  }) {
    return PrayerCalculationSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      adjustments: adjustments ?? this.adjustments,
      highLatitudeRule: highLatitudeRule ?? this.highLatitudeRule,
      isDST: isDST ?? this.isDST,
      timeFormat: timeFormat ?? this.timeFormat,
      language: language ?? this.language,
    );
  }

  // JSON serialization methods
  factory PrayerCalculationSettings.fromJson(Map<String, dynamic> json) {
    return PrayerCalculationSettings(
      calculationMethod: json['calculationMethod'] ?? 'MWL',
      madhab: Madhab.values.firstWhere(
        (e) => e.name == json['madhab'],
        orElse: () => Madhab.shafi,
      ),
      adjustments: Map<String, double>.from(json['adjustments'] ?? {}),
      highLatitudeRule: HighLatitudeRule.values.firstWhere(
        (e) => e.name == json['highLatitudeRule'],
        orElse: () => HighLatitudeRule.middleOfNight,
      ),
      isDST: json['isDST'] ?? false,
      timeFormat: json['timeFormat'],
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calculationMethod': calculationMethod,
      'madhab': madhab.name,
      'adjustments': adjustments,
      'highLatitudeRule': highLatitudeRule.name,
      'isDST': isDST,
      'timeFormat': timeFormat,
      'language': language,
    };
  }
}

enum Madhab {
  hanafi,
  shafi,
  maliki,
  hanbali,
}

enum HighLatitudeRule {
  middleOfNight,
  seventhOfNight,
  twilightAngle,
}
