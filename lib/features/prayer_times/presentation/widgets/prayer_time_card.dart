import 'package:flutter/material.dart';
// import '../screens/prayer_times_screen.dart';

/// Beautiful Prayer Time Card with Islamic Design
/// Displays individual prayer time with completion status and Islamic styling
class PrayerTimeCard extends StatefulWidget {
  const PrayerTimeCard({
    required this.prayerName,
    required this.prayerTime,
    required this.isCompleted,
    required this.onCompletionToggle,
    super.key,
  });
  final String prayerName;
  final String prayerTime;
  final bool isCompleted;
  final Function(bool) onCompletionToggle;

  @override
  State<PrayerTimeCard> createState() => _PrayerTimeCardState();
}

class _PrayerTimeCardState extends State<PrayerTimeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _completionController;
  late Animation<double> _checkAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _checkAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _completionController,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.green.withOpacity(0.1),
    ).animate(
      CurvedAnimation(
        parent: _completionController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _completionController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isCompleted) {
      _completionController.forward();
    }
  }

  @override
  void didUpdateWidget(PrayerTimeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCompleted != widget.isCompleted) {
      if (widget.isCompleted) {
        _completionController.forward();
      } else {
        _completionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentPrayer = _isCurrentPrayer();
    final nextPrayerTime = _getNextPrayerTime();
    final timeUntilPrayer = _getTimeUntilPrayer();

    return AnimatedBuilder(
      animation: _completionController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrentPrayer
                    ? Colors.green
                    : Colors.green.withOpacity(0.2),
                width: isCurrentPrayer ? 2 : 1,
              ),
              boxShadow: [
                if (isCurrentPrayer)
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                _buildPrayerIcon(isCurrentPrayer),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPrayerInfo(isCurrentPrayer, timeUntilPrayer),
                ),
                _buildPrayerTime(),
                const SizedBox(width: 16),
                _buildCompletionCheckbox(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrayerIcon(bool isCurrentPrayer) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isCurrentPrayer ? Colors.green : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isCurrentPrayer)
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Icon(
        Icons.access_time,
        color: isCurrentPrayer ? Colors.white : Colors.green,
        size: 28,
      ),
    );
  }

  Widget _buildPrayerInfo(bool isCurrentPrayer, String? timeUntilPrayer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.prayerName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isCurrentPrayer ? Colors.green : Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'فجر', // Default Arabic name
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isCurrentPrayer ? Colors.green : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (isCurrentPrayer && timeUntilPrayer != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Next | পরবর্তী: $timeUntilPrayer',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          )
        else if (!isCurrentPrayer && timeUntilPrayer != null)
          Text(
            timeUntilPrayer,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildPrayerTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.prayerTime,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        if (false) ...[
          // Removed adjustment check for now
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Adjusted',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.orange[700],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompletionCheckbox() {
    return GestureDetector(
      onTap: () {
        // Allow toggling both ways - completed to uncompleted and vice versa
        widget.onCompletionToggle(!widget.isCompleted);
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: widget.isCompleted ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
        ),
        child: widget.isCompleted
            ? ScaleTransition(
                scale: _checkAnimation,
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }

  bool _isCurrentPrayer() {
    final now = DateTime.now();
    final prayerTime = DateTime.now(); // Simplified for now

    // Check if this prayer is happening now or coming up next
    // This is a simplified logic - in a real app, you'd use the current prayer provider
    final timeDifference = prayerTime.difference(now).inMinutes;
    return timeDifference >= -30 &&
        timeDifference <= 120; // 30 min ago to 2 hours ahead
  }

  String? _getTimeUntilPrayer() {
    final now = DateTime.now();
    final prayerTime = DateTime.now(); // Simplified for now
    final difference = prayerTime.difference(now);

    if (difference.isNegative) {
      final passedDuration = now.difference(prayerTime);
      if (passedDuration.inMinutes < 60) {
        return '${passedDuration.inMinutes}m ago';
      } else if (passedDuration.inHours < 24) {
        return '${passedDuration.inHours}h ago';
      }
      return null;
    } else {
      if (difference.inMinutes < 60) {
        return 'in ${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        return 'in ${hours}h ${minutes}m';
      }
      return null;
    }
  }

  DateTime _getNextPrayerTime() {
    // This would be implemented to get the actual next prayer time
    // For now, return the current prayer time
    return DateTime.now(); // Simplified for now
  }
}
