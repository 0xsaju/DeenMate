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
          
          // Next Prayer Countdown (Working version)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildWorkingPrayerCard(),
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

  Widget _buildWorkingPrayerCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF42A5F5),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Current Prayer | বর্তমান নামাজ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Prayer name
            Row(
              children: [
                const Text(
                  'Dhuhr',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ظهر',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            const Text(
              'যোহর',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Time info container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prayer Time | সময়',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '12:30 PM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remaining | বাকি',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '2h 30m',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Action buttons
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildActionChip(Icons.mosque, 'Qibla'),
                _buildActionChip(Icons.volume_up, 'Athan'),
                _buildActionChip(Icons.notifications, 'Reminder'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
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
