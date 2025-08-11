import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/theme_switcher.dart';
import '../widgets/themed_widgets.dart';

/// More screen for additional features and settings
/// Provides access to secondary features in a beautiful Islamic design
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: ThemedAppBar(
        titleText: 'More Features | আরও ফিচার',
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        showBackButton: false,
        actions: const [
          QuickThemeToggle(),
        ],
      ),
      body: Column(
        children: [
          // Islamic header
          _buildIslamicHeader(context),
          
          // Theme switcher card
          const Padding(
            padding: EdgeInsets.all(16),
            child: ThemeSwitcher(
              compact: true,
              showDescription: false,
            ),
          ),
          
          // Features grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    'Sawm Tracker',
                    'সিয়াম ট্র্যাকার',
                    Icons.calendar_month,
                    'Track your fasting',
                    FeatureColors.getColor('islamic', context),
                    AppRouter.sawmTracker,
                  ),
                  _buildFeatureCard(
                    context,
                    'Islamic Will',
                    'ইসলামিক উইল',
                    Icons.description,
                    'Generate Islamic will',
                    FeatureColors.getColor('dua', context),
                    AppRouter.islamicWill,
                  ),
                  _buildFeatureCard(
                    context,
                    'History',
                    'ইতিহাস',
                    Icons.history,
                    'View calculations',
                    FeatureColors.getColor('prayer', context),
                    AppRouter.history,
                  ),
                  _buildFeatureCard(
                    context,
                    'Reports',
                    'রিপোর্ট',
                    Icons.assessment,
                    'Generate reports',
                    colorScheme.error,
                    AppRouter.reports,
                  ),
                  _buildFeatureCard(
                    context,
                    'Profile',
                    'প্রোফাইল',
                    Icons.person,
                    'Manage profile',
                    FeatureColors.getColor('zakat', context),
                    AppRouter.profile,
                  ),
                  _buildFeatureCard(
                    context,
                    'Settings',
                    'সেটিংস',
                    Icons.settings,
                    'App preferences',
                    FeatureColors.getColor('qibla', context),
                    AppRouter.settings,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIslamicHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark 
          ? [colorScheme.surface, colorScheme.primary.withOpacity(0.6)]
          : [AppTheme.islamicGreen, AppTheme.lightIslamicGreen],
    );
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: gradient),
      child: Column(
        children: [
          Text(
            'جزاك الله خيراً',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
              fontFamily: 'NotoSansArabic',
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            'May Allah reward you with goodness',
            style: textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'আল্লাহ আপনাকে কল্যাণ দান করুন',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.8),
              fontFamily: 'NotoSansBengali',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String bengaliTitle,
    IconData icon,
    String description,
    Color color,
    String route,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ThemedCard(
      onTap: () => context.go(route),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(isDark ? 0.2 : 0.1),
          if (isDark) colorScheme.surface else Colors.white,
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.3 : 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            bengaliTitle,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontFamily: 'NotoSansBengali',
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
