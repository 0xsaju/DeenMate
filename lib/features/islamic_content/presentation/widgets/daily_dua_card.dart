import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/islamic_theme.dart';

/// Beautiful card displaying daily dua
class DailyDuaCard extends StatelessWidget {
  
  const DailyDuaCard({
    required this.dua, super.key,
  });
  final Map<String, dynamic> dua;

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
                  color: IslamicTheme.duaBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pan_tool,
                  color: IslamicTheme.duaBrown,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dua['occasion'] ?? 'Daily Dua',
                      style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                        color: IslamicTheme.duaBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'দৈনিক দোয়া',
                      style: IslamicTheme.textTheme.bodySmall?.copyWith(
                        color: IslamicTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _shareDua(context),
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
              color: IslamicTheme.duaBrown.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dua['arabic'] ?? '',
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
          if (dua['transliteration'] != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: IslamicTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dua['transliteration'],
                style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: IslamicTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // English translation
          Text(
            dua['english'] ?? '',
            style: IslamicTheme.textTheme.bodyLarge?.copyWith(
              color: IslamicTheme.textPrimary,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Bengali translation
          Text(
            dua['bengali'] ?? '',
            style: IslamicTheme.bengaliMedium.copyWith(
              color: IslamicTheme.textSecondary,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Benefit
          if (dua['benefit'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: IslamicTheme.duaBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: IslamicTheme.duaBrown.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: IslamicTheme.duaBrown,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Benefit: ${dua['benefit']}',
                      style: IslamicTheme.textTheme.bodySmall?.copyWith(
                        color: IslamicTheme.duaBrown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyDua(context),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: IslamicTheme.duaBrown,
                    side: BorderSide(color: IslamicTheme.duaBrown.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveDua(context),
                  icon: const Icon(Icons.bookmark, size: 16),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IslamicTheme.duaBrown,
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

  void _copyDua(BuildContext context) {
    final text = '''
${dua['arabic']}

${dua['transliteration'] ?? ''}

${dua['english']}

${dua['bengali']}

Occasion: ${dua['occasion']}
Benefit: ${dua['benefit'] ?? ''}
''';
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dua copied to clipboard'),
        backgroundColor: IslamicTheme.duaBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _shareDua(BuildContext context) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing feature coming soon!'),
        backgroundColor: IslamicTheme.duaBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _saveDua(BuildContext context) {
    // TODO: Implement save to favorites functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dua saved to favorites!'),
        backgroundColor: IslamicTheme.duaBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
