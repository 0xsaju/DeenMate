import 'package:flutter/material.dart';

/// Next Prayer Countdown Widget
/// Shows countdown to next prayer with beautiful Islamic design
class NextPrayerCountdownWidget extends StatefulWidget {
  const NextPrayerCountdownWidget({super.key});

  @override
  State<NextPrayerCountdownWidget> createState() => _NextPrayerCountdownWidgetState();
}

class _NextPrayerCountdownWidgetState extends State<NextPrayerCountdownWidget>
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
    final nextPrayer = _getNextPrayerInfo();
    
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
              nextPrayer.color,
              nextPrayer.color.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: nextPrayer.color.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next Prayer | পরবর্তী নামাজ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          nextPrayer.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          nextPrayer.arabicName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontFamily: 'NotoSansArabic',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
                          nextPrayer.icon,
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
            
            // Time info
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
                      'Prayer Time | সময়',
                      nextPrayer.time,
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
                      'Remaining | বাকি',
                      nextPrayer.timeRemaining,
                      Icons.timer,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusItem(
                  icon: Icons.mosque,
                  label: 'Qibla | কিবলা',
                  value: 'Ready',
                ),
                _buildStatusItem(
                  icon: Icons.volume_up,
                  label: 'Athan | আযান',
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

  NextPrayerInfo _getNextPrayerInfo() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // This is a simplified example - in real implementation, 
    // this would come from prayer times provider
    if (hour < 5) {
      return NextPrayerInfo(
        name: 'Fajr',
        arabicName: 'فجر',
        time: '5:15 AM',
        timeRemaining: '${5 - hour}h ${15 - now.minute}m',
        color: const Color(0xFF1565C0),
        icon: Icons.wb_twilight,
      );
    } else if (hour < 13) {
      return NextPrayerInfo(
        name: 'Dhuhr',
        arabicName: 'ظهر',
        time: '1:20 PM',
        timeRemaining: '${13 - hour}h ${20 - now.minute}m',
        color: const Color(0xFFFF8F00),
        icon: Icons.wb_sunny,
      );
    } else if (hour < 16) {
      return NextPrayerInfo(
        name: 'Asr',
        arabicName: 'عصر',
        time: '4:45 PM',
        timeRemaining: '${16 - hour}h ${45 - now.minute}m',
        color: const Color(0xFF7B1FA2),
        icon: Icons.wb_cloudy,
      );
    } else if (hour < 18) {
      return NextPrayerInfo(
        name: 'Maghrib',
        arabicName: 'مغرب',
        time: '6:30 PM',
        timeRemaining: '${18 - hour}h ${30 - now.minute}m',
        color: const Color(0xFFD84315),
        icon: Icons.wb_twilight,
      );
    } else if (hour < 20) {
      return NextPrayerInfo(
        name: 'Isha',
        arabicName: 'عشاء',
        time: '8:00 PM',
        timeRemaining: '${20 - hour}h ${0 - now.minute}m',
        color: const Color(0xFF5D4037),
        icon: Icons.nightlight,
      );
    } else {
      return NextPrayerInfo(
        name: 'Fajr',
        arabicName: 'فجر',
        time: '5:15 AM',
        timeRemaining: '${24 + 5 - hour}h ${15 - now.minute}m',
        color: const Color(0xFF1565C0),
        icon: Icons.wb_twilight,
      );
    }
  }
}

/// Data class for next prayer information
class NextPrayerInfo {

  const NextPrayerInfo({
    required this.name,
    required this.arabicName,
    required this.time,
    required this.timeRemaining,
    required this.color,
    required this.icon,
  });
  final String name;
  final String arabicName;
  final String time;
  final String timeRemaining;
  final Color color;
  final IconData icon;
}
