import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/audio_providers.dart';

/// Widget for previewing Athan audio
class AthanPreviewWidget extends ConsumerWidget {

  const AthanPreviewWidget({
    required this.muadhinVoice, required this.volume, super.key,
  });
  final String muadhinVoice;
  final double volume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final athanAudioState = ref.watch(athanAudioProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.1),
            AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Preview Athan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Listen to a sample of the selected Muadhin voice:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          
          // Preview controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (athanAudioState.isPlaying) ...[
                _buildStopButton(ref),
                const SizedBox(width: 16),
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                const Text(
                  'Playing...',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ] else ...[
                _buildPlayButton(ref),
                const SizedBox(width: 16),
                Icon(
                  Icons.volume_up,
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${(volume * 100).toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.secondary,
                  ),
                ),
              ],
            ],
          ),
          
          // Error message
          if (athanAudioState.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      athanAudioState.error!.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Information about the voice
          const SizedBox(height: 16),
          _buildVoiceInfo(),
        ],
      ),
    );
  }

  Widget _buildPlayButton(WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        ref.read(athanAudioProvider.notifier).previewAthan(muadhinVoice);
      },
      icon: const Icon(Icons.play_arrow),
      label: const Text('Preview'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildStopButton(WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        ref.read(athanAudioProvider.notifier).stopAthan();
      },
      icon: const Icon(Icons.stop),
      label: const Text('Stop'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildVoiceInfo() {
    // Get voice information based on selected voice
    final voiceInfo = _getVoiceInfo(muadhinVoice);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voiceInfo['name']!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  voiceInfo['description']!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getVoiceInfo(String voiceId) {
    switch (voiceId) {
      case 'abdulbasit':
        return {
          'name': 'Abdul Basit Abdul Samad',
          'description': 'Renowned Quranic reciter from Egypt with a melodious voice',
        };
      case 'mishary':
        return {
          'name': 'Mishary Rashid Alafasy',
          'description': 'Famous Imam and reciter from Kuwait',
        };
      case 'sudais':
        return {
          'name': 'Sheikh Abdul Rahman Al-Sudais',
          'description': 'Imam of Masjid al-Haram in Mecca',
        };
      case 'shuraim':
        return {
          'name': 'Sheikh Saud Al-Shuraim',
          'description': 'Imam of Masjid al-Haram in Mecca',
        };
      case 'maher':
        return {
          'name': 'Maher Al-Muaiqly',
          'description': 'Imam of Masjid al-Haram with beautiful recitation',
        };
      case 'yasser':
        return {
          'name': 'Yasser Ad-Dussary',
          'description': 'Beautiful voice from Saudi Arabia',
        };
      case 'ajmi':
        return {
          'name': 'Ahmad Al-Ajmi',
          'description': 'Kuwaiti reciter with distinctive style',
        };
      case 'ghamdi':
        return {
          'name': 'Saad Al-Ghamdi',
          'description': 'Saudi reciter known for emotional recitation',
        };
      default:
        return {
          'name': 'Default Athan',
          'description': 'Standard Islamic call to prayer',
        };
    }
  }
}
