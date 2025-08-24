import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/providers.dart';
import '../widgets/verse_card_widget.dart';
import '../../../../core/theme/theme_helper.dart';

/// Screen for reading a specific Juz (Para)
class JuzReaderScreen extends ConsumerWidget {
  const JuzReaderScreen({
    super.key,
    required this.juzNumber,
  });

  final int juzNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versesAsync = ref.watch(versesByJuzProvider(juzNumber));

    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.getBackgroundColor(context),
        elevation: 0,
        title: Text(
          'Juz $juzNumber',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeHelper.getTextPrimaryColor(context)),
          onPressed: () {
            try {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/quran/navigation');
              }
            } catch (e) {
              // Fallback navigation
              context.go('/quran');
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_outline, color: ThemeHelper.getTextPrimaryColor(context)),
            onPressed: () {
              // TODO: Add bookmark functionality for Juz
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: ThemeHelper.getTextPrimaryColor(context)),
            onPressed: () {
              // TODO: Add share functionality for Juz
            },
          ),
        ],
      ),
      body: versesAsync.when(
        data: (verses) {
          if (verses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No verses found for Juz $juzNumber',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This feature is under development',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: verses.length,
            itemBuilder: (context, index) {
              final verse = verses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: VerseCardWidget(
                  verse: verse,
                  translationResources: [], // TODO: Add translations
                  onBookmark: () {
                    // Handle bookmark tap
                  },
                  onShare: () {
                    // Handle share tap
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading Juz $juzNumber: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(versesByJuzProvider(juzNumber)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
