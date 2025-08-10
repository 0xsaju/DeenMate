import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/islamic_theme.dart';

/// Beautiful card displaying daily Hadith
class DailyHadithCard extends StatelessWidget {
  
  const DailyHadithCard({
    required this.hadith, super.key,
  });
  final Map<String, dynamic> hadith;

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
                  color: IslamicTheme.hadithOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.format_quote,
                  color: IslamicTheme.hadithOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hadith of the Day',
                      style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                        color: IslamicTheme.hadithOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'আজকের হাদিস',
                      style: IslamicTheme.textTheme.bodySmall?.copyWith(
                        color: IslamicTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _shareHadith(context),
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
              color: IslamicTheme.hadithOrange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              hadith['arabic'] ?? '',
              style: IslamicTheme.arabicLarge.copyWith(
                fontSize: 18,
                height: 1.8,
                color: IslamicTheme.textPrimary,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Transliteration
          if (hadith['transliteration'] != null) ...[
            Text(
              hadith['transliteration'],
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
            hadith['english'] ?? '',
            style: IslamicTheme.textTheme.bodyLarge?.copyWith(
              color: IslamicTheme.textPrimary,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Bengali translation
          Text(
            hadith['bengali'] ?? '',
            style: IslamicTheme.bengaliMedium.copyWith(
              color: IslamicTheme.textSecondary,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Narrator and source
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: IslamicTheme.backgroundLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: IslamicTheme.hadithOrange.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hadith['narrator'] != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: IslamicTheme.hadithOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Narrator: ',
                        style: IslamicTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: IslamicTheme.hadithOrange,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          hadith['narrator'],
                          style: IslamicTheme.textTheme.bodySmall?.copyWith(
                            color: IslamicTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                
                if (hadith['source'] != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.library_books,
                        size: 16,
                        color: IslamicTheme.hadithOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Source: ',
                        style: IslamicTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: IslamicTheme.hadithOrange,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          hadith['source'],
                          style: IslamicTheme.textTheme.bodySmall?.copyWith(
                            color: IslamicTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Theme tag
          if (hadith['theme'] != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: IslamicTheme.hadithOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hadith['theme'],
                  style: IslamicTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyHadith(context),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: IslamicTheme.hadithOrange,
                    side: BorderSide(color: IslamicTheme.hadithOrange.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveHadith(context),
                  icon: const Icon(Icons.bookmark, size: 16),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IslamicTheme.hadithOrange,
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

  void _copyHadith(BuildContext context) {
    final text = '''
${hadith['arabic']}

${hadith['english']}

${hadith['bengali']}

Narrator: ${hadith['narrator'] ?? 'Unknown'}
Source: ${hadith['source'] ?? 'Unknown'}
Theme: ${hadith['theme'] ?? ''}
''';
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Hadith copied to clipboard'),
        backgroundColor: IslamicTheme.hadithOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _shareHadith(BuildContext context) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing feature coming soon!'),
        backgroundColor: IslamicTheme.hadithOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _saveHadith(BuildContext context) {
    // TODO: Implement save to favorites functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Hadith saved to favorites!'),
        backgroundColor: IslamicTheme.hadithOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
