import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/islamic_theme.dart';

/// Beautiful card displaying daily Quran verse
class DailyVerseCard extends StatelessWidget {
  
  const DailyVerseCard({
    required this.verse, super.key,
  });
  final Map<String, dynamic> verse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: IslamicTheme.quranPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: IslamicTheme.quranPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verse of the Day',
                      style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                        color: IslamicTheme.quranPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'আজকের আয়াত',
                      style: IslamicTheme.textTheme.bodySmall?.copyWith(
                        color: IslamicTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _shareVerse(context),
                icon: const Icon(
                  Icons.share,
                  color: IslamicTheme.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Arabic text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: IslamicTheme.quranPurple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              verse['arabic'] ?? '',
              style: IslamicTheme.arabicLarge.copyWith(
                fontSize: 20,
                height: 1.8,
                color: IslamicTheme.textPrimary,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Transliteration
          if (verse['transliteration'] != null) ...[
            Text(
              verse['transliteration'],
              style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: IslamicTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // English translation
          Text(
            verse['english'] ?? '',
            style: IslamicTheme.textTheme.bodyLarge?.copyWith(
              color: IslamicTheme.textPrimary,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Bengali translation
          Text(
            verse['bengali'] ?? '',
            style: IslamicTheme.bengaliMedium.copyWith(
              color: IslamicTheme.textSecondary,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Reference and theme
          Row(
            children: [
              // Reference
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: IslamicTheme.quranPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  verse['reference'] ?? '',
                  style: IslamicTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Theme
              if (verse['theme'] != null)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: IslamicTheme.quranPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: IslamicTheme.quranPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      verse['theme'],
                      style: IslamicTheme.textTheme.bodySmall?.copyWith(
                        color: IslamicTheme.quranPurple,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyVerse(context),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: IslamicTheme.quranPurple,
                    side: BorderSide(color: IslamicTheme.quranPurple.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveVerse(context),
                  icon: const Icon(Icons.bookmark, size: 16),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IslamicTheme.quranPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyVerse(BuildContext context) {
    final text = '''
${verse['arabic']}

${verse['english']}

${verse['bengali']}

${verse['reference']}
''';
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Verse copied to clipboard'),
        backgroundColor: IslamicTheme.quranPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _shareVerse(BuildContext context) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing feature coming soon!'),
        backgroundColor: IslamicTheme.quranPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _saveVerse(BuildContext context) {
    // TODO: Implement save to favorites functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Verse saved to favorites!'),
        backgroundColor: IslamicTheme.quranPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
