import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../localization/strings.dart';
import '../routing/app_router.dart';

/// Quick Actions Widget
/// Provides fast access to main app features in a beautiful grid
class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(builder: (context) {
          return Text(
            S.t(context, 'quick_actions_title', 'Quick Actions | দ্রুত কার্যক্রম'),
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          );
        }),
        const SizedBox(height: 16),
        
        // Main actions row
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                S.t(context, 'prayer_times', 'Prayer Times'),
                S.t(context, 'prayer_times_bn', 'নামাজের সময়'),
                Icons.access_time,
                S.t(context, 'todays_schedule', "Today's prayer schedule"),
                const Color(0xFF1565C0),
                AppRouter.prayerTimes,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Zakat Calculator',
                'যাকাত ক্যালকুলেটর',
                Icons.calculate,
                'Calculate obligation',
                const Color(0xFF2E7D32),
                '/zakat-calculator',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Secondary actions row
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                S.t(context, 'qibla_finder', 'Qibla Finder'),
                S.t(context, 'qibla_finder_bn', 'কিবলার দিক'),
                Icons.explore,
                S.t(context, 'qibla_desc', 'Find direction to Kaaba'),
                const Color(0xFFFF8F00),
                AppRouter.qiblaFinder,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                S.t(context, 'islamic_content', 'Islamic Content'),
                S.t(context, 'islamic_content_bn', 'ইসলামিক কন্টেন্ট'),
                Icons.menu_book,
                S.t(context, 'daily_quran_hadith', 'Daily Quran & Hadith'),
                const Color(0xFF7B1FA2),
                '/islamic-content', // Will create this route
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String bengaliTitle,
    IconData icon,
    String description,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 140, // Increased height to prevent overflow
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 2),
              
              // Bengali title
              Text(
                bengaliTitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'NotoSansBengali',
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Description
              Flexible(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
