import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prayer_tracking.dart';
import '../../domain/repositories/prayer_times_repository.dart';

/// Use case for tracking prayer completion with Islamic context
class TrackPrayerUsecase {

  const TrackPrayerUsecase(this.repository);
  final PrayerTimesRepository repository;

  /// Mark a prayer as completed
  Future<Either<Failure, PrayerTracking>> call(TrackPrayerParams params) async {
    // Validate input parameters
    final validationResult = await _validateTrackingParams(params);
    if (validationResult.isLeft()) {
      return validationResult.fold(Left.new, (_) => throw Exception());
    }

    // Create prayer tracking entry
    final prayerTracking = PrayerTracking(
      date: params.date,
      prayerName: params.prayerName,
      isCompleted: true,
      isOnTime: params.isOnTime,
      completedAt: params.completedAt ?? DateTime.now(),
      notes: params.notes,
      completionType: params.completionType,
    );

    // Save tracking information
    final saveResult = await repository.savePrayerTracking(prayerTracking);
    
    return saveResult.fold(
      Left.new,
      (_) async {
        // Update prayer statistics and streaks
        await _updatePrayerStatistics(prayerTracking);
        
        // Check for achievements (like prayer streaks)
        await _checkPrayerAchievements(prayerTracking);
        
        return Right(prayerTracking);
      },
    );
  }

  /// Validate prayer tracking parameters
  Future<Either<Failure, void>> _validateTrackingParams(TrackPrayerParams params) async {
    // Validate prayer name
    final validPrayerNames = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    if (!validPrayerNames.contains(params.prayerName.toLowerCase())) {
      return const Left(Failure.islamicValidationFailure(
        field: 'prayerName',
        message: 'Invalid prayer name. Must be one of the five daily prayers.',
        islamicReference: 'The five daily prayers are: Fajr, Dhuhr, Asr, Maghrib, and Isha',
      ),);
    }

    // Validate date (cannot be in future)
    if (params.date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return const Left(Failure.validationFailure(
        field: 'date',
        message: 'Cannot track prayers for future dates.',
      ),);
    }

    // Validate completion time if provided
    if (params.completedAt != null) {
      if (params.completedAt!.isAfter(DateTime.now())) {
        return const Left(Failure.validationFailure(
          field: 'completedAt',
          message: 'Prayer completion time cannot be in the future.',
        ),);
      }

      // Check if completion time is reasonable for the prayer
      if (params.completedAt!.isBefore(params.date.subtract(const Duration(days: 1)))) {
        return const Left(Failure.validationFailure(
          field: 'completedAt',
          message: 'Prayer completion time is too far in the past.',
        ),);
      }
    }

    return const Right(null);
  }

  /// Update prayer statistics after tracking
  Future<void> _updatePrayerStatistics(PrayerTracking tracking) async {
    try {
      // Get current month statistics
      final startOfMonth = DateTime(tracking.date.year, tracking.date.month);
      final endOfMonth = DateTime(tracking.date.year, tracking.date.month + 1, 0);
      
      final statisticsResult = await repository.getPrayerStatistics(
        fromDate: startOfMonth,
        toDate: endOfMonth,
      );

      statisticsResult.fold(
        (failure) => {
          // Log error but don't fail the tracking operation
        },
        (statistics) async {
          // Statistics are automatically updated when we save prayer tracking
          // This method can be used for additional processing if needed
        },
      );
    } catch (e) {
      // Statistics update shouldn't fail the main operation
    }
  }

  /// Check for prayer achievements and milestones
  Future<void> _checkPrayerAchievements(PrayerTracking tracking) async {
    try {
      // Get recent prayer history to check for streaks
      final historyResult = await repository.getPrayerTrackingHistory(
        startDate: tracking.date.subtract(const Duration(days: 30)),
        endDate: tracking.date,
      );

      historyResult.fold(
        (failure) => {
          // Log error but don't fail the operation
        },
        (history) {
          _processAchievements(history, tracking);
        },
      );
    } catch (e) {
      // Achievement processing shouldn't fail the main operation
    }
  }

  /// Process prayer achievements and streaks
  void _processAchievements(List<PrayerTracking> history, PrayerTracking newTracking) {
    // Calculate current streak
    final currentStreak = _calculateCurrentStreak(history);
    
    // Check for milestone achievements
    if (currentStreak == 7) {
      _triggerAchievement('7_day_streak', 'Completed prayers for 7 consecutive days! ماشاء الله');
    } else if (currentStreak == 30) {
      _triggerAchievement('30_day_streak', 'Completed prayers for 30 consecutive days! الحمد لله');
    } else if (currentStreak == 100) {
      _triggerAchievement('100_day_streak', 'Completed prayers for 100 consecutive days! سبحان الله');
    }

    // Check for perfect month
    final monthStart = DateTime(newTracking.date.year, newTracking.date.month);
    final monthEnd = DateTime(newTracking.date.year, newTracking.date.month + 1, 0);
    final monthHistory = history.where((p) => 
      p.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
      p.date.isBefore(monthEnd.add(const Duration(days: 1))),
    ).toList();

    if (_isMonthPerfect(monthHistory, monthStart, monthEnd)) {
      _triggerAchievement('perfect_month', 'Perfect prayer month completed! بارك الله فيك');
    }
  }

  /// Calculate current prayer streak
  int _calculateCurrentStreak(List<PrayerTracking> history) {
    // Sort history by date (newest first)
    history.sort((a, b) => b.date.compareTo(a.date));

    var streak = 0;
    final currentDate = DateTime.now();
    
    // Group prayers by date
    final prayersByDate = <String, List<PrayerTracking>>{};
    for (final prayer in history) {
      final dateKey = '${prayer.date.year}-${prayer.date.month}-${prayer.date.day}';
      prayersByDate[dateKey] = prayersByDate[dateKey] ?? [];
      prayersByDate[dateKey]!.add(prayer);
    }

    // Check each day backwards
    for (var i = 0; i < 365; i++) { // Maximum 1 year lookback
      final checkDate = currentDate.subtract(Duration(days: i));
      final dateKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
      
      final dayPrayers = prayersByDate[dateKey] ?? [];
      
      // Check if all 5 prayers were completed on this day
      if (_hasCompletedAllPrayers(dayPrayers)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Check if all 5 prayers were completed on a day
  bool _hasCompletedAllPrayers(List<PrayerTracking> dayPrayers) {
    final requiredPrayers = {'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'};
    final completedPrayers = dayPrayers
        .where((p) => p.isCompleted)
        .map((p) => p.prayerName.toLowerCase())
        .toSet();
    
    return requiredPrayers.every(completedPrayers.contains);
  }

  /// Check if a month has perfect prayer completion
  bool _isMonthPerfect(List<PrayerTracking> monthHistory, DateTime monthStart, DateTime monthEnd) {
    final daysInMonth = monthEnd.day;
    
    for (var day = 1; day <= daysInMonth; day++) {
      final checkDate = DateTime(monthStart.year, monthStart.month, day);
      final dayPrayers = monthHistory.where((p) => 
        p.date.year == checkDate.year &&
        p.date.month == checkDate.month &&
        p.date.day == checkDate.day,
      ).toList();
      
      if (!_hasCompletedAllPrayers(dayPrayers)) {
        return false;
      }
    }
    
    return true;
  }

  /// Trigger achievement notification
  void _triggerAchievement(String achievementId, String message) {
    // This would typically trigger a notification or update achievement storage
    // For now, we'll just log it
    print('Achievement unlocked: $achievementId - $message');
  }
}

/// Parameters for tracking prayer completion
class TrackPrayerParams {

  const TrackPrayerParams({
    required this.date,
    required this.prayerName,
    required this.isOnTime,
    this.completedAt,
    this.notes,
    this.completionType,
  });
  final DateTime date;
  final String prayerName;
  final bool isOnTime;
  final DateTime? completedAt;
  final String? notes;
  final PrayerCompletionType? completionType;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TrackPrayerParams &&
    runtimeType == other.runtimeType &&
    date == other.date &&
    prayerName == other.prayerName &&
    isOnTime == other.isOnTime &&
    completedAt == other.completedAt &&
    notes == other.notes &&
    completionType == other.completionType;

  @override
  int get hashCode =>
    date.hashCode ^
    prayerName.hashCode ^
    isOnTime.hashCode ^
    completedAt.hashCode ^
    notes.hashCode ^
    completionType.hashCode;
}
