import 'package:equatable/equatable.dart';

class PrayerTracking extends Equatable {
  const PrayerTracking({
    required this.date,
    required this.prayerName,
    required this.isCompleted,
    required this.isOnTime,
    this.completedAt,
    this.notes,
    this.completionType,
  });

  final DateTime date;
  final String prayerName;
  final bool isCompleted;
  final bool isOnTime;
  final DateTime? completedAt;
  final String? notes;
  final PrayerCompletionType? completionType;

  @override
  List<Object?> get props => [
        date,
        prayerName,
        isCompleted,
        isOnTime,
        completedAt,
        notes,
        completionType,
      ];

  PrayerTracking copyWith({
    DateTime? date,
    String? prayerName,
    bool? isCompleted,
    bool? isOnTime,
    DateTime? completedAt,
    String? notes,
    PrayerCompletionType? completionType,
  }) {
    return PrayerTracking(
      date: date ?? this.date,
      prayerName: prayerName ?? this.prayerName,
      isCompleted: isCompleted ?? this.isCompleted,
      isOnTime: isOnTime ?? this.isOnTime,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      completionType: completionType ?? this.completionType,
    );
  }

  // JSON serialization methods
  factory PrayerTracking.fromJson(Map<String, dynamic> json) {
    return PrayerTracking(
      date: DateTime.parse(json['date']),
      prayerName: json['prayerName'],
      isCompleted: json['isCompleted'] ?? false,
      isOnTime: json['isOnTime'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      notes: json['notes'],
      completionType: json['completionType'] != null 
          ? PrayerCompletionType.values.firstWhere(
              (e) => e.name == json['completionType'],
              orElse: () => PrayerCompletionType.onTime,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'prayerName': prayerName,
      'isCompleted': isCompleted,
      'isOnTime': isOnTime,
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'completionType': completionType?.name,
    };
  }
}

class PrayerDetail extends Equatable {
  const PrayerDetail({
    required this.currentPrayer,
    required this.nextPrayer,
    required this.prayerTimes,
    required this.timeUntilNextPrayer,
  });

  final String? currentPrayer;
  final String? nextPrayer;
  final dynamic prayerTimes; // Using dynamic to avoid circular dependency
  final Duration timeUntilNextPrayer;

  @override
  List<Object?> get props => [currentPrayer, nextPrayer, prayerTimes, timeUntilNextPrayer];
}

enum PrayerCompletionType {
  onTime,
  late,
  makeup,
  congregational,
  individual,
}
