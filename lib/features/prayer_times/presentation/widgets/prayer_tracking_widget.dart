import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/prayer_statistics.dart';
import '../providers/prayer_times_providers.dart';

/// Widget showing prayer tracking statistics and streaks
class PrayerTrackingWidget extends ConsumerWidget {
  const PrayerTrackingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));
    
    // Temporarily disable prayer statistics to avoid Hive errors
    // final statisticsAsync = ref.watch(prayerStatisticsProvider(
    //   DateTime.now(),
    // ),);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          // Temporarily show loading state
          _buildLoadingState(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.analytics,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Prayer Tracking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          Icons.trending_up,
          color: Colors.green[600],
          size: 16,
        ),
      ],
    );
  }

  Widget _buildStatistics(PrayerStatistics statistics) {
    return Column(
      children: [
        // Completion Rate
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Completion Rate',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(statistics.completionRate * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getCompletionRateColor(statistics.completionRate),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: statistics.completionRate,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getCompletionRateColor(statistics.completionRate),
          ),
          minHeight: 6,
        ),
        const SizedBox(height: 16),
        
        // Current Streak
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Streak',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${statistics.completedCount} prayers',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (statistics.completedCount >= 5)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStreakBadge(statistics.completedCount),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Prayer-wise breakdown
        _buildPrayerBreakdown(statistics),
      ],
    );
  }

  Widget _buildPrayerBreakdown(PrayerStatistics statistics) {
    final prayerNames = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final prayerIcons = [
      Icons.wb_twilight,
      Icons.wb_sunny_outlined,
      Icons.wb_cloudy,
      Icons.wb_twilight,
      Icons.nightlight,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prayer Breakdown (30 days)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(prayerNames.length, (index) {
            final prayerName = prayerNames[index];
            final count = statistics.completedPrayers[prayerName] == true ? 1 : 0;
            final percentage = count / 30; // 30 days
            
            return Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: percentage >= 0.8
                        ? Colors.green.withOpacity(0.2)
                        : percentage >= 0.6
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    prayerIcons[index],
                    size: 16,
                    color: percentage >= 0.8
                        ? Colors.green[600]
                        : percentage >= 0.6
                            ? Colors.orange[600]
                            : Colors.red[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prayerName.substring(0, 1).toUpperCase() + prayerName.substring(1, 3),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load statistics',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCompletionRateColor(double rate) {
    if (rate >= 0.8) return Colors.green[600]!;
    if (rate >= 0.6) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  String _getStreakBadge(int days) {
    if (days >= 100) return '🔥 Master';
    if (days >= 30) return '⭐ Excellent';
    if (days >= 14) return '👍 Great';
    if (days >= 7) return '✨ Good';
    return '';
  }
}
