import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dto/verse_dto.dart';
import '../../data/dto/translation_resource_dto.dart';
import '../state/providers.dart';
import '../../utils/text_utils.dart';
import '../../../../core/theme/theme_helper.dart';
import '../../../../core/localization/strings.dart';

class VerseCardWidget extends ConsumerWidget {
  const VerseCardWidget({
    super.key,
    required this.verse,
    required this.translationResources,
    this.onShare,
    this.onBookmark,
    this.onCopy,
    this.onTafsir,
    this.isBookmarked = false,
    this.showVerseActions = true,
  });

  final VerseDto verse;
  final List<TranslationResourceDto> translationResources;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onCopy;
  final VoidCallback? onTafsir;
  final bool isBookmarked;
  final bool showVerseActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse number indicator
          _buildVerseNumber(context),
          
          // Bismillah for first verse of chapters (except At-Tawbah)
          if (verse.verseNumber == 1 && !verse.verseKey.startsWith('9:'))
            _buildBismillah(context, prefs),
          
          // Arabic text
          if (prefs.showArabic)
            _buildArabicText(context, prefs),
          
          // Translations
          if (prefs.showTranslation)
            _buildTranslations(context, prefs),
          
          // Verse actions
          if (showVerseActions)
            _buildVerseActions(context),
          
          // Divider
          _buildDivider(context),
        ],
      ),
    );
  }

  Widget _buildVerseNumber(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '${verse.verseNumber}',
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
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                    ThemeHelper.getPrimaryColor(context).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillah(BuildContext context, QuranPrefs prefs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          style: TextStyle(
            fontSize: prefs.arabicFontSize + 4, // Slightly larger for Bismillah
            height: prefs.arabicLineHeight,
            color: ThemeHelper.getTextPrimaryColor(context),
            fontFamily: 'Uthmani',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildArabicText(BuildContext context, QuranPrefs prefs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SelectableText(
        verse.textUthmani,
        style: TextStyle(
          fontSize: prefs.arabicFontSize,
          height: prefs.arabicLineHeight,
          color: ThemeHelper.getTextPrimaryColor(context),
          fontFamily: prefs.arabicFontFamily ?? 'Uthmani',
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildTranslations(BuildContext context, QuranPrefs prefs) {
    if (verse.translations.isEmpty) {
      return _buildLoadingTranslation(context);
    }

    // Filter selected translations
    var selectedTranslations = <TranslationDto>[];
    
    if (prefs.selectedTranslationIds.isNotEmpty) {
      selectedTranslations = verse.translations
          .where((translation) => 
              prefs.selectedTranslationIds.contains(translation.resourceId))
          .toList();
    }
    
    if (selectedTranslations.isEmpty && verse.translations.isNotEmpty) {
      selectedTranslations = [verse.translations.first];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: selectedTranslations.map((translation) {
        final resource = translationResources.firstWhere(
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
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Translation label (only show if multiple translations)
              if (selectedTranslations.length > 1)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          resource.name ?? 'Translation ${translation.resourceId}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.getPrimaryColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Translation text
              SelectableText(
                _cleanTranslationText(translation.text),
                style: TextStyle(
                  fontSize: prefs.translationFontSize,
                  height: prefs.translationLineHeight,
                  color: ThemeHelper.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
                textAlign: _getTranslationTextAlign(resource),
                textDirection: _getTranslationTextDirection(resource),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingTranslation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeHelper.getDividerColor(context),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeHelper.getPrimaryColor(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading translation...',
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.getTextSecondaryColor(context),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          _buildActionButton(
            context,
            Icons.bookmark_outline,
            isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
            onBookmark,
            isBookmarked ? 'Remove bookmark' : 'Bookmark verse',
            isActive: isBookmarked,
          ),
          _buildActionButton(
            context,
            Icons.copy_outlined,
            Icons.copy_outlined,
            onCopy,
            'Copy verse',
          ),
          _buildActionButton(
            context,
            Icons.share_outlined,
            Icons.share_outlined,
            onShare,
            'Share verse',
          ),
          _buildActionButton(
            context,
            Icons.menu_book_outlined,
            Icons.menu_book_outlined,
            onTafsir,
            'View tafsir',
          ),
          _buildThreeDotMenu(context),
        ],
      ),
    );
  }

  Widget _buildThreeDotMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 18,
        color: ThemeHelper.getTextSecondaryColor(context),
      ),
      onSelected: (value) {
        switch (value) {
          case 'word_analysis':
            // TODO: Implement word analysis
            break;
          case 'audio':
            // TODO: Implement audio playback
            break;
          case 'download':
            // TODO: Implement audio download
            break;
          case 'notes':
            // TODO: Implement notes
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'word_analysis',
          child: Row(
            children: [
              Icon(Icons.psychology, size: 18),
              SizedBox(width: 8),
              Text('Word Analysis'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'audio',
          child: Row(
            children: [
              Icon(Icons.play_arrow, size: 18),
              SizedBox(width: 8),
              Text('Play Audio'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download, size: 18),
              SizedBox(width: 8),
              Text('Download Audio'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'notes',
          child: Row(
            children: [
              Icon(Icons.note_add, size: 18),
              SizedBox(width: 8),
              Text('Add Note'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    IconData activeIcon,
    VoidCallback? onTap,
    String tooltip, {
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive 
              ? ThemeHelper.getPrimaryColor(context).withOpacity(0.1)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isActive ? activeIcon : icon,
            size: 18,
            color: isActive 
              ? ThemeHelper.getPrimaryColor(context)
              : ThemeHelper.getTextSecondaryColor(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            ThemeHelper.getDividerColor(context).withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  String _cleanTranslationText(String text) {
    return QuranTextUtils.sanitizeTranslationText(text);
  }

  /// Get text direction for translation based on language
  TextDirection _getTranslationTextDirection(TranslationResourceDto resource) {
    final langName = resource.languageName?.toLowerCase() ?? '';
    
    // Check if language is RTL
    if (S.isRTL(langName)) {
      return TextDirection.rtl;
    }
    
    // Check for language keywords
    if (langName.contains('arabic') || langName.contains('urdu') ||
        langName.contains('عربي') || langName.contains('اردو') ||
        langName.contains('persian') || langName.contains('farsi')) {
      return TextDirection.rtl;
    }
    
    return TextDirection.ltr;
  }

  /// Get text alignment for translation based on language
  TextAlign _getTranslationTextAlign(TranslationResourceDto resource) {
    return _getTranslationTextDirection(resource) == TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left;
  }
}
