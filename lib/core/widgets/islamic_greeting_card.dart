import 'package:flutter/material.dart';
import '../theme/islamic_theme.dart';

/// Islamic greeting card matching the home screen design
class IslamicGreetingCard extends StatelessWidget {
  
  const IslamicGreetingCard({
    super.key,
    this.arabicGreeting = 'السَّلاَمُ عَلَيْكُمْ وَرَحْمَةُ اللهِ وَبَرَكَاتُهُ',
    this.englishGreeting = "Peace be upon you and Allah's mercy and blessings",
    this.bengaliGreeting = 'আপনার উপর শান্তি ও আল্লাহর রহমত ও বরকত হোক',
    this.padding,
    this.borderRadius,
  });
  final String arabicGreeting;
  final String englishGreeting;
  final String bengaliGreeting;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
              child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E8).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Arabic greeting
            Text(
              arabicGreeting,
              style: IslamicTheme.arabicMedium.copyWith(
                color: IslamicTheme.islamicGreen,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 6),
            
            // English translation
            Text(
              englishGreeting,
              style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                color: IslamicTheme.textPrimary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 3),
            
            // Bengali translation
            Text(
              bengaliGreeting,
              style: IslamicTheme.bengaliSmall.copyWith(
                color: IslamicTheme.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Islamic header with bismillah (matching enhanced home design)
class IslamicBismillahHeader extends StatelessWidget {
  
  const IslamicBismillahHeader({
    super.key,
    this.title = 'DeenMate',
    this.bismillah = 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
    this.englishTranslation = 'In the name of Allah, the Most Gracious, the Most Merciful',
    this.bengaliTranslation = 'পরম করুণাময় ও অসীম দয়ালু আল্লাহর নামে',
    this.backgroundGradient,
    this.height = 110,
  });
  final String title;
  final String bismillah;
  final String englishTranslation;
  final String bengaliTranslation;
  final Gradient? backgroundGradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: backgroundGradient ?? IslamicTheme.islamicGreenGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Bismillah in Arabic
            Text(
              bismillah,
              style: IslamicTheme.arabicMedium.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 3),
            
            // English translation
            Text(
              englishTranslation,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 1),
            
            // Bengali translation
            Text(
              bengaliTranslation,
              style: IslamicTheme.bengaliSmall.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
