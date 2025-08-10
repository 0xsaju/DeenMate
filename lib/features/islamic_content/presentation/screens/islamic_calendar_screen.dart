import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/islamic_theme.dart';

/// Islamic Calendar Screen following app-screens design
class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  final DateTime _selectedDate = DateTime.now();
  late HijriCalendar _currentHijriDate;

  @override
  void initState() {
    super.initState();
    _currentHijriDate = HijriCalendar.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IslamicTheme.backgroundLight,
      body: Column(
        children: [
          // App Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  IslamicTheme.islamicGreen,
                  IslamicTheme.islamicGreen.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Expanded(
                  child: Text(
                    'Islamic Calendar | ইসলামিক ক্যালেন্ডার',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Settings functionality
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Current Date Card
                  _buildCurrentDateCard(),
                  const SizedBox(height: 20),
                  
                  // Calendar Grid
                  _buildCalendarGrid(),
                  const SizedBox(height: 20),
                  
                  // Important Dates
                  _buildImportantDates(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDateCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            IslamicTheme.islamicGreen.withOpacity(0.1),
            IslamicTheme.islamicGreen.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: IslamicTheme.islamicGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Current Date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: IslamicTheme.islamicGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            DateFormat('EEEE, MMMM d, y').format(_selectedDate),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_currentHijriDate.hDay} ${_getHijriMonthName(_currentHijriDate.hMonth)} ${_currentHijriDate.hYear}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: IslamicTheme.islamicGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calendar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: IslamicTheme.islamicGreen,
            ),
          ),
          const SizedBox(height: 16),
          // Simple calendar representation
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 35, // 5 weeks
            itemBuilder: (context, index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImportantDates() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Important Islamic Dates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: IslamicTheme.islamicGreen,
            ),
          ),
          const SizedBox(height: 16),
          _buildImportantDateItem('Ramadan', 'রমজান', '9th Month'),
          _buildImportantDateItem('Eid al-Fitr', 'ঈদুল ফিতর', 'End of Ramadan'),
          _buildImportantDateItem('Eid al-Adha', 'ঈদুল আযহা', 'Feast of Sacrifice'),
          _buildImportantDateItem('Muharram', 'মুহাররম', '1st Month'),
        ],
      ),
    );
  }

  Widget _buildImportantDateItem(String title, String titleBengali, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: IslamicTheme.islamicGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.event,
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  titleBengali,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHijriMonthName(int month) {
    const months = [
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah',
    ];
    return months[month - 1];
  }
}
