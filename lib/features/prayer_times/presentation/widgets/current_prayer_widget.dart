import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/islamic_utils.dart';
import '../../domain/entities/prayer_times.dart';

/// Widget displaying the current prayer status with beautiful Islamic design
class CurrentPrayerWidget extends ConsumerWidget {

  const CurrentPrayerWidget({
    required this.prayerDetail, super.key,
  });
  final PrayerDetail prayerDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCurrentPrayerHeader(),
          const SizedBox(height: 20),
          _buildCurrentPrayerInfo(),
          const SizedBox(height: 16),
          _buildPrayerStatusRow(),
        ],
      ),
    );
  }

  Widget _buildCurrentPrayerHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Prayer',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getCurrentPrayerName(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _getCurrentPrayerIcon(),
            color: Colors.white,
            size: 32,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPrayerInfo() {
    return Container(
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
            child: _buildInfoColumn(
              'Prayer Time',
              prayerDetail.time.getFormattedTime(),
              Icons.access_time,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildInfoColumn(
              'Remaining',
              _formatDuration(prayerDetail.timeUntilNextPrayer),
              Icons.timer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
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
        ),
      ],
    );
  }

  Widget _buildPrayerStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatusItem(
          icon: Icons.mosque,
          label: 'Direction',
          value: 'Qibla',
        ),
        _buildStatusItem(
          icon: Icons.volume_up,
          label: 'Athan',
          value: 'Enabled',
        ),
        _buildStatusItem(
          icon: Icons.notifications,
          label: 'Reminder',
          value: '10m',
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
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

  String _getCurrentPrayerName() {
    switch (prayerDetail.name) {
      case PrayerTime.fajr:
        return 'Fajr';
      case PrayerTime.sunrise:
        return 'Sunrise';
      case PrayerTime.dhuhr:
        return 'Dhuhr';
      case PrayerTime.asr:
        return 'Asr';
      case PrayerTime.maghrib:
        return 'Maghrib';
      case PrayerTime.isha:
        return 'Isha';
      case PrayerTime.midnight:
        return 'Midnight';
    }
  }

  IconData _getCurrentPrayerIcon() {
    switch (prayerDetail.name) {
      case PrayerTime.fajr:
        return Icons.wb_twilight;
      case PrayerTime.sunrise:
        return Icons.wb_sunny;
      case PrayerTime.dhuhr:
        return Icons.wb_sunny_outlined;
      case PrayerTime.asr:
        return Icons.wb_cloudy;
      case PrayerTime.maghrib:
        return Icons.wb_twilight;
      case PrayerTime.isha:
        return Icons.nightlight;
      case PrayerTime.midnight:
        return Icons.bedtime;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return 'Passed';
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
