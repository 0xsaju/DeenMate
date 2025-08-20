import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dto/verse_dto.dart';
import '../state/providers.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({super.key, required this.chapterId});
  final int chapterId;

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  final ScrollController _controller = ScrollController();
  final List<VerseDto> _verses = [];
  int _page = 1;
  int _totalPages = 1;
  bool _loading = false;
  bool _isFetchingMore = false;
  int? _inflightPage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPage(1);
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (_controller.position.pixels >
            _controller.position.maxScrollExtent * 0.8 &&
        !_isFetchingMore &&
        _page < _totalPages) {
      _loadPage(_page + 1);
    }
  }

  Future<void> _loadPage(int page) async {
    if (_inflightPage == page) return;
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
      final args = SurahPageArgs(widget.chapterId, page);
      // ignore: avoid_print
      print('Reader: loading chapter=${widget.chapterId} page=$page');
      final dto = await ref.read(surahPageProvider(args).future);
      // ignore: avoid_print
      print(
          'Reader: received verses=${dto.verses.length} page=${dto.pagination.currentPage}/${dto.pagination.totalPages}');
      setState(() {
        _page = dto.pagination.currentPage;
        _totalPages = dto.pagination.totalPages;
        _verses.addAll(dto.verses);
      });
    } catch (e, st) {
      // ignore: avoid_print
      print('Reader: load failed for page=$page error=$e');
      // ignore: avoid_print
      print(st);
      _errorMessage = e.toString();
      // ignore for now; UI stays with loaded items
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Surah ${widget.chapterId}')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_verses.isEmpty) {
      return _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_errorMessage == null
                      ? 'No verses loaded'
                      : 'Failed to load. ${_errorMessage!.length > 90 ? _errorMessage!.substring(0, 90) + '…' : _errorMessage!}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _loadPage(1),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
    }
    return RefreshIndicator(
      onRefresh: () async {
        _verses.clear();
        _page = 0;
        _totalPages = 1;
        _errorMessage = null;
        await _loadPage(1);
      },
      child: ListView.builder(
        controller: _controller,
        itemCount: _verses.length + 1,
        itemBuilder: (context, index) {
          if (index >= _verses.length) {
            if (_isFetchingMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (_page >= _totalPages) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('— End of Surah —')),
              );
            }
            return const SizedBox.shrink();
          }
          final v = _verses[index];
          final rawTr =
              v.translations.isNotEmpty ? v.translations.first.text : '';
          final firstTr = _cleanTranslationText(rawTr);
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          const double arabicFontSize = 26;
          const double arabicLineHeight = 1.9;
          const double translationFontSize = 15;
          const double translationLineHeight = 1.6;
          const double verseVerticalSpace = 18;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(
                  v.textUthmani,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: arabicFontSize,
                    height: arabicLineHeight,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                ),
                if (firstTr.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    firstTr,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: translationFontSize,
                      height: translationLineHeight,
                      color: isDark ? Colors.white70 : const Color(0xFF3E3E3E),
                    ),
                  ),
                ],
                const SizedBox(height: verseVerticalSpace),
              ],
            ),
          );
        },
      ),
    );
  }

  String _cleanTranslationText(String input) {
    if (input.isEmpty) return input;
    // Remove footnote superscripts like <sup foot_note=...>...</sup>
    final withoutSup = input.replaceAll(
        RegExp(r'<sup[^>]*>[\s\S]*?<\/sup>', dotAll: true), '');
    // Strip any remaining HTML tags
    final withoutTags = withoutSup.replaceAll(RegExp(r'<[^>]+>'), '');
    // Decode a few common HTML entities
    return withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
