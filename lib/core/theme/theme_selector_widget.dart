import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'theme_provider.dart';

/// Theme selector widget for settings screen
class ThemeSelectorWidget extends ConsumerWidget {
  const ThemeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final availableThemes = ref.watch(availableThemesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'App Theme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Choose your preferred reading experience',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...availableThemes.map((themeMetadata) => ThemeOptionTile(
          themeMetadata: themeMetadata,
          isSelected: currentTheme == themeMetadata.theme,
          onSelected: () => themeNotifier.setTheme(themeMetadata.theme),
        )),
      ],
    );
  }
}

/// Individual theme option tile
class ThemeOptionTile extends StatelessWidget {
  const ThemeOptionTile({
    super.key,
    required this.themeMetadata,
    required this.isSelected,
    required this.onSelected,
  });

  final ThemeMetadata themeMetadata;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected 
                    ? themeMetadata.previewColor
                    : colorScheme.outline.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected 
                  ? themeMetadata.previewColor.withOpacity(0.05)
                  : colorScheme.surface,
            ),
            child: Row(
              children: [
                // Theme icon with preview color
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: themeMetadata.previewColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    themeMetadata.icon,
                    color: themeMetadata.previewColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Theme info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        themeMetadata.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? themeMetadata.previewColor
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        themeMetadata.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Selection indicator
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: themeMetadata.previewColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme preview widget showing Arabic and translation text samples
class ThemePreviewWidget extends StatelessWidget {
  const ThemePreviewWidget({
    super.key,
    required this.themeMetadata,
  });

  final ThemeMetadata themeMetadata;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeMetadata.previewColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arabic text sample
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: themeMetadata.arabicTextColor,
              height: 1.8,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          
          // Translation text sample
          Text(
            'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
            style: TextStyle(
              fontFamily: 'CrimsonText',
              fontSize: 14,
              color: themeMetadata.translationTextColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (themeMetadata.theme) {
      case AppTheme.lightSerenity:
        return const Color(0xFFFAFAF7);
      case AppTheme.nightCalm:
        return const Color(0xFF121212);
      case AppTheme.heritageSepia:
        return const Color(0xFFFDF6E3);
    }
  }
}

/// Quick theme toggle button for app bar
class QuickThemeToggleButton extends ConsumerWidget {
  const QuickThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    return IconButton(
      icon: Icon(_getThemeIcon(currentTheme)),
      tooltip: 'Switch Theme',
      onPressed: () => themeNotifier.toggleTheme(),
    );
  }

  IconData _getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.lightSerenity:
        return Icons.wb_sunny;
      case AppTheme.nightCalm:
        return Icons.nights_stay;
      case AppTheme.heritageSepia:
        return Icons.auto_stories;
    }
  }
}
