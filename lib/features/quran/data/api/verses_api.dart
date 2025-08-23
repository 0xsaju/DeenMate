import 'package:dio/dio.dart';
import '../dto/verses_page_dto.dart';

class VersesApi {
  VersesApi(this.dio);
  final Dio dio;

  Future<VersesPageDto> byChapter({
    required int chapterId,
    required List<int> translationIds,
    int? recitationId,
    int page = 1,
    int perPage = 50,
  }) async {
    final q = <String, dynamic>{
      'language': 'en',
      'translations': translationIds.join(','),
      'page': page,
      'per_page': perPage,
      'words': 'false',
      'fields': 'text_uthmani,translations,audio,verse_key,verse_number',
      'translation_fields': 'text,resource_id,language_name',
      if (recitationId != null && recitationId != 0) 'audio': recitationId,
    };
    if (translationIds.isEmpty) {
      q.remove('translations');
    }
    // Try different API endpoints to see which one works
    final r = await dio.get('/verses/by_chapter/$chapterId', queryParameters: q);
    // Debug
    // ignore: avoid_print
    print(
        'QuranAPI byChapter status: ${r.statusCode} url: ${r.requestOptions.uri}');
    try {
      final map = r.data as Map<String, dynamic>;
      final verses = map['verses'] as List<dynamic>?;
      // ignore: avoid_print
      print('QuranAPI byChapter verseCount: ${verses?.length}');
      
      // Debug: Check the first verse structure
      if (verses != null && verses.isNotEmpty) {
        final firstVerse = verses.first as Map<String, dynamic>;
        print('DEBUG: First verse keys: ${firstVerse.keys.toList()}');
        print('DEBUG: First verse has translations: ${firstVerse.containsKey('translations')}');
        
        // Check if translations exist in the response
        if (firstVerse.containsKey('translations')) {
          final translations = firstVerse['translations'] as List<dynamic>?;
          print('DEBUG: Translations count: ${translations?.length}');
          if (translations != null && translations.isNotEmpty) {
            final firstTranslation = translations.first as Map<String, dynamic>;
            print('DEBUG: First translation keys: ${firstTranslation.keys.toList()}');
          }
        } else {
          // If no translations field, check if there's a different field name
          print('DEBUG: No translations field found. Checking for alternative field names...');
          final possibleFields = ['translation', 'text_translation', 'translated_text'];
          for (final field in possibleFields) {
            if (firstVerse.containsKey(field)) {
              print('DEBUG: Found alternative field: $field');
              final fieldData = firstVerse[field];
              print('DEBUG: Field data type: ${fieldData.runtimeType}');
              if (fieldData is List) {
                print('DEBUG: Field data length: ${fieldData.length}');
              }
            }
          }
        }
        
        // Print the full first verse for debugging
        print('DEBUG: Full first verse data: $firstVerse');
      }
    } catch (e) {
      print('DEBUG: Error parsing API response: $e');
    }
    return VersesPageDto.fromJson(r.data as Map<String, dynamic>);
  }
}
