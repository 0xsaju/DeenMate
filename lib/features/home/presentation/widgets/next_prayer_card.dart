import 'package:flutter/material.dart';
import '../../../../core/theme/islamic_theme.dart';

/// Next prayer countdown card matching the home screen design
class NextPrayerCard extends StatelessWidget {
  
  const NextPrayerCard({
    required this.nextPrayer, required this.nextPrayerArabic, required this.nextPrayerBengali, required this.prayerTime, required this.timeRemaining, super.key,
    this.onTap,
  });
  final String nextPrayer;
  final String nextPrayerArabic;
  final String nextPrayerBengali;
  final String prayerTime;
  final String timeRemaining;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: IslamicTheme.prayerBlueGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: IslamicTheme.prayerBlue),
          boxShadow: [
            BoxShadow(
              color: IslamicTheme.prayerBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Prayer | পরবর্তী নামাজ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                
                // Prayer icon (matching design)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Prayer name row
            Row(
              children: [
                // English name
                Text(
                  nextPrayer,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Arabic name
                Text(
                  nextPrayerArabic,
                  style: IslamicTheme.arabicMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Bengali name
            Text(
              nextPrayerBengali,
              style: IslamicTheme.bengaliMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Time info container (matching design)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Prayer time section
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Prayer Time | সময়',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prayerTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Separator line
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  
                  // Remaining time section
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Remaining | বাকি',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeRemaining,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}
