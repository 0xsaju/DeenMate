import 'package:equatable/equatable.dart';

/// Prayer statistics for tracking user's prayer completion
class PrayerStatistics extends Equatable {
  const PrayerStatistics({
    required this.date,
    required this.completedPrayers,
    required this.totalPrayers,
    required this.completedCount,
    required this.completionRate,
    required this.totalPrayerTime,
    required this.missedPrayers,
    required this.onTimePrayers,
    required this.delayedPrayers,
  });

  final DateTime date;
  final Map<String, bool> completedPrayers;
  final int totalPrayers;
  final int completedCount;
  final double completionRate;
  final Duration totalPrayerTime;
  final List<String> missedPrayers;
  final List<String> onTimePrayers;
  final List<String> delayedPrayers;

  @override
  List<Object?> get props => [
        date,
        completedPrayers,
        totalPrayers,
        completedCount,
        completionRate,
        totalPrayerTime,
        missedPrayers,
        onTimePrayers,
        delayedPrayers,
      ];

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'completedPrayers': completedPrayers,
        'totalPrayers': totalPrayers,
        'completedCount': completedCount,
        'completionRate': completionRate,
        'totalPrayerTime': totalPrayerTime.inMinutes,
        'missedPrayers': missedPrayers,
        'onTimePrayers': onTimePrayers,
        'delayedPrayers': delayedPrayers,
      };

  factory PrayerStatistics.fromJson(Map<String, dynamic> json) {
    return PrayerStatistics(
      date: DateTime.parse(json['date'] as String),
      completedPrayers: Map<String, bool>.from(json['completedPrayers'] as Map),
      totalPrayers: json['totalPrayers'] as int,
      completedCount: json['completedCount'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
      totalPrayerTime: Duration(minutes: json['totalPrayerTime'] as int),
      missedPrayers: List<String>.from(json['missedPrayers'] as List),
      onTimePrayers: List<String>.from(json['onTimePrayers'] as List),
      delayedPrayers: List<String>.from(json['delayedPrayers'] as List),
    );
  }
}

/// Weekly prayer statistics
class WeeklyPrayerStatistics extends Equatable {
  const WeeklyPrayerStatistics({
    required this.weekStart,
    required this.weekEnd,
    required this.dailyStats,
    required this.totalCompleted,
    required this.totalMissed,
    required this.averageCompletionRate,
    required this.totalPrayerTime,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final List<PrayerStatistics> dailyStats;
  final int totalCompleted;
  final int totalMissed;
  final double averageCompletionRate;
  final Duration totalPrayerTime;

  @override
  List<Object?> get props => [
        weekStart,
        weekEnd,
        dailyStats,
        totalCompleted,
        totalMissed,
        averageCompletionRate,
        totalPrayerTime,
      ];

  Map<String, dynamic> toJson() => {
        'weekStart': weekStart.toIso8601String(),
        'weekEnd': weekEnd.toIso8601String(),
        'dailyStats': dailyStats.map((e) => e.toJson()).toList(),
        'totalCompleted': totalCompleted,
        'totalMissed': totalMissed,
        'averageCompletionRate': averageCompletionRate,
        'totalPrayerTime': totalPrayerTime.inMinutes,
      };

  factory WeeklyPrayerStatistics.fromJson(Map<String, dynamic> json) {
    return WeeklyPrayerStatistics(
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      dailyStats: (json['dailyStats'] as List)
          .map((e) => PrayerStatistics.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCompleted: json['totalCompleted'] as int,
      totalMissed: json['totalMissed'] as int,
      averageCompletionRate: (json['averageCompletionRate'] as num).toDouble(),
      totalPrayerTime: Duration(minutes: json['totalPrayerTime'] as int),
    );
  }
}

/// Monthly prayer statistics
class MonthlyPrayerStatistics extends Equatable {
  const MonthlyPrayerStatistics({
    required this.monthStart,
    required this.monthEnd,
    required this.weeklyStats,
    required this.totalCompleted,
    required this.totalMissed,
    required this.averageCompletionRate,
    required this.totalPrayerTime,
    required this.prayerTypeBreakdown,
  });

  final DateTime monthStart;
  final DateTime monthEnd;
  final List<WeeklyPrayerStatistics> weeklyStats;
  final int totalCompleted;
  final int totalMissed;
  final double averageCompletionRate;
  final Duration totalPrayerTime;
  final Map<String, int> prayerTypeBreakdown;

  @override
  List<Object?> get props => [
        monthStart,
        monthEnd,
        weeklyStats,
        totalCompleted,
        totalMissed,
        averageCompletionRate,
        totalPrayerTime,
        prayerTypeBreakdown,
      ];

  Map<String, dynamic> toJson() => {
        'monthStart': monthStart.toIso8601String(),
        'monthEnd': monthEnd.toIso8601String(),
        'weeklyStats': weeklyStats.map((e) => e.toJson()).toList(),
        'totalCompleted': totalCompleted,
        'totalMissed': totalMissed,
        'averageCompletionRate': averageCompletionRate,
        'totalPrayerTime': totalPrayerTime.inMinutes,
        'prayerTypeBreakdown': prayerTypeBreakdown,
      };

  factory MonthlyPrayerStatistics.fromJson(Map<String, dynamic> json) {
    return MonthlyPrayerStatistics(
      monthStart: DateTime.parse(json['monthStart'] as String),
      monthEnd: DateTime.parse(json['monthEnd'] as String),
      weeklyStats: (json['weeklyStats'] as List)
          .map((e) => WeeklyPrayerStatistics.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCompleted: json['totalCompleted'] as int,
      totalMissed: json['totalMissed'] as int,
      averageCompletionRate: (json['averageCompletionRate'] as num).toDouble(),
      totalPrayerTime: Duration(minutes: json['totalPrayerTime'] as int),
      prayerTypeBreakdown: Map<String, int>.from(json['prayerTypeBreakdown'] as Map),
    );
  }
}
