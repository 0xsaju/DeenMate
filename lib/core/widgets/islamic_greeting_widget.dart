import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Islamic Greeting Widget
/// Displays time-appropriate Islamic greetings in Arabic, English, and Bengali
class IslamicGreetingWidget extends StatelessWidget {
  const IslamicGreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final greeting = _getIslamicGreeting();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Arabic greeting
            Text(
              greeting.arabic,
              style: const TextStyle(
                fontFamily: 'NotoSansArabic',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            
            const SizedBox(height: 8),
            
            // English greeting
            Text(
              greeting.english,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 6),
            
            // Bengali greeting
            Text(
              greeting.bengali,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'NotoSansBengali',
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Time and date info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    greeting.icon,
                    size: 16,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    greeting.timeInfo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IslamicGreeting _getIslamicGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 4 && hour < 6) {
      // Fajr time
      return const IslamicGreeting(
        arabic: 'السَّلاَمُ عَلَيْكُمْ وَرَحْمَةُ اللهِ وَبَرَكَاتُهُ',
        english: "Peace be upon you and Allah's mercy and blessings",
        bengali: 'আপনার উপর শান্তি ও আল্লাহর রহমত ও বরকত হোক',
        timeInfo: 'Fajr Time | ফজরের সময়',
        icon: Icons.wb_twilight,
      );
    } else if (hour >= 6 && hour < 12) {
      // Morning
      return const IslamicGreeting(
        arabic: 'صَبَاحُ الْخَيْرِ، بَارَكَ اللَّهُ فِي يَوْمِكَ',
        english: 'Good morning, may Allah bless your day',
        bengali: 'শুভ সকাল, আল্লাহ আপনার দিনকে বরকতময় করুন',
        timeInfo: 'Morning | সকাল',
        icon: Icons.wb_sunny,
      );
    } else if (hour >= 12 && hour < 15) {
      // Afternoon
      return const IslamicGreeting(
        arabic: 'السَّلاَمُ عَلَيْكُمْ',
        english: 'Peace be upon you',
        bengali: 'আসসালামু আলাইকুম',
        timeInfo: 'Afternoon | দুপুর',
        icon: Icons.wb_sunny_outlined,
      );
    } else if (hour >= 15 && hour < 18) {
      // Late afternoon
      return const IslamicGreeting(
        arabic: 'مَسَاءُ الْخَيْرِ، بَارَكَ اللَّهُ فِيكَ',
        english: 'Good afternoon, may Allah bless you',
        bengali: 'শুভ বিকাল, আল্লাহ আপনাকে বরকত দিন',
        timeInfo: 'Afternoon | বিকাল',
        icon: Icons.wb_cloudy,
      );
    } else if (hour >= 18 && hour < 22) {
      // Evening
      return const IslamicGreeting(
        arabic: 'مَسَاءُ الْخَيْرِ، أَسْأَلُ اللَّهَ لَكَ السَّلاَمَة',
        english: 'Good evening, may Allah grant you peace',
        bengali: 'শুভ সন্ধ্যা, আল্লাহ আপনাকে শান্তি দান করুন',
        timeInfo: 'Evening | সন্ধ্যা',
        icon: Icons.wb_twilight,
      );
    } else {
      // Night
      return const IslamicGreeting(
        arabic: 'تُصْبِحُونَ عَلَى خَيْرٍ',
        english: 'May you have a peaceful night',
        bengali: 'আপনার শান্তিময় রাত হোক',
        timeInfo: 'Night | রাত',
        icon: Icons.nightlight,
      );
    }
  }
}

/// Data class for Islamic greetings
class IslamicGreeting {

  const IslamicGreeting({
    required this.arabic,
    required this.english,
    required this.bengali,
    required this.timeInfo,
    required this.icon,
  });
  final String arabic;
  final String english;
  final String bengali;
  final String timeInfo;
  final IconData icon;
}
