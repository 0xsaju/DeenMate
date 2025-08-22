import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/storage/hive_boxes.dart' as boxes;
import '../api/chapters_api.dart';
import '../api/verses_api.dart';
import '../api/resources_api.dart';
import '../cache/cache_keys.dart';
import '../dto/chapter_dto.dart';
import '../dto/verses_page_dto.dart';
import '../dto/translation_resource_dto.dart';
import '../dto/recitation_resource_dto.dart';

class QuranRepository {
  QuranRepository(
      this._chaptersApi, this._versesApi, this._resourcesApi, this._hive);
  final ChaptersApi _chaptersApi;
  final VersesApi _versesApi;
  final ResourcesApi _resourcesApi;
  final HiveInterface _hive;

  Future<List<ChapterDto>> getChapters({bool refresh = true}) async {
    final box = await _hive.openBox(boxes.Boxes.chapters);
    final cached = box.get('all');
    if (cached is List) {
      if (refresh) _refreshChapters(box);
      return cached
          .cast<Map>()
          .map((e) => ChapterDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (cached is String) {
      final list = (jsonDecode(cached) as List)
          .map((e) => ChapterDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (refresh) _refreshChapters(box);
      return list;
    }
    final fresh = await _chaptersApi.list();
    await box.put('all', fresh.map((e) => e.toJson()).toList());
    return fresh;
  }

  Future<void> _refreshChapters(Box box) async {
    try {
      final fresh = await _chaptersApi.list();
      await box.put('all', fresh.map((e) => e.toJson()).toList());
    } catch (_) {}
  }

  Future<VersesPageDto> getChapterPage({
    required int chapterId,
    required List<int> translationIds,
    required int recitationId,
    required int page,
    int perPage = 50,
    bool refresh = true,
  }) async {
    final key = versesKey(chapterId, translationIds, recitationId, page);
    final vBox = await _hive.openBox(boxes.Boxes.verses);
    final cached = vBox.get(key);
    // ignore: avoid_print
    print('QuranRepo getChapterPage key=$key cached=${cached != null}');
    if (cached != null) {
      if (refresh) {
        _refreshChapterPage(
          chapterId,
          translationIds,
          recitationId,
          page,
          perPage,
          key,
          vBox,
        );
      }
      // Parse cached (defensively handle legacy/map types)
      VersesPageDto parsed;
      try {
        if (cached is Map) {
          parsed =
              VersesPageDto.fromJson(Map<String, dynamic>.from(cached as Map));
        } else if (cached is String) {
          parsed = VersesPageDto.fromJson(
              Map<String, dynamic>.from(jsonDecode(cached) as Map));
        } else {
          return _fetchAndCache(
            chapterId,
            translationIds,
            recitationId,
            page,
            perPage,
            key,
            vBox,
          );
        }
      } catch (e) {
        // Corrupt cache: delete and refetch
        // ignore: avoid_print
        print('QuranRepo: cache parse error for key=$key → refresh. $e');
        await vBox.delete(key);
        return _fetchAndCache(
          chapterId,
          translationIds,
          recitationId,
          page,
          perPage,
          key,
          vBox,
        );
      }
      // If cached is empty (possibly from earlier parse error), fetch fresh now
      if (parsed.verses.isEmpty) {
        // ignore: avoid_print
        print('QuranRepo cached verses empty → fetching fresh for key=$key');
        return _fetchAndCache(
          chapterId,
          translationIds,
          recitationId,
          page,
          perPage,
          key,
          vBox,
        );
      }
      // ignore: avoid_print
      print('QuranRepo returning cached verses count=${parsed.verses.length}');
      return parsed;
    }

    // Try fallback: any cached variant of this chapter/page regardless of translation/reciter
    try {
      final keys = vBox.keys;
      String? altKey;
      for (final k in keys) {
        if (k is! String) continue;
        if (k.startsWith('ch:$chapterId|') && k.endsWith('|p:$page')) {
          altKey = k;
          break;
        }
      }
      if (altKey != null) {
        final alt = vBox.get(altKey);
        if (alt != null) {
          // ignore: avoid_print
          print(
              'QuranRepo using fallback cached key=$altKey for requested key=$key');
          if (alt is String) {
            return VersesPageDto.fromJson(
                Map<String, dynamic>.from(jsonDecode(alt) as Map));
          }
          if (alt is Map) {
            return VersesPageDto.fromJson(
                Map<String, dynamic>.from(alt as Map));
          }
        }
      }
    } catch (_) {}

    return _fetchAndCache(
      chapterId,
      translationIds,
      recitationId,
      page,
      perPage,
      key,
      vBox,
    );
  }

  Future<List<RecitationResourceDto>> getRecitations(
      {bool refresh = true}) async {
    final box = await _hive.openBox(boxes.Boxes.resources);
    final key = 'recitations';
    final cached = box.get(key);
    if (cached is List) {
      if (refresh) _refreshRecitations(box);
      return cached
          .cast<Map>()
          .map((e) =>
              RecitationResourceDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (cached is String) {
      final list = (jsonDecode(cached) as List)
          .map((e) =>
              RecitationResourceDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (refresh) _refreshRecitations(box);
      return list;
    }
    final fresh = await _resourcesApi.getRecitations();
    await box.put(key, fresh.map((e) => {'id': e.id, 'name': e.name}).toList());
    return fresh;
  }

  Future<void> _refreshRecitations(Box box) async {
    try {
      final fresh = await _resourcesApi.getRecitations();
      await box.put('recitations',
          fresh.map((e) => {'id': e.id, 'name': e.name}).toList());
    } catch (_) {}
  }

  Future<VersesPageDto> _fetchAndCache(
    int chapterId,
    List<int> translationIds,
    int recitationId,
    int page,
    int perPage,
    String key,
    Box vBox,
  ) async {
    final fresh = await _versesApi.byChapter(
      chapterId: chapterId,
      translationIds: translationIds,
      recitationId: recitationId == 0 ? null : recitationId,
      page: page,
      perPage: perPage,
    );
    // ignore: avoid_print
    print(
        'QuranRepo fetched fresh verses count=${fresh.verses.length} for key=$key');
    await vBox.put(key, fresh.toJson());
    return fresh;
  }

  Future<void> _refreshChapterPage(
    int chapterId,
    List<int> tIds,
    int rId,
    int page,
    int perPage,
    String key,
    Box box,
  ) async {
    try {
      final fresh = await _versesApi.byChapter(
        chapterId: chapterId,
        translationIds: tIds,
        recitationId: rId == 0 ? null : rId,
        page: page,
        perPage: perPage,
      );
      await box.put(key, fresh.toJson());
    } catch (_) {}
  }

  /// Get available translation resources
  Future<List<TranslationResourceDto>> getTranslationResources(
      {bool refresh = true}) async {
    final box = await _hive.openBox(boxes.Boxes.resources);
    final cached = box.get('translation_resources');

    if (cached != null && !refresh) {
      if (cached is List) {
        return cached
            .cast<Map>()
            .map((e) =>
                TranslationResourceDto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (cached is String) {
        final list = (jsonDecode(cached) as List)
            .map((e) =>
                TranslationResourceDto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return list;
      }
    }

    final fresh = await _resourcesApi.getTranslationResources();
    await box.put(
        'translation_resources', fresh.map((e) => e.toJson()).toList());
    return fresh;
  }

  /// Get translation resources by language
  Future<List<TranslationResourceDto>> getTranslationResourcesByLanguage(
      String language,
      {bool refresh = true}) async {
    final key = 'translation_resources_$language';
    final box = await _hive.openBox(boxes.Boxes.resources);
    final cached = box.get(key);

    if (cached != null && !refresh) {
      if (cached is List) {
        return cached
            .cast<Map>()
            .map((e) =>
                TranslationResourceDto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (cached is String) {
        final list = (jsonDecode(cached) as List)
            .map((e) =>
                TranslationResourceDto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return list;
      }
    }

    final fresh =
        await _resourcesApi.getTranslationResourcesByLanguage(language);
    await box.put(key, fresh.map((e) => e.toJson()).toList());
    return fresh;
  }
}
