import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/hive_boxes.dart' as boxes;

import '../../data/repo/quran_repository.dart';
import '../../data/dto/juz_dto.dart';

/// Service responsible for managing offline Quran content
/// Handles pre-loading, selective downloads, and offline availability checks
class OfflineContentService {
  OfflineContentService(this._quranRepo);
  final QuranRepository _quranRepo;

  /// Check what content is available offline
  Future<OfflineContentStatus> getOfflineStatus() async {
    final chaptersBox = await Hive.openBox(boxes.Boxes.chapters);
    final versesBox = await Hive.openBox(boxes.Boxes.verses);
    
    final hasChapters = chaptersBox.isNotEmpty;
    final totalVerses = versesBox.length;
    
    // Calculate rough offline coverage
    final estimatedTotalVerses = 6236; // Total verses in Quran
    final coverage = totalVerses / estimatedTotalVerses;
    
    return OfflineContentStatus(
      hasBasicContent: hasChapters,
      versesCached: totalVerses,
      estimatedCoverage: coverage,
      downloadedTranslations: await _getDownloadedTranslations(),
      downloadedTafsirs: await _getDownloadedTafsirs(),
    );
  }

  /// Pre-load essential content for offline use
  Future<void> preloadEssentialContent({
    List<int> translationIds = const [20], // Saheeh International by default
    List<int> priorityChapters = const [1, 2, 18, 36, 55, 67, 112, 113, 114], // Al-Fatiha, Al-Baqarah, Al-Kahf, Yasin, Ar-Rahman, Al-Mulk, Last 3 surahs
    Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.0, 'Starting essential content download...');
    
    // Step 1: Download all chapters (lightweight)
    onProgress?.call(0.1, 'Downloading chapter information...');
    await _quranRepo.getChapters(refresh: true);
    
    // Step 2: Download priority chapters with translations
    final totalSteps = priorityChapters.length;
    for (int i = 0; i < priorityChapters.length; i++) {
      final chapterId = priorityChapters[i];
      final progress = 0.1 + (0.8 * (i / totalSteps));
      
      onProgress?.call(progress, 'Downloading Surah $chapterId...');
      await _downloadFullChapter(chapterId, translationIds);
    }
    
    onProgress?.call(1.0, 'Essential content downloaded successfully!');
  }

  /// Download essential Quran text for offline use (background, no audio)
  /// This runs silently on app install and includes Arabic text + one translation
  Future<void> downloadEssentialQuranText() async {
    try {
      // Step 1: Download all chapters (lightweight)
      await _quranRepo.getChapters(refresh: true);
      
      // Step 2: Download most frequently read chapters with basic translation
      // Focus on chapters that users read most often
      final essentialChapters = [
        1,   // Al-Fatiha (The Opening)
        2,   // Al-Baqarah (The Cow) - First few pages
        18,  // Al-Kahf (The Cave) - Read on Fridays
        36,  // Yasin (Heart of Quran)
        55,  // Ar-Rahman (The Beneficent)
        67,  // Al-Mulk (The Dominion)
        112, // Al-Ikhlas (The Sincerity)
        113, // Al-Falaq (The Daybreak)
        114, // An-Nas (Mankind)
      ];
      
      // Use Saheeh International translation (ID: 131) as default
      const translationIds = [131];
      
      for (final chapterId in essentialChapters) {
        // For Al-Baqarah, only download first 3 pages to keep size manageable
        if (chapterId == 2) {
          for (int page = 1; page <= 3; page++) {
            await _quranRepo.getChapterPage(
              chapterId: chapterId,
              translationIds: translationIds,
              recitationId: 0, // No audio
              page: page,
              refresh: true,
            );
          }
        } else {
          // Download complete chapter for smaller surahs
          await _downloadFullChapter(chapterId, translationIds);
        }
      }
    } catch (e) {
      // Log error but don't throw - this is background download
      if (kDebugMode) {
        print('Error downloading essential Quran text: $e');
      }
    }
  }

  /// Download specific chapter completely for offline use
  Future<void> downloadChapter(int chapterId, List<int> translationIds) async {
    await _downloadFullChapter(chapterId, translationIds);
  }

  /// Download specific translation for all chapters
  Future<void> downloadTranslation(int translationId, {
    Function(double progress, String status)? onProgress,
  }) async {
    final chapters = await _quranRepo.getChapters();
    final totalChapters = chapters.length;
    
    for (int i = 0; i < chapters.length; i++) {
      final chapter = chapters[i];
      final progress = i / totalChapters;
      
      onProgress?.call(progress, 'Downloading ${chapter.nameSimple}...');
      await _downloadFullChapter(chapter.id, [translationId]);
    }
    
    onProgress?.call(1.0, 'Translation downloaded successfully!');
  }

  /// Remove downloaded content to free space
  Future<void> clearOfflineContent({bool keepEssential = true}) async {
    final versesBox = await Hive.openBox(boxes.Boxes.verses);
    
    if (keepEssential) {
      // Keep essential chapters
      final essentialChapters = [1, 2, 18, 36, 55, 67, 112, 113, 114];
      final keysToDelete = <String>[];
      
      for (final key in versesBox.keys) {
        final keyStr = key.toString();
        bool isEssential = false;
        
        for (final chapter in essentialChapters) {
          if (keyStr.startsWith('ch:$chapter|')) {
            isEssential = true;
            break;
          }
        }
        
        if (!isEssential) {
          keysToDelete.add(keyStr);
        }
      }
      
      for (final key in keysToDelete) {
        await versesBox.delete(key);
      }
    } else {
      await versesBox.clear();
    }
  }

  /// Check if specific content is available offline
  Future<bool> isChapterAvailableOffline(int chapterId, List<int> translationIds) async {
    final versesBox = await Hive.openBox(boxes.Boxes.verses);
    
    // Check if at least first page is cached with required translations
    final key = 'ch:$chapterId|t:${translationIds.join(',')}|r:7|p:1';
    return versesBox.containsKey(key);
  }

  /// Get storage usage statistics
  Future<OfflineStorageStats> getStorageStats() async {
    final chaptersBox = await Hive.openBox(boxes.Boxes.chapters);
    final versesBox = await Hive.openBox(boxes.Boxes.verses);
    
    return OfflineStorageStats(
      chaptersCount: chaptersBox.length,
      versesCount: versesBox.length,
      estimatedSizeMB: _estimateStorageSize(chaptersBox, versesBox),
    );
  }

  /// Cache Juz/Hizb mappings and metadata for offline navigation
  Future<void> cacheNavigationMappings() async {
    try {
      await _cacheJuzMappings();
      await _cacheHizbMappings();
      await _cachePageMappings();
      await _cacheRukuMappings();
    } catch (e) {
      if (kDebugMode) {
        print('Error caching navigation mappings: $e');
      }
    }
  }

  /// Check if navigation mappings are cached
  Future<bool> areNavigationMappingsCached() async {
    try {
      final juzBox = await Hive.openBox('juz_mappings');
      final hizbBox = await Hive.openBox('hizb_mappings');
      final pageBox = await Hive.openBox('page_mappings');
      final rukuBox = await Hive.openBox('ruku_mappings');
      
      return juzBox.isNotEmpty && hizbBox.isNotEmpty && 
             pageBox.isNotEmpty && rukuBox.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get cached Juz list
  Future<List<JuzDto>> getCachedJuzList() async {
    try {
      final juzBox = await Hive.openBox('juz_mappings');
      final List<JuzDto> juzList = [];
      
      for (final key in juzBox.keys) {
        final juzData = juzBox.get(key);
        if (juzData is Map) {
          juzList.add(JuzDto.fromJson(Map<String, dynamic>.from(juzData)));
        }
      }
      
      juzList.sort((a, b) => a.juzNumber.compareTo(b.juzNumber));
      return juzList;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached Juz list: $e');
      }
      return [];
    }
  }

  // Private methods

  Future<void> _downloadFullChapter(int chapterId, List<int> translationIds) async {
    // Get chapter info to know total verses
    final chapters = await _quranRepo.getChapters();
    final chapter = chapters.firstWhere((c) => c.id == chapterId);
    
    // Calculate total pages needed (50 verses per page)
    final totalPages = (chapter.versesCount / 50).ceil();
    
    // Download all pages
    for (int page = 1; page <= totalPages; page++) {
      await _quranRepo.getChapterPage(
        chapterId: chapterId,
        translationIds: translationIds,
        recitationId: 7,
        page: page,
        refresh: true,
      );
    }
  }

  Future<List<int>> _getDownloadedTranslations() async {
    final versesBox = await Hive.openBox(boxes.Boxes.verses);
    final translationIds = <int>{};
    
    for (final key in versesBox.keys) {
      final keyStr = key.toString();
      final match = RegExp(r't:(\d+(?:,\d+)*)').firstMatch(keyStr);
      if (match != null) {
        final ids = match.group(1)!.split(',').map(int.parse);
        translationIds.addAll(ids);
      }
    }
    
    return translationIds.toList();
  }

  Future<List<int>> _getDownloadedTafsirs() async {
    // TODO: Implement when tafsir caching is added
    return [];
  }

  double _estimateStorageSize(Box chaptersBox, Box versesBox) {
    // Rough estimation: each verse ~1KB, chapters ~10KB total
    final chaptersSize = chaptersBox.length * 0.01; // 10KB total / 114 chapters
    final versesSize = versesBox.length * 1.0; // 1KB per cached verse entry
    
    return chaptersSize + versesSize; // Return in MB
  }

  /// Cache Juz mappings for offline use
  Future<void> _cacheJuzMappings() async {
    try {
      final juzBox = await Hive.openBox('juz_mappings');
      
      // Static Juz data - 30 Juz with their starting chapters and verses
      final juzMappings = [
        {'id': 1, 'juz_number': 1, 'first_verse_id': 1, 'last_verse_id': 148, 'verse_mapping': {'1': [1, 7], '2': [1, 141]}},
        {'id': 2, 'juz_number': 2, 'first_verse_id': 149, 'last_verse_id': 259, 'verse_mapping': {'2': [142, 252]}},
        {'id': 3, 'juz_number': 3, 'first_verse_id': 260, 'last_verse_id': 385, 'verse_mapping': {'2': [253, 286], '3': [1, 92]}},
        {'id': 4, 'juz_number': 4, 'first_verse_id': 386, 'last_verse_id': 516, 'verse_mapping': {'3': [93, 200], '4': [1, 23]}},
        {'id': 5, 'juz_number': 5, 'first_verse_id': 517, 'last_verse_id': 640, 'verse_mapping': {'4': [24, 147]}},
        {'id': 6, 'juz_number': 6, 'first_verse_id': 641, 'last_verse_id': 750, 'verse_mapping': {'4': [148, 176], '5': [1, 81]}},
        {'id': 7, 'juz_number': 7, 'first_verse_id': 751, 'last_verse_id': 899, 'verse_mapping': {'5': [82, 120], '6': [1, 110]}},
        {'id': 8, 'juz_number': 8, 'first_verse_id': 900, 'last_verse_id': 1041, 'verse_mapping': {'6': [111, 165], '7': [1, 87]}},
        {'id': 9, 'juz_number': 9, 'first_verse_id': 1042, 'last_verse_id': 1200, 'verse_mapping': {'7': [88, 206], '8': [1, 40]}},
        {'id': 10, 'juz_number': 10, 'first_verse_id': 1201, 'last_verse_id': 1327, 'verse_mapping': {'8': [41, 75], '9': [1, 92]}},
        {'id': 11, 'juz_number': 11, 'first_verse_id': 1328, 'last_verse_id': 1478, 'verse_mapping': {'9': [93, 129], '10': [1, 109], '11': [1, 5]}},
        {'id': 12, 'juz_number': 12, 'first_verse_id': 1479, 'last_verse_id': 1648, 'verse_mapping': {'11': [6, 123], '12': [1, 52]}},
        {'id': 13, 'juz_number': 13, 'first_verse_id': 1649, 'last_verse_id': 1803, 'verse_mapping': {'12': [53, 111], '13': [1, 43], '14': [1, 52]}},
        {'id': 14, 'juz_number': 14, 'first_verse_id': 1804, 'last_verse_id': 1901, 'verse_mapping': {'15': [1, 99], '16': [1, 128]}},
        {'id': 15, 'juz_number': 15, 'first_verse_id': 1902, 'last_verse_id': 2029, 'verse_mapping': {'17': [1, 111], '18': [1, 74]}},
        {'id': 16, 'juz_number': 16, 'first_verse_id': 2030, 'last_verse_id': 2140, 'verse_mapping': {'18': [75, 110], '19': [1, 98], '20': [1, 135]}},
        {'id': 17, 'juz_number': 17, 'first_verse_id': 2141, 'last_verse_id': 2250, 'verse_mapping': {'21': [1, 112], '22': [1, 78]}},
        {'id': 18, 'juz_number': 18, 'first_verse_id': 2251, 'last_verse_id': 2348, 'verse_mapping': {'23': [1, 118], '24': [1, 20], '25': [1, 20]}},
        {'id': 19, 'juz_number': 19, 'first_verse_id': 2349, 'last_verse_id': 2483, 'verse_mapping': {'25': [21, 77], '26': [1, 227], '27': [1, 55]}},
        {'id': 20, 'juz_number': 20, 'first_verse_id': 2484, 'last_verse_id': 2595, 'verse_mapping': {'27': [56, 93], '28': [1, 88], '29': [1, 45]}},
        {'id': 21, 'juz_number': 21, 'first_verse_id': 2596, 'last_verse_id': 2705, 'verse_mapping': {'29': [46, 69], '30': [1, 60], '31': [1, 34], '32': [1, 30], '33': [1, 30]}},
        {'id': 22, 'juz_number': 22, 'first_verse_id': 2706, 'last_verse_id': 2800, 'verse_mapping': {'33': [31, 73], '34': [1, 54], '35': [1, 45], '36': [1, 21]}},
        {'id': 23, 'juz_number': 23, 'first_verse_id': 2801, 'last_verse_id': 2901, 'verse_mapping': {'36': [22, 83], '37': [1, 182], '38': [1, 88], '39': [1, 31]}},
        {'id': 24, 'juz_number': 24, 'first_verse_id': 2902, 'last_verse_id': 3014, 'verse_mapping': {'39': [32, 75], '40': [1, 85], '41': [1, 46]}},
        {'id': 25, 'juz_number': 25, 'first_verse_id': 3015, 'last_verse_id': 3159, 'verse_mapping': {'41': [47, 54], '42': [1, 53], '43': [1, 89], '44': [1, 59], '45': [1, 37]}},
        {'id': 26, 'juz_number': 26, 'first_verse_id': 3160, 'last_verse_id': 3252, 'verse_mapping': {'46': [1, 35], '47': [1, 38], '48': [1, 29], '49': [1, 18], '50': [1, 45], '51': [1, 30]}},
        {'id': 27, 'juz_number': 27, 'first_verse_id': 3253, 'last_verse_id': 3385, 'verse_mapping': {'51': [31, 60], '52': [1, 49], '53': [1, 62], '54': [1, 55], '55': [1, 78], '56': [1, 96], '57': [1, 29]}},
        {'id': 28, 'juz_number': 28, 'first_verse_id': 3386, 'last_verse_id': 4980, 'verse_mapping': {'58': [1, 22], '59': [1, 24], '60': [1, 13], '61': [1, 14], '62': [1, 11], '63': [1, 11], '64': [1, 18], '65': [1, 12], '66': [1, 12]}},
        {'id': 29, 'juz_number': 29, 'first_verse_id': 5555, 'last_verse_id': 6088, 'verse_mapping': {'67': [1, 30], '68': [1, 52], '69': [1, 52], '70': [1, 44], '71': [1, 28], '72': [1, 28], '73': [1, 20], '74': [1, 56], '75': [1, 40], '76': [1, 31], '77': [1, 50]}},
        {'id': 30, 'juz_number': 30, 'first_verse_id': 6089, 'last_verse_id': 6236, 'verse_mapping': {'78': [1, 40], '79': [1, 46], '80': [1, 42], '81': [1, 29], '82': [1, 19], '83': [1, 36], '84': [1, 25], '85': [1, 22], '86': [1, 17], '87': [1, 19], '88': [1, 26], '89': [1, 30], '90': [1, 20], '91': [1, 15], '92': [1, 21], '93': [1, 11], '94': [1, 8], '95': [1, 8], '96': [1, 19], '97': [1, 5], '98': [1, 8], '99': [1, 8], '100': [1, 11], '101': [1, 11], '102': [1, 8], '103': [1, 3], '104': [1, 9], '105': [1, 5], '106': [1, 4], '107': [1, 7], '108': [1, 3], '109': [1, 6], '110': [1, 3], '111': [1, 5], '112': [1, 4], '113': [1, 5], '114': [1, 6]}}
      ];
      
      for (final juzData in juzMappings) {
        await juzBox.put('juz_${juzData['juz_number']}', juzData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching Juz mappings: $e');
      }
    }
  }

  /// Cache Hizb mappings for offline use
  Future<void> _cacheHizbMappings() async {
    try {
      final hizbBox = await Hive.openBox('hizb_mappings');
      
      // Static Hizb data - 60 Hizb (2 per Juz)
      for (int juz = 1; juz <= 30; juz++) {
        for (int hizbInJuz = 1; hizbInJuz <= 2; hizbInJuz++) {
          final hizbNumber = (juz - 1) * 2 + hizbInJuz;
          final hizbData = {
            'id': hizbNumber,
            'hizb_number': hizbNumber,
            'juz_number': juz,
            'quarter_in_juz': hizbInJuz,
          };
          await hizbBox.put('hizb_$hizbNumber', hizbData);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching Hizb mappings: $e');
      }
    }
  }

  /// Cache Page mappings for offline use  
  Future<void> _cachePageMappings() async {
    try {
      final pageBox = await Hive.openBox('page_mappings');
      
      // Static Page data - 604 pages in the Mushaf
      for (int page = 1; page <= 604; page++) {
        final pageData = {
          'id': page,
          'page_number': page,
          'juz_number': ((page - 1) ~/ 20) + 1, // Rough approximation
        };
        await pageBox.put('page_$page', pageData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching Page mappings: $e');
      }
    }
  }

  /// Cache Ruku mappings for offline use
  Future<void> _cacheRukuMappings() async {
    try {
      final rukuBox = await Hive.openBox('ruku_mappings');
      
      // Static Ruku data - 558 Ruku sections in the Quran
      for (int ruku = 1; ruku <= 558; ruku++) {
        final rukuData = {
          'id': ruku,
          'ruku_number': ruku,
          'chapter_id': ((ruku - 1) ~/ 5) + 1, // Rough approximation - 5 rukus per chapter average
        };
        await rukuBox.put('ruku_$ruku', rukuData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching Ruku mappings: $e');
      }
    }
  }
}

/// Status of offline content availability
class OfflineContentStatus {
  const OfflineContentStatus({
    required this.hasBasicContent,
    required this.versesCached,
    required this.estimatedCoverage,
    required this.downloadedTranslations,
    required this.downloadedTafsirs,
  });

  final bool hasBasicContent;
  final int versesCached;
  final double estimatedCoverage; // 0.0 to 1.0
  final List<int> downloadedTranslations;
  final List<int> downloadedTafsirs;

  bool get isFullyOffline => estimatedCoverage > 0.95;
  bool get hasEssentialContent => versesCached > 500; // Rough estimate
}

/// Storage usage statistics
class OfflineStorageStats {
  const OfflineStorageStats({
    required this.chaptersCount,
    required this.versesCount,
    required this.estimatedSizeMB,
  });

  final int chaptersCount;
  final int versesCount;
  final double estimatedSizeMB;
}

// Providers will be moved to providers.dart to avoid circular imports
