import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/net/dio_client.dart';
import '../../../../core/storage/hive_boxes.dart' as boxes;
import '../../domain/services/audio_service.dart';
import '../../domain/services/offline_content_service.dart';
import '../../domain/services/bookmarks_service.dart';
import '../../domain/services/search_service.dart';
import '../../data/api/chapters_api.dart';
import '../../data/api/verses_api.dart';
import '../../data/api/resources_api.dart';
import '../../data/repo/quran_repository.dart';
import '../../data/dto/chapter_dto.dart';
import '../../data/dto/verse_dto.dart';
import '../../data/dto/verses_page_dto.dart';
import '../../data/dto/translation_resource_dto.dart';
import '../../data/dto/recitation_resource_dto.dart';
import '../../data/dto/tafsir_dto.dart';
import '../../data/dto/juz_dto.dart';
import '../../data/dto/word_analysis_dto.dart';
import '../../data/dto/audio_download_dto.dart';
import '../../data/dto/note_dto.dart';
import '../../data/dto/download_dto.dart';

final dioQfProvider = Provider((ref) => ref.watch(dioProvider));
final chaptersApiProvider =
    Provider((ref) => ChaptersApi(ref.watch(dioQfProvider)));
final versesApiProvider =
    Provider((ref) => VersesApi(ref.watch(dioQfProvider)));
final resourcesApiProvider =
    Provider((ref) => ResourcesApi(ref.watch(dioQfProvider)));
final quranRepoProvider = Provider((ref) => QuranRepository(
      ref.watch(chaptersApiProvider),
      ref.watch(versesApiProvider),
      ref.watch(resourcesApiProvider),
      Hive,
    ));



// Audio service providers
final quranAudioServiceProvider = Provider<QuranAudioService>((ref) {
  final dio = ref.watch(dioQfProvider);
  final service = QuranAudioService(dio);
  
  // Initialize the service
  service.initialize();
  
  return service;
});

// Override the providers from audio_service.dart
final audioStateProvider = StreamProvider<AudioState>((ref) {
  final service = ref.watch(quranAudioServiceProvider);
  return service.stateStream;
});

final audioPositionProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(quranAudioServiceProvider);
  return service.positionStream;
});

final audioDurationProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(quranAudioServiceProvider);
  return service.durationStream;
});

final audioDownloadProgressProvider = StreamProvider<AudioDownloadProgress>((ref) {
  final service = ref.watch(quranAudioServiceProvider);
  return service.downloadStream;
});

final audioStorageStatsProvider = FutureProvider<AudioStorageStats>((ref) async {
  final service = ref.watch(quranAudioServiceProvider);
  return service.getStorageStats();
});

// Offline content service provider (configured properly)
final offlineContentServiceProvider = Provider<OfflineContentService>((ref) {
  final quranRepo = ref.watch(quranRepoProvider);
  return OfflineContentService(quranRepo);
});

final offlineContentStatusProvider = FutureProvider<OfflineContentStatus>((ref) async {
  final service = ref.watch(offlineContentServiceProvider);
  return service.getOfflineStatus();
});

final offlineStorageStatsProvider = FutureProvider<OfflineStorageStats>((ref) async {
  final service = ref.watch(offlineContentServiceProvider);
  return service.getStorageStats();
});

// Background Quran text download provider (auto-initializes on app start)
final quranBackgroundDownloadProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(offlineContentServiceProvider);
  final prefs = await SharedPreferences.getInstance();
  
  // Check if initial download has been completed
  final hasDownloadedBasicQuran = prefs.getBool('quran_basic_downloaded') ?? false;
  
  if (!hasDownloadedBasicQuran) {
    try {
      // Download essential Quran content in background (without audio)
      // This includes Arabic text + one translation for most important surahs
      await service.downloadEssentialQuranText();
      
      // Mark as completed
      await prefs.setBool('quran_basic_downloaded', true);
      
      if (kDebugMode) {
        print('Background Quran text download completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Background Quran text download failed: $e');
      }
      // Don't rethrow - let the app continue functioning normally
    }
  }
});

final surahListProvider =
    FutureProvider.autoDispose<List<ChapterDto>>((ref) async {
  final repo = ref.read(quranRepoProvider);
  return repo.getChapters();
});

// -------------------- Last Read --------------------
class LastReadEntry {
  LastReadEntry({
    required this.chapterId,
    required this.verseKey,
    this.scrollOffset,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
  final int chapterId;
  final String verseKey; // e.g., "2:255"
  final double? scrollOffset; // optional pixel offset for precise resume
  final DateTime? updatedAt;
  Map<String, dynamic> toMap() => {
        'chapterId': chapterId,
        'verseKey': verseKey,
        if (scrollOffset != null) 'scrollOffset': scrollOffset,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
  static LastReadEntry? from(dynamic v) {
    if (v is Map) {
      final m = Map<String, dynamic>.from(v);
      return LastReadEntry(
        chapterId: (m['chapterId'] ?? 0) as int,
        verseKey: (m['verseKey'] ?? '') as String,
        scrollOffset: (m['scrollOffset'] is num)
            ? (m['scrollOffset'] as num).toDouble()
            : null,
        updatedAt: m['updatedAt'] is String
            ? DateTime.tryParse(m['updatedAt'] as String)
            : null,
      );
    }
    return null;
  }
}

final _lastReadBoxProvider = FutureProvider<Box>((_) async {
  await Hive.initFlutter();
  return Hive.openBox('quran_last_read');
});

final lastReadProvider = StreamProvider<LastReadEntry?>((ref) async* {
  final box = await ref.watch(_lastReadBoxProvider.future);

  // Initial value
  final raw = box.get('entry');
  yield LastReadEntry.from(raw);

  // Listen for changes
  await for (final _ in box.watch(key: 'entry')) {
    final updatedRaw = box.get('entry');
    yield LastReadEntry.from(updatedRaw);
  }
});

final lastReadUpdaterProvider =
    Provider<Future<void> Function(LastReadEntry)>((ref) {
  return (entry) async {
    print(
        'LastReadUpdater: Saving entry - Chapter: ${entry.chapterId}, Verse: ${entry.verseKey}');
    final box = await ref.read(_lastReadBoxProvider.future);
    await box.put('entry', entry.toMap());
    print('LastReadUpdater: Entry saved to Hive successfully');
    // The StreamProvider will automatically emit the new value
  };
});

// -------------------- Unified Bookmarks (Service-based) --------------------
// Legacy key-based providers removed - now using BookmarksService only

// Stream of verse keys that are bookmarked (for compatibility with existing widgets)
final bookmarksProvider = StreamProvider<Set<String>>((ref) async* {
  final service = ref.watch(bookmarksServiceProvider);
  final stream = service.bookmarksStream;
  
  await for (final bookmarks in stream) {
    final verseKeys = bookmarks.map((b) => b.verseKey).toSet();
    yield verseKeys;
  }
});

// Toggle bookmark function (delegates to service)
final bookmarkTogglerProvider = Provider<Future<void> Function(String)>((ref) {
  final service = ref.read(bookmarksServiceProvider);
  return (verseKey) async {
    final isBookmarked = await service.isBookmarked(verseKey);
    if (isBookmarked) {
      await service.removeBookmark(verseKey);
    } else {
      // Derive chapter info from verseKey for new bookmarks
      final parts = verseKey.split(':');
      final chapterId = int.tryParse(parts.first) ?? 1;
      final verseNumber = int.tryParse(parts.last) ?? 1;
      await service.addBookmark(
        verseKey: verseKey,
        chapterId: chapterId,
        verseNumber: verseNumber,
      );
    }
  };
});

// -------------------- Chapter Bookmarks --------------------
final _chapterBookmarksBoxProvider = FutureProvider<Box>((_) async {
  await Hive.initFlutter();
  return Hive.openBox('quran_bookmarks_chapters');
});

final chapterBookmarksProvider = StreamProvider<Set<int>>((ref) async* {
  final box = await ref.watch(_chapterBookmarksBoxProvider.future);
  Set<int> read() => (box.get('keys', defaultValue: <int>[]) as List)
      .map((e) => int.tryParse(e.toString()) ?? 0)
      .where((e) => e > 0)
      .toSet();
  yield read();
  await for (final _ in box.watch()) {
    yield read();
  }
});

final chapterBookmarkTogglerProvider =
    Provider<Future<void> Function(int)>((ref) {
  return (chapterId) async {
    final box = await ref.read(_chapterBookmarksBoxProvider.future);
    final list = (box.get('keys', defaultValue: <int>[]) as List).toSet();
    if (list.contains(chapterId)) {
      list.remove(chapterId);
    } else {
      list.add(chapterId);
    }
    await box.put('keys', list.toList());
  };
});

// -------------------- Audio Controller --------------------
class QuranAudioState {
  const QuranAudioState({required this.isPlaying, this.currentIndex});
  final bool isPlaying;
  final int? currentIndex;
}

class QuranAudioController extends StateNotifier<QuranAudioState> {
  QuranAudioController(this._ref)
      : super(const QuranAudioState(isPlaying: false));
  final Ref _ref;
  final AudioPlayer _player = AudioPlayer();
  List<String> _urls = const [];

  void setPlaylist(List<String> urls) {
    _urls = urls
        .map((u) => u.trim())
        .map((u) => u.isEmpty
            ? ''
            : (u.startsWith('http') ? u : 'https://audio.qurancdn.com/$u'))
        .toList();
  }

  Future<void> playIndex(int index) async {
    if (index < 0 || index >= _urls.length) return;
    final url = _urls[index];
    if (url.isEmpty) return;
    await _player.stop();
    await _player.setSourceUrl(url);
    await _player.resume();
    state = QuranAudioState(isPlaying: true, currentIndex: index);
    _player.onPlayerComplete.listen((_) {
      final prefs = _ref.read(prefsProvider);
      final current = state.currentIndex ?? -1;
      int? target;
      if (!prefs.autoAdvance) {
        target = null;
      } else if (prefs.repeatMode == 'one') {
        target = current;
      } else {
        final next = current + 1;
        if (next < _urls.length) {
          target = next;
        } else if (prefs.repeatMode == 'all' && _urls.isNotEmpty) {
          target = 0;
        }
      }
      if (target != null) {
        playIndex(target);
      } else {
        state = const QuranAudioState(isPlaying: false, currentIndex: null);
      }
    });
  }

  Future<void> togglePause() async {
    if (state.isPlaying) {
      await _player.pause();
      state =
          QuranAudioState(isPlaying: false, currentIndex: state.currentIndex);
    } else {
      await _player.resume();
      state =
          QuranAudioState(isPlaying: true, currentIndex: state.currentIndex);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = const QuranAudioState(isPlaying: false, currentIndex: null);
  }

  Future<void> previous() async {
    final current = state.currentIndex ?? 0;
    final target = current - 1;
    await playIndex(target);
  }

  Future<void> next() async {
    final current = state.currentIndex ?? -1;
    final target = current + 1;
    await playIndex(target);
  }
}

final quranAudioProvider =
    StateNotifierProvider<QuranAudioController, QuranAudioState>((ref) {
  return QuranAudioController(ref);
});

// -------------------- Translation Resources --------------------
final translationResourcesProvider =
    FutureProvider.autoDispose<List<TranslationResourceDto>>((ref) async {
  print('DEBUG: Loading translation resources...');
  final repo = ref.read(quranRepoProvider);
  final resources = await repo.getTranslationResources();
  print('DEBUG: Loaded ${resources.length} translation resources');
  return resources;
});

final recitationsProvider =
    FutureProvider.autoDispose<List<RecitationResourceDto>>((ref) async {
  final repo = ref.read(quranRepoProvider);
  return repo.getRecitations();
});

// Alias for audio downloads screen
final recitationResourcesProvider = recitationsProvider;

// -------------------- Tafsir Resources --------------------
final tafsirResourcesProvider =
    FutureProvider.autoDispose<List<TafsirResourceDto>>((ref) async {
  final repo = ref.read(quranRepoProvider);
  return repo.getTafsirResources();
});

final tafsirByVerseProvider = FutureProvider.family<TafsirDto, Map<String, dynamic>>((ref, params) async {
  final repo = ref.read(quranRepoProvider);
  return repo.getTafsirByVerse(
    verseKey: params['verseKey'] as String,
    resourceId: params['resourceId'] as int,
  );
});

// -------------------- Word Analysis Resources --------------------
final wordAnalysisResourcesProvider =
    FutureProvider.autoDispose<List<WordAnalysisResourceDto>>((ref) async {
  final repo = ref.read(quranRepoProvider);
  return repo.getWordAnalysisResources();
});

final wordAnalysisByVerseProvider = FutureProvider.family<WordAnalysisDto, Map<String, dynamic>>((ref, params) async {
  final repo = ref.read(quranRepoProvider);
  return repo.getWordAnalysisByVerse(
    verseKey: params['verseKey'] as String,
    resourceId: params['resourceId'] as int,
  );
});

// -------------------- Audio Downloads --------------------
final audioDownloadInfoProvider = FutureProvider.family<AudioDownloadDto, Map<String, dynamic>>((ref, params) async {
  final repo = ref.read(quranRepoProvider);
  return repo.getAudioDownloadInfo(
    chapterId: params['chapterId'] as int,
    recitationId: params['recitationId'] as int,
  );
});

final audioDownloadProgressDtoProvider = StreamProvider.family<AudioDownloadProgressDto?, Map<String, dynamic>>((ref, params) async* {
  // This will be updated by the download service
  yield null;
});

final audioDownloadManagerProvider = StateNotifierProvider<AudioDownloadManager, Map<String, AudioDownloadDto>>((ref) {
  return AudioDownloadManager(ref);
});

class AudioDownloadManager extends StateNotifier<Map<String, AudioDownloadDto>> {
  AudioDownloadManager(this._ref) : super({});
  final Ref _ref;

  Future<void> downloadAudio(String chapterId) async {
    // Implementation for audio download
    // This is a placeholder - will be implemented when needed
  }

  Future<void> cancelDownload(String chapterId) async {
    // Implementation for canceling download
    // This is a placeholder - will be implemented when needed
  }
}

// -------------------- Notes --------------------
final _notesBoxProvider = FutureProvider<Box>((_) async {
  await Hive.initFlutter();
  return Hive.openBox(boxes.Boxes.notes);
});

final notesProvider = StreamProvider<Map<String, NoteDto>>((ref) async* {
  final box = await ref.watch(_notesBoxProvider.future);
  Map<String, NoteDto> read() {
    final data = box.get('notes', defaultValue: <String, dynamic>{});
    if (data is Map) {
      return data.map((key, value) => MapEntry(
            key.toString(),
            NoteDto.fromMap(Map<String, dynamic>.from(value)),
          ));
    }
    return {};
  }

  yield read();
  await for (final _ in box.watch(key: 'notes')) {
    yield read();
  }
});

final noteUpdaterProvider =
    Provider<Future<void> Function(String, String)>((ref) {
  return (verseKey, text) async {
    final box = await ref.read(_notesBoxProvider.future);
    final notes = Map<String, dynamic>.from(
        box.get('notes', defaultValue: <String, dynamic>{}));
    if (text.trim().isEmpty) {
      notes.remove(verseKey);
    } else {
      notes[verseKey] = NoteDto(verseKey: verseKey, text: text.trim()).toMap();
    }
    await box.put('notes', notes);
  };
});

// -------------------- Downloads --------------------
final _downloadsBoxProvider = FutureProvider<Box>((_) async {
  await Hive.initFlutter();
  return Hive.openBox(boxes.Boxes.downloads);
});

final downloadsProvider =
    StreamProvider<Map<int, ChapterDownloadDto>>((ref) async* {
  final box = await ref.watch(_downloadsBoxProvider.future);
  Map<int, ChapterDownloadDto> read() {
    final data = box.get('downloads', defaultValue: <String, dynamic>{});
    if (data is Map) {
      return data.map((key, value) => MapEntry(
            int.parse(key.toString()),
            ChapterDownloadDto.fromMap(Map<String, dynamic>.from(value)),
          ));
    }
    return {};
  }

  yield read();
  await for (final _ in box.watch(key: 'downloads')) {
    yield read();
  }
});

final downloadManagerProvider = Provider<DownloadManager>((ref) {
  return DownloadManager(ref);
});

class DownloadManager {
  DownloadManager(this._ref);
  final Ref _ref;

  Future<void> downloadChapter(int chapterId) async {
    final box = await _ref.read(_downloadsBoxProvider.future);
    final downloads = Map<String, dynamic>.from(
        box.get('downloads', defaultValue: <String, dynamic>{}));

    // Mark as downloading
    downloads[chapterId.toString()] = ChapterDownloadDto(
      chapterId: chapterId,
      status: 'downloading',
    ).toMap();
    await box.put('downloads', downloads);

    try {
      // Get total pages first
      final repo = _ref.read(quranRepoProvider);
      final firstPage = await repo.getChapterPage(
        chapterId: chapterId,
        translationIds: const [20],
        recitationId: 7,
        page: 1,
      );

      final totalPages = firstPage.pagination.totalPages;
      int downloadedPages = 1; // First page already fetched

      // Update with total pages
      downloads[chapterId.toString()] = ChapterDownloadDto(
        chapterId: chapterId,
        status: 'downloading',
        totalPages: totalPages,
        downloadedPages: downloadedPages,
      ).toMap();
      await box.put('downloads', downloads);

      // Download remaining pages
      for (int page = 2; page <= totalPages; page++) {
        await repo.getChapterPage(
          chapterId: chapterId,
          translationIds: const [20],
          recitationId: 7,
          page: page,
        );

        downloadedPages++;
        downloads[chapterId.toString()] = ChapterDownloadDto(
          chapterId: chapterId,
          status: 'downloading',
          totalPages: totalPages,
          downloadedPages: downloadedPages,
        ).toMap();
        await box.put('downloads', downloads);
      }

      // Mark as completed
      downloads[chapterId.toString()] = ChapterDownloadDto(
        chapterId: chapterId,
        status: 'completed',
        downloadedAt: DateTime.now(),
        totalPages: totalPages,
        downloadedPages: downloadedPages,
      ).toMap();
      await box.put('downloads', downloads);
    } catch (e) {
      // Mark as failed
      downloads[chapterId.toString()] = ChapterDownloadDto(
        chapterId: chapterId,
        status: 'failed',
      ).toMap();
      await box.put('downloads', downloads);
    }
  }

  Future<void> removeDownload(int chapterId) async {
    final box = await _ref.read(_downloadsBoxProvider.future);
    final downloads = Map<String, dynamic>.from(
        box.get('downloads', defaultValue: <String, dynamic>{}));
    downloads.remove(chapterId.toString());
    await box.put('downloads', downloads);

    // Clear from cache as well
    final cacheBox = await Hive.openBox(boxes.Boxes.verses);
    final keys = cacheBox.keys
        .where((k) => k.toString().startsWith('ch_${chapterId}_'))
        .toList();
    for (final key in keys) {
      await cacheBox.delete(key);
    }
  }
}

// -------------------- Quran Preferences --------------------
class QuranPrefs {
  const QuranPrefs({
    this.selectedTranslationIds = const [20], // Try the original working translation ID
    this.selectedTafsirIds = const [],
    this.selectedWordAnalysisIds = const [],
    this.recitationId = 7,
    this.showArabic = true,
    this.showTranslation = true,
    this.showTafsir = false,
    this.showWordAnalysis = false,
    this.arabicFontSize = 26.0,
    this.translationFontSize = 15.0,
    this.tafsirFontSize = 14.0,
    this.wordAnalysisFontSize = 13.0,
    this.arabicLineHeight = 1.9,
    this.translationLineHeight = 1.6,
    this.tafsirLineHeight = 1.5,
    this.wordAnalysisLineHeight = 1.4,
    this.arabicFontFamily,
    this.repeatMode = 'off',
    this.autoAdvance = true,
  });

  final List<int> selectedTranslationIds;
  final List<int> selectedTafsirIds;
  final List<int> selectedWordAnalysisIds;
  final int recitationId;
  final bool showArabic;
  final bool showTranslation;
  final bool showTafsir;
  final bool showWordAnalysis;
  final double arabicFontSize;
  final double translationFontSize;
  final double tafsirFontSize;
  final double wordAnalysisFontSize;
  final double arabicLineHeight;
  final double translationLineHeight;
  final double tafsirLineHeight;
  final double wordAnalysisLineHeight;
  final String? arabicFontFamily;
  final String repeatMode; // off | one | all
  final bool autoAdvance;

  Map<String, dynamic> toMap() => {
        'selectedTranslationIds': selectedTranslationIds,
        'selectedTafsirIds': selectedTafsirIds,
        'selectedWordAnalysisIds': selectedWordAnalysisIds,
        'recitationId': recitationId,
        'showArabic': showArabic,
        'showTranslation': showTranslation,
        'showTafsir': showTafsir,
        'showWordAnalysis': showWordAnalysis,
        'arabicFontSize': arabicFontSize,
        'translationFontSize': translationFontSize,
        'tafsirFontSize': tafsirFontSize,
        'wordAnalysisFontSize': wordAnalysisFontSize,
        'arabicLineHeight': arabicLineHeight,
        'translationLineHeight': translationLineHeight,
        'tafsirLineHeight': tafsirLineHeight,
        'wordAnalysisLineHeight': wordAnalysisLineHeight,
        'arabicFontFamily': arabicFontFamily,
        'repeatMode': repeatMode,
        'autoAdvance': autoAdvance,
      };

  static QuranPrefs fromMap(Map<String, dynamic> map) => QuranPrefs(
        selectedTranslationIds:
            List<int>.from(map['selectedTranslationIds'] ?? [20]), // Original working ID
        selectedTafsirIds:
            List<int>.from(map['selectedTafsirIds'] ?? []),
        selectedWordAnalysisIds:
            List<int>.from(map['selectedWordAnalysisIds'] ?? []),
        recitationId: (map['recitationId'] ?? 7) as int,
        showArabic: (map['showArabic'] ?? true) as bool,
        showTranslation: (map['showTranslation'] ?? true) as bool,
        showTafsir: (map['showTafsir'] ?? false) as bool,
        showWordAnalysis: (map['showWordAnalysis'] ?? false) as bool,
        arabicFontSize: (map['arabicFontSize'] ?? 26.0).toDouble(),
        translationFontSize: (map['translationFontSize'] ?? 15.0).toDouble(),
        tafsirFontSize: (map['tafsirFontSize'] ?? 14.0).toDouble(),
        wordAnalysisFontSize: (map['wordAnalysisFontSize'] ?? 13.0).toDouble(),
        arabicLineHeight: (map['arabicLineHeight'] ?? 1.9).toDouble(),
        translationLineHeight: (map['translationLineHeight'] ?? 1.6).toDouble(),
        tafsirLineHeight: (map['tafsirLineHeight'] ?? 1.5).toDouble(),
        wordAnalysisLineHeight: (map['wordAnalysisLineHeight'] ?? 1.4).toDouble(),
        arabicFontFamily: map['arabicFontFamily'] as String?,
        repeatMode: (map['repeatMode'] ?? 'off') as String,
        autoAdvance: (map['autoAdvance'] ?? true) as bool,
      );
}

final _prefsBoxProvider = FutureProvider<Box>((_) async {
  await Hive.initFlutter();
  return Hive.openBox('quran_prefs');
});

final prefsProvider = NotifierProvider<PrefsNotifier, QuranPrefs>(() {
  return PrefsNotifier();
});

class PrefsNotifier extends Notifier<QuranPrefs> {
  @override
  QuranPrefs build() {
    return const QuranPrefs();
  }

  Future<void> loadPrefs() async {
    final box = await ref.read(_prefsBoxProvider.future);
    final raw = box.get('prefs');
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      // Check if we need to migrate from old translation ID
      final currentIds = List<int>.from(map['selectedTranslationIds'] ?? []);
      if (currentIds.contains(131)) {
        // Migrate from new translation ID back to working one
        final newIds = currentIds.map((id) => id == 131 ? 20 : id).toList();
        map['selectedTranslationIds'] = newIds;
        // Save the migrated preferences
        await box.put('prefs', map);
      }
      state = QuranPrefs.fromMap(map);
    }
  }

  Future<void> updateTranslationIds(List<int> translationIds) async {
    print('DEBUG: updateTranslationIds called with: $translationIds');
    final box = await ref.read(_prefsBoxProvider.future);
    final newPrefs = QuranPrefs(
      selectedTranslationIds: translationIds,
      recitationId: state.recitationId,
      showArabic: state.showArabic,
      showTranslation: state.showTranslation,
      arabicFontSize: state.arabicFontSize,
      translationFontSize: state.translationFontSize,
      arabicLineHeight: state.arabicLineHeight,
      translationLineHeight: state.translationLineHeight,
      arabicFontFamily: state.arabicFontFamily,
    );
    state = newPrefs;
    await box.put('prefs', newPrefs.toMap());
    print('DEBUG: Translation IDs updated to: ${newPrefs.selectedTranslationIds}');
  }

  Future<void> clearCacheAndReset() async {
    final box = await ref.read(_prefsBoxProvider.future);
    await box.clear(); // Clear all stored preferences
    state = const QuranPrefs(); // Reset to default with translation ID 20
    
    // Also clear verses cache to force fresh fetch with translation ID 20
    try {
      final versesBox = await Hive.openBox(boxes.Boxes.verses);
      await versesBox.clear();
      print('DEBUG: Cleared verses cache to force fresh fetch with translation ID 20');
    } catch (e) {
      print('DEBUG: Error clearing verses cache: $e');
    }
  }

  Future<void> updateRecitationId(int recitationId) async {
    final box = await ref.read(_prefsBoxProvider.future);
    final newPrefs = QuranPrefs(
      selectedTranslationIds: state.selectedTranslationIds,
      recitationId: recitationId,
      showArabic: state.showArabic,
      showTranslation: state.showTranslation,
      arabicFontSize: state.arabicFontSize,
      translationFontSize: state.translationFontSize,
      arabicLineHeight: state.arabicLineHeight,
      translationLineHeight: state.translationLineHeight,
      arabicFontFamily: state.arabicFontFamily,
    );
    state = newPrefs;
    await box.put('prefs', newPrefs.toMap());
  }

  Future<void> updateArabicFontSize(double size) async {
    final box = await ref.read(_prefsBoxProvider.future);
    final newPrefs = stateCopy(arabicFontSize: size);
    state = newPrefs;
    await box.put('prefs', newPrefs.toMap());
  }

  Future<void> updateTranslationFontSize(double size) async {
    final box = await ref.read(_prefsBoxProvider.future);
    final newPrefs = stateCopy(translationFontSize: size);
    state = newPrefs;
    await box.put('prefs', newPrefs.toMap());
  }

  Future<void> updateArabicLineHeight(double h) async {
    final box = await ref.read(_prefsBoxProvider.future);
    final newPrefs = stateCopy(arabicLineHeight: h);
    state = newPrefs;
    await box.put('prefs', newPrefs.toMap());
  }

  Future<void> updateTranslationLineHeight(double h) async {
    final box = await ref.read(_prefsBoxProvider.future);
    final newPrefs = stateCopy(translationLineHeight: h);
    state = newPrefs;
    await box.put('prefs', newPrefs.toMap());
  }

  Future<void> updateShowArabic(bool v) async {
    final box = await ref.read(_prefsBoxProvider.future);
    final newPrefs = stateCopy(showArabic: v);
    state = newPrefs;
    await box.put('prefs', newPrefs.toMap());
  }

  Future<void> updateShowTranslation(bool v) async {
    final box = await ref.read(_prefsBoxProvider.future);
    final newPrefs = stateCopy(showTranslation: v);
    state = newPrefs;
    await box.put('prefs', newPrefs.toMap());
  }

  Future<void> updateArabicFontFamily(String? family) async {
    final box = await ref.read(_prefsBoxProvider.future);
    final newPrefs = stateCopy(arabicFontFamily: family);
    state = newPrefs;
    await box.put('prefs', newPrefs.toMap());
  }

  Future<void> updateRepeatMode(String mode) async {
    final box = await ref.read(_prefsBoxProvider.future);
    final newPrefs = stateCopy(repeatMode: mode);
    state = newPrefs;
    await box.put('prefs', newPrefs.toMap());
  }

  Future<void> updateAutoAdvance(bool on) async {
    final box = await ref.read(_prefsBoxProvider.future);
    final newPrefs = stateCopy(autoAdvance: on);
    state = newPrefs;
    await box.put('prefs', newPrefs.toMap());
  }

  QuranPrefs stateCopy({
    List<int>? selectedTranslationIds,
    int? recitationId,
    bool? showArabic,
    bool? showTranslation,
    double? arabicFontSize,
    double? translationFontSize,
    double? arabicLineHeight,
    double? translationLineHeight,
    String? arabicFontFamily,
    String? repeatMode,
    bool? autoAdvance,
  }) {
    return QuranPrefs(
      selectedTranslationIds:
          selectedTranslationIds ?? state.selectedTranslationIds,
      recitationId: recitationId ?? state.recitationId,
      showArabic: showArabic ?? state.showArabic,
      showTranslation: showTranslation ?? state.showTranslation,
      arabicFontSize: arabicFontSize ?? state.arabicFontSize,
      translationFontSize: translationFontSize ?? state.translationFontSize,
      arabicLineHeight: arabicLineHeight ?? state.arabicLineHeight,
      translationLineHeight:
          translationLineHeight ?? state.translationLineHeight,
      arabicFontFamily: arabicFontFamily ?? state.arabicFontFamily,
      repeatMode: repeatMode ?? state.repeatMode,
      autoAdvance: autoAdvance ?? state.autoAdvance,
    );
  }
}

class SurahPageArgs {
  const SurahPageArgs(this.chapterId, this.page,
      {this.translationIds = const [20], this.recitationId = 7});
  final int chapterId;
  final int page;
  final List<int> translationIds;
  final int recitationId;
}

final surahPageProvider =
    FutureProvider.family<VersesPageDto, SurahPageArgs>((ref, args) async {
  // ignore: avoid_print
  print(
      'Provider: surahPageProvider start ch=${args.chapterId} p=${args.page}');
  final repo = ref.read(quranRepoProvider);
  final prefs = ref.watch(prefsProvider);

  try {
    final dto = await repo.getChapterPage(
      chapterId: args.chapterId,
      translationIds: args.translationIds.isNotEmpty
          ? args.translationIds
          : prefs.selectedTranslationIds,
      recitationId:
          args.recitationId != 7 ? args.recitationId : prefs.recitationId,
      page: args.page,
    );
    // ignore: avoid_print
    print('Provider: surahPageProvider got verses=${dto.verses.length}');
    return dto;
  } catch (e) {
    // Try offline fallback
    try {
      final dto = await repo.getChapterPage(
        chapterId: args.chapterId,
        translationIds: const [],
        recitationId: 0,
        page: args.page,
        refresh: false,
      );
      // ignore: avoid_print
      print('Provider: offline fallback hit verses=${dto.verses.length}');
      return dto;
    } catch (_) {
      rethrow;
    }
  }
});

// -------------------- Missing Service Providers --------------------

// Bookmarks Service (actual implementation)
final bookmarksServiceProvider = Provider<BookmarksService>((ref) {
  return BookmarksService();
});

final bookmarksListProvider = FutureProvider.autoDispose<List<Bookmark>>((ref) async {
  final service = ref.read(bookmarksServiceProvider);
  return service.getAllBookmarks();
});

final bookmarkCategoriesProvider = FutureProvider.autoDispose<List<BookmarkCategory>>((ref) async {
  final service = ref.read(bookmarksServiceProvider);
  return service.getAllCategories();
});

// Reading Plans Service (placeholder until implementation)
final readingPlansServiceProvider = Provider<dynamic>((ref) {
  // TODO: Replace with actual ReadingPlansService implementation  
  return PlaceholderReadingPlansService();
});

class PlaceholderReadingPlansService {
  Future<List<dynamic>> getActivePlans() async => [];
  Future<List<dynamic>> getTemplates() async => [];
}

final activeReadingPlansProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final service = ref.read(readingPlansServiceProvider);
  return service.getActivePlans();
});

final readingPlanTemplatesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final service = ref.read(readingPlansServiceProvider);
  return service.getTemplates();
});

// -------------------- Navigation Providers (Juz/Page/Hizb/Ruku) --------------------

/// Provider for Juz list 
final juzListProvider = FutureProvider<List<JuzDto>>((ref) async {
  final api = ref.watch(resourcesApiProvider);
  try {
    return await api.getJuzList();
  } catch (e) {
    print('Error loading Juz list: $e');
    return [];
  }
});

/// Provider for Page list
final pagesProvider = FutureProvider<List<PageDto>>((ref) async {
  final api = ref.watch(resourcesApiProvider);
  try {
    return await api.getPageList();
  } catch (e) {
    print('Error loading Page list: $e');
    return [];
  }
});

/// Provider for Hizb list
final hizbListProvider = FutureProvider<List<HizbDto>>((ref) async {
  final api = ref.watch(resourcesApiProvider);
  try {
    return await api.getHizbList();
  } catch (e) {
    print('Error loading Hizb list: $e');
    return [];
  }
});

/// Provider for Ruku list
final rukuListProvider = FutureProvider<List<RukuDto>>((ref) async {
  final api = ref.watch(resourcesApiProvider);
  try {
    return await api.getRukuList();
  } catch (e) {
    print('Error loading Ruku list: $e');
    return [];
  }
});

/// Provider for verses in a specific Juz
final versesByJuzProvider = FutureProvider.family<List<VerseDto>, int>((ref, juzNumber) async {
  final api = ref.watch(resourcesApiProvider);
  try {
    return await api.getVersesByJuz(juzNumber);
  } catch (e) {
    print('Error loading verses for Juz $juzNumber: $e');
    return [];
  }
});

/// Provider for verses in a specific Page
final versesByPageProvider = FutureProvider.family<List<VerseDto>, int>((ref, pageNumber) async {
  final api = ref.watch(resourcesApiProvider);
  try {
    return await api.getVersesByPage(pageNumber);
  } catch (e) {
    print('Error loading verses for Page $pageNumber: $e');
    return [];
  }
});

/// Provider for verses in a specific Hizb
final versesByHizbProvider = FutureProvider.family<List<VerseDto>, int>((ref, hizbNumber) async {
  final api = ref.watch(resourcesApiProvider);
  try {
    return await api.getVersesByHizb(hizbNumber);
  } catch (e) {
    print('Error loading verses for Hizb $hizbNumber: $e');
    return [];
  }
});

/// Provider for verses in a specific Ruku
final versesByRukuProvider = FutureProvider.family<List<VerseDto>, int>((ref, rukuNumber) async {
  final api = ref.watch(resourcesApiProvider);
  try {
    return await api.getVersesByRuku(rukuNumber);
  } catch (e) {
    print('Error loading verses for Ruku $rukuNumber: $e');
    return [];
  }
});

// -------------------- Search Service Provider --------------------

/// Provider for Quran search service with offline cache support
final quranSearchServiceProvider = Provider<QuranSearchService>((ref) {
  final repository = ref.watch(quranRepoProvider);
  return QuranSearchService(repository);
});

/// Provider for search suggestions
final searchSuggestionsProvider = FutureProvider.family<List<SearchSuggestion>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  
  final searchService = ref.watch(quranSearchServiceProvider);
  return await searchService.getSearchSuggestions(query);
});

/// Provider for search history
final searchHistoryProvider = FutureProvider<List<String>>((ref) async {
  final searchService = ref.watch(quranSearchServiceProvider);
  return await searchService.getSearchHistory();
});

// -------------------- Offline Cache Providers --------------------

/// Provider to cache navigation mappings on app start
final cacheNavigationMappingsProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(offlineContentServiceProvider);
  
  // Check if already cached
  final areCached = await service.areNavigationMappingsCached();
  if (!areCached) {
    await service.cacheNavigationMappings();
  }
});

/// Provider for cached Juz list (offline-first)
final cachedJuzListProvider = FutureProvider<List<JuzDto>>((ref) async {
  final service = ref.watch(offlineContentServiceProvider);
  
  // Ensure navigation mappings are cached first
  await ref.watch(cacheNavigationMappingsProvider.future);
  
  return service.getCachedJuzList();
});
