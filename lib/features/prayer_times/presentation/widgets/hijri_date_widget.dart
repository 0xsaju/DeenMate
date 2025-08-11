import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/islamic_utils.dart';

/// Widget displaying current Hijri date with Islamic styling
class HijriDateWidget extends StatelessWidget {
  const HijriDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hijriDate = IslamicUtils.getCurrentHijriDate();
    final gregorianDate = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Hijri Date
          Text(
            IslamicUtils.formatHijriDateArabic(hijriDate),
            style: const TextStyle(
              fontFamily: 'NotoSansArabic',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
              height: 1.4,
            ),
            // textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 4),
          Text(
            IslamicUtils.formatHijriDateEnglish(hijriDate),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          // Separator
          Container(
            width: 40,
            height: 1,
            color: const Color(0xFF2E7D32).withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          // Gregorian Date
          Text(
            DateFormat('EEEE, MMMM d, y').format(gregorianDate),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          _buildSpecialOccasion(hijriDate),
        ],
      ),
    );
  }

  Widget _buildSpecialOccasion(hijriDate) {
    final specialOccasion = _getSpecialOccasion(hijriDate);
    
    if (specialOccasion == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 16,
            color: Colors.amber[700],
          ),
          const SizedBox(width: 6),
          Text(
            specialOccasion,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }

  String? _getSpecialOccasion(hijriDate) {
    // Check for special Islamic occasions
    if (hijriDate.hMonth == 9) {
      if (hijriDate.hDay == 1) {
        return 'First Day of Ramadan';
      } else if (hijriDate.hDay >= 21 && hijriDate.hDay <= 30) {
        return 'Laylat al-Qadr Period';
      } else {
        return 'Holy Month of Ramadan';
      }
    }

    if (hijriDate.hMonth == 10 && hijriDate.hDay == 1) {
      return 'Eid al-Fitr';
    }

    if (hijriDate.hMonth == 12) {
      if (hijriDate.hDay >= 8 && hijriDate.hDay <= 10) {
        return 'Hajj Period';
      } else if (hijriDate.hDay == 10) {
        return 'Eid al-Adha';
      } else if (hijriDate.hDay >= 11 && hijriDate.hDay <= 13) {
        return 'Days of Tashreeq';
      }
    }

    if (hijriDate.hMonth == 1 && hijriDate.hDay == 10) {
      return 'Day of Ashura';
    }

    if (hijriDate.hMonth == 3 && hijriDate.hDay == 12) {
      return 'Mawlid an-Nabi';
    }

    if (hijriDate.hMonth == 7 && hijriDate.hDay == 27) {
      return "Laylat al-Mi'raj";
    }

    if (hijriDate.hMonth == 8 && hijriDate.hDay == 15) {
      return "Laylat al-Bara'at";
    }

    // Check for Fridays
    final now = DateTime.now();
    if (now.weekday == DateTime.friday) {
      return "Jumu'ah Mubarak";
    }

    return null;
  }
}
