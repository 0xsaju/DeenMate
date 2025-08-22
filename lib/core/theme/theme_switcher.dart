import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_provider.dart';
import 'app_theme.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'App Theme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AppTheme>(
              value: currentTheme,
              decoration: InputDecoration(
                labelText: 'Select Theme',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  _getThemeIcon(currentTheme),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              items: AppTheme.values.map((theme) {
                return DropdownMenuItem<AppTheme>(
                  value: theme,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getThemeColor(theme),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppThemeData.getThemeName(theme),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            AppThemeData.getThemeDescription(theme),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (theme) {
                if (theme != null) {
                  themeNotifier.setTheme(theme);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => themeNotifier.toggleTheme(),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Quick Toggle'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showThemePreview(context, ref),
                    icon: const Icon(Icons.preview),
                    label: const Text('Preview'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Icons.wb_sunny_outlined;
      case AppTheme.sepia:
        return Icons.filter_vintage_outlined;
      case AppTheme.dark:
        return Icons.nights_stay_outlined;
    }
  }

  Color _getThemeColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return const Color(0xFFF5F8F7);
      case AppTheme.sepia:
        return const Color(0xFFF4E9D7);
      case AppTheme.dark:
        return const Color(0xFF000B06);
    }
  }

  void _showThemePreview(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ThemePreviewDialog(),
    );
  }
}

class ThemePreviewDialog extends ConsumerWidget {
  const ThemePreviewDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Theme Preview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: AppTheme.values.map((theme) {
                return _buildThemePreview(context, ref, theme);
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreview(BuildContext context, WidgetRef ref, AppTheme theme) {
    final currentTheme = ref.watch(themeProvider);
    final isSelected = currentTheme == theme;

    return GestureDetector(
      onTap: () {
        ref.read(themeProvider.notifier).setTheme(theme);
        Navigator.of(context).pop();
      },
      child: Container(
        width: 80,
        height: 120,
        decoration: BoxDecoration(
          color: _getThemeColor(theme),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getThemeIcon(theme),
              color: _getThemeIconColor(theme),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              AppThemeData.getThemeName(theme),
              style: TextStyle(
                color: _getThemeTextColor(theme),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getThemeColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return const Color(0xFFF5F8F7);
      case AppTheme.sepia:
        return const Color(0xFFF4E9D7);
      case AppTheme.dark:
        return const Color(0xFF000B06);
    }
  }

  Color _getThemeIconColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return const Color(0xFF54655F);
      case AppTheme.sepia:
        return const Color(0xFF6B5F52);
      case AppTheme.dark:
        return const Color(0xFF9BB6AB);
    }
  }

  Color _getThemeTextColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return const Color(0xFF54655F);
      case AppTheme.sepia:
        return const Color(0xFF6B5F52);
      case AppTheme.dark:
        return const Color(0xFF9BB6AB);
    }
  }

  IconData _getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Icons.wb_sunny_outlined;
      case AppTheme.sepia:
        return Icons.filter_vintage_outlined;
      case AppTheme.dark:
        return Icons.nights_stay_outlined;
    }
  }
}
