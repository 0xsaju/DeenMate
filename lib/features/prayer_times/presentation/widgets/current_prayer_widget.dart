import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/prayer_tracking.dart';

/// Widget displaying the current prayer status with beautiful Islamic design
class CurrentPrayerWidget extends ConsumerWidget {

  const CurrentPrayerWidget({
    required this.prayerDetail, super.key,
  });
  final PrayerDetail prayerDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradientColors = _headerGradient();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gradientColors.first.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCurrentPrayerHeader(),
          const SizedBox(height: 16),
          _buildCurrentPrayerInfo(),
          const SizedBox(height: 12),
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
              'Current Prayer | বর্তমান নামাজ',
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
            const SizedBox(height: 2),
            Text(
              _getCurrentPrayerArabicName(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 16,
                fontFamily: 'NotoSansArabic',
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
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoColumn(
              'Prayer Time | সময়',
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
            child: _buildInfoColumn(
              'Remaining | বাকি',
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

  List<Color> _headerGradient() {
    // Color-code header by prayer to match design accents
    switch (prayerDetail.currentPrayer?.toLowerCase()) {
      case 'fajr':
        return [const Color(0xFF3F51B5), const Color(0xFF7986CB)];
      case 'sunrise':
        return [const Color(0xFFFFB300), const Color(0xFFFFE082)];
      case 'dhuhr':
        return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
      case 'asr':
        return [const Color(0xFF7B1FA2), const Color(0xFFBA68C8)];
      case 'maghrib':
        return [const Color(0xFFD84315), const Color(0xFFFF7043)];
      case 'isha':
        return [const Color(0xFF5D4037), const Color(0xFF8D6E63)];
      case 'midnight':
        return [const Color(0xFF263238), const Color(0xFF455A64)];
      default:
        return [const Color(0xFF3F51B5), const Color(0xFF7986CB)];
    }
  }

  String _getCurrentPrayerName() {
    switch (prayerDetail.currentPrayer?.toLowerCase()) {
      case 'fajr':
        return 'Fajr';
      case 'sunrise':
        return 'Sunrise';
      case 'dhuhr':
        return 'Dhuhr';
      case 'asr':
        return 'Asr';
      case 'maghrib':
        return 'Maghrib';
      case 'isha':
        return 'Isha';
      case 'midnight':
        return 'Midnight';
      default:
        return 'Prayer';
    }
  }

  String _getCurrentPrayerArabicName() {
    switch (prayerDetail.currentPrayer?.toLowerCase()) {
      case 'fajr':
        return 'فجر';
      case 'sunrise':
        return 'شروق';
      case 'dhuhr':
        return 'ظهر';
      case 'asr':
        return 'عصر';
      case 'maghrib':
        return 'مغرب';
      case 'isha':
        return 'عشاء';
      case 'midnight':
        return 'منتصف الليل';
      default:
        return 'صلاة';
    }
  }

  IconData _getCurrentPrayerIcon() {
    switch (prayerDetail.currentPrayer?.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'sunrise':
        return Icons.wb_sunny;
      case 'dhuhr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.wb_cloudy;
      case 'maghrib':
        return Icons.wb_twilight;
      case 'isha':
        return Icons.nightlight;
      case 'midnight':
        return Icons.bedtime;
      default:
        return Icons.mosque;
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
