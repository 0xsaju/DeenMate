import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/quran_repository.dart';
import '../../data/dto/chapter_dto.dart';
import '../../data/dto/verses_page_dto.dart';

final surahListProvider = FutureProvider.autoDispose<List<ChapterDto>>((ref) async {
  final repo = ref.read(quranRepositoryProvider);
  return repo.getChapters();
});

class SurahPageArgs {
  const SurahPageArgs({required this.chapterId, required this.translationIds, this.reciterId, required this.page});
  final int chapterId;
  final List<int> translationIds;
  final int? reciterId;
  final int page;
}

final surahPageProvider = FutureProvider.family.autoDispose<VersesPageDto, SurahPageArgs>((ref, args) async {
  final repo = ref.read(quranRepositoryProvider);
  return repo.getChapterPage(
    chapterId: args.chapterId,
    translationIds: args.translationIds,
    reciterId: args.reciterId,
    page: args.page,
  );
});


