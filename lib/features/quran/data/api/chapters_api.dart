import 'package:dio/dio.dart';
import '../dto/chapter_dto.dart';

class ChaptersApi {
  ChaptersApi(this.dio);
  final Dio dio;

  Future<List<ChapterDto>> list() async {
    final r = await dio.get('/chapters', queryParameters: {'language': 'en'});
    final list = (r.data['chapters'] as List)
        .map((e) => e as Map<String, dynamic>)
        .map((e) => ChapterDto.fromJson(e))
        .toList();
    return list;
  }
}
