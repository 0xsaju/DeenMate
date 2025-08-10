import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_controller.dart';

/// Theme switcher widget for settings or bottom sheet
class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({
    super.key,
    this.showTitle = true,
    this.showDescription = true,
    this.compact = false,
  });

  final bool showTitle;
  final bool showDescription;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);

    if (compact) {
      return _buildCompactSwitcher(context, themeState, themeController);
    }

    return _buildFullSwitcher(context, themeState, themeController);
  }

  Widget _buildCompactSwitcher(
    BuildContext context,
    ThemeState themeState,
    ThemeController themeController,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.palette_outlined,
              color: context.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme | থিম',
                    style: context.textTheme.titleMedium,
                  ),
                  Text(
                    '${themeState.themeMode.label} | ${themeState.themeMode.bengaliLabel}',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            DropdownButton<AppThemeMode>(
              value: themeState.themeMode,
              underline: const SizedBox(),
              items: AppThemeMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mode.icon),
                      const SizedBox(width: 8),
                      Text(mode.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: themeState.isLoading
                  ? null
                  : (mode) {
                      if (mode != null) {
                        themeController.setThemeMode(mode);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullSwitcher(
    BuildContext context,
    ThemeState themeState,
    ThemeController themeController,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: context.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'App Theme | অ্যাপ থিম',
                    style: context.textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (showDescription) ...[
              Text(
                'Choose your preferred theme appearance',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                'আপনার পছন্দের থিম নির্বাচন করুন',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ...AppThemeMode.values.map((mode) {
              return _ThemeOptionTile(
                mode: mode,
                isSelected: themeState.themeMode == mode,
                isLoading: themeState.isLoading,
                onTap: () => themeController.setThemeMode(mode),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Individual theme option tile
class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.mode,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  final AppThemeMode mode;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.outline.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? context.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.surfaceContainerHighest,
          ),
          child: Center(
            child: Text(
              mode.icon,
              style: TextStyle(
                fontSize: 20,
                color: isSelected
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        title: Text(
          mode.label,
          style: context.textTheme.titleMedium?.copyWith(
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mode.bengaliLabel,
              style: context.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? context.colorScheme.primary.withOpacity(0.8)
                    : context.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              _getThemeDescription(mode),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: context.colorScheme.primary,
              )
            : null,
        onTap: isLoading ? null : onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _getThemeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Always use light theme';
      case AppThemeMode.dark:
        return 'Always use dark theme';
      case AppThemeMode.system:
        return 'Follow system settings';
    }
  }
}

/// Quick theme toggle button for app bars
class QuickThemeToggle extends ConsumerWidget {
  const QuickThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);
    final isDark = themeController.isDarkMode(context);

    return IconButton(
      onPressed: themeState.isLoading
          ? null
          : themeController.toggleTheme,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
        ),
      ),
      tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
    );
  }
}

/// Theme switcher bottom sheet
class ThemeSwitcherBottomSheet extends StatelessWidget {
  const ThemeSwitcherBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ThemeSwitcherBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            'Choose Theme | থিম নির্বাচন করুন',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          
          // Theme switcher
          const ThemeSwitcher(
            showTitle: false,
            showDescription: false,
          ),
          
          const SizedBox(height: 20),
          
          // Close button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close | বন্ধ করুন'),
            ),
          ),
          
          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Extension for theme-related context extensions
extension ThemeContextExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
