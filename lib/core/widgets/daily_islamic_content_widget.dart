import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Daily Islamic Content Widget
/// Displays Quran verses, Hadith, and Duas like the reference Bengali apps
class DailyIslamicContentWidget extends StatelessWidget {
  const DailyIslamicContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Islamic Content | দৈনিক ইসলামিক কন্টেন্ট',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Today's Ayah
        _buildContentCard(
          title: "Today's Ayah | আজকের আয়াত",
          arabicText: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
          transliteration: "Wa man yattaqi Allaha yaj'al lahu makhrajan",
          translation: 'যে আল্লাহকে ভয় করে, তিনি তার জন্য উত্তরণের পথ করে দেন।',
          englishTranslation: 'And whoever fears Allah, He will make for him a way out.',
          reference: 'Surah At-Talaq 65:2',
          color: const Color(0xFF7B1FA2),
          icon: Icons.menu_book,
        ),
        
        const SizedBox(height: 16),
        
        // Today's Hadith
        _buildContentCard(
          title: "Today's Hadith | আজকের হাদিস",
          arabicText: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
          transliteration: "Innama al-a'malu bil-niyyat",
          translation: 'নিশ্চয়ই সকল কাজ নিয়তের উপর নির্ভরশীল।',
          englishTranslation: 'Verily, deeds are only with intentions.',
          reference: 'Sahih Bukhari 1',
          color: const Color(0xFFFF8F00),
          icon: Icons.format_quote,
        ),
        
        const SizedBox(height: 16),
        
        // Today's Dua
        _buildContentCard(
          title: "Today's Dua | আজকের দোয়া",
          arabicText: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
          transliteration: "Rabbana atina fi'd-dunya hasanatan wa fi'l-akhirati hasanatan wa qina 'adhab an-nar",
          translation: 'হে আমাদের রব! আমাদের দুনিয়াতে কল্যাণ দিন এবং আখিরাতেও কল্যাণ দিন এবং আগুনের আযাব থেকে রক্ষা করুন।',
          englishTranslation: 'Our Lord! Give us good in this world and good in the hereafter, and save us from the punishment of the Fire.',
          reference: 'Quran 2:201',
          color: const Color(0xFF5D4037),
          icon: Icons.favorite,
        ),
      ],
    );
  }

  Widget _buildContentCard({
    required String title,
    required String arabicText,
    required String transliteration,
    required String translation,
    required String englishTranslation,
    required String reference,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      arabicText,
                      style: const TextStyle(
                        fontFamily: 'UthmanicHafs',
                        fontSize: 20,
                        height: 1.8,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Transliteration
                  Text(
                    transliteration,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Bengali translation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      translation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSansBengali',
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // English translation
                  Text(
                    englishTranslation,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Reference
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          reference,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
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
