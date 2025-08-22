import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/net/dio_client.dart';
import '../../../../core/storage/hive_boxes.dart' as boxes;
import '../../data/api/chapters_api.dart';
import '../../data/api/verses_api.dart';
import '../../data/api/resources_api.dart';
import '../../data/repo/quran_repository.dart';
import '../../data/dto/chapter_dto.dart';
import '../../data/dto/verses_page_dto.dart';
import '../../data/dto/translation_resource_dto.dart';
import '../../data/dto/recitation_resource_dto.dart';
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

// -------------------- Bookmarks --------------------
final _bookmarksBoxProvider = FutureProvider<Box>((_) async {
  await Hive.initFlutter();
  return Hive.openBox('quran_bookmarks');
});

final bookmarksProvider = StreamProvider<Set<String>>((ref) async* {
  final box = await ref.watch(_bookmarksBoxProvider.future);
  Set<String> read() => (box.get('keys', defaultValue: <String>[]) as List)
      .map((e) => e.toString())
      .toSet();
  yield read();
  await for (final _ in box.watch()) {
    yield read();
  }
});

final bookmarkTogglerProvider = Provider<Future<void> Function(String)>((ref) {
  return (verseKey) async {
    final box = await ref.read(_bookmarksBoxProvider.future);
    final list = (box.get('keys', defaultValue: <String>[]) as List).toSet();
    if (list.contains(verseKey)) {
      list.remove(verseKey);
    } else {
      list.add(verseKey);
    }
    await box.put('keys', list.toList());
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
  final repo = ref.read(quranRepoProvider);
  return repo.getTranslationResources();
});

final recitationsProvider =
    FutureProvider.autoDispose<List<RecitationResourceDto>>((ref) async {
  final repo = ref.read(quranRepoProvider);
  return repo.getRecitations();
});

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
    this.selectedTranslationIds = const [20],
    this.recitationId = 7,
    this.showArabic = true,
    this.showTranslation = true,
    this.arabicFontSize = 26.0,
    this.translationFontSize = 15.0,
    this.arabicLineHeight = 1.9,
    this.translationLineHeight = 1.6,
    this.arabicFontFamily,
    this.repeatMode = 'off',
    this.autoAdvance = true,
  });

  final List<int> selectedTranslationIds;
  final int recitationId;
  final bool showArabic;
  final bool showTranslation;
  final double arabicFontSize;
  final double translationFontSize;
  final double arabicLineHeight;
  final double translationLineHeight;
  final String? arabicFontFamily;
  final String repeatMode; // off | one | all
  final bool autoAdvance;

  Map<String, dynamic> toMap() => {
        'selectedTranslationIds': selectedTranslationIds,
        'recitationId': recitationId,
        'showArabic': showArabic,
        'showTranslation': showTranslation,
        'arabicFontSize': arabicFontSize,
        'translationFontSize': translationFontSize,
        'arabicLineHeight': arabicLineHeight,
        'translationLineHeight': translationLineHeight,
        'arabicFontFamily': arabicFontFamily,
        'repeatMode': repeatMode,
        'autoAdvance': autoAdvance,
      };

  static QuranPrefs fromMap(Map<String, dynamic> map) => QuranPrefs(
        selectedTranslationIds:
            List<int>.from(map['selectedTranslationIds'] ?? [20]),
        recitationId: (map['recitationId'] ?? 7) as int,
        showArabic: (map['showArabic'] ?? true) as bool,
        showTranslation: (map['showTranslation'] ?? true) as bool,
        arabicFontSize: (map['arabicFontSize'] ?? 26.0).toDouble(),
        translationFontSize: (map['translationFontSize'] ?? 15.0).toDouble(),
        arabicLineHeight: (map['arabicLineHeight'] ?? 1.9).toDouble(),
        translationLineHeight: (map['translationLineHeight'] ?? 1.6).toDouble(),
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
      state = QuranPrefs.fromMap(Map<String, dynamic>.from(raw));
    }
  }

  Future<void> updateTranslationIds(List<int> translationIds) async {
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
