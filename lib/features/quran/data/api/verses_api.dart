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
    final r =
        await dio.get('/verses/by_chapter/$chapterId', queryParameters: q);
    // Debug
    // ignore: avoid_print
    print(
        'QuranAPI byChapter status: ${r.statusCode} url: ${r.requestOptions.uri}');
    try {
      final map = r.data as Map<String, dynamic>;
      final verses = map['verses'] as List<dynamic>?;
      // ignore: avoid_print
      print('QuranAPI byChapter verseCount: ${verses?.length}');
    } catch (_) {}
    return VersesPageDto.fromJson(r.data as Map<String, dynamic>);
  }
}
