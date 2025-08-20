import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/dto/chapter_dto.dart';
import '../state/providers.dart';

class QuranHomeScreen extends ConsumerWidget {
  const QuranHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(surahListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Qur\'an')),
      body: chapters.when(
        data: (list) => _buildList(context, list),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<ChapterDto> list) {
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, i) {
        final c = list[i];
        return ListTile(
          title: Text('${c.nameArabic} — ${c.nameSimple}'),
          subtitle: Text('${c.revelationPlace} • ${c.versesCount} ayah'),
          onTap: () => GoRouter.of(context).push('/quran/surah/${c.id}'),
        );
      },
    );
  }
}
