import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/localization/strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/islamic_utils.dart' as islamic_utils;
import '../../domain/entities/location.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/prayer_times.dart' as prayer_entities;
import '../../domain/entities/prayer_tracking.dart';

import '../providers/prayer_times_providers.dart';
import '../widgets/current_prayer_widget.dart';
import '../widgets/hijri_date_widget.dart';
import '../widgets/islamic_greeting_widget.dart';
import '../widgets/next_prayer_countdown.dart';
import '../widgets/prayer_time_card.dart';
import '../widgets/prayer_tracking_widget.dart';
import '../widgets/qibla_direction_widget.dart';

/// Prayer Times Screen with New Design
/// Displays daily prayer times, current prayer status, and Islamic information
class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  bool _showWeeklyView = false;

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(currentPrayerTimesProvider);
    final currentAndNextPrayerAsync = ref.watch(currentAndNextPrayerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header with Islamic date and current prayer
          _buildHeader(),

          // Alert bar
          _buildAlertBar(),

          // Main content area with proper scrolling
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Current and Next Prayer Cards
                  _buildPrayerCards(currentAndNextPrayerAsync),

                  const SizedBox(height: 4),

                  // Suhoor and Iftaar Times
                  _buildSuhoorIftaarSection(),

                  const SizedBox(height: 4),

                  // Location Card
                  _buildLocationCard(),

                  const SizedBox(height: 4),

                  // Prayer Times List
                  _buildPrayerTimesList(prayerTimesAsync),

                  const SizedBox(height: 4),

                  // Additional Daily Timings (horizontal)
                  _buildAdditionalTimingsHorizontal(),

                  // Bottom padding for navigation bar
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF34495E),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Mosque background image (blurred)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

          // Content
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 20, 16, 12), // Reduced padding
            child: Row(
              children: [
                // Left side - Islamic date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getHijriDate(),
                        style: const TextStyle(
                          fontSize: 20, // Reduced font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2), // Reduced spacing
                      Text(
                        DateFormat('EEEE, MMMM d yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 12, // Reduced font size
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right side - Current prayer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Dzuhur',
                      style: TextStyle(
                        fontSize: 18, // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2), // Added small spacing
                    const Text(
                      '11:40',
                      style: TextStyle(
                        fontSize: 14, // Reduced font size
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFF2C3E50),
      child: Row(
        children: [
          const Icon(
            Icons.access_time,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Dzuhur in 10m, get ready to go to the mosque!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCards(AsyncValue<PrayerDetail> currentAndNextPrayerAsync) {
    return Row(
      children: [
        // Current Prayer Card
        Expanded(
          child: _buildPrayerCard(
            title: 'Now time is',
            prayerName: currentAndNextPrayerAsync.when(
              data: (data) => data.currentPrayer ?? 'Duhur',
              loading: () => 'Duhur',
              error: (_, __) => 'Duhur',
            ),
            time: currentAndNextPrayerAsync.when(
              data: (data) => '12:27 PM',
              loading: () => '12:27 PM',
              error: (_, __) => '12:27 PM',
            ),
            endTime: '3:54 PM',
            isCurrent: true,
          ),
        ),

        const SizedBox(width: 12),

        // Next Prayer Card
        Expanded(
          child: _buildPrayerCard(
            title: 'Next prayer is',
            prayerName: currentAndNextPrayerAsync.when(
              data: (data) => data.nextPrayer ?? 'Asr',
              loading: () => 'Asr',
              error: (_, __) => 'Asr',
            ),
            time: currentAndNextPrayerAsync.when(
              data: (data) => '03:54 PM',
              loading: () => '03:54 PM',
              error: (_, __) => '03:54 PM',
            ),
            azanTime: '5:15 PM',
            jamaatTime: '5:30 PM',
            isCurrent: false,
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerCard({
    required String title,
    required String prayerName,
    required String time,
    String? endTime,
    String? azanTime,
    String? jamaatTime,
    required bool isCurrent,
  }) {
    return Container(
      height: 60, // Final reduction to eliminate overflow
      padding: const EdgeInsets.all(4), // Minimal padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Mosque silhouette background
          Positioned(
            right: -2,
            bottom: -2,
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.mosque,
                size: 28, // Final size reduction
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 7,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                prayerName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isCurrent
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuhoorIftaarSection() {
    return Container(
      padding: const EdgeInsets.all(12), // Further reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Suhoor
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // Increased padding
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10), // Larger radius
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Color(0xFFFF6B35),
                    size: 22, // Larger icon
                  ),
                ),
                const SizedBox(width: 16), // Increased spacing
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suhoor',
                      style: TextStyle(
                        fontSize: 15, // Larger font
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const Text(
                      '04:57 AM',
                      style: TextStyle(
                        fontSize: 20, // Larger font
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 50, // Increased height
            color: const Color(0xFFE5E7EB),
          ),

          // Iftaar
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Iftaar',
                      style: TextStyle(
                        fontSize: 15, // Larger font
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const Text(
                      '6:37 PM',
                      style: TextStyle(
                        fontSize: 20, // Larger font
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16), // Increased spacing
                Container(
                  padding: const EdgeInsets.all(10), // Increased padding
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F8C8D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10), // Larger radius
                  ),
                  child: const Icon(
                    Icons.notifications_off,
                    color: Color(0xFF7F8C8D),
                    size: 22, // Larger icon
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF2C3E50),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Al Masjid an Nabawi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  'Medina, Saudi Arabia',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(
      AsyncValue<prayer_entities.PrayerTimes> prayerTimesAsync) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: prayerTimesAsync.when(
        data: (prayerTimes) => _buildPrayerTimesListView(prayerTimes),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: Color(0xFFFF6B35),
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFF7F8C8D),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading prayer times',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesListView(prayer_entities.PrayerTimes prayerTimes) {
    final currentPrayerAsync = ref.watch(currentAndNextPrayerProvider);
    String? currentPrayerName;

    currentPrayerAsync.whenData((data) {
      currentPrayerName = data.currentPrayer;
    });

    final prayers = [
      {
        'name': 'Fajr',
        'time': prayerTimes.fajr.getFormattedTime(),
        'icon': Icons.nightlight_round
      },
      {
        'name': 'Duhur',
        'time': prayerTimes.dhuhr.getFormattedTime(),
        'icon': Icons.wb_sunny
      },
      {
        'name': 'Asr',
        'time': prayerTimes.asr.getFormattedTime(),
        'icon': Icons.wb_sunny_outlined
      },
      {
        'name': 'Maghrib',
        'time': prayerTimes.maghrib.getFormattedTime(),
        'icon': Icons.wb_sunny_outlined
      },
      {
        'name': 'Isha',
        'time': prayerTimes.isha.getFormattedTime(),
        'icon': Icons.nightlight_round
      },
    ];

    return Column(
      children: prayers.asMap().entries.map((entry) {
        final index = entry.key;
        final prayer = entry.value;
        final isCurrentPrayer = prayer['name'] == currentPrayerName;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16), // Reduced padding
              child: Row(
                children: [
                  // Prayer Icon
                  Container(
                    padding: const EdgeInsets.all(8), // Reduced padding
                    decoration: BoxDecoration(
                      color: isCurrentPrayer
                          ? const Color(0xFFFF6B35).withOpacity(0.1)
                          : const Color(0xFF7F8C8D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8), // Smaller radius
                    ),
                    child: Icon(
                      prayer['icon'] as IconData,
                      color: isCurrentPrayer
                          ? const Color(0xFFFF6B35)
                          : const Color(0xFF7F8C8D),
                      size: 18, // Smaller icon
                    ),
                  ),

                  const SizedBox(width: 12), // Reduced spacing

                  // Prayer Name
                  Expanded(
                    child: Text(
                      prayer['name'] as String,
                      style: TextStyle(
                        fontSize: 15, // Smaller font
                        fontWeight: FontWeight.w600,
                        color: isCurrentPrayer
                            ? const Color(0xFFFF6B35)
                            : const Color(0xFF2C3E50),
                      ),
                    ),
                  ),

                  // Prayer Time (aligned to the right)
                  Text(
                    prayer['time'] as String,
                    style: TextStyle(
                      fontSize: 15, // Smaller font
                      fontWeight: FontWeight.w500,
                      color: isCurrentPrayer
                          ? const Color(0xFFFF6B35)
                          : const Color(0xFF2C3E50),
                    ),
                  ),

                  const SizedBox(width: 12), // Reduced spacing

                  // Notification Bell
                  Container(
                    padding: const EdgeInsets.all(8), // Reduced padding
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8), // Smaller radius
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFFFF6B35),
                      size: 18, // Smaller icon
                    ),
                  ),
                ],
              ),
            ),
            // Add divider between prayers (except after the last one)
            if (index < prayers.length - 1)
              Container(
                height: 1,
                color: const Color(0xFFE5E7EB),
                margin: const EdgeInsets.symmetric(
                    horizontal: 16), // Reduced margin
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAdditionalTimingsHorizontal() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sunrise
          Expanded(
            child: _buildTimingColumn('Sunrise', '6:17 AM', Icons.wb_sunny),
          ),

          // Divider
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE5E7EB),
          ),

          // Mid Day
          Expanded(
            child: _buildTimingColumn('Mid Day', '12:43 PM', Icons.access_time),
          ),

          // Divider
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE5E7EB),
          ),

          // Sunset
          Expanded(
            child: _buildTimingColumn(
                'Sunset', '6:52 PM', Icons.wb_sunny_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingColumn(String label, String time, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF7F8C8D),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getPrayerIconColor(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return const Color(0xFF9B59B6);
      case 'duhur':
      case 'dhuhr':
        return const Color(0xFFFF6B35);
      case 'asr':
        return const Color(0xFFF39C12);
      case 'maghrib':
        return const Color(0xFFE74C3C);
      case 'isha':
        return const Color(0xFF34495E);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.nightlight_round;
      case 'duhur':
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return Icons.wb_sunny_outlined;
      case 'isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  String _getHijriDate() {
    final hijri = islamic_utils.IslamicUtils.getCurrentHijriDate();
    final monthNames = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qadah',
      'Dhu al-Hijjah'
    ];

    return '${monthNames[hijri.hMonth - 1]} ${hijri.hDay}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B35),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
