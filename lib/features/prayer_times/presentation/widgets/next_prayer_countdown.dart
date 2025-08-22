
import 'package:deen_mate/features/prayer_times/domain/entities/prayer_tracking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/prayer_times_providers.dart';

/// Countdown widget showing time until next prayer with animated progress
class NextPrayerCountdown extends ConsumerStatefulWidget {

  const NextPrayerCountdown({
    required this.prayerDetail, super.key,
  });
  final PrayerDetail prayerDetail;

  @override
  ConsumerState<NextPrayerCountdown> createState() => _NextPrayerCountdownState();
}

class _NextPrayerCountdownState extends ConsumerState<NextPrayerCountdown>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ),);

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ),);

    _pulseController.repeat(reverse: true);
    _progressController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeUntilNextStream = ref.watch(timeUntilNextPrayerProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.blue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          _buildCountdownHeader(),
          const SizedBox(height: 16),
          timeUntilNextStream.when(
            data: _buildCountdownDisplay,
            loading: _buildLoadingCountdown,
            error: (error, stack) => _buildErrorCountdown(),
          ),
          const SizedBox(height: 16),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildCountdownHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Prayer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getNextPrayerName(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getNextPrayerIcon(),
                  color: Colors.blue,
                  size: 24,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCountdownDisplay(Duration timeUntil) {
    if (timeUntil.isNegative) {
      return _buildPrayerInProgress();
    }

    final hours = timeUntil.inHours;
    final minutes = timeUntil.inMinutes % 60;
    final seconds = timeUntil.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Hours'),
        _buildTimeSeparator(),
        _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Minutes'),
        _buildTimeSeparator(),
        _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Seconds'),
      ],
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildPrayerInProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Prayer time has arrived!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCountdown() {
    return SizedBox(
      height: 80,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildErrorCountdown() {
    return SizedBox(
      height: 80,
      child: Center(
        child: Text(
          'Unable to calculate time',
          style: TextStyle(
            color: Colors.red[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Time',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Next Prayer',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _calculateProgress() * _progressAnimation.value,
              backgroundColor: Colors.blue.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue,
              ),
              minHeight: 6,
            );
          },
        ),
      ],
    );
  }

  String _getNextPrayerName() {
    switch (widget.prayerDetail.nextPrayer?.toLowerCase()) {
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
        return 'Next Prayer';
    }
  }

  IconData _getNextPrayerIcon() {
    switch (widget.prayerDetail.nextPrayer?.toLowerCase()) {
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

  double _calculateProgress() {
    // Use the timeUntilNextPrayer from PrayerDetail
    final totalDuration = widget.prayerDetail.timeUntilNextPrayer;
    
    if (totalDuration.inSeconds == 0) return 0;
    
    // Calculate progress based on remaining time
    final progress = 1.0 - (totalDuration.inSeconds / (24 * 60 * 60)); // Assuming 24-hour cycle
    return progress.clamp(0.0, 1.0);
  }
}
