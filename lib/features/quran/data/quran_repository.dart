import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'auth_token_notifier.dart';
import 'dto/chapter_dto.dart';
import 'dto/verses_page_dto.dart';

class QuranRepository {
  QuranRepository(this._dio, this._auth, this._hive);
  final Dio _dio;
  final AuthTokenNotifier _auth;
  final HiveInterface _hive;

  static const String chaptersBox = 'quran_chapters';
  static const String versesBox = 'quran_verses_v4';

  static const Duration ttlChapters = Duration(days: 30);
  static const Duration ttlVerses = Duration(days: 7);

  Future<List<ChapterDto>> getChapters({bool forceRefresh = false}) async {
    final box = await _hive.openBox<String>(chaptersBox);
    final cached = box.get('chapters');
    if (cached != null && !forceRefresh) {
      // SWR: return immediately
      _refreshChaptersInBackground();
      final list = (json.decode(cached) as List)
          .map((e) => ChapterDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    }
    // Fetch network
    final fresh = await _fetchChapters();
    await box.put(
        'chapters', json.encode(fresh.map((e) => e.toJson()).toList()));
    return fresh;
  }

  Future<void> _refreshChaptersInBackground() async {
    try {
      final fresh = await _fetchChapters();
      final box = await _hive.openBox<String>(chaptersBox);
      await box.put(
          'chapters', json.encode(fresh.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<List<ChapterDto>> _fetchChapters() async {
    // Example Quran.Foundation endpoint (adjust to API v4 contract)
    final res =
        await _dio.get('https://api.quran.com/api/v4/chapters?language=en');
    final data = res.data as Map<String, dynamic>;
    final List<dynamic> arr = data['chapters'] as List<dynamic>;
    return arr
        .map((e) => ChapterDto(
              id: e['id'] as int,
              nameArabic: (e['name_arabic'] as String?) ?? '',
              nameSimple: (e['name_simple'] as String?) ?? '',
              versesCount: (e['verses_count'] as num?)?.toInt() ?? 0,
              revelationPlace: (e['revelation_place'] as String?) ?? 'meccan',
            ))
        .toList();
  }

  String versesKey({
    required int chapterId,
    required List<int> translationIds,
    required int? reciterId,
    required int page,
  }) {
    final t = translationIds.join(',');
    final r = reciterId?.toString() ?? '0';
    return 'ch:$chapterId|t:$t|r:$r|p:$page';
  }

  Future<VersesPageDto> getChapterPage({
    required int chapterId,
    required List<int> translationIds,
    required int? reciterId,
    required int page,
    int perPage = 50,
  }) async {
    final key = versesKey(
      chapterId: chapterId,
      translationIds: translationIds,
      reciterId: reciterId,
      page: page,
    );
    final box = await _hive.openBox<String>(versesBox);
    final cached = box.get(key);
    if (cached != null) {
      // SWR
      _refreshChapterPageInBackground(
        chapterId: chapterId,
        translationIds: translationIds,
        reciterId: reciterId,
        page: page,
        perPage: perPage,
        cacheKey: key,
      );
      return VersesPageDto.fromJson(
          json.decode(cached) as Map<String, dynamic>);
    }
    final fresh = await _fetchChapterPage(
      chapterId: chapterId,
      translationIds: translationIds,
      reciterId: reciterId,
      page: page,
      perPage: perPage,
    );
    await box.put(key, json.encode(fresh.toJson()));
    return fresh;
  }

  Future<void> _refreshChapterPageInBackground({
    required int chapterId,
    required List<int> translationIds,
    required int? reciterId,
    required int page,
    required int perPage,
    required String cacheKey,
  }) async {
    try {
      final fresh = await _fetchChapterPage(
        chapterId: chapterId,
        translationIds: translationIds,
        reciterId: reciterId,
        page: page,
        perPage: perPage,
      );
      final box = await _hive.openBox<String>(versesBox);
      await box.put(cacheKey, json.encode(fresh.toJson()));
    } catch (_) {}
  }

  Future<VersesPageDto> _fetchChapterPage({
    required int chapterId,
    required List<int> translationIds,
    required int? reciterId,
    required int page,
    required int perPage,
  }) async {
    final t = translationIds.join(',');
    final r = reciterId?.toString();
    final res = await _dio.get(
      'https://api.quran.com/api/v4/verses/by_chapter/$chapterId',
      queryParameters: {
        'language': 'en',
        'page': page,
        'per_page': perPage,
        'words': false,
        'audio': r != null ? 1 : 0,
        if (r != null) 'reciter': r,
        'translations': t,
        'fields': 'text_uthmani',
      },
    );
    final data = res.data as Map<String, dynamic>;
    final verses =
        (data['verses'] as List).map((v) => v as Map<String, dynamic>).toList();
    // Map to DTOs (simplified; adapt to API fields)
    final dtos = verses.map((v) {
      final translations = (v['translations'] as List? ?? [])
          .map((tr) => TranslationDto(
                resourceId: (tr['resource_id'] as num?)?.toInt() ?? 0,
                text: (tr['text'] as String?) ?? '',
                language: (tr['language_name'] as String?) ?? 'en',
              ))
          .toList();
      return VerseDto(
        verseKey: (v['verse_key'] as String?) ?? '',
        verseNumber: (v['verse_number'] as num?)?.toInt() ?? 0,
        textUthmani: (v['text_uthmani'] as String?) ?? '',
        translations: translations,
        audioUrl: (v['audio']?['url'] as String?),
      );
    }).toList();
    final pagination = PaginationDto(
      totalPages: (data['pagination']?['total_pages'] as num?)?.toInt() ?? 1,
      currentPage:
          (data['pagination']?['current_page'] as num?)?.toInt() ?? page,
    );
    return VersesPageDto(verses: dtos, pagination: pagination);
  }
}

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  final dio = Dio();
  final auth = ref.read(authTokenNotifierProvider.notifier);
  dio.interceptors
      .add(auth.createInterceptor(clientId: 'deenmate')); // x-client-id
  return QuranRepository(dio, auth, Hive);
});
