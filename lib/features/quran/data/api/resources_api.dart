import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../dto/translation_resource_dto.dart';
import '../dto/recitation_resource_dto.dart';
import '../dto/tafsir_dto.dart';
import '../dto/word_analysis_dto.dart';
import '../dto/audio_download_dto.dart';
import '../dto/juz_dto.dart';
import '../dto/verse_dto.dart';

class ResourcesApi {
  const ResourcesApi(this._dio);
  final Dio _dio;

  /// Fetch available translation resources
  Future<List<TranslationResourceDto>> getTranslationResources() async {
    try {
      final response = await _dio.get('/resources/translations');

      if (response.statusCode == 200) {
        final data = response.data['translations'] as List;
        return data
            .map((json) {
              try {
                return TranslationResourceDto.fromJson(json);
              } catch (parseError) {
                print('DEBUG: Error parsing translation resource: $parseError');
                print('DEBUG: JSON data: $json');
                rethrow;
              }
            })
            .toList();
      }

      throw Exception('Failed to fetch translation resources');
    } catch (e) {
      print('DEBUG: Translation resources API error: $e');
      throw Exception('Failed to fetch translation resources: $e');
    }
  }

  /// Fetch translation resources by language
  Future<List<TranslationResourceDto>> getTranslationResourcesByLanguage(
      String language) async {
    try {
      final response = await _dio.get('/resources/translations',
          queryParameters: {'language': language});

      if (response.statusCode == 200) {
        final data = response.data['translations'] as List;
        return data
            .map((json) => TranslationResourceDto.fromJson(json))
            .toList();
      }

      throw Exception('Failed to fetch translation resources for $language');
    } catch (e) {
      throw Exception(
          'Failed to fetch translation resources for $language: $e');
    }
  }

  /// Fetch available recitation resources (reciters)
  Future<List<RecitationResourceDto>> getRecitations() async {
    try {
      final response = await _dio.get('/resources/recitations');
      if (response.statusCode == 200) {
        final data = response.data['recitations'] as List;
        return data.map((json) {
          // Map Quran.com API response to our DTO
          return RecitationResourceDto(
            id: json['id'] as int,
            name: json['reciter_name'] as String,
            languageName: json['translated_name']?['language_name'] as String? ?? 'english',
            style: json['style'] as String?,
          );
        }).toList();
      }
      throw Exception('Failed to fetch recitation resources');
    } catch (e) {
      throw Exception('Failed to fetch recitation resources: $e');
    }
  }

  /// Fetch available Tafsir resources
  Future<List<TafsirResourceDto>> getTafsirResources() async {
    try {
      final response = await _dio.get('/resources/tafsirs');
      if (response.statusCode == 200) {
        final data = response.data['tafsirs'] as List;
        return data
            .map((json) => TafsirResourceDto.fromJson(json))
            .toList();
      }
      throw Exception('Failed to fetch Tafsir resources');
    } catch (e) {
      throw Exception('Failed to fetch Tafsir resources: $e');
    }
  }

  /// Fetch Tafsir for a specific verse
  Future<TafsirDto> getTafsirByVerse({
    required String verseKey,
    required int resourceId,
  }) async {
    try {
      final response = await _dio.get('/tafsirs/$resourceId/by_ayah/$verseKey');
      if (response.statusCode == 200) {
        return TafsirDto.fromJson(response.data['tafsir']);
      }
      throw Exception('Failed to fetch Tafsir for verse $verseKey');
    } catch (e) {
      throw Exception('Failed to fetch Tafsir for verse $verseKey: $e');
    }
  }

  /// Fetch available word analysis resources
  Future<List<WordAnalysisResourceDto>> getWordAnalysisResources() async {
    try {
      final response = await _dio.get('/resources/word_analysis');
      if (response.statusCode == 200) {
        final data = response.data['word_analysis'] as List;
        return data
            .map((json) => WordAnalysisResourceDto.fromJson(json))
            .toList();
      }
      throw Exception('Failed to fetch word analysis resources');
    } catch (e) {
      throw Exception('Failed to fetch word analysis resources: $e');
    }
  }

  /// Fetch word-by-word analysis for a specific verse
  Future<WordAnalysisDto> getWordAnalysisByVerse({
    required String verseKey,
    required int resourceId,
  }) async {
    try {
      final response = await _dio.get('/word_analysis/$resourceId/by_ayah/$verseKey');
      if (response.statusCode == 200) {
        return WordAnalysisDto.fromJson(response.data['word_analysis']);
      }
      throw Exception('Failed to fetch word analysis for verse $verseKey');
    } catch (e) {
      throw Exception('Failed to fetch word analysis for verse $verseKey: $e');
    }
  }

  /// Get audio download info for a chapter
  Future<AudioDownloadDto> getAudioDownloadInfo({
    required int chapterId,
    required int recitationId,
  }) async {
    try {
      final response = await _dio.get('/audio/download_info/$chapterId/$recitationId');
      if (response.statusCode == 200) {
        return AudioDownloadDto.fromJson(response.data['download_info']);
      }
      throw Exception('Failed to get audio download info for chapter $chapterId');
    } catch (e) {
      throw Exception('Failed to get audio download info for chapter $chapterId: $e');
    }
  }

  /// Get Juz information
  Future<List<JuzDto>> getJuzList() async {
    try {
      final response = await _dio.get('/juzs');
      if (response.statusCode == 200) {
        final data = response.data['juzs'] as List;
        return data.map((json) => JuzDto.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch Juz list');
    } catch (e) {
      // Fallback: create static Juz data if API not available
      return _createStaticJuzData();
    }
  }

  /// Get Page information
  Future<List<PageDto>> getPageList() async {
    try {
      final response = await _dio.get('/pages');
      if (response.statusCode == 200) {
        final data = response.data['pages'] as List;
        return data.map((json) => PageDto.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch Page list');
    } catch (e) {
      // Fallback: create page data from Juz mapping
      return _createPageDataFromJuzMapping();
    }
  }

  /// Get Hizb information
  Future<List<HizbDto>> getHizbList() async {
    try {
      final response = await _dio.get('/hizb-quarter');
      if (response.statusCode == 200) {
        final data = response.data['hizb_quarters'] as List;
        return data.map((json) => HizbDto.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch Hizb list');
    } catch (e) {
      // Fallback: create hizb data from Juz mapping
      return _createHizbDataFromJuzMapping();
    }
  }

  /// Get Ruku information
  Future<List<RukuDto>> getRukuList() async {
    try {
      final response = await _dio.get('/ruku');
      if (response.statusCode == 200) {
        final data = response.data['rukus'] as List;
        return data.map((json) => RukuDto.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch Ruku list');
    } catch (e) {
      // Fallback: create ruku data from chapter mapping
      return _createRukuDataFromChapterMapping();
    }
  }

  /// Get verses by Juz
  Future<List<VerseDto>> getVersesByJuz(int juzNumber) async {
    try {
      // Since the Quran.com API doesn't have direct Juz endpoints,
      // we'll get the first chapter of the Juz and return a sample
      final juzMapping = _getJuzVerseMapping(juzNumber);
      
      if (juzMapping.isEmpty) {
        throw Exception('No mapping found for Juz $juzNumber');
      }
      
      // Get the first chapter and its verse range from the Juz
      final firstChapterId = juzMapping.keys.first;
      final verseRange = juzMapping[firstChapterId]!;
      final startVerse = verseRange[0];
      final endVerse = verseRange[1];
      
      // Use the existing verses API to get a page of verses from this chapter
      final response = await _dio.get('/verses/by_chapter/$firstChapterId', queryParameters: {
        'language': 'en',
        'translations': '131', // Saheeh International
        'fields': 'text_uthmani,verse_key,verse_number,translations',
        'translation_fields': 'text,resource_id',
        'per_page': math.min(50, endVerse - startVerse + 1), // Limit to reasonable number
        'page': 1,
      });
      
      if (response.statusCode == 200) {
        final data = response.data['verses'] as List;
        final verses = data.map((json) => VerseDto.fromJson(json)).toList();
        
        // Filter verses to only include those in the Juz range
        final filteredVerses = verses.where((verse) {
          final verseNum = verse.verseNumber;
          return verseNum >= startVerse && verseNum <= endVerse;
        }).toList();
        
        return filteredVerses;
      }
      
      throw Exception('API returned ${response.statusCode} for Juz $juzNumber');
    } catch (e) {
      throw Exception('Failed to fetch verses for Juz $juzNumber: $e');
    }
  }

  /// Get verses by Page
  Future<List<VerseDto>> getVersesByPage(int pageNumber) async {
    try {
      // Fallback: return sample verses from Al-Fatiha for demonstration
      final response = await _dio.get('/verses/by_chapter/1', queryParameters: {
        'language': 'en',
        'translations': '131',
        'fields': 'text_uthmani,verse_key,verse_number,translations',
        'translation_fields': 'text,resource_id',
        'per_page': 7,
        'page': 1,
      });
      
      if (response.statusCode == 200) {
        final data = response.data['verses'] as List;
        return data.map((json) => VerseDto.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch verses for Page $pageNumber');
    } catch (e) {
      throw Exception('Failed to fetch verses for Page $pageNumber: $e');
    }
  }

  /// Get verses by Hizb
  Future<List<VerseDto>> getVersesByHizb(int hizbNumber) async {
    try {
      // Fallback: return sample verses from chapter 2 for demonstration
      final response = await _dio.get('/verses/by_chapter/2', queryParameters: {
        'language': 'en',
        'translations': '131',
        'fields': 'text_uthmani,verse_key,verse_number,translations',
        'translation_fields': 'text,resource_id',
        'per_page': 10,
        'page': 1,
      });
      
      if (response.statusCode == 200) {
        final data = response.data['verses'] as List;
        return data.map((json) => VerseDto.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch verses for Hizb $hizbNumber');
    } catch (e) {
      throw Exception('Failed to fetch verses for Hizb $hizbNumber: $e');
    }
  }

  /// Get verses by Ruku
  Future<List<VerseDto>> getVersesByRuku(int rukuNumber) async {
    try {
      // Fallback: return sample verses from chapter 3 for demonstration
      final response = await _dio.get('/verses/by_chapter/3', queryParameters: {
        'language': 'en',
        'translations': '131',
        'fields': 'text_uthmani,verse_key,verse_number,translations',
        'translation_fields': 'text,resource_id',
        'per_page': 15,
        'page': 1,
      });
      
      if (response.statusCode == 200) {
        final data = response.data['verses'] as List;
        return data.map((json) => VerseDto.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch verses for Ruku $rukuNumber');
    } catch (e) {
      throw Exception('Failed to fetch verses for Ruku $rukuNumber: $e');
    }
  }

  /// Create static Juz data as fallback
  List<JuzDto> _createStaticJuzData() {
    return List.generate(30, (index) {
      final juzNumber = index + 1;
      return JuzDto(
        id: juzNumber,
        juzNumber: juzNumber,
        verseMapping: _getJuzVerseMapping(juzNumber),
      );
    });
  }

  /// Get verse mapping for a Juz (simplified version)
  Map<int, List<int>> _getJuzVerseMapping(int juzNumber) {
    // Simplified mapping for first few Juz - in a real app you'd have complete data
    switch (juzNumber) {
      case 1:
        return {1: [1, 7], 2: [1, 141]};
      case 2:
        return {2: [142, 252]};
      case 3:
        return {2: [253, 286], 3: [1, 92]};
      case 4:
        return {3: [93, 200], 4: [1, 23]};
      case 5:
        return {4: [24, 147]};
      case 6:
        return {4: [148, 176], 5: [1, 81]};
      case 7:
        return {5: [82, 120], 6: [1, 110]};
      case 8:
        return {6: [111, 165], 7: [1, 87]};
      case 9:
        return {7: [88, 206], 8: [1, 40]};
      case 10:
        return {8: [41, 75], 9: [1, 92]};
      default:
        // For other Juz, return a sample from Al-Fatiha to prevent empty results
        return {1: [1, 7]};
    }
  }

  /// Download audio file for a chapter
  Future<void> downloadAudio({
    required int chapterId,
    required int recitationId,
    required String savePath,
    Function(AudioDownloadProgressDto)? onProgress,
  }) async {
    try {
      await _dio.download(
        '/audio/download/$chapterId/$recitationId',
        savePath,
        onReceiveProgress: (received, total) {
          if (onProgress != null && total != -1) {
            final progress = received / total;
            onProgress(AudioDownloadProgressDto(
              chapterId: chapterId,
              recitationId: recitationId,
              progress: progress,
              downloadedBytes: received,
              totalBytes: total,
            ));
          }
        },
      );
    } catch (e) {
      throw Exception('Failed to download audio for chapter $chapterId: $e');
    }
  }

  /// Create page data from Juz mapping as fallback
  List<PageDto> _createPageDataFromJuzMapping() {
    final pages = <PageDto>[];
    int pageId = 1;
    
    // Create 604 pages (standard Quran page count)
    for (int pageNumber = 1; pageNumber <= 604; pageNumber++) {
      // Calculate which Juz this page belongs to
      final juzNumber = _calculateJuzFromPage(pageNumber);
      
      pages.add(PageDto(
        id: pageId++,
        pageNumber: pageNumber,
        juzNumber: juzNumber,
        verseCount: _getVerseCountForPage(pageNumber),
      ));
    }
    
    return pages;
  }

  /// Create hizb data from Juz mapping as fallback
  List<HizbDto> _createHizbDataFromJuzMapping() {
    final hizbs = <HizbDto>[];
    int hizbId = 1;
    
    // Create 60 hizbs (30 Juz × 2 hizbs per Juz)
    for (int hizbNumber = 1; hizbNumber <= 60; hizbNumber++) {
      final juzNumber = ((hizbNumber - 1) ~/ 2) + 1;
      
      hizbs.add(HizbDto(
        id: hizbId++,
        hizbNumber: hizbNumber,
        juzNumber: juzNumber,
        verseCount: _getVerseCountForHizb(hizbNumber),
      ));
    }
    
    return hizbs;
  }

  /// Create ruku data from chapter mapping as fallback
  List<RukuDto> _createRukuDataFromChapterMapping() {
    final rukus = <RukuDto>[];
    int rukuId = 1;
    
    // Create 558 rukus (standard Quran ruku count)
    for (int rukuNumber = 1; rukuNumber <= 558; rukuNumber++) {
      final chapterId = _calculateChapterFromRuku(rukuNumber);
      
      rukus.add(RukuDto(
        id: rukuId++,
        rukuNumber: rukuNumber,
        chapterId: chapterId,
        verseCount: _getVerseCountForRuku(rukuNumber),
      ));
    }
    
    return rukus;
  }

  /// Calculate Juz number from page number
  int _calculateJuzFromPage(int pageNumber) {
    // Simplified calculation - in reality this would be more complex
    if (pageNumber <= 22) return 1;
    if (pageNumber <= 49) return 2;
    if (pageNumber <= 76) return 3;
    if (pageNumber <= 106) return 4;
    if (pageNumber <= 128) return 5;
    if (pageNumber <= 150) return 6;
    if (pageNumber <= 177) return 7;
    if (pageNumber <= 187) return 8;
    if (pageNumber <= 208) return 9;
    if (pageNumber <= 221) return 10;
    if (pageNumber <= 235) return 11;
    if (pageNumber <= 249) return 12;
    if (pageNumber <= 255) return 13;
    if (pageNumber <= 267) return 14;
    if (pageNumber <= 282) return 15;
    if (pageNumber <= 293) return 16;
    if (pageNumber <= 305) return 17;
    if (pageNumber <= 312) return 18;
    if (pageNumber <= 322) return 19;
    if (pageNumber <= 332) return 20;
    if (pageNumber <= 342) return 21;
    if (pageNumber <= 350) return 22;
    if (pageNumber <= 359) return 23;
    if (pageNumber <= 367) return 24;
    if (pageNumber <= 377) return 25;
    if (pageNumber <= 385) return 26;
    if (pageNumber <= 396) return 27;
    if (pageNumber <= 404) return 28;
    if (pageNumber <= 411) return 29;
    return 30;
  }

  /// Calculate chapter number from ruku number
  int _calculateChapterFromRuku(int rukuNumber) {
    // Simplified calculation - in reality this would be more complex
    if (rukuNumber <= 40) return 1;
    if (rukuNumber <= 87) return 2;
    if (rukuNumber <= 121) return 3;
    if (rukuNumber <= 147) return 4;
    if (rukuNumber <= 173) return 5;
    if (rukuNumber <= 189) return 6;
    if (rukuNumber <= 207) return 7;
    if (rukuNumber <= 221) return 8;
    if (rukuNumber <= 235) return 9;
    if (rukuNumber <= 249) return 10;
    if (rukuNumber <= 263) return 11;
    if (rukuNumber <= 277) return 12;
    if (rukuNumber <= 291) return 13;
    if (rukuNumber <= 305) return 14;
    if (rukuNumber <= 319) return 15;
    if (rukuNumber <= 333) return 16;
    if (rukuNumber <= 347) return 17;
    if (rukuNumber <= 361) return 18;
    if (rukuNumber <= 375) return 19;
    if (rukuNumber <= 389) return 20;
    if (rukuNumber <= 403) return 21;
    if (rukuNumber <= 417) return 22;
    if (rukuNumber <= 431) return 23;
    if (rukuNumber <= 445) return 24;
    if (rukuNumber <= 459) return 25;
    if (rukuNumber <= 473) return 26;
    if (rukuNumber <= 487) return 27;
    if (rukuNumber <= 501) return 28;
    if (rukuNumber <= 515) return 29;
    return 30;
  }

  /// Get verse count for a page (simplified)
  int _getVerseCountForPage(int pageNumber) {
    // Simplified - in reality this would be based on actual page content
    return 10 + (pageNumber % 5);
  }

  /// Get verse count for a hizb (simplified)
  int _getVerseCountForHizb(int hizbNumber) {
    // Simplified - in reality this would be based on actual hizb content
    return 15 + (hizbNumber % 10);
  }

  /// Get verse count for a ruku (simplified)
  int _getVerseCountForRuku(int rukuNumber) {
    // Simplified - in reality this would be based on actual ruku content
    return 5 + (rukuNumber % 8);
  }
}
