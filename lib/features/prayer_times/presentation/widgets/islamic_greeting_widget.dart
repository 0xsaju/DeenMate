import 'package:flutter/material.dart';
import '../../../../core/utils/islamic_utils.dart';

/// Widget displaying Islamic greeting based on time of day
class IslamicGreetingWidget extends StatelessWidget {
  const IslamicGreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final greeting = IslamicUtils.getIslamicGreeting();
    final englishGreeting = _getEnglishGreeting();

    return Column(
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontFamily: 'NotoSansArabic',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 6),
        Text(
          englishGreeting,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getEnglishGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 4 && hour < 6) {
      return "Peace be upon you and Allah's mercy and blessings";
    } else if (hour >= 6 && hour < 12) {
      return 'Good morning, may Allah bless your day';
    } else if (hour >= 12 && hour < 15) {
      return 'Peace be upon you';
    } else if (hour >= 15 && hour < 18) {
      return 'Good afternoon, may your day be blessed';
    } else if (hour >= 18 && hour < 22) {
      return 'Good evening, may Allah grant you peace';
    } else {
      return 'May you have a peaceful night';
    }
  }
}
