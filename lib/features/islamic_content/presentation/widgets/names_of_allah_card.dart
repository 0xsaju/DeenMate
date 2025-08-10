import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/islamic_theme.dart';

/// Beautiful card displaying one of the 99 Names of Allah
class NamesOfAllahCard extends StatelessWidget {
  
  const NamesOfAllahCard({
    required this.name, super.key,
  });
  final Map<String, dynamic> name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            IslamicTheme.islamicGreen,
            IslamicTheme.islamicGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: IslamicTheme.islamicGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Name of Allah',
                style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.star,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          
          Text(
            'আল্লাহর নাম',
            style: IslamicTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Arabic name - large and prominent
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Text(
              name['arabic'] ?? '',
              style: IslamicTheme.arabicLarge.copyWith(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Transliteration
          Text(
            name['transliteration'] ?? '',
            style: IslamicTheme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // English meaning
          Text(
            name['english'] ?? '',
            style: IslamicTheme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Bengali meaning
          Text(
            name['bengali'] ?? '',
            style: IslamicTheme.bengaliMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyName(context),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _learnMore(context),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Learn More'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: IslamicTheme.islamicGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Reminder about contemplation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reflect on this beautiful name of Allah and its meaning',
                    style: IslamicTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyName(BuildContext context) {
    final text = '''
${name['arabic']}
${name['transliteration']}
${name['english']}
${name['bengali']}

One of the 99 Beautiful Names of Allah
''';
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Name of Allah copied to clipboard'),
        backgroundColor: IslamicTheme.islamicGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _learnMore(BuildContext context) {
    // TODO: Implement detailed explanation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Detailed explanations coming soon!'),
        backgroundColor: IslamicTheme.islamicGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
