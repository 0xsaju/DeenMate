import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Production Prayer Times Screen matching app-screens/02_prayer_times_screen.svg
/// Features: Live countdown, Islamic design, Bengali integration, prayer tracking
class PrayerTimesProductionScreen extends ConsumerStatefulWidget {
  const PrayerTimesProductionScreen({super.key});

  @override
  ConsumerState<PrayerTimesProductionScreen> createState() => _PrayerTimesProductionScreenState();
}

class _PrayerTimesProductionScreenState extends ConsumerState<PrayerTimesProductionScreen>
    with TickerProviderStateMixin {
  late Timer _countdownTimer;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Update countdown every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _countdownTimer.cancel();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeController,
              child: Column(
                children: [
                  _buildDateHeader(),
                  const SizedBox(height: 16),
                  _buildCurrentPrayerCard(),
                  const SizedBox(height: 16),
                  _buildUpcomingPrayersSection(),
                  const SizedBox(height: 16),
                  _buildTodaysProgressCard(),
                  const SizedBox(height: 16),
                  _buildLocationInfoCard(),
                  const SizedBox(height: 100), // Bottom padding for navigation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Prayer Times | নামাজের সময়',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            // Navigate to prayer settings
          },
        ),
      ],
    );
  }

  Widget _buildDateHeader() {
    final today = DateTime.now();
    final hijriDate = _getHijriDate(today);
    final banglaDate = _getBanglaDate(today);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today | আজ',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatEnglishDate(today),
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hijriDate,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banglaDate,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                '🌙',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPrayerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x1A2E7D32),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '🌅',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fajr | ফজর',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '5:15 AM',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '✓ Completed | সম্পন্ন',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Text(
                'Next in',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + 0.1 * _pulseController.value,
                    child: Text(
                      _getTimeUntilNextPrayer(),
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPrayersSection() {
    final prayers = _getUpcomingPrayers();
    
    return Column(
      children: prayers.map((prayer) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: prayer['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                prayer['icon'],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          title: Text(
            prayer['name'],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prayer['time'],
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 13,
                ),
              ),
              Text(
                prayer['remaining'],
                style: TextStyle(
                  color: prayer['color'],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDDDDD), width: 2),
            ),
          ),
        ),
      ),).toList(),
    );
  }

  Widget _buildTodaysProgressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Progress | আজকের অগ্রগতি",
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProgressItem('Prayers', '1/5', const Color(0xFF2E7D32)),
              const SizedBox(width: 16),
              _buildProgressItem('Streak', '7 days', const Color(0xFFFF8F00)),
              const SizedBox(width: 16),
              _buildProgressItem('Month', '85%', const Color(0xFF1565C0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📍 Dhaka, Bangladesh',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Calculation Method: Islamic Society of North America',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getHijriDate(DateTime date) {
    // Use proper Hijri date calculation
    final hijriDate = IslamicUtils.getCurrentHijriDate();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekday = weekdays[date.weekday - 1];
    final monthNames = [
      'Muharram', 'Safar', "Rabi' al-awwal", "Rabi' al-thani",
      'Jumada al-awwal', 'Jumada al-thani', 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
    ];
    final monthName = monthNames[hijriDate.hMonth - 1];
    return '$weekday, ${hijriDate.hDay} $monthName ${hijriDate.hYear}';
  }

  String _getBanglaDate(DateTime date) {
    // Use proper Hijri date for Bengali
    final hijriDate = IslamicUtils.getCurrentHijriDate();
    final bengaliHijriMonths = {
      1: 'মুহররম', 2: 'সফর', 3: 'রবিউল আউয়াল', 4: 'রবিউস সানি',
      5: 'জমাদিউল আউয়াল', 6: 'জমাদিউস সানি', 7: 'রজব', 8: 'শাবান',
      9: 'রমজান', 10: 'শাওয়াল', 11: 'জিলকদ', 12: 'জিলহজ',
    };
    final bengaliHijriMonth = bengaliHijriMonths[hijriDate.hMonth] ?? 'রমজান';
    return 'জুমা, ${hijriDate.hDay} $bengaliHijriMonth ${hijriDate.hYear}';
  }

  String _formatEnglishDate(DateTime date) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getTimeUntilNextPrayer() {
    // Mock implementation - would calculate actual time
    final now = DateTime.now();
    final nextPrayer = DateTime(now.year, now.month, now.day, 13, 20); // Next Dhuhr
    
    if (nextPrayer.isBefore(now)) {
      // If Dhuhr has passed, show next day's Fajr
      final nextFajr = DateTime(now.year, now.month, now.day + 1, 5, 15);
      final diff = nextFajr.difference(now);
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    
    final diff = nextPrayer.difference(now);
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  List<Map<String, dynamic>> _getUpcomingPrayers() {
    return [
      {
        'name': 'Dhuhr | যুহর',
        'time': '1:20 PM',
        'remaining': 'in 6h 5m',
        'icon': '☀️',
        'color': const Color(0xFFFF8F00),
      },
      {
        'name': 'Asr | আসর',
        'time': '4:45 PM',
        'remaining': 'in 9h 30m',
        'icon': '🌤',
        'color': const Color(0xFF7B1FA2),
      },
      {
        'name': 'Maghrib | মাগরিব',
        'time': '6:30 PM',
        'remaining': 'in 11h 15m',
        'icon': '🌆',
        'color': const Color(0xFFD84315),
      },
      {
        'name': 'Isha | ইশা',
        'time': '8:00 PM',
        'remaining': 'in 12h 45m',
        'icon': '🌙',
        'color': const Color(0xFF5D4037),
      },
    ];
  }
}
