import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/islamic_theme.dart';
import '../../../../core/utils/islamic_utils.dart';

/// Islamic calendar card showing Hijri and Gregorian dates
class IslamicCalendarCard extends StatelessWidget {
  const IslamicCalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final gregorianDay = DateFormat('EEEE').format(now);
    
    // Use proper Hijri date calculation
    final hijriDate = IslamicUtils.getCurrentHijriDate();
    final hijriYear = hijriDate.hYear;
    final hijriMonth = _getHijriMonthName(hijriDate.hMonth);
    final hijriDay = hijriDate.hDay;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: IslamicTheme.islamicGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: IslamicTheme.islamicGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Islamic Calendar',
                      style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                        color: IslamicTheme.islamicGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ইসলামিক ক্যালেন্ডার',
                      style: IslamicTheme.textTheme.bodySmall?.copyWith(
                        color: IslamicTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Today's dates
          Row(
            children: [
              // Hijri date
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: IslamicTheme.islamicGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: IslamicTheme.islamicGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hijri Date',
                        style: IslamicTheme.textTheme.bodySmall?.copyWith(
                          color: IslamicTheme.islamicGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$hijriDay',
                        style: IslamicTheme.textTheme.headlineLarge?.copyWith(
                          color: IslamicTheme.islamicGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        hijriMonth,
                        style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                          color: IslamicTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$hijriYear AH',
                        style: IslamicTheme.textTheme.bodySmall?.copyWith(
                          color: IslamicTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Gregorian date
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: IslamicTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: IslamicTheme.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gregorian Date',
                        style: IslamicTheme.textTheme.bodySmall?.copyWith(
                          color: IslamicTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${now.day}',
                        style: IslamicTheme.textTheme.headlineLarge?.copyWith(
                          color: IslamicTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMMM').format(now),
                        style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                          color: IslamicTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${now.year} CE',
                        style: IslamicTheme.textTheme.bodySmall?.copyWith(
                          color: IslamicTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Day of week
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: IslamicTheme.islamicGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                gregorianDay,
                style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Upcoming events (if any)
          _buildUpcomingEvents(),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    // Sample upcoming events - in production this would be calculated
    final upcomingEvents = [
      'Ramadan starts in 45 days',
      'Laylat al-Qadr expected in 67 days',
    ];
    
    if (upcomingEvents.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Events',
          style: IslamicTheme.textTheme.bodyMedium?.copyWith(
            color: IslamicTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...upcomingEvents.map((event) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: IslamicTheme.islamicGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event,
                  style: IslamicTheme.textTheme.bodySmall?.copyWith(
                    color: IslamicTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),),
      ],
    );
  }

  String _getHijriMonthName(int month) {
    const months = [
      'Muharram',
      'Safar', 
      "Rabi' al-awwal",
      "Rabi' al-thani",
      'Jumada al-awwal',
      'Jumada al-thani',
      'Rajab',
      "Sha'ban",
      'Ramadan',
      'Shawwal',
      "Dhu al-Qi'dah",
      'Dhu al-Hijjah',
    ];
    
    return months[(month - 1) % 12];
  }
}
