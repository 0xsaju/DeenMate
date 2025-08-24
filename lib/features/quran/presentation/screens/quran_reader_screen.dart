import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/dto/verse_dto.dart';
import '../../data/dto/translation_resource_dto.dart';
import '../state/providers.dart';
import '../widgets/translation_picker_widget.dart';
import '../../../../core/theme/theme_helper.dart';
import '../../../../core/storage/hive_boxes.dart' as boxes;

class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({
    super.key,
    required this.chapterId,
    this.targetVerseKey,
  });
  final int chapterId;
  final String? targetVerseKey;

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen>
    with WidgetsBindingObserver {
  final ScrollController _controller = ScrollController();
  final Map<int, List<VerseDto>> _pageCache = {};
  final List<VerseDto> _verses = [];
  final List<String> _audioUrls = [];
  final Set<String> _localBookmarkOn = {};
  final Set<String> _localBookmarkOff = {};
  static const int _maxCachedPages = 5;
  int _page = 1;
  int _totalPages = 1;
  bool _loading = false;
  bool _isFetchingMore = false;
  int? _inflightPage;
  String? _errorMessage;

  Timer? _scrollDebounceTimer;
  Timer? _periodicSaveTimer;
  int _lastSavedVerseIndex = -1;
  Timer? _autoScrollTimer;
  bool _autoScrolling = false;
  double _autoScrollSpeedPxPerSec = 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPage(1);
    _controller.addListener(_onScroll);

    _controller.addListener(() {
      if (!_controller.position.isScrollingNotifier.value) {
        _onScrollEnd();
      }
    });

    _periodicSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_controller.hasClients) {
        _saveCurrentVersePosition();
      }
    });

    // Note: Removed clearCacheAndReset call as it was resetting user preferences

    // Listen for translation preference changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(prefsProvider, (previous, next) {
        print('DEBUG: Translation preferences changed from ${previous?.selectedTranslationIds} to ${next.selectedTranslationIds}');
        if (previous?.selectedTranslationIds != next.selectedTranslationIds) {
          print('DEBUG: Calling _onTranslationPreferencesChanged');
          _onTranslationPreferencesChanged();
        }
      });
    });
  }

  void _updateVersesFromCache() {
    final allVerses = <VerseDto>[];
    final allUrls = <String>[];
    final sortedPages = _pageCache.keys.toList()..sort();
    for (final page in sortedPages) {
      final pageVerses = _pageCache[page] ?? [];
      allVerses.addAll(pageVerses);
      allUrls.addAll(pageVerses.map((v) => v.audio?.url ?? ''));
    }
    setState(() {
      _verses.clear();
      _verses.addAll(allVerses);
      _audioUrls.clear();
      _audioUrls.addAll(allUrls);
      ref.read(quranAudioProvider.notifier).setPlaylist(_audioUrls);
    });
  }

  void _onTranslationPreferencesChanged() async {
    print('DEBUG: _onTranslationPreferencesChanged - clearing cache and reloading page $_page');
    
    // Clear the page cache when translations change
    _pageCache.clear();
    
    // Clear the Hive cache for all pages of this chapter to force fresh API calls
    final vBox = await Hive.openBox(boxes.Boxes.verses);
    
    // Clear all cached pages for this chapter with any translation combination
    final keysToDelete = <String>[];
    for (final key in vBox.keys) {
      if (key.toString().startsWith('ch:${widget.chapterId}|')) {
        keysToDelete.add(key.toString());
      }
    }
    
    for (final key in keysToDelete) {
      await vBox.delete(key);
      print('DEBUG: Deleted cache key: $key');
    }
    
    // Reload the current page with new translations
    await _loadPage(_page);
  }

  void _cleanupOldPages() {
    if (_pageCache.length > _maxCachedPages) {
      final sortedPages = _pageCache.keys.toList()..sort();
      final pagesToRemove =
          sortedPages.take(_pageCache.length - _maxCachedPages);
      for (final page in pagesToRemove) {
        _pageCache.remove(page);
      }
    }
  }

  void _onScroll() {
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      _saveCurrentVersePosition();
    });
  }

  void _onScrollEnd() {
    _saveCurrentVersePosition();
  }

  void _saveCurrentVersePosition() {
    if (!_controller.hasClients || _verses.isEmpty) return;

    try {
      final scrollPosition = _controller.offset;
      final viewportHeight = _controller.position.viewportDimension;
      final centerY = scrollPosition + (viewportHeight / 2);

      final totalHeight = _controller.position.maxScrollExtent + viewportHeight;
      final averageVerseHeight = totalHeight / _verses.length;
      final estimatedIndex = centerY / averageVerseHeight;
      final clampedIndex = estimatedIndex.round().clamp(0, _verses.length - 1);

      if (clampedIndex != _lastSavedVerseIndex &&
          clampedIndex >= 0 &&
          clampedIndex < _verses.length) {
        final currentVerse = _verses[clampedIndex];
        _updateLastRead(currentVerse);
        _lastSavedVerseIndex = clampedIndex;
      }
    } catch (e) {
      print('Error saving verse position: $e');
    }
  }

  void _updateLastRead(VerseDto v) {
    final updater = ref.read(lastReadUpdaterProvider);
    double? offset;
    if (_controller.hasClients) {
      final min = 0.0;
      final max = _controller.position.maxScrollExtent;
      offset = _controller.offset.clamp(min, max);
    }
    updater(LastReadEntry(
      chapterId: widget.chapterId,
      verseKey: v.verseKey,
      scrollOffset: offset,
    ));
  }

  void _scrollToVerse(String verseKey) {
    if (!_controller.hasClients || _verses.isEmpty) return;

    final verseIndex = _verses.indexWhere((v) => v.verseKey == verseKey);
    if (verseIndex == -1) return;

    final totalHeight = _controller.position.maxScrollExtent +
        _controller.position.viewportDimension;
    final averageVerseHeight = totalHeight / _verses.length;
    final estimatedScrollPosition = (verseIndex * averageVerseHeight) -
        (_controller.position.viewportDimension / 2);

    final clampedScrollPosition = estimatedScrollPosition.clamp(
        0.0, _controller.position.maxScrollExtent);

    _controller.animateTo(
      clampedScrollPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadPage(int page) async {
    if (_inflightPage == page) return;
    if (_pageCache.containsKey(page)) {
      _updateVersesFromCache();
      return;
    }
    final bool isInitial = _verses.isEmpty && page == 1;
    setState(() {
      _errorMessage = null;
      _inflightPage = page;
      if (isInitial) {
        _loading = true;
      } else {
        _isFetchingMore = true;
      }
    });
    try {
      final prefs = ref.read(prefsProvider);
      print('DEBUG: Loading page $page with translation IDs: ${prefs.selectedTranslationIds}');
      final args = SurahPageArgs(
        widget.chapterId, 
        page,
        translationIds: prefs.selectedTranslationIds,
      );
      final dto = await ref.read(surahPageProvider(args).future);
      setState(() {
        _page = dto.pagination.currentPage;
        _totalPages = dto.pagination.totalPages;
        _pageCache[page] = dto.verses;
        _cleanupOldPages();
        _updateVersesFromCache();
        if (isInitial && dto.verses.isNotEmpty) {
          _updateLastRead(dto.verses.first);
        }
      });

      if (isInitial && widget.targetVerseKey != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToVerse(widget.targetVerseKey!);
        });
      }
      if (isInitial && widget.targetVerseKey == null) {
        final last = ref.read(lastReadProvider).value;
        if (last != null && last.chapterId == widget.chapterId) {
          () async {
            if (last.scrollOffset != null && _controller.hasClients) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _controller.jumpTo(
                  last.scrollOffset!
                      .clamp(0.0, _controller.position.maxScrollExtent),
                );
              });
            } else {
              await _ensureVerseLoaded(last.verseKey);
              if (!mounted) return;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToVerse(last.verseKey);
              });
            }
          }();
        }
      }
    } catch (e) {
      print('Reader: load failed for page=$page error=$e');
      if (isInitial) {
        _errorMessage = e.toString();
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _isFetchingMore = false;
          _inflightPage = null;
        });
      }
    }
  }

  Future<void> _ensureVerseLoaded(String verseKey) async {
    if (_verses.any((v) => v.verseKey == verseKey)) return;
    while (_page < _totalPages) {
      final next = _page + 1;
      await _loadPage(next);
      if (_verses.any((v) => v.verseKey == verseKey)) break;
      if (next >= _totalPages) break;
    }
  }

  @override
  void dispose() {
    if (_controller.hasClients) {
      _saveCurrentVersePosition();
    }
    _scrollDebounceTimer?.cancel();
    _periodicSaveTimer?.cancel();
    _autoScrollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (_controller.hasClients) {
          _saveCurrentVersePosition();
        }
      },
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus && _controller.hasClients) {
            _saveCurrentVersePosition();
          }
        },
        child: Scaffold(
          backgroundColor: ThemeHelper.getBackgroundColor(context),
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomControls(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final chaptersAsync = ref.watch(surahListProvider);
    return AppBar(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu, color: ThemeHelper.getTextPrimaryColor(context)),
        onPressed: () {
          // TODO: Implement drawer
        },
      ),
      title: chaptersAsync.maybeWhen(
        data: (list) {
          final c = list.firstWhere((e) => e.id == widget.chapterId,
              orElse: () => list.first);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.chapterId}. ${c.nameSimple}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ThemeHelper.getTextPrimaryColor(context),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down,
                  color: ThemeHelper.getPrimaryColor(context), size: 20),
            ],
          );
        },
        orElse: () => Text(
          'Surah ${widget.chapterId}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.settings,
              color: ThemeHelper.getTextPrimaryColor(context)),
          onPressed: () => _openQuickTools(context),
          tooltip: 'Quick Tools',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
          child: CircularProgressIndicator(
        color: ThemeHelper.getPrimaryColor(context),
      ));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Failed to load: $_errorMessage',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadPage(1),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSurahInfoCard(),
        Expanded(
          child: _buildVersesList(),
        ),
      ],
    );
  }

  Widget _buildSurahInfoCard() {
    final chaptersAsync = ref.watch(surahListProvider);
    return chaptersAsync.maybeWhen(
      data: (list) {
        final c = list.firstWhere((e) => e.id == widget.chapterId,
            orElse: () => list.first);
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeHelper.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ThemeHelper.getDividerColor(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.nameSimple,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.nameArabic,
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeHelper.getTextSecondaryColor(context),
                        fontFamily: 'Uthmani',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${c.versesCount} Verses • ${c.revelationPlace}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.mosque,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 32,
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildVersesList() {
    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _verses.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _verses.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: Color(0xFF7B1FA2),
              ),
            ),
          );
        }

        final verse = _verses[index];
        return _buildVerseCard(verse);
      },
    );
  }

  Widget _buildVerseCard(VerseDto verse) {
    final isBookmarked = _isVerseBookmarked(verse.verseKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bismillah for first verse of each surah (except Al-Fatihah)
          if (verse.verseNumber == 1 && widget.chapterId > 1)
            Consumer(
              builder: (context, ref, child) {
                final prefs = ref.watch(prefsProvider);
                if (!prefs.showArabic) return const SizedBox.shrink();
                
                return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: TextStyle(
                      fontSize: prefs.arabicFontSize,
                  fontWeight: FontWeight.w600,
                  color: ThemeHelper.getPrimaryColor(context),
                  fontFamily: 'Uthmani',
                ),
                textAlign: TextAlign.center,
              ),
                );
              },
            ),

          // Verse number and controls
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    verse.verseNumber.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.getPrimaryColor(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildVerseControl(
                      icon: Icons.play_arrow,
                      onTap: () => _playVerse(verse),
                    ),
                    const SizedBox(width: 8),
                    _buildVerseControl(
                      icon:
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      onTap: () => _toggleBookmark(verse.verseKey),
                      isActive: isBookmarked,
                    ),
                    const SizedBox(width: 8),
                    _buildVerseControl(
                      icon: Icons.share,
                      onTap: () => _shareVerse(verse),
                    ),
                    const SizedBox(width: 8),
                    _buildVerseControl(
                      icon: Icons.more_vert,
                      onTap: () => _showVerseOptions(verse),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Arabic text
          Consumer(
            builder: (context, ref, child) {
              final prefs = ref.watch(prefsProvider);
              if (!prefs.showArabic) return const SizedBox.shrink();
              
              return Text(
            verse.textUthmani,
            style: TextStyle(
                  fontSize: prefs.arabicFontSize,
              fontWeight: FontWeight.w500,
              color: ThemeHelper.getTextPrimaryColor(context),
              fontFamily: 'Uthmani',
                  height: prefs.arabicLineHeight,
            ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Translations
          // Debug: Check if translations exist
          Builder(builder: (context) {
            print('DEBUG: Verse ${verse.verseNumber} - translations.isNotEmpty: ${verse.translations.isNotEmpty}');
            return const SizedBox.shrink();
          }),
          Consumer(
            builder: (context, ref, child) {
              final prefs = ref.watch(prefsProvider);
              if (!prefs.showTranslation || verse.translations.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  const SizedBox(height: 12),
                  _buildTranslationsSection(verse),
                ],
              );
            },
            ),
        ],
      ),
    );
  }

  Widget _buildVerseControl({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? ThemeHelper.getPrimaryColor(context).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? ThemeHelper.getPrimaryColor(context)
              : ThemeHelper.getTextSecondaryColor(context),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        border: Border(
          top: BorderSide(
            color: ThemeHelper.getDividerColor(context),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openAudioManager(context),
                icon: Icon(Icons.headphones,
                    color: ThemeHelper.getPrimaryColor(context)),
                label: Text(
                  'Audio Manager',
                  style: TextStyle(color: ThemeHelper.getPrimaryColor(context)),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: ThemeHelper.getPrimaryColor(context)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openAutoScrollManager(context),
                icon: Icon(Icons.auto_awesome,
                    color: ThemeHelper.getPrimaryColor(context)),
                label: Text(
                  'Auto Scroll',
                  style: TextStyle(color: ThemeHelper.getPrimaryColor(context)),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: ThemeHelper.getPrimaryColor(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _cleanTranslationText(String raw) {
    return raw
        .replaceAll(RegExp(r'<sup[^>]*>[\s\S]*?<\/sup>', dotAll: true), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Widget _buildTranslationsSection(VerseDto verse) {
    final prefs = ref.watch(prefsProvider);
    final resourcesAsync = ref.watch(translationResourcesProvider);
    
    return resourcesAsync.when(
      data: (resources) {
        // Debug: Print all available translations and selected IDs
        print('DEBUG: Available translations in verse: ${verse.translations.length}');
        print('DEBUG: Selected translation IDs: ${prefs.selectedTranslationIds}');
        for (var translation in verse.translations) {
          print('DEBUG: Translation resourceId: ${translation.resourceId}, text preview: ${translation.text.substring(0, translation.text.length > 30 ? 30 : translation.text.length)}...');
        }
        
        // Get selected translations with fallback logic
        var selectedTranslations = <TranslationDto>[];
        
        // First try to match selected translation IDs
        if (prefs.selectedTranslationIds.isNotEmpty) {
          selectedTranslations = verse.translations
              .where((translation) => 
                  prefs.selectedTranslationIds.contains(translation.resourceId))
              .toList();
        }
        
        // If no matches found, use any available translation
        if (selectedTranslations.isEmpty && verse.translations.isNotEmpty) {
          selectedTranslations = [verse.translations.first];
        }
        
        // Debug info to see what's happening
        print('DEBUG: Available translations: ${verse.translations.length}, Selected: ${selectedTranslations.length}');
        print('DEBUG: Selected translation IDs: ${prefs.selectedTranslationIds}');
        for (var translation in verse.translations) {
          print('DEBUG: Translation resourceId: ${translation.resourceId}, text preview: ${translation.text.substring(0, translation.text.length > 30 ? 30 : translation.text.length)}...');
        }
        
        if (selectedTranslations.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeHelper.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ThemeHelper.getDividerColor(context),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Translation Loading...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.getTextSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Available translations: ${verse.translations.length}\nSelected IDs: ${prefs.selectedTranslationIds.join(', ')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelper.getTextSecondaryColor(context),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while translations are being loaded...',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelper.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: selectedTranslations.map((translation) {
            // Find translation resource info
            final resource = resources.firstWhere(
              (r) => r.id == translation.resourceId,
              orElse: () => TranslationResourceDto(
                id: translation.resourceId,
                name: 'Translation ${translation.resourceId}',
                authorName: 'Unknown',
                languageName: 'Unknown',
                slug: 'unknown',
              ),
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeHelper.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ThemeHelper.getDividerColor(context),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Translation header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          resource.languageName ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.getPrimaryColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          resource.name ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ThemeHelper.getTextSecondaryColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Translation text
                  Consumer(
                    builder: (context, ref, child) {
                      final prefs = ref.watch(prefsProvider);
                      return Text(
                        _cleanTranslationText(translation.text),
                        style: TextStyle(
                          fontSize: prefs.translationFontSize,
                          color: ThemeHelper.getTextPrimaryColor(context),
                          height: prefs.translationLineHeight,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(12),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Text(
          'Failed to load translations',
          style: TextStyle(
            fontSize: 14,
            color: Colors.red,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  bool _isVerseBookmarked(String verseKey) {
    final bookmarks = ref.watch(bookmarksProvider).value ?? {};
    if (_localBookmarkOn.contains(verseKey)) return true;
    if (_localBookmarkOff.contains(verseKey)) return false;
    return bookmarks.contains(verseKey);
  }

  void _playVerse(VerseDto verse) {
    final index = _verses.indexOf(verse);
    if (index != -1) {
      ref.read(quranAudioProvider.notifier).playIndex(index);
    }
  }

  void _toggleBookmark(String verseKey) async {
    setState(() {
      if (_isVerseBookmarked(verseKey)) {
        _localBookmarkOff.add(verseKey);
        _localBookmarkOn.remove(verseKey);
      } else {
        _localBookmarkOn.add(verseKey);
        _localBookmarkOff.remove(verseKey);
      }
    });

    await ref.read(bookmarkTogglerProvider)(verseKey);
  }

  void _shareVerse(VerseDto verse) {
    final chaptersAsync = ref.read(surahListProvider);
    chaptersAsync.whenData((chapters) {
      final chapter = chapters.firstWhere(
        (c) => c.id == widget.chapterId,
        orElse: () => chapters.first,
      );

      final arabicText = verse.textUthmani;
      final translationText = verse.translations.isNotEmpty 
          ? _cleanTranslationText(verse.translations.first.text)
          : '';

      final shareText = '''
$arabicText

$translationText

- ${chapter.nameSimple} ${verse.verseNumber} (${verse.verseKey})
- Shared from DeenMate Islamic App
''';

      Share.share(
        shareText,
        subject: '${chapter.nameSimple} ${verse.verseNumber} - Quran Verse',
      );
    });
  }

  void _showVerseOptions(VerseDto verse) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _VerseOptionsSheet(verse: verse),
    );
  }

  void _openQuickTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickToolsOverlay(
        onOpenTranslationPicker: () => _openTranslationPicker(context),
      ),
    );
  }

  void _openAudioManager(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _AudioManagerSheet(),
    );
  }

  void _openTranslationPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TranslationPickerWidget(),
    );
  }

  void _openAutoScrollManager(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AutoScrollSheet(
        isOn: _autoScrolling,
        speed: _autoScrollSpeedPxPerSec,
        onToggle: (on) {
          setState(() => _autoScrolling = on);
          _autoScrollTimer?.cancel();
          if (on) {
            _autoScrollTimer =
                Timer.periodic(const Duration(milliseconds: 50), (_) {
              if (!_controller.hasClients) return;
              final delta = _autoScrollSpeedPxPerSec / 20;
              final nextOffset = (_controller.offset + delta)
                  .clamp(0.0, _controller.position.maxScrollExtent);
              _controller.jumpTo(nextOffset);
            });
          }
        },
        onSpeedChanged: (v) {
          setState(() => _autoScrollSpeedPxPerSec = v);
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_controller.hasClients) {
        _saveCurrentVersePosition();
      }
    }
  }
}

class _QuickToolsOverlay extends ConsumerWidget {
  const _QuickToolsOverlay({required this.onOpenTranslationPicker});
  
  final VoidCallback onOpenTranslationPicker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    final notifier = ref.read(prefsProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Column(
        children: [
          // Tap area to close
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Quick Tools Panel
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: ThemeHelper.getSurfaceColor(context),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: ThemeHelper.getTextPrimaryColor(context)),
                        ),
                        Expanded(
                          child: Text(
                          'Quick Tools',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.getTextPrimaryColor(context),
                          ),
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Navigation Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Sura', 'Page', 'Juz', 'Hizb', 'Ruku'].map((tab) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tab == 'Sura' 
                                    ? ThemeHelper.getPrimaryColor(context)
                                    : Colors.transparent,
                                foregroundColor: tab == 'Sura'
                                    ? Colors.white
                                    : ThemeHelper.getPrimaryColor(context),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: tab == 'Sura'
                                        ? ThemeHelper.getPrimaryColor(context)
                                        : ThemeHelper.getDividerColor(context),
                                  ),
                                ),
                              ),
                              child: Text(tab),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Content Settings
                    Text(
                      'Content',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Arabic Toggle
                    _buildToggleRow(
                      'Arabic',
                      prefs.showArabic,
                      (value) => notifier.updateShowArabic(value),
                      context,
                    ),
                    
                    // Translation Toggle
                    _buildToggleRow(
                      'Translation',
                      prefs.showTranslation,
                      (value) => notifier.updateShowTranslation(value),
                      context,
                    ),
                    
                    // Translation Settings
                    if (prefs.showTranslation) ...[
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Translation Settings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ThemeHelper.getTextSecondaryColor(context),
                          ),
                        ),
                        subtitle: Text(
                          '${prefs.selectedTranslationIds.length} selected',
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeHelper.getTextSecondaryColor(context),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: ThemeHelper.getTextSecondaryColor(context),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          onOpenTranslationPicker();
                        },
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Font Settings
                    Text(
                      'Font Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Arabic Font Size
                    _buildSliderRow(
                      'Arabic Font Size',
                      prefs.arabicFontSize,
                      18.0,
                      32.0,
                      (value) => notifier.updateArabicFontSize(value),
                      context,
                    ),
                    
                    // Translation Font Size
                    _buildSliderRow(
                      'Translation Font Size',
                      prefs.translationFontSize,
                      12.0,
                      20.0,
                      (value) => notifier.updateTranslationFontSize(value),
                      context,
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ThemeHelper.getPrimaryColor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                label,
                style: TextStyle(
                fontSize: 16,
                  color: ThemeHelper.getTextPrimaryColor(context),
              ),
            ),
            Text(
                value.toInt().toString(),
                style: TextStyle(
                fontSize: 16,
                  color: ThemeHelper.getPrimaryColor(context),
                  fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: ThemeHelper.getPrimaryColor(context),
            inactiveColor: ThemeHelper.getDividerColor(context),
          ),
        ],
      ),
    );
  }






}

class _AudioManagerSheet extends ConsumerWidget {
  const _AudioManagerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(quranAudioProvider);
    final recitations = ref.watch(recitationsProvider);
    final prefs = ref.watch(prefsProvider);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                  child: Text('Audio Manager',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600))),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Reciter:'),
              const SizedBox(width: 12),
              Expanded(
                child: recitations.when(
                  data: (list) => DropdownButton<int>(
                    isExpanded: true,
                    value: prefs.recitationId,
                    items: [
                      for (final r in list)
                        DropdownMenuItem(
                          value: r.id,
                          child: Text(r.name),
                        )
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      await ref
                          .read(prefsProvider.notifier)
                          .updateRecitationId(v);
                      // force re-setup current playlist source if playing
                      final ctrl = ref.read(quranAudioProvider.notifier);
                      if (audio.currentIndex != null) {
                        await ctrl.playIndex(audio.currentIndex!);
                      }
                    },
                  ),
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (e, _) => Text('Failed to load reciters: $e'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {
                  final idx = (audio.currentIndex ?? 0) - 1;
                  ref.read(quranAudioProvider.notifier).playIndex(idx);
                },
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(audio.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () =>
                    ref.read(quranAudioProvider.notifier).togglePause(),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {
                  final idx = (audio.currentIndex ?? -1) + 1;
                  ref.read(quranAudioProvider.notifier).playIndex(idx);
                },
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () => ref.read(quranAudioProvider.notifier).stop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _AutoScrollSheet extends StatelessWidget {
  const _AutoScrollSheet({
    required this.isOn,
    required this.speed,
    required this.onToggle,
    required this.onSpeedChanged,
  });
  final bool isOn;
  final double speed; // px/sec
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                  child: Text('Auto Scroll',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600))),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable Auto Scroll'),
            value: isOn,
            onChanged: onToggle,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          const Text('Speed (px/sec)'),
          Slider(
            value: speed.clamp(20, 200),
            min: 20,
            max: 200,
            divisions: 18,
            label: speed.toStringAsFixed(0),
            onChanged: onSpeedChanged,
          ),
        ],
      ),
    );
  }
}



class _QuickJumpSheet extends ConsumerStatefulWidget {
  const _QuickJumpSheet({
    required this.currentChapterId,
    required this.onGoToSurah,
    required this.onGoToAyah,
    required this.onGoToJuz,
  });
  final int currentChapterId;
  final void Function(int chapterId) onGoToSurah;
  final void Function(int chapterId, String verseKey) onGoToAyah;
  final void Function(int juz) onGoToJuz;

  @override
  ConsumerState<_QuickJumpSheet> createState() => _QuickJumpSheetState();
}

class _QuickJumpSheetState extends ConsumerState<_QuickJumpSheet> {
  final TextEditingController _ayahCtrl = TextEditingController();
  int _selectedJuz = 1;
  @override
  void dispose() {
    _ayahCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(surahListProvider);
    final chapters = chaptersAsync.value ?? const [];
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                    child: Text('Quick Jump',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Surah'),
            const SizedBox(height: 4),
            DropdownButton<int>(
              isExpanded: true,
              value: chapters.any((e) => e.id == widget.currentChapterId)
                  ? widget.currentChapterId
                  : (chapters.isNotEmpty ? chapters.first.id : null),
              items: [
                for (final c in chapters)
                  DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.id}. ${c.nameSimple}'),
                  )
              ],
              onChanged: (v) {
                if (v == null) return;
                widget.onGoToSurah(v);
              },
            ),
            const SizedBox(height: 12),
            const Text('Juz'),
            const SizedBox(height: 4),
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedJuz,
              items: [
                for (int i = 1; i <= 30; i++)
                  DropdownMenuItem(value: i, child: Text('Juz $i'))
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedJuz = v);
                widget.onGoToJuz(v);
              },
            ),
            const SizedBox(height: 12),
            const Text('Go to Ayah (chapter:verse, e.g., 2:255)'),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ayahCtrl,
                    keyboardType: TextInputType.text,
                    decoration:
                        const InputDecoration(hintText: 'e.g., 18:10 or 36:1'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final text = _ayahCtrl.text.trim();
                    if (text.isEmpty) return;
                    final parts = text.split(':');
                    if (parts.length != 2) return;
                    final c = int.tryParse(parts[0]);
                    final v = int.tryParse(parts[1]);
                    if (c == null || v == null) return;
                    widget.onGoToAyah(c, '$c:$v');
                  },
                  child: const Text('Go'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}



class _VerseOptionsSheet extends ConsumerWidget {
  const _VerseOptionsSheet({required this.verse});
  
  final VerseDto verse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Verse Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.getTextPrimaryColor(context),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: ThemeHelper.getTextPrimaryColor(context)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Copy Arabic Text
          ListTile(
            leading: Icon(Icons.copy, color: ThemeHelper.getPrimaryColor(context)),
            title: const Text('Copy Arabic Text'),
            subtitle: const Text('Copy only the Arabic verse'),
            onTap: () {
              _copyArabicText(context);
              Navigator.pop(context);
            },
          ),
          
          // Copy Translation
          if (verse.translations.isNotEmpty)
            ListTile(
              leading: Icon(Icons.translate, color: ThemeHelper.getPrimaryColor(context)),
              title: const Text('Copy Translation'),
              subtitle: const Text('Copy only the translation'),
              onTap: () {
                _copyTranslation(context);
                Navigator.pop(context);
              },
            ),
          
          // Copy Full Verse
          ListTile(
            leading: Icon(Icons.content_copy, color: ThemeHelper.getPrimaryColor(context)),
            title: const Text('Copy Full Verse'),
            subtitle: const Text('Copy Arabic text with translation'),
            onTap: () {
              _copyFullVerse(context, ref);
              Navigator.pop(context);
            },
          ),
          
          // Report Error
          ListTile(
            leading: Icon(Icons.report_problem, color: Colors.orange),
            title: const Text('Report Translation Error'),
            subtitle: const Text('Help improve translation accuracy'),
            onTap: () {
              Navigator.pop(context);
              _showReportDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _copyArabicText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: verse.textUthmani));
    _showCopySuccess(context, 'Arabic text copied');
  }

  void _copyTranslation(BuildContext context) {
    if (verse.translations.isEmpty) return;
    final cleanText = verse.translations.first.text
        .replaceAll(RegExp(r'<sup[^>]*>[\s\S]*?<\/sup>', dotAll: true), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    Clipboard.setData(ClipboardData(text: cleanText));
    _showCopySuccess(context, 'Translation copied');
  }

  void _copyFullVerse(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.read(surahListProvider);
    chaptersAsync.whenData((chapters) {
      final chapterId = int.parse(verse.verseKey.split(':').first);
      final chapter = chapters.firstWhere(
        (c) => c.id == chapterId,
        orElse: () => chapters.first,
      );

      final translationText = verse.translations.isNotEmpty
          ? verse.translations.first.text
              .replaceAll(RegExp(r'<sup[^>]*>[\s\S]*?<\/sup>', dotAll: true), ' ')
              .replaceAll(RegExp(r'<[^>]+>'), ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim()
          : '';

      final fullText = '''
${verse.textUthmani}

$translationText

${chapter.nameSimple} ${verse.verseNumber} (${verse.verseKey})
''';

      Clipboard.setData(ClipboardData(text: fullText));
      _showCopySuccess(context, 'Full verse copied');
    });
  }

  void _showCopySuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ThemeHelper.getPrimaryColor(context),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Translation Error'),
        content: Text(
          'Thank you for helping improve the Quran translation. '
          'Please email us at support@deenmate.app with details about the error in verse ${verse.verseKey}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Could implement email functionality here
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }
}
