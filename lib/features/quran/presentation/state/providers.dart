import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/net/dio_client.dart';
import '../../data/api/chapters_api.dart';
import '../../data/api/verses_api.dart';
import '../../data/repo/quran_repository.dart';
import '../../data/dto/chapter_dto.dart';
import '../../data/dto/verses_page_dto.dart';

final dioQfProvider = Provider((ref) => ref.watch(dioProvider));
final chaptersApiProvider =
    Provider((ref) => ChaptersApi(ref.watch(dioQfProvider)));
final versesApiProvider =
    Provider((ref) => VersesApi(ref.watch(dioQfProvider)));
final quranRepoProvider = Provider((ref) => QuranRepository(
      ref.watch(chaptersApiProvider),
      ref.watch(versesApiProvider),
      Hive,
    ));

final surahListProvider =
    FutureProvider.autoDispose<List<ChapterDto>>((ref) async {
  final repo = ref.read(quranRepoProvider);
  return repo.getChapters();
});

class SurahPageArgs {
  const SurahPageArgs(this.chapterId, this.page,
      {this.translationIds = const [20], this.recitationId = 0});
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
  try {
    final dto = await repo.getChapterPage(
      chapterId: args.chapterId,
      translationIds: args.translationIds,
      recitationId: args.recitationId,
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
