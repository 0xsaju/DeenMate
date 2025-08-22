import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Welcome screen for the onboarding flow
/// Displays Islamic greeting and app introduction with modern Material 3 design
class WelcomeScreen extends ConsumerWidget {
  final VoidCallback? onNext;

  const WelcomeScreen({super.key, this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.mosque,
                      size: 64,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Arabic greeting
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'السلام عليكم ورحمة الله وبركاته',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: 'Uthmani',
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // English welcome message
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Welcome to DeenMate',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Your spiritual companion for prayer times, Quran reading, and Islamic guidance',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 64),

                  // Feature highlights
                  _buildFeatureHighlights(theme),

                  const SizedBox(height: 48),

                  // Bottom decoration
                  _buildBottomDecoration(theme),
                ],
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildContinueButton(context, theme),
                  const SizedBox(height: 16),
                  Text(
                    'Tap to continue',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights(ThemeData theme) {
    final features = [
      {'icon': Icons.access_time, 'text': 'Accurate Prayer Times'},
      {'icon': Icons.menu_book, 'text': 'Complete Quran Reading'},
      {'icon': Icons.explore, 'text': 'Qibla Direction'},
      {'icon': Icons.notifications, 'text': 'Azan Notifications'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: features
            .map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          size: 20,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          feature['text'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => onNext?.call(),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_forward,
          color: theme.colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildBottomDecoration(ThemeData theme) {
    return Column(
      children: [
        // Decorative line
        Container(
          width: 60,
          height: 2,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 16),
        // Decorative dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDecorativeDot(theme.colorScheme.primary),
            const SizedBox(width: 8),
            _buildDecorativeDot(theme.colorScheme.primary, size: 6),
            const SizedBox(width: 8),
            _buildDecorativeDot(theme.colorScheme.primary),
          ],
        ),
      ],
    );
  }

  Widget _buildDecorativeDot(Color color, {double size = 4}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
