import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../../data/dto/translation_resource_dto.dart';

class TranslationPickerWidget extends ConsumerWidget {
  const TranslationPickerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    final resourcesAsync = ref.watch(translationResourcesProvider);

    return AlertDialog(
      title: const Text('Select Translations'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: resourcesAsync.when(
          data: (resources) => _buildTranslationList(context, ref, resources, prefs),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading translations: $error'),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildTranslationList(
    BuildContext context,
    WidgetRef ref,
    List<TranslationResourceDto> resources,
    QuranPrefs prefs,
  ) {
    return Column(
      children: [
        // Filter by language
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const Text('Language: '),
              DropdownButton<String>(
                value: 'en', // Default to English for now
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                  DropdownMenuItem(value: 'ur', child: Text('Urdu')),
                  DropdownMenuItem(value: 'bn', child: Text('Bengali')),
                ],
                onChanged: (value) {
                  // TODO: Implement language filtering
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              final isSelected = prefs.selectedTranslationIds.contains(resource.id);
              
              return CheckboxListTile(
                title: Text(
                  resource.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'by ${resource.authorName}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                value: isSelected,
                onChanged: (selected) {
                  if (selected == null) return;
                  
                  final notifier = ref.read(prefsProvider.notifier);
                  if (selected) {
                    // Add translation
                    final newIds = [...prefs.selectedTranslationIds, resource.id];
                    notifier.updateTranslationIds(newIds);
                  } else {
                    // Remove translation (but keep at least one)
                    if (prefs.selectedTranslationIds.length > 1) {
                      final newIds = prefs.selectedTranslationIds
                          .where((id) => id != resource.id)
                          .toList();
                      notifier.updateTranslationIds(newIds);
                    }
                  }
                },
                secondary: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      resource.languageName.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Selected count
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            '${prefs.selectedTranslationIds.length} translation${prefs.selectedTranslationIds.length == 1 ? '' : 's'} selected',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
