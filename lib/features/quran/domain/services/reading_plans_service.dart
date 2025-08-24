import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/dto/chapter_dto.dart';
import '../../data/repo/quran_repository.dart';
import '../../../../core/storage/hive_boxes.dart' as boxes;

/// Service for managing Quran reading plans
/// Supports 30-day plans, Ramadan schedules, custom plans, and progress tracking
class ReadingPlansService {
  ReadingPlansService(this._quranRepo);
  
  final QuranRepository _quranRepo;
  final StreamController<List<ReadingPlan>> _plansController = StreamController<List<ReadingPlan>>.broadcast();
  final StreamController<ReadingProgress> _progressController = StreamController<ReadingProgress>.broadcast();

  Stream<List<ReadingPlan>> get plansStream => _plansController.stream;
  Stream<ReadingProgress> get progressStream => _progressController.stream;

  /// Create a 30-day Quran completion plan
  Future<ReadingPlan> create30DayPlan({
    String? name,
    DateTime? startDate,
    bool includeWeekends = true,
    List<int>? restDays, // Days of week to skip (1=Monday, 7=Sunday)
  }) async {
    final chapters = await _quranRepo.getChapters();
    final totalVerses = chapters.fold<int>(0, (sum, chapter) => sum + chapter.versesCount);
    
    final effectiveStartDate = startDate ?? DateTime.now();
    final planName = name ?? '30-Day Quran Plan';
    
    // Calculate verses per day considering rest days
    final activeDays = _calculateActiveDays(30, includeWeekends, restDays ?? []);
    final versesPerDay = (totalVerses / activeDays).ceil();
    
    final plan = ReadingPlan(
      id: _generateId(),
      name: planName,
      type: ReadingPlanType.thirtyDay,
      description: 'Complete the Quran in 30 days with $versesPerDay verses per day',
      totalDays: 30,
      versesPerDay: versesPerDay,
      startDate: effectiveStartDate,
      endDate: effectiveStartDate.add(const Duration(days: 29)),
      isActive: false,
      includeWeekends: includeWeekends,
      restDays: restDays ?? [],
      schedule: await _generateDailySchedule(
        chapters, 
        versesPerDay, 
        effectiveStartDate, 
        30,
        includeWeekends,
        restDays ?? [],
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _savePlan(plan);
    return plan;
  }

  /// Create a Ramadan reading plan (30 days)
  Future<ReadingPlan> createRamadanPlan({
    String? name,
    DateTime? ramadanStartDate,
    RamadanPlanType planType = RamadanPlanType.completeQuran,
  }) async {
    final chapters = await _quranRepo.getChapters();
    final effectiveStartDate = ramadanStartDate ?? _getNextRamadanDate();
    final planName = name ?? 'Ramadan ${DateTime.now().year} Plan';
    
    List<DailyReading> schedule;
    String description;
    int versesPerDay;

    switch (planType) {
      case RamadanPlanType.completeQuran:
        final totalVerses = chapters.fold<int>(0, (sum, chapter) => sum + chapter.versesCount);
        versesPerDay = (totalVerses / 30).ceil();
        description = 'Complete the Quran during Ramadan with $versesPerDay verses per day';
        schedule = await _generateDailySchedule(chapters, versesPerDay, effectiveStartDate, 30, true, []);
        break;
      
      case RamadanPlanType.essentialChapters:
        final essentialChapters = [1, 2, 3, 18, 36, 44, 55, 56, 67, 78, 112, 113, 114];
        final selectedChapters = chapters.where((c) => essentialChapters.contains(c.id)).toList();
        final totalVerses = selectedChapters.fold<int>(0, (sum, chapter) => sum + chapter.versesCount);
        versesPerDay = (totalVerses / 30).ceil();
        description = 'Read essential chapters during Ramadan';
        schedule = await _generateDailySchedule(selectedChapters, versesPerDay, effectiveStartDate, 30, true, []);
        break;
      
      case RamadanPlanType.shortChapters:
        final shortChapters = chapters.where((c) => c.versesCount <= 50).toList();
        versesPerDay = 2; // 2 short chapters per day
        description = 'Read shorter chapters during Ramadan for easy completion';
        schedule = await _generateShortChaptersSchedule(shortChapters, effectiveStartDate);
        break;
    }

    final plan = ReadingPlan(
      id: _generateId(),
      name: planName,
      type: ReadingPlanType.ramadan,
      description: description,
      totalDays: 30,
      versesPerDay: versesPerDay,
      startDate: effectiveStartDate,
      endDate: effectiveStartDate.add(const Duration(days: 29)),
      isActive: false,
      includeWeekends: true,
      restDays: [],
      schedule: schedule,
      metadata: {'ramadanPlanType': planType.toString()},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _savePlan(plan);
    return plan;
  }

  /// Create a custom reading plan
  Future<ReadingPlan> createCustomPlan({
    required String name,
    required int totalDays,
    required List<int> selectedChapterIds,
    DateTime? startDate,
    String? description,
    bool includeWeekends = true,
    List<int> restDays = const [],
  }) async {
    final chapters = await _quranRepo.getChapters();
    final selectedChapters = chapters.where((c) => selectedChapterIds.contains(c.id)).toList();
    final totalVerses = selectedChapters.fold<int>(0, (sum, chapter) => sum + chapter.versesCount);
    
    final effectiveStartDate = startDate ?? DateTime.now();
    final activeDays = _calculateActiveDays(totalDays, includeWeekends, restDays);
    final versesPerDay = (totalVerses / activeDays).ceil();
    
    final plan = ReadingPlan(
      id: _generateId(),
      name: name,
      type: ReadingPlanType.custom,
      description: description ?? 'Custom reading plan with ${selectedChapters.length} chapters',
      totalDays: totalDays,
      versesPerDay: versesPerDay,
      startDate: effectiveStartDate,
      endDate: effectiveStartDate.add(Duration(days: totalDays - 1)),
      isActive: false,
      includeWeekends: includeWeekends,
      restDays: restDays,
      schedule: await _generateDailySchedule(
        selectedChapters, 
        versesPerDay, 
        effectiveStartDate, 
        totalDays,
        includeWeekends,
        restDays,
      ),
      metadata: {'selectedChapterIds': selectedChapterIds},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _savePlan(plan);
    return plan;
  }

  /// Start a reading plan
  Future<void> startPlan(String planId) async {
    final plans = await getAllPlans();
    
    // Deactivate other plans
    for (int i = 0; i < plans.length; i++) {
      if (plans[i].isActive) {
        plans[i] = plans[i].copyWith(isActive: false);
      }
      if (plans[i].id == planId) {
        plans[i] = plans[i].copyWith(
          isActive: true,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: plans[i].totalDays - 1)),
        );
      }
    }
    
    await _savePlans(plans);
    await _initializeProgress(planId);
    
    if (kDebugMode) {
      print('Reading plan started: $planId');
    }
  }

  /// Stop/pause a reading plan
  Future<void> stopPlan(String planId) async {
    final plans = await getAllPlans();
    
    for (int i = 0; i < plans.length; i++) {
      if (plans[i].id == planId) {
        plans[i] = plans[i].copyWith(isActive: false);
        break;
      }
    }
    
    await _savePlans(plans);
    
    if (kDebugMode) {
      print('Reading plan stopped: $planId');
    }
  }

  /// Mark a day's reading as completed
  Future<void> markDayCompleted(String planId, int dayNumber, {
    List<String> completedVerses = const [],
    Duration? readingTime,
    String? notes,
  }) async {
    final progress = await getProgress(planId);
    if (progress == null) return;

    final dayProgress = DayProgress(
      dayNumber: dayNumber,
      isCompleted: true,
      completedAt: DateTime.now(),
      completedVerses: completedVerses,
      readingTime: readingTime,
      notes: notes,
    );

    final updatedDayProgress = Map<int, DayProgress>.from(progress.dayProgress);
    updatedDayProgress[dayNumber] = dayProgress;

    final updatedProgress = progress.copyWith(
      dayProgress: updatedDayProgress,
      lastReadDate: DateTime.now(),
      totalReadingTime: (progress.totalReadingTime ?? Duration.zero) + (readingTime ?? Duration.zero),
    );

    await _saveProgress(updatedProgress);
    
    if (kDebugMode) {
      print('Day $dayNumber marked completed for plan: $planId');
    }
  }

  /// Get today's reading for active plan
  Future<DailyReading?> getTodaysReading() async {
    final activePlan = await getActivePlan();
    if (activePlan == null) return null;

    final daysSinceStart = DateTime.now().difference(activePlan.startDate).inDays + 1;
    if (daysSinceStart <= 0 || daysSinceStart > activePlan.totalDays) return null;

    // Check if today is a rest day
    final today = DateTime.now().weekday;
    if (activePlan.restDays.contains(today)) return null;

    return activePlan.schedule.firstWhere(
      (reading) => reading.dayNumber == daysSinceStart,
      orElse: () => activePlan.schedule.first,
    );
  }

  /// Get reading for specific day
  Future<DailyReading?> getReadingForDay(String planId, int dayNumber) async {
    final plan = await getPlan(planId);
    if (plan == null) return null;

    try {
      return plan.schedule.firstWhere((reading) => reading.dayNumber == dayNumber);
    } catch (e) {
      return null;
    }
  }

  /// Get active reading plan
  Future<ReadingPlan?> getActivePlan() async {
    final plans = await getAllPlans();
    try {
      return plans.firstWhere((plan) => plan.isActive);
    } catch (e) {
      return null;
    }
  }

  /// Get specific reading plan
  Future<ReadingPlan?> getPlan(String planId) async {
    final plans = await getAllPlans();
    try {
      return plans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  /// Get all reading plans
  Future<List<ReadingPlan>> getAllPlans() async {
    try {
      final box = await Hive.openBox(boxes.Boxes.readingPlans);
      final data = box.get('plans', defaultValue: <Map>[]) as List;
      
      return data
          .map((item) => ReadingPlan.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting reading plans: $e');
      }
      return [];
    }
  }

  /// Get reading progress for a plan
  Future<ReadingProgress?> getProgress(String planId) async {
    try {
      final box = await Hive.openBox(boxes.Boxes.readingPlans);
      final data = box.get('progress_$planId') as Map?;
      
      if (data != null) {
        return ReadingProgress.fromMap(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting reading progress: $e');
      }
      return null;
    }
  }

  /// Get reading statistics
  Future<ReadingStats> getReadingStats() async {
    final plans = await getAllPlans();
    final activePlan = await getActivePlan();
    
    int totalPlans = plans.length;
    int completedPlans = 0;
    Duration totalReadingTime = Duration.zero;
    int totalDaysRead = 0;
    int currentStreak = 0;
    int longestStreak = 0;

    for (final plan in plans) {
      final progress = await getProgress(plan.id);
      if (progress != null) {
        if (progress.isCompleted) {
          completedPlans++;
        }
        
        totalReadingTime += progress.totalReadingTime ?? Duration.zero;
        totalDaysRead += progress.dayProgress.length;
        
        // Calculate streaks
        final streaks = _calculateStreaks(progress.dayProgress);
        if (streaks.isNotEmpty) {
          longestStreak = max(longestStreak, streaks.reduce(max));
          if (plan.isActive) {
            currentStreak = _calculateCurrentStreak(progress.dayProgress);
          }
        }
      }
    }

    return ReadingStats(
      totalPlans: totalPlans,
      completedPlans: completedPlans,
      activePlans: plans.where((p) => p.isActive).length,
      totalReadingTime: totalReadingTime,
      totalDaysRead: totalDaysRead,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      averageReadingTime: totalDaysRead > 0 
        ? Duration(milliseconds: totalReadingTime.inMilliseconds ~/ totalDaysRead)
        : Duration.zero,
      activePlan: activePlan,
    );
  }

  /// Delete a reading plan
  Future<void> deletePlan(String planId) async {
    final plans = await getAllPlans();
    plans.removeWhere((plan) => plan.id == planId);
    await _savePlans(plans);
    
    // Delete progress
    final box = await Hive.openBox(boxes.Boxes.readingPlans);
    await box.delete('progress_$planId');
    
    if (kDebugMode) {
      print('Reading plan deleted: $planId');
    }
  }

  // Private methods

  Future<void> _savePlan(ReadingPlan plan) async {
    final plans = await getAllPlans();
    final existingIndex = plans.indexWhere((p) => p.id == plan.id);
    
    if (existingIndex != -1) {
      plans[existingIndex] = plan;
    } else {
      plans.add(plan);
    }
    
    await _savePlans(plans);
    _plansController.add(plans);
  }

  Future<void> _savePlans(List<ReadingPlan> plans) async {
    final box = await Hive.openBox(boxes.Boxes.readingPlans);
    await box.put('plans', plans.map((p) => p.toMap()).toList());
  }

  Future<void> _saveProgress(ReadingProgress progress) async {
    final box = await Hive.openBox(boxes.Boxes.readingPlans);
    await box.put('progress_${progress.planId}', progress.toMap());
    _progressController.add(progress);
  }

  Future<void> _initializeProgress(String planId) async {
    final progress = ReadingProgress(
      planId: planId,
      startDate: DateTime.now(),
      dayProgress: {},
      isCompleted: false,
      lastReadDate: null,
      totalReadingTime: Duration.zero,
    );
    
    await _saveProgress(progress);
  }

  Future<List<DailyReading>> _generateDailySchedule(
    List<ChapterDto> chapters,
    int versesPerDay,
    DateTime startDate,
    int totalDays,
    bool includeWeekends,
    List<int> restDays,
  ) async {
    final schedule = <DailyReading>[];
    int currentVerseIndex = 0;
    int totalVerses = chapters.fold<int>(0, (sum, chapter) => sum + chapter.versesCount);
    
    // Create verse mapping
    final verseMapping = <VerseMapping>[];
    for (final chapter in chapters) {
      for (int verse = 1; verse <= chapter.versesCount; verse++) {
        verseMapping.add(VerseMapping(
          chapterId: chapter.id,
          chapterName: chapter.nameSimple,
          verseNumber: verse,
          globalIndex: verseMapping.length,
        ));
      }
    }

    int dayNumber = 1;
    DateTime currentDate = startDate;
    
    while (dayNumber <= totalDays && currentVerseIndex < totalVerses) {
      // Skip rest days
      if (restDays.contains(currentDate.weekday)) {
        currentDate = currentDate.add(const Duration(days: 1));
        continue;
      }

      final dailyVerses = <VerseRange>[];
      int versesForToday = min(versesPerDay, totalVerses - currentVerseIndex);
      
      while (versesForToday > 0 && currentVerseIndex < totalVerses) {
        final currentMapping = verseMapping[currentVerseIndex];
        final chapterId = currentMapping.chapterId;
        final startVerse = currentMapping.verseNumber;
        
        // Find consecutive verses in the same chapter
        int endVerse = startVerse;
        int versesInThisChapter = 1;
        
        while (versesInThisChapter < versesForToday && 
               currentVerseIndex + versesInThisChapter < totalVerses) {
          final nextMapping = verseMapping[currentVerseIndex + versesInThisChapter];
          if (nextMapping.chapterId != chapterId) break;
          
          endVerse = nextMapping.verseNumber;
          versesInThisChapter++;
        }
        
        dailyVerses.add(VerseRange(
          chapterId: chapterId,
          chapterName: currentMapping.chapterName,
          startVerse: startVerse,
          endVerse: endVerse,
          verseCount: versesInThisChapter,
        ));
        
        currentVerseIndex += versesInThisChapter;
        versesForToday -= versesInThisChapter;
      }

      schedule.add(DailyReading(
        dayNumber: dayNumber,
        date: currentDate,
        verseRanges: dailyVerses,
        estimatedReadingTime: _estimateReadingTime(dailyVerses),
        isRestDay: false,
      ));

      dayNumber++;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return schedule;
  }

  Future<List<DailyReading>> _generateShortChaptersSchedule(
    List<ChapterDto> shortChapters,
    DateTime startDate,
  ) async {
    final schedule = <DailyReading>[];
    int chapterIndex = 0;
    
    for (int day = 1; day <= 30; day++) {
      final date = startDate.add(Duration(days: day - 1));
      final dailyVerses = <VerseRange>[];
      
      // Add 2 short chapters per day
      for (int i = 0; i < 2 && chapterIndex < shortChapters.length; i++) {
        final chapter = shortChapters[chapterIndex];
        dailyVerses.add(VerseRange(
          chapterId: chapter.id,
          chapterName: chapter.nameSimple,
          startVerse: 1,
          endVerse: chapter.versesCount,
          verseCount: chapter.versesCount,
        ));
        chapterIndex++;
      }
      
      schedule.add(DailyReading(
        dayNumber: day,
        date: date,
        verseRanges: dailyVerses,
        estimatedReadingTime: _estimateReadingTime(dailyVerses),
        isRestDay: false,
      ));
    }
    
    return schedule;
  }

  int _calculateActiveDays(int totalDays, bool includeWeekends, List<int> restDays) {
    if (includeWeekends && restDays.isEmpty) {
      return totalDays;
    }
    
    int activeDays = 0;
    DateTime current = DateTime.now();
    
    for (int i = 0; i < totalDays; i++) {
      if (!restDays.contains(current.weekday)) {
        activeDays++;
      }
      current = current.add(const Duration(days: 1));
    }
    
    return activeDays;
  }

  Duration _estimateReadingTime(List<VerseRange> verses) {
    // Estimate 15 seconds per verse on average
    final totalVerses = verses.fold<int>(0, (sum, range) => sum + range.verseCount);
    return Duration(seconds: totalVerses * 15);
  }

  List<int> _calculateStreaks(Map<int, DayProgress> dayProgress) {
    if (dayProgress.isEmpty) return [];
    
    final sortedDays = dayProgress.keys.toList()..sort();
    final streaks = <int>[];
    int currentStreak = 0;
    
    for (int i = 0; i < sortedDays.length; i++) {
      if (dayProgress[sortedDays[i]]?.isCompleted == true) {
        currentStreak++;
      } else {
        if (currentStreak > 0) {
          streaks.add(currentStreak);
          currentStreak = 0;
        }
      }
    }
    
    if (currentStreak > 0) {
      streaks.add(currentStreak);
    }
    
    return streaks;
  }

  int _calculateCurrentStreak(Map<int, DayProgress> dayProgress) {
    if (dayProgress.isEmpty) return 0;
    
    final sortedDays = dayProgress.keys.toList()..sort((a, b) => b.compareTo(a));
    int streak = 0;
    
    for (final day in sortedDays) {
      if (dayProgress[day]?.isCompleted == true) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  DateTime _getNextRamadanDate() {
    // This is a simplified calculation - in real app, use proper Islamic calendar
    final now = DateTime.now();
    final currentYear = now.year;
    
    // Approximate Ramadan dates (would need proper Islamic calendar calculation)
    final ramadanDates = {
      2024: DateTime(2024, 3, 11),
      2025: DateTime(2025, 2, 28),
      2026: DateTime(2026, 2, 18),
    };
    
    final thisYearRamadan = ramadanDates[currentYear];
    if (thisYearRamadan != null && thisYearRamadan.isAfter(now)) {
      return thisYearRamadan;
    }
    
    return ramadanDates[currentYear + 1] ?? DateTime(currentYear + 1, 3, 1);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void dispose() {
    _plansController.close();
    _progressController.close();
  }
}

// Data classes

enum ReadingPlanType {
  thirtyDay,
  ramadan,
  custom,
}

enum RamadanPlanType {
  completeQuran,
  essentialChapters,
  shortChapters,
}

class ReadingPlan {
  const ReadingPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.totalDays,
    required this.versesPerDay,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.includeWeekends,
    required this.restDays,
    required this.schedule,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  final String id;
  final String name;
  final ReadingPlanType type;
  final String description;
  final int totalDays;
  final int versesPerDay;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool includeWeekends;
  final List<int> restDays;
  final List<DailyReading> schedule;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReadingPlan copyWith({
    String? id,
    String? name,
    ReadingPlanType? type,
    String? description,
    int? totalDays,
    int? versesPerDay,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? includeWeekends,
    List<int>? restDays,
    List<DailyReading>? schedule,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReadingPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      totalDays: totalDays ?? this.totalDays,
      versesPerDay: versesPerDay ?? this.versesPerDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      includeWeekends: includeWeekends ?? this.includeWeekends,
      restDays: restDays ?? this.restDays,
      schedule: schedule ?? this.schedule,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'description': description,
      'totalDays': totalDays,
      'versesPerDay': versesPerDay,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'isActive': isActive,
      'includeWeekends': includeWeekends,
      'restDays': restDays,
      'schedule': schedule.map((s) => s.toMap()).toList(),
      'metadata': metadata,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ReadingPlan.fromMap(Map<String, dynamic> map) {
    return ReadingPlan(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: ReadingPlanType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => ReadingPlanType.custom,
      ),
      description: map['description'] ?? '',
      totalDays: map['totalDays'] ?? 0,
      versesPerDay: map['versesPerDay'] ?? 0,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? 0),
      isActive: map['isActive'] ?? false,
      includeWeekends: map['includeWeekends'] ?? true,
      restDays: List<int>.from(map['restDays'] ?? []),
      schedule: (map['schedule'] as List? ?? [])
          .map((s) => DailyReading.fromMap(Map<String, dynamic>.from(s)))
          .toList(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }
}

class DailyReading {
  const DailyReading({
    required this.dayNumber,
    required this.date,
    required this.verseRanges,
    required this.estimatedReadingTime,
    required this.isRestDay,
  });

  final int dayNumber;
  final DateTime date;
  final List<VerseRange> verseRanges;
  final Duration estimatedReadingTime;
  final bool isRestDay;

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'date': date.millisecondsSinceEpoch,
      'verseRanges': verseRanges.map((v) => v.toMap()).toList(),
      'estimatedReadingTime': estimatedReadingTime.inMilliseconds,
      'isRestDay': isRestDay,
    };
  }

  factory DailyReading.fromMap(Map<String, dynamic> map) {
    return DailyReading(
      dayNumber: map['dayNumber'] ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      verseRanges: (map['verseRanges'] as List? ?? [])
          .map((v) => VerseRange.fromMap(Map<String, dynamic>.from(v)))
          .toList(),
      estimatedReadingTime: Duration(milliseconds: map['estimatedReadingTime'] ?? 0),
      isRestDay: map['isRestDay'] ?? false,
    );
  }
}

class VerseRange {
  const VerseRange({
    required this.chapterId,
    required this.chapterName,
    required this.startVerse,
    required this.endVerse,
    required this.verseCount,
  });

  final int chapterId;
  final String chapterName;
  final int startVerse;
  final int endVerse;
  final int verseCount;

  String get displayText {
    if (startVerse == endVerse) {
      return '$chapterName $startVerse';
    }
    return '$chapterName $startVerse-$endVerse';
  }

  Map<String, dynamic> toMap() {
    return {
      'chapterId': chapterId,
      'chapterName': chapterName,
      'startVerse': startVerse,
      'endVerse': endVerse,
      'verseCount': verseCount,
    };
  }

  factory VerseRange.fromMap(Map<String, dynamic> map) {
    return VerseRange(
      chapterId: map['chapterId'] ?? 0,
      chapterName: map['chapterName'] ?? '',
      startVerse: map['startVerse'] ?? 0,
      endVerse: map['endVerse'] ?? 0,
      verseCount: map['verseCount'] ?? 0,
    );
  }
}

class ReadingProgress {
  const ReadingProgress({
    required this.planId,
    required this.startDate,
    required this.dayProgress,
    required this.isCompleted,
    this.lastReadDate,
    this.totalReadingTime,
  });

  final String planId;
  final DateTime startDate;
  final Map<int, DayProgress> dayProgress;
  final bool isCompleted;
  final DateTime? lastReadDate;
  final Duration? totalReadingTime;

  double get completionPercentage {
    if (dayProgress.isEmpty) return 0.0;
    final completedDays = dayProgress.values.where((d) => d.isCompleted).length;
    return completedDays / dayProgress.length;
  }

  ReadingProgress copyWith({
    String? planId,
    DateTime? startDate,
    Map<int, DayProgress>? dayProgress,
    bool? isCompleted,
    DateTime? lastReadDate,
    Duration? totalReadingTime,
  }) {
    return ReadingProgress(
      planId: planId ?? this.planId,
      startDate: startDate ?? this.startDate,
      dayProgress: dayProgress ?? this.dayProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'startDate': startDate.millisecondsSinceEpoch,
      'dayProgress': dayProgress.map((k, v) => MapEntry(k.toString(), v.toMap())),
      'isCompleted': isCompleted,
      'lastReadDate': lastReadDate?.millisecondsSinceEpoch,
      'totalReadingTime': totalReadingTime?.inMilliseconds,
    };
  }

  factory ReadingProgress.fromMap(Map<String, dynamic> map) {
    final dayProgressMap = <int, DayProgress>{};
    final dayProgressData = map['dayProgress'] as Map? ?? {};
    
    for (final entry in dayProgressData.entries) {
      final day = int.tryParse(entry.key.toString());
      if (day != null) {
        dayProgressMap[day] = DayProgress.fromMap(Map<String, dynamic>.from(entry.value));
      }
    }

    return ReadingProgress(
      planId: map['planId'] ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      dayProgress: dayProgressMap,
      isCompleted: map['isCompleted'] ?? false,
      lastReadDate: map['lastReadDate'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['lastReadDate'])
        : null,
      totalReadingTime: map['totalReadingTime'] != null 
        ? Duration(milliseconds: map['totalReadingTime'])
        : null,
    );
  }
}

class DayProgress {
  const DayProgress({
    required this.dayNumber,
    required this.isCompleted,
    this.completedAt,
    this.completedVerses = const [],
    this.readingTime,
    this.notes,
  });

  final int dayNumber;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<String> completedVerses;
  final Duration? readingTime;
  final String? notes;

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'completedVerses': completedVerses,
      'readingTime': readingTime?.inMilliseconds,
      'notes': notes,
    };
  }

  factory DayProgress.fromMap(Map<String, dynamic> map) {
    return DayProgress(
      dayNumber: map['dayNumber'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
        : null,
      completedVerses: List<String>.from(map['completedVerses'] ?? []),
      readingTime: map['readingTime'] != null 
        ? Duration(milliseconds: map['readingTime'])
        : null,
      notes: map['notes'],
    );
  }
}

class ReadingStats {
  const ReadingStats({
    required this.totalPlans,
    required this.completedPlans,
    required this.activePlans,
    required this.totalReadingTime,
    required this.totalDaysRead,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageReadingTime,
    this.activePlan,
  });

  final int totalPlans;
  final int completedPlans;
  final int activePlans;
  final Duration totalReadingTime;
  final int totalDaysRead;
  final int currentStreak;
  final int longestStreak;
  final Duration averageReadingTime;
  final ReadingPlan? activePlan;
}

class VerseMapping {
  const VerseMapping({
    required this.chapterId,
    required this.chapterName,
    required this.verseNumber,
    required this.globalIndex,
  });

  final int chapterId;
  final String chapterName;
  final int verseNumber;
  final int globalIndex;
}
