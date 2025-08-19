enum IshaStatus {
  optimal, // First third of the night (best time)
  permissible, // After optimal but before Islamic midnight
  ending, // Approaching Islamic midnight (30 min before)
  ended, // Past Islamic midnight
}

enum ScholarlyView {
  strict, // Ibn Hazm, Al-Albani: Hard deadline at Islamic midnight
  majority, // Jumhur: Preferred until midnight, permissible until Fajr
}

class IshaTimeData {
  final DateTime startTime;
  final DateTime optimalEndTime;
  final DateTime absoluteEndTime;
  final DateTime islamicMidnight;
  final IshaStatus status;
  final ScholarlyView scholarlyView;
  final Duration nightDuration;
  final Duration timeUntilMidnight;

  const IshaTimeData({
    required this.startTime,
    required this.optimalEndTime,
    required this.absoluteEndTime,
    required this.islamicMidnight,
    required this.status,
    required this.scholarlyView,
    required this.nightDuration,
    required this.timeUntilMidnight,
  });

  IshaTimeData copyWith({
    DateTime? startTime,
    DateTime? optimalEndTime,
    DateTime? absoluteEndTime,
    DateTime? islamicMidnight,
    IshaStatus? status,
    ScholarlyView? scholarlyView,
    Duration? nightDuration,
    Duration? timeUntilMidnight,
  }) {
    return IshaTimeData(
      startTime: startTime ?? this.startTime,
      optimalEndTime: optimalEndTime ?? this.optimalEndTime,
      absoluteEndTime: absoluteEndTime ?? this.absoluteEndTime,
      islamicMidnight: islamicMidnight ?? this.islamicMidnight,
      status: status ?? this.status,
      scholarlyView: scholarlyView ?? this.scholarlyView,
      nightDuration: nightDuration ?? this.nightDuration,
      timeUntilMidnight: timeUntilMidnight ?? this.timeUntilMidnight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IshaTimeData &&
        other.startTime == startTime &&
        other.optimalEndTime == optimalEndTime &&
        other.absoluteEndTime == absoluteEndTime &&
        other.islamicMidnight == islamicMidnight &&
        other.status == status &&
        other.scholarlyView == scholarlyView &&
        other.nightDuration == nightDuration &&
        other.timeUntilMidnight == timeUntilMidnight;
  }

  @override
  int get hashCode {
    return startTime.hashCode ^
        optimalEndTime.hashCode ^
        absoluteEndTime.hashCode ^
        islamicMidnight.hashCode ^
        status.hashCode ^
        scholarlyView.hashCode ^
        nightDuration.hashCode ^
        timeUntilMidnight.hashCode;
  }

  @override
  String toString() {
    return 'IshaTimeData(startTime: $startTime, optimalEndTime: $optimalEndTime, absoluteEndTime: $absoluteEndTime, islamicMidnight: $islamicMidnight, status: $status, scholarlyView: $scholarlyView, nightDuration: $nightDuration, timeUntilMidnight: $timeUntilMidnight)';
  }
}
