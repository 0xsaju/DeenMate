import 'package:dartz/dartz.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/repositories/prayer_times_repository.dart';

/// Use case for getting current prayer information with Islamic context
class GetCurrentPrayerUsecase {

  const GetCurrentPrayerUsecase(this.repository);
  final PrayerTimesRepository repository;

  /// Get current prayer status and next prayer information
  Future<Either<Failure, CurrentPrayerInfo>> call() async {
    try {
      // Get current prayer times
      final prayerTimesResult = await repository.getCurrentPrayerTimes();
      
      return prayerTimesResult.fold(
        Left.new,
        (prayerTimes) async {
          final currentPrayerInfo = _analyzePrayerStatus(prayerTimes);
          
          // Get additional Islamic context
          final islamicContext = await _getIslamicContext(currentPrayerInfo, prayerTimes);
          
          return Right(currentPrayerInfo.copyWith(
            islamicContext: islamicContext,
          ),);
        },
      );
    } catch (e) {
      return Left(Failure.unknownFailure(
        message: 'Failed to get current prayer information',
        details: e.toString(),
      ),);
    }
  }

  /// Analyze current prayer status
  CurrentPrayerInfo _analyzePrayerStatus(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    final prayers = [
      prayerTimes.fajr,
      prayerTimes.dhuhr,
      prayerTimes.asr,
      prayerTimes.maghrib,
      prayerTimes.isha,
    ];

    // Find current and next prayer
    PrayerTime? currentPrayer;
    PrayerTime? nextPrayer;
    var currentStatus = PrayerStatus.upcoming;

    // Find the next upcoming prayer
    for (var i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      
      if (now.isBefore(prayer.time)) {
        // This is the next prayer
        nextPrayer = prayer;
        
        // Find the current prayer (the one that just passed)
        if (i > 0) {
          currentPrayer = prayers[i - 1];
          currentStatus = PrayerStatus.completed;
        } else {
          // Before Fajr, so no current prayer yet
          currentStatus = PrayerStatus.upcoming;
        }
        break;
      }
    }

    // If no next prayer found, we're after Isha
    if (nextPrayer == null) {
      currentPrayer = prayerTimes.isha;
      currentStatus = PrayerStatus.completed;
      // Next prayer would be Fajr of tomorrow (handled separately)
    }

    // Calculate time information
    Duration? timeUntilNext;
    Duration? timeSinceCurrent;

    if (nextPrayer != null) {
      timeUntilNext = nextPrayer.time.difference(now);
    }

    if (currentPrayer != null) {
      timeSinceCurrent = now.difference(currentPrayer.time);
    }

    return CurrentPrayerInfo(
      currentPrayer: currentPrayer,
      nextPrayer: nextPrayer,
      currentStatus: currentStatus,
      timeUntilNext: timeUntilNext,
      timeSinceCurrent: timeSinceCurrent,
      prayerTimes: prayerTimes,
      isQiyamTime: _isQiyamTime(prayerTimes, now),
      dayCompletionRate: _calculateDayCompletion(prayerTimes),
      islamicContext: null, // Will be filled later
    );
  }

  /// Determine the status of current prayer
  PrayerStatus _determinePrayerStatus(PrayerTime currentPrayer, PrayerTime? nextPrayer, DateTime now) {
    if (currentPrayer.isCompleted) {
      return PrayerStatus.completed;
    }

    // Check if we're still within the preferred time for the prayer
    if (nextPrayer != null) {
      final prayerDuration = nextPrayer.time.difference(currentPrayer.time);
      final preferredDuration = Duration(minutes: prayerDuration.inMinutes ~/ 3); // First third is preferred
      
      if (now.isBefore(currentPrayer.time.add(preferredDuration))) {
        return PrayerStatus.current;
      } else {
        return PrayerStatus.inProgress; // Still valid but past preferred time
      }
    }

    return PrayerStatus.current;
  }

  /// Check if it's currently Qiyam/Tahajjud time
  bool _isQiyamTime(PrayerTimes prayerTimes, DateTime now) {
    // Qiyam time is from after Isha until before Fajr
    // Best time is the last third of the night
    final ishaTime = prayerTimes.isha.time;
    final fajrTime = prayerTimes.fajr.time;
    
    // Handle night crossing midnight
    if (fajrTime.isBefore(ishaTime)) {
      // Next day's Fajr
      final nextFajr = fajrTime.add(const Duration(days: 1));
      return now.isAfter(ishaTime) || now.isBefore(fajrTime);
    } else {
      return now.isAfter(ishaTime) && now.isBefore(fajrTime);
    }
  }

  /// Calculate prayer completion rate for the day
  double _calculateDayCompletion(PrayerTimes prayerTimes) {
    final prayers = [
      prayerTimes.fajr,
      prayerTimes.dhuhr,
      prayerTimes.asr,
      prayerTimes.maghrib,
      prayerTimes.isha,
    ];

    final completed = prayers.where((p) => p.isCompleted).length;
    return completed / prayers.length;
  }

  /// Get additional Islamic context for current prayer status
  Future<IslamicPrayerContext> _getIslamicContext(
    CurrentPrayerInfo info,
    PrayerTimes prayerTimes,
  ) async {
    final now = DateTime.now();
    
    // Get appropriate Islamic messages and duas
    final statusMessage = _getStatusMessage(info.currentStatus, info.currentPrayer);
    final duaRecommendation = _getDuaRecommendation(info.currentPrayer, info.nextPrayer);
    final islamicReminder = _getIslamicReminder(info.currentStatus, now, prayerTimes);
    
    // Get Qibla direction
    final qiblaResult = await repository.getQiblaDirection(prayerTimes.location);
    final qiblaDirection = qiblaResult.fold((failure) => null, (direction) => direction);
    
    // Parse hijriDate string to HijriCalendar object
    final hijriParts = prayerTimes.hijriDate.split('-');
    final hijriCalendar = HijriCalendar()
      ..hDay = int.parse(hijriParts[0])
      ..hMonth = int.parse(hijriParts[1])
      ..hYear = int.parse(hijriParts[2]);

    return IslamicPrayerContext(
      statusMessage: statusMessage,
      duaRecommendation: duaRecommendation,
      islamicReminder: islamicReminder,
      qiblaDirection: qiblaDirection,
      hijriDate: hijriCalendar,
      isHolyDay: await _checkIfHolyDay(hijriCalendar),
      recommendedActions: _getRecommendedActions(info.currentStatus, info.currentPrayer),
    );
  }

  /// Get status message based on current prayer situation
  String _getStatusMessage(PrayerStatus status, PrayerTime? currentPrayer) {
    switch (status) {
      case PrayerStatus.upcoming:
        return 'Prepare for the next prayer. الوضوء نور (Ablution is light)';
      case PrayerStatus.current:
        if (currentPrayer != null) {
          return "It's time for ${currentPrayer.name} prayer. حي على الصلاة";
        }
        return 'Prayer time has begun. حي على الصلاة';
      case PrayerStatus.inProgress:
        return "Prayer time is still valid. Don't delay! لا تؤخر الصلاة";
      case PrayerStatus.completed:
        return 'الحمد لله! Well done. Remember Allah throughout the day.';
      case PrayerStatus.missed:
        return 'Make up the missed prayer when possible. التوبة مقبولة';
    }
  }

  /// Get dua recommendation based on prayer timing
  String _getDuaRecommendation(PrayerTime? currentPrayer, PrayerTime? nextPrayer) {
    if (currentPrayer?.name.toLowerCase() == 'fajr') {
      return 'Recite morning adhkar after Fajr. أذكار الصباح';
    } else if (currentPrayer?.name.toLowerCase() == 'maghrib') {
      return 'Recite evening adhkar after Maghrib. أذكار المساء';
    } else if (nextPrayer?.name.toLowerCase() == 'fajr') {
      return 'Consider praying Tahajjud before Fajr. قيام الليل';
    } else {
      return 'Remember Allah with Tasbih, Tahmid, and Takbir. الذكر';
    }
  }

  /// Get Islamic reminder based on current situation
  String _getIslamicReminder(PrayerStatus status, DateTime now, PrayerTimes prayerTimes) {
    final hour = now.hour;
    
    if (hour >= 4 && hour < 6) {
      return 'The best time for dua is before Fajr. دعاء السحر';
    } else if (hour >= 12 && hour < 13) {
      return 'Friday Jummah prayer is approaching. صلاة الجمعة';
    } else if (hour >= 15 && hour < 16) {
      return 'Time between Asr and Maghrib is blessed. وقت مبارك';
    } else {
      return 'Keep your tongue moist with the remembrance of Allah. الذكر';
    }
  }

  /// Check if current Hijri date is a holy day
  Future<bool> _checkIfHolyDay(HijriCalendar hijriDate) async {
    // Check for major Islamic holidays
    if (hijriDate.hMonth == 9) return true; // Ramadan
    if (hijriDate.hMonth == 10 && hijriDate.hDay == 1) return true; // Eid al-Fitr
    if (hijriDate.hMonth == 12 && hijriDate.hDay >= 10 && hijriDate.hDay <= 13) return true; // Eid al-Adha
    if (hijriDate.hMonth == 1 && hijriDate.hDay == 10) return true; // Day of Ashura
    if (hijriDate.hMonth == 3 && hijriDate.hDay == 12) return true; // Mawlid (some opinions)
    
    return false;
  }

  /// Get recommended actions based on prayer status
  List<String> _getRecommendedActions(PrayerStatus status, PrayerTime? currentPrayer) {
    switch (status) {
      case PrayerStatus.upcoming:
        return [
          'Perform Wudu (ablution)',
          'Find Qibla direction',
          'Prepare prayer mat',
          'Silence devices',
        ];
      case PrayerStatus.current:
        return [
          'Pray immediately',
          'Recite with concentration',
          'Make dua after Salah',
          'Seek forgiveness',
        ];
      case PrayerStatus.inProgress:
        return [
          'Pray before time expires',
          "Seek Allah's forgiveness",
          'Make dua for consistency',
        ];
      case PrayerStatus.completed:
        return [
          'Recite Adhkar',
          'Make personal dua',
          'Read Quran',
          'Remember Allah',
        ];
      case PrayerStatus.missed:
        return [
          'Pray Qada (makeup)',
          'Seek forgiveness',
          'Set reminders',
          'Increase awareness',
        ];
    }
  }
}

/// Current prayer information with Islamic context
class CurrentPrayerInfo {

  const CurrentPrayerInfo({
    required this.currentPrayer,
    required this.nextPrayer,
    required this.currentStatus,
    required this.timeUntilNext,
    required this.timeSinceCurrent,
    required this.prayerTimes,
    required this.isQiyamTime,
    required this.dayCompletionRate,
    required this.islamicContext,
  });
  final PrayerTime? currentPrayer;
  final PrayerTime? nextPrayer;
  final PrayerStatus currentStatus;
  final Duration? timeUntilNext;
  final Duration? timeSinceCurrent;
  final PrayerTimes prayerTimes;
  final bool isQiyamTime;
  final double dayCompletionRate;
  final IslamicPrayerContext? islamicContext;

  CurrentPrayerInfo copyWith({
    PrayerTime? currentPrayer,
    PrayerTime? nextPrayer,
    PrayerStatus? currentStatus,
    Duration? timeUntilNext,
    Duration? timeSinceCurrent,
    PrayerTimes? prayerTimes,
    bool? isQiyamTime,
    double? dayCompletionRate,
    IslamicPrayerContext? islamicContext,
  }) {
    return CurrentPrayerInfo(
      currentPrayer: currentPrayer ?? this.currentPrayer,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      currentStatus: currentStatus ?? this.currentStatus,
      timeUntilNext: timeUntilNext ?? this.timeUntilNext,
      timeSinceCurrent: timeSinceCurrent ?? this.timeSinceCurrent,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      isQiyamTime: isQiyamTime ?? this.isQiyamTime,
      dayCompletionRate: dayCompletionRate ?? this.dayCompletionRate,
      islamicContext: islamicContext ?? this.islamicContext,
    );
  }
}

/// Islamic context for prayer guidance
class IslamicPrayerContext {

  const IslamicPrayerContext({
    required this.statusMessage,
    required this.duaRecommendation,
    required this.islamicReminder,
    required this.qiblaDirection,
    required this.hijriDate,
    required this.isHolyDay,
    required this.recommendedActions,
  });
  final String statusMessage;
  final String duaRecommendation;
  final String islamicReminder;
  final double? qiblaDirection;
  final HijriCalendar hijriDate;
  final bool isHolyDay;
  final List<String> recommendedActions;
}
