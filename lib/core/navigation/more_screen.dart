import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          // Theme toggle moved to Settings
        ],
      ),
      body: Column(
        children: [
          // Islamic header
          _buildIslamicHeader(context),
          
          // Features grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // SETTINGS SECTION
                  _buildFeatureCard(
                    context,
                    'Settings',
                    'সেটিংস',
                    Icons.settings,
                    'App preferences & configuration',
                    FeatureColors.getColor('qibla', context),
                    '/settings',
                  ),
                  
                  // QURAN ADVANCED FEATURES
                  _buildFeatureCard(
                    context,
                    'Quran Bookmarks',
                    'কুরআন বুকমার্ক',
                    Icons.bookmark,
                    'Saved verses & notes',
                    FeatureColors.getColor('prayer', context),
                    '/quran/bookmarks',
                  ),
                  _buildFeatureCard(
                    context,
                    'Reading Plans',
                    'পঠন পরিকল্পনা',
                    Icons.schedule,
                    '30-day & Ramadan plans',
                    FeatureColors.getColor('islamic', context),
                    '/quran/reading-plans',
                  ),
                  _buildFeatureCard(
                    context,
                    'Audio Downloads',
                    'অডিও ডাউনলোড',
                    Icons.download,
                    'Offline recitations',
                    FeatureColors.getColor('dua', context),
                    '/quran/audio-downloads',
                  ),
                  
                  // ISLAMIC TOOLS
                  _buildFeatureCard(
                    context,
                    'Inheritance',
                    'উত্তরাধিকার',
                    Icons.calculate,
                    'Islamic inheritance calculator',
                    FeatureColors.getColor('islamic', context),
                    '/inheritance-calculator',
                  ),
                  _buildFeatureCard(
                    context,
                    'Shariah Guide',
                    'শরীয়ত গাইড',
                    Icons.book,
                    'Learn inheritance principles',
                    FeatureColors.getColor('dua', context),
                    '/shariah-clarification',
                  ),
                  
                  // USER FEATURES
                  _buildFeatureCard(
                    context,
                    'Profile',
                    'প্রোফাইল',
                    Icons.person,
                    'Manage profile',
                    FeatureColors.getColor('zakat', context),
                    '/profile',
                  ),
                  _buildFeatureCard(
                    context,
                    'History',
                    'ইতিহাস',
                    Icons.history,
                    'View calculations',
                    FeatureColors.getColor('prayer', context),
                    '/history',
                  ),
                  
                  // FUTURE FEATURES
                  _buildFeatureCard(
                    context,
                    'Sawm Tracker',
                    'সিয়াম ট্র্যাকার',
                    Icons.calendar_month,
                    'Track your fasting',
                    FeatureColors.getColor('islamic', context),
                    '/sawm-tracker',
                  ),
                  _buildFeatureCard(
                    context,
                    'Islamic Will',
                    'ইসলামিক উইল',
                    Icons.description,
                    'Generate Islamic will',
                    FeatureColors.getColor('dua', context),
                    '/islamic-will',
                  ),
                  _buildFeatureCard(
                    context,
                    'Reports',
                    'রিপোর্ট',
                    Icons.assessment,
                    'Generate reports',
                    colorScheme.error,
                    '/reports',
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
          : [colorScheme.primary, colorScheme.primaryContainer],
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
          colorScheme.surface,
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
