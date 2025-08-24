import 'package:flutter/material.dart';
import '../../../../core/theme/theme_helper.dart';

/// Dialog to prompt user when audio is not available offline
/// Asks: "Play online or download surah?"
class AudioDownloadPromptDialog extends StatelessWidget {
  const AudioDownloadPromptDialog({
    super.key,
    required this.verse,
    required this.chapterName,
  });

  final dynamic verse; // Will be VerseAudio when implemented
  final String chapterName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.download_outlined,
            color: ThemeHelper.getPrimaryColor(context),
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Audio Not Downloaded',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The audio for $chapterName is not available offline.',
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Would you like to:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          // Download option
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.download,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Download Surah',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Save for offline listening',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeHelper.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Online option
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Play Online',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Requires internet connection',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeHelper.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Play online
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi,
                size: 18,
                color: Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                'Play Online',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true), // Download
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeHelper.getPrimaryColor(context),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.download, size: 18),
              SizedBox(width: 4),
              Text('Download'),
            ],
          ),
        ),
      ],
    );
  }

  /// Show the download prompt dialog
  static Future<bool> show(
    BuildContext context,
    dynamic verse,
    String chapterName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AudioDownloadPromptDialog(
        verse: verse,
        chapterName: chapterName,
      ),
    );
    return result ?? false; // Default to false (play online) if dismissed
  }
}

/// Alternative simple version for quick prompts
class QuickAudioPrompt {
  static Future<bool> showSimple(
    BuildContext context,
    String verseKey,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio not available offline'),
        content: Text('Play $verseKey online or download for offline use?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Play Online'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Download'),
          ),
        ],
      ),
    ) ?? false;
  }
}
