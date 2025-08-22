import 'package:dio/dio.dart';
import '../dto/translation_resource_dto.dart';
import '../dto/recitation_resource_dto.dart';

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
            .map((json) => TranslationResourceDto.fromJson(json))
            .toList();
      }

      throw Exception('Failed to fetch translation resources');
    } catch (e) {
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
}
