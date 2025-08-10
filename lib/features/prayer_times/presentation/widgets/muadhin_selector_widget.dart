import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/athan_settings.dart';

/// Widget for selecting Muadhin voice for Athan
class MuadhinSelectorWidget extends StatelessWidget {

  const MuadhinSelectorWidget({
    required this.selectedVoice, required this.onVoiceChanged, super.key,
  });
  final String selectedVoice;
  final Function(String) onVoiceChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.record_voice_over,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Muadhin Voice',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your preferred voice for the call to prayer:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          
          // Grid of voice options
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: MuadhinVoice.values.length,
            itemBuilder: (context, index) {
              final voice = MuadhinVoice.values[index];
              final isSelected = selectedVoice == voice.audioFileName;
              
              return _buildVoiceCard(voice, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceCard(MuadhinVoice voice, bool isSelected) {
    return GestureDetector(
      onTap: () => onVoiceChanged(voice.audioFileName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected 
                      ? AppTheme.lightTheme.colorScheme.primary
                      : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    voice.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? AppTheme.lightTheme.colorScheme.primary
                          : Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              voice.description,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
