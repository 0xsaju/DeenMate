import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/prayer_times/domain/entities/prayer_times.dart' as prayer_entities;
import '../../features/prayer_times/domain/entities/prayer_tracking.dart';
import '../../features/prayer_times/presentation/providers/prayer_times_providers.dart';
import '../../core/utils/islamic_utils.dart' as islamic_utils;
import '../localization/bengali_strings.dart';
import '../theme/app_theme.dart';

/// Connected Prayer Countdown Widget that uses real prayer times data
/// This replaces the mock version with actual Riverpod provider integration
class ConnectedPrayerCountdownWidget extends ConsumerStatefulWidget {
  const ConnectedPrayerCountdownWidget({super.key});

  @override
  ConsumerState<ConnectedPrayerCountdownWidget> createState() => _ConnectedPrayerCountdownWidgetState();
}

class _ConnectedPrayerCountdownWidgetState extends ConsumerState<ConnectedPrayerCountdownWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ),);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(currentPrayerTimesProvider);
    final currentPrayerAsync = ref.watch(currentAndNextPrayerProvider);
    
    return prayerTimesAsync.when(
      data: (prayerTimes) => currentPrayerAsync.when(
        data: (currentPrayer) => _buildPrayerCountdown(prayerTimes, currentPrayer),
        loading: _buildLoadingCard,
        error: (error, stack) => _buildErrorCard(error),
      ),
      loading: _buildLoadingCard,
      error: (error, stack) => _buildErrorCard(error),
    );
  }

  Widget _buildPrayerCountdown(prayer_entities.PrayerTimes prayerTimes, PrayerDetail? currentPrayer) {
    if (currentPrayer == null) {
      return _buildNoDataCard();
    }

    final nextPrayerInfo = _getNextPrayerInfo(prayerTimes, currentPrayer);
    
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              nextPrayerInfo.color,
              nextPrayerInfo.color.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: nextPrayerInfo.color.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with Bengali support
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'next_prayer'.bn} | Next Prayer',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          nextPrayerInfo.englishName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          nextPrayerInfo.arabicName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontFamily: 'NotoSansArabic',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      nextPrayerInfo.bengaliName,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                        fontFamily: 'NotoSansBengali',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          nextPrayerInfo.icon,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Time info with Bengali labels
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTimeInfo(
                      '${'prayer_time'.bn} | Time',
                      'Current Time',
                      Icons.access_time,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildTimeInfo(
                      '${'time_remaining'.bn} | Remaining',
                      _formatDuration(currentPrayer.timeUntilNextPrayer),
                      Icons.timer,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status indicators with Bengali
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusItem(
                  icon: Icons.mosque,
                  label: '${'qibla'.bn} | Qibla',
                  value: 'Ready',
                ),
                _buildStatusItem(
                  icon: Icons.volume_up,
                  label: '${'athan'.bn} | Athan',
                  value: 'On',
                ),
                _buildStatusItem(
                  icon: Icons.notifications,
                  label: 'Alert | সতর্কতা',
                  value: '10m',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
              Colors.grey.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '${'loading'.bn}...',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(Object error) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.red.withOpacity(0.1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[700],
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                '${'error'.bn} | Error loading prayer times',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                color: Colors.grey[600],
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No prayer data available | কোন নামাজের তথ্য পাওয়া যায়নি',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ConnectedPrayerInfo _getNextPrayerInfo(prayer_entities.PrayerTimes prayerTimes, PrayerDetail currentPrayer) {
    // Map prayer names to colors and details
    final prayerColors = {
      islamic_utils.PrayerTime.fajr: const Color(0xFF1565C0),
      islamic_utils.PrayerTime.sunrise: const Color(0xFFFFD700),
      islamic_utils.PrayerTime.dhuhr: const Color(0xFFFF8F00),
      islamic_utils.PrayerTime.asr: const Color(0xFF7B1FA2),
      islamic_utils.PrayerTime.maghrib: const Color(0xFFD84315),
      islamic_utils.PrayerTime.isha: const Color(0xFF5D4037),
      islamic_utils.PrayerTime.midnight: const Color(0xFF2F4F4F),
    };

    final prayerIcons = {
      islamic_utils.PrayerTime.fajr: Icons.wb_twilight,
      islamic_utils.PrayerTime.sunrise: Icons.wb_sunny,
      islamic_utils.PrayerTime.dhuhr: Icons.wb_sunny_outlined,
      islamic_utils.PrayerTime.asr: Icons.wb_cloudy,
      islamic_utils.PrayerTime.maghrib: Icons.wb_twilight,
      islamic_utils.PrayerTime.isha: Icons.nightlight,
      islamic_utils.PrayerTime.midnight: Icons.bedtime,
    };

    final bengaliNames = {
      islamic_utils.PrayerTime.fajr: 'ফজর',
      islamic_utils.PrayerTime.sunrise: 'সূর্যোদয়',
      islamic_utils.PrayerTime.dhuhr: 'যুহর',
      islamic_utils.PrayerTime.asr: 'আসর',
      islamic_utils.PrayerTime.maghrib: 'মাগরিব',
      islamic_utils.PrayerTime.isha: 'ইশা',
      islamic_utils.PrayerTime.midnight: 'মধ্যরাত',
    };

    final arabicNames = {
      islamic_utils.PrayerTime.fajr: 'فجر',
      islamic_utils.PrayerTime.sunrise: 'شروق',
      islamic_utils.PrayerTime.dhuhr: 'ظهر',
      islamic_utils.PrayerTime.asr: 'عصر',
      islamic_utils.PrayerTime.maghrib: 'مغرب',
      islamic_utils.PrayerTime.isha: 'عشاء',
      islamic_utils.PrayerTime.midnight: 'منتصف الليل',
    };

    final englishNames = {
      islamic_utils.PrayerTime.fajr: 'Fajr',
      islamic_utils.PrayerTime.sunrise: 'Sunrise',
      islamic_utils.PrayerTime.dhuhr: 'Dhuhr',
      islamic_utils.PrayerTime.asr: 'Asr',
      islamic_utils.PrayerTime.maghrib: 'Maghrib',
      islamic_utils.PrayerTime.isha: 'Isha',
      islamic_utils.PrayerTime.midnight: 'Midnight',
    };

    return ConnectedPrayerInfo(
      englishName: englishNames[currentPrayer.currentPrayer] ?? 'Prayer',
      arabicName: arabicNames[currentPrayer.currentPrayer] ?? '',
      bengaliName: bengaliNames[currentPrayer.currentPrayer] ?? '',
      color: prayerColors[currentPrayer.currentPrayer] ?? AppTheme.lightTheme.colorScheme.primary,
      icon: prayerIcons[currentPrayer.currentPrayer] ?? Icons.access_time,
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return 'Passed | অতিবাহিত';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// Data class for connected prayer information
class ConnectedPrayerInfo {

  const ConnectedPrayerInfo({
    required this.englishName,
    required this.arabicName,
    required this.bengaliName,
    required this.color,
    required this.icon,
  });
  final String englishName;
  final String arabicName;
  final String bengaliName;
  final Color color;
  final IconData icon;
}
