import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dto/verse_dto.dart';
import '../../data/dto/word_analysis_dto.dart';
import '../state/providers.dart';
import '../../../../core/theme/theme_helper.dart';

class WordAnalysisWidget extends ConsumerStatefulWidget {
  const WordAnalysisWidget({
    super.key,
    required this.verse,
    this.selectedResourceId,
  });

  final VerseDto verse;
  final int? selectedResourceId;

  @override
  ConsumerState<WordAnalysisWidget> createState() => _WordAnalysisWidgetState();
}

class _WordAnalysisWidgetState extends ConsumerState<WordAnalysisWidget>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  
  bool _isExpanded = false;
  int? _selectedResourceId;
  int? _selectedWordIndex;
  bool _showTransliteration = true;
  bool _showGrammar = false;

  @override
  void initState() {
    super.initState();
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    
    _selectedResourceId = widget.selectedResourceId;
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordAnalysisResourcesAsync = ref.watch(wordAnalysisResourcesProvider);

    return wordAnalysisResourcesAsync.when(
      data: (resources) {
        if (resources.isEmpty) {
          return _buildNoAnalysisAvailable();
        }

        // Set default resource if none selected
        if (_selectedResourceId == null && resources.isNotEmpty) {
          _selectedResourceId = resources.first.id;
        }

        return Container(
          margin: const EdgeInsets.only(top: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(resources),
              if (_isExpanded) ...[
                _buildResourceSelector(resources),
                _buildControls(),
                _buildWordAnalysisContent(),
              ],
            ],
          ),
        );
      },
      loading: () => _buildLoadingAnalysis(),
      error: (error, _) => _buildErrorAnalysis(error),
    );
  }

  Widget _buildHeader(List<WordAnalysisResourceDto> resources) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
          if (_isExpanded) {
            _expandController.forward();
          } else {
            _expandController.reverse();
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.translate,
                color: ThemeHelper.getPrimaryColor(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Word-by-Word Analysis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isExpanded 
                      ? 'Tap to hide analysis'
                      : 'Arabic • Transliteration • Translation',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeHelper.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceSelector(List<WordAnalysisResourceDto> resources) {
    if (resources.length <= 1) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ThemeHelper.getDividerColor(context),
            width: 1,
          ),
          bottom: BorderSide(
            color: ThemeHelper.getDividerColor(context),
            width: 1,
          ),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedResourceId,
          isExpanded: true,
          style: TextStyle(
            fontSize: 14,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
          items: resources.map((resource) {
            return DropdownMenuItem<int>(
              value: resource.id,
              child: Text(resource.name ?? 'Analysis ${resource.id}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedResourceId = value;
              _selectedWordIndex = null; // Reset selection
            });
          },
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ThemeHelper.getDividerColor(context),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Display Options',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Transliteration', style: TextStyle(fontSize: 12)),
                  value: _showTransliteration,
                  onChanged: (value) {
                    setState(() {
                      _showTransliteration = value ?? true;
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Grammar', style: TextStyle(fontSize: 12)),
                  value: _showGrammar,
                  onChanged: (value) {
                    setState(() {
                      _showGrammar = value ?? false;
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWordAnalysisContent() {
    if (_selectedResourceId == null) {
      return const SizedBox.shrink();
    }

    final wordAnalysisAsync = ref.watch(wordAnalysisByVerseProvider({
      'verseKey': widget.verse.verseKey,
      'resourceId': _selectedResourceId!,
    }));

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          constraints: BoxConstraints(
            minHeight: 200 * _expandAnimation.value,
            maxHeight: 600 * _expandAnimation.value,
          ),
          child: wordAnalysisAsync.when(
            data: (wordAnalysis) => _buildWordAnalysisGrid(wordAnalysis),
            loading: () => _buildLoadingContent(),
            error: (error, _) => _buildErrorContent(error),
          ),
        );
      },
    );
  }

  Widget _buildWordAnalysisGrid(WordAnalysisDto wordAnalysis) {
    final prefs = ref.watch(prefsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse text with clickable words
          _buildClickableVerseText(wordAnalysis.words, prefs),
          
          const SizedBox(height: 24),
          
          // Word analysis grid
          if (_selectedWordIndex == null)
            _buildWordsOverview(wordAnalysis.words)
          else
            _buildSelectedWordDetails(wordAnalysis.words[_selectedWordIndex!]),
        ],
      ),
    );
  }

  Widget _buildClickableVerseText(List<WordDto> words, QuranPrefs prefs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getPrimaryColor(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tap on any word for detailed analysis',
            style: TextStyle(
              fontSize: 12,
              color: ThemeHelper.getTextSecondaryColor(context),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            textDirection: TextDirection.rtl,
            children: words.asMap().entries.map((entry) {
              final index = entry.key;
              final word = entry.value;
              final isSelected = _selectedWordIndex == index;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedWordIndex = isSelected ? null : index;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                      ? ThemeHelper.getPrimaryColor(context).withOpacity(0.2)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                        ? ThemeHelper.getPrimaryColor(context)
                        : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    word.textUthmani,
                    style: TextStyle(
                      fontSize: prefs.arabicFontSize - 2,
                      fontFamily: 'Uthmani',
                      color: isSelected
                        ? ThemeHelper.getPrimaryColor(context)
                        : ThemeHelper.getTextPrimaryColor(context),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWordsOverview(List<WordDto> words) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Word Analysis Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.getTextPrimaryColor(context),
              ),
            ),
            const Spacer(),
            Text(
              '${words.length} words',
              style: TextStyle(
                fontSize: 12,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Words grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: words.length,
          itemBuilder: (context, index) {
            return _buildWordCard(words[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildWordCard(WordDto word, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedWordIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
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
            // Arabic word
            Text(
              word.textUthmani,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Uthmani',
                color: ThemeHelper.getTextPrimaryColor(context),
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
            ),
            
            const SizedBox(height: 4),
            
            // Transliteration
            if (_showTransliteration)
              Text(
                word.transliteration,
                style: TextStyle(
                  fontSize: 11,
                  color: ThemeHelper.getTextSecondaryColor(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
            
            const Spacer(),
            
            // Translation
            Text(
              word.translation,
              style: TextStyle(
                fontSize: 12,
                color: ThemeHelper.getTextPrimaryColor(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedWordDetails(WordDto word) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: ThemeHelper.getTextPrimaryColor(context),
              ),
              onPressed: () {
                setState(() {
                  _selectedWordIndex = null;
                });
              },
            ),
            Text(
              'Word Analysis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Word details card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeHelper.getPrimaryColor(context).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Arabic word (large)
              Text(
                word.textUthmani,
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Uthmani',
                  color: ThemeHelper.getPrimaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.rtl,
              ),
              
              const SizedBox(height: 12),
              
              // Transliteration
              Text(
                word.transliteration,
                style: TextStyle(
                  fontSize: 18,
                  color: ThemeHelper.getTextSecondaryColor(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Translation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ThemeHelper.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  word.translation,
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeHelper.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Detailed information
        _buildWordDetails(word),
      ],
    );
  }

  Widget _buildWordDetails(WordDto word) {
    final details = <String, String?>{
      'Position': '${word.position}',
      'Root': word.root,
      'Lemma': word.lemma,
      'Stem': word.stem,
      'Part of Speech': word.partOfSpeech,
    };
    
    if (_showGrammar) {
      details.addAll({
        'Gender': word.gender,
        'Number': word.number,
        'Person': word.person,
        'Tense': word.tense,
        'Mood': word.mood,
        'Voice': word.voice,
        'Grammar': word.grammar,
      });
    }
    
    // Filter out null values
    final filteredDetails = Map<String, String>.fromEntries(
      details.entries.where((entry) => entry.value != null && entry.value!.isNotEmpty)
          .map((entry) => MapEntry(entry.key, entry.value!)),
    );
    
    if (filteredDetails.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeHelper.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'No additional details available for this word.',
          style: TextStyle(
            fontSize: 14,
            color: ThemeHelper.getTextSecondaryColor(context),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeHelper.getDividerColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Word Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.getPrimaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: filteredDetails.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeHelper.getTextSecondaryColor(context),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeHelper.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAnalysis() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeHelper.getPrimaryColor(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading word analysis...',
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeHelper.getPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading word analysis...',
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorAnalysis(Object error) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error loading word analysis: $error',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(Object error) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading word analysis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: TextStyle(
                fontSize: 12,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAnalysisAvailable() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.translate_outlined,
            color: ThemeHelper.getTextSecondaryColor(context),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No word analysis available for this verse',
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getTextSecondaryColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
