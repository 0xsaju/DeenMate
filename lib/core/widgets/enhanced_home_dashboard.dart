import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';

import 'connected_prayer_countdown_widget.dart';
import 'daily_islamic_content_widget.dart';
import 'islamic_greeting_widget.dart';
import 'quick_actions_widget.dart';
import 'theme_switcher.dart';

/// Enhanced Home Dashboard for DeenMate
/// Provides a rich, information-dense experience inspired by Bengali Islamic apps
class EnhancedHomeDashboard extends ConsumerWidget {
  const EnhancedHomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Islamic gradient app bar per design
          _buildIslamicAppBar(context, ref),

          // Islamic Greeting
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: IslamicGreetingWidget(),
            ),
          ),
          
          // Next Prayer Countdown (Connected to real data)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ConnectedPrayerCountdownWidget(),
            ),
          ),
          
          // Quick Actions Grid
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: QuickActionsWidget(),
            ),
          ),
          
          // Daily Islamic Content
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: DailyIslamicContentWidget(),
            ),
          ),
          
          // Bottom spacing for navigation
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicAppBar(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Create theme-aware gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark 
          ? [colorScheme.surface, colorScheme.primary.withOpacity(0.8)]
          : [AppTheme.islamicGreen, AppTheme.lightIslamicGreen],
    );
    
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: colorScheme.primary,
      actions: [
        // Theme toggle in app bar
        const QuickThemeToggle(),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // Show theme switcher bottom sheet
            ThemeSwitcherBottomSheet.show(context);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'DeenMate',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(gradient: gradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40), // Account for status bar
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                style: textTheme.displayMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontFamily: 'UthmanicHafs',
                  fontWeight: FontWeight.w400,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Text(
                'In the name of Allah, the Most Gracious, the Most Merciful',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'পরম করুণাময় ও অসীম দয়ালু আল্লাহর নামে',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                  fontFamily: 'NotoSansBengali',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
