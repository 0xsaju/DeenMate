import 'package:dio/dio.dart';
import '../dto/translation_resource_dto.dart';
import '../dto/recitation_resource_dto.dart';
import '../dto/tafsir_dto.dart';
import '../dto/word_analysis_dto.dart';
import '../dto/audio_download_dto.dart';

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
        return data
            .map((json) => RecitationResourceDto.fromJson(json))
            .toList();
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
}
