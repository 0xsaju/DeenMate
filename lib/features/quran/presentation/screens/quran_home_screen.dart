import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/dto/chapter_dto.dart';
import '../state/providers.dart';
import '../../../../core/theme/theme_helper.dart';
import 'quran_reader_screen.dart';

class QuranHomeScreen extends ConsumerStatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  ConsumerState<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends ConsumerState<QuranHomeScreen> {
  String _selectedTab = 'Sura';
  final List<String> _tabs = ['Sura', 'Page', 'Juz', 'Hizb', 'Ruku'];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  List<ChapterDto> _filteredChapters = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query, List<ChapterDto> allChapters) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredChapters = allChapters;
      } else {
        _filteredChapters = allChapters.where((chapter) {
          final queryLower = query.toLowerCase();
          
          // Search by English name
          if (chapter.nameSimple.toLowerCase().contains(queryLower)) return true;
          
          // Search by Arabic name
          if (chapter.nameArabic.contains(query)) return true;
          
          // Search by chapter number
          if (chapter.id.toString() == query) return true;
          
          // Search by verse reference (e.g., "2:255")
          if (query.contains(':')) {
            final parts = query.split(':');
            if (parts.length == 2) {
              final chapterNum = int.tryParse(parts[0]);
              if (chapterNum == chapter.id) return true;
            }
          }
          
          return false;
        }).toList();
      }
    });
  }

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
        leading: _isSearching ? null : IconButton(
          icon:
              Icon(Icons.menu, color: ThemeHelper.getTextPrimaryColor(context)),
          onPressed: () {
            // TODO: Implement menu
          },
        ),
        title: _isSearching ? _buildSearchField() : Text(
          'Al Quran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        centerTitle: !_isSearching,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: ThemeHelper.getTextPrimaryColor(context)),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                  _filteredChapters = [];
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: chapters.when(
        data: (list) {
          // Initialize filtered chapters if needed
          if (!_isSearching && _filteredChapters.isEmpty) {
            _filteredChapters = list;
          }
          
          final displayList = _isSearching || _searchQuery.isNotEmpty ? _filteredChapters : list;
          return _buildBody(context, displayList, lastRead);
        },
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: TextStyle(
        color: ThemeHelper.getTextPrimaryColor(context),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'Search surah, verse number...',
        hintStyle: TextStyle(
          color: ThemeHelper.getTextSecondaryColor(context),
          fontSize: 16,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: (query) {
        final chapters = ref.read(surahListProvider);
        chapters.whenData((list) {
          _performSearch(query, list);
        });
      },
      onSubmitted: (query) {
        // Handle verse reference search (e.g., "2:255")
        if (query.contains(':')) {
          final parts = query.split(':');
          if (parts.length == 2) {
            final chapterNum = int.tryParse(parts[0]);
            final verseNum = int.tryParse(parts[1]);
            if (chapterNum != null && verseNum != null) {
              // Navigate directly to the verse
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranReaderScreen(
                    chapterId: chapterNum,
                    targetVerseKey: query,
                  ),
                ),
              );
              return;
            }
          }
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, List<ChapterDto> list,
      AsyncValue<LastReadEntry?> lastReadAsync) {
    
    // Show search results
    if (_isSearching) {
      if (_searchQuery.isEmpty) {
        return _buildSearchGuidance();
      } else if (list.isEmpty) {
        return _buildNoSearchResults();
      } else {
        return _buildSearchResults(list);
      }
    }
    
    // Show normal content
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
    // Find the chapter for the last read entry
    final chapter = chapters.firstWhere(
      (c) => c.id == last.chapterId,
      orElse: () => ChapterDto(
        id: last.chapterId,
        nameArabic: 'Unknown',
        nameSimple: 'Unknown',
        versesCount: 0,
        revelationPlace: 'Meccan',
      ),
    );

    // Extract verse number from verse key (e.g., "2:255" -> "255")
    final verseNumber = last.verseKey.split(':').last;

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // Navigate to the last read position
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuranReaderScreen(
                        chapterId: last.chapterId,
                        targetVerseKey: last.verseKey,
                      ),
                    ),
                  );
                },
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
                        chapter.nameSimple,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.getPrimaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verse $verseNumber',
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
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: ThemeHelper.getPrimaryColor(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildSearchGuidance() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: ThemeHelper.getTextSecondaryColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Search Al Quran',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for:',
            style: TextStyle(
              fontSize: 16,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildSearchExample('Surah names', 'Al-Baqarah, Yasin'),
          _buildSearchExample('Chapter numbers', '1, 2, 36'),
          _buildSearchExample('Verse references', '2:255, 36:9'),
        ],
      ),
    );
  }

  Widget _buildSearchExample(String title, String example) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: ThemeHelper.getPrimaryColor(context),
          ),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          Text(
            example,
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: ThemeHelper.getTextSecondaryColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords or check the spelling.',
            style: TextStyle(
              fontSize: 16,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<ChapterDto> results) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search results header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '${results.length} result${results.length == 1 ? '' : 's'} for "$_searchQuery"',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
        ),
        
        // Search results list
        ...results.map((chapter) => _buildSurahTile(chapter)).toList(),
      ],
    );
  }
}
