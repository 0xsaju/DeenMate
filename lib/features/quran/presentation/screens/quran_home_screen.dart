import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/dto/chapter_dto.dart';
import '../state/providers.dart';
import '../../../../core/theme/theme_helper.dart';

class QuranHomeScreen extends ConsumerStatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  ConsumerState<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends ConsumerState<QuranHomeScreen> {
  String _selectedTab = 'Sura';
  final List<String> _tabs = ['Sura', 'Page', 'Juz', 'Hizb', 'Ruku'];

  @override
  Widget build(BuildContext context) {
    final chapters = ref.watch(surahListProvider);
    final lastRead = ref.watch(lastReadProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.menu, color: ThemeHelper.getTextPrimaryColor(context)),
          onPressed: () {
            // TODO: Implement menu
          },
        ),
        title: Text(
          'Al Quran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search,
                color: ThemeHelper.getTextPrimaryColor(context)),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: chapters.when(
        data: (list) => _buildBody(context, list, lastRead),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7B1FA2),
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading Quran',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<ChapterDto> list,
      AsyncValue<LastReadEntry?> lastReadAsync) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Last Read Section
        if (lastReadAsync.value != null) ...[
          const Text(
            'Last Read',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 12),
          _buildLastReadSection(lastReadAsync.value!, list),
          const SizedBox(height: 24),
        ],

        // Navigation Tabs
        _buildNavigationTabs(),
        const SizedBox(height: 16),

        // Chapter List
        ..._buildSurahList(list),
      ],
    );
  }

  Widget _buildLastReadSection(LastReadEntry last, List<ChapterDto> chapters) {
    // Mock data for multiple last read items as shown in design
    final lastReadItems = [
      {'name': 'Al-Baqarah', 'verse': '285', 'chapterId': 2},
      {'name': 'Al-Mumtahanah', 'verse': '9', 'chapterId': 60},
      {'name': 'Al-M', 'verse': '1', 'chapterId': 3},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lastReadItems.length,
        itemBuilder: (context, index) {
          final item = lastReadItems[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                      ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.getPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verse ${item['verse']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getTextSecondaryColor(context),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeHelper.getPrimaryColor(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = tab == _selectedTab;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = tab;
                });
                // TODO: Implement tab switching
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ThemeHelper.getPrimaryColor(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? ThemeHelper.getPrimaryColor(context)
                        : ThemeHelper.getDividerColor(context),
                    width: 1,
                  ),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : ThemeHelper.getPrimaryColor(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSurahList(List<ChapterDto> list) {
    return list.map((chapter) => _buildSurahTile(chapter)).toList();
  }

  Widget _buildSurahTile(ChapterDto chapter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${chapter.id}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeHelper.getPrimaryColor(context),
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  chapter.nameSimple,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.getTextPrimaryColor(context),
                  ),
                ),
              ),
              Text(
                chapter.nameArabic,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ThemeHelper.getPrimaryColor(context),
                  fontFamily: 'Uthmani',
                ),
              ),
            ],
          ),
          subtitle: Text(
            '${chapter.versesCount} Verses • ${chapter.revelationPlace}',
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
          onTap: () => GoRouter.of(context).push('/quran/surah/${chapter.id}'),
        ),
      ),
    );
  }
}
