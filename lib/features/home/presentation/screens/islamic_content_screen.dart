import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class IslamicContentScreen extends StatefulWidget {
  const IslamicContentScreen({super.key});

  @override
  State<IslamicContentScreen> createState() => _IslamicContentScreenState();
}

class _IslamicContentScreenState extends State<IslamicContentScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _content = [
    {
      'type': 'ayah',
      'title': 'Today\'s Ayah | আজকের আয়াত',
      'arabic': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
      'transliteration': 'Wa man yattaqi Allaha yaj\'al lahu makhrajan',
      'bengali': 'যে আল্লাহকে ভয় করে, তিনি তার জন্য উত্তরণের পথ করে দেন।',
      'reference': 'Surah At-Talaq 65:2',
      'icon': '📖',
      'color': const Color(0xFF7B1FA2),
      'bgColor': const Color(0xFFF3E5F5),
    },
    {
      'type': 'hadith',
      'title': 'Today\'s Hadith | আজকের হাদিস',
      'arabic': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      'transliteration': 'Innama al-a\'malu bil-niyyat',
      'bengali': 'নিশ্চয়ই সকল কাজ নিয়তের উপর নির্ভরশীল।',
      'english': 'Verily, deeds are only with intentions.',
      'reference': 'Sahih Bukhari 1',
      'icon': '💬',
      'color': const Color(0xFFFF8F00),
      'bgColor': const Color(0xFFFFF3E0),
    },
    {
      'type': 'dua',
      'title': 'Today\'s Dua | আজকের দোয়া',
      'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
      'bengali': 'হে আমাদের রব! আমাদের দুনিয়াতে কল্যাণ দিন।',
      'reference': 'Quran 2:201',
      'icon': '🤲',
      'color': const Color(0xFF5D4037),
      'bgColor': const Color(0xFFEFEBE9),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Islamic Content',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF7B1FA2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF7B1FA2),
              const Color(0xFF7B1FA2).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Content Title
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Today\'s Islamic Content',
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'দৈনিক ইসলামিক কন্টেন্ট',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 14,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content Cards
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _content.length,
                  itemBuilder: (context, index) {
                    final item = _content[index];
                    return _buildContentCard(item);
                  },
                ),
              ),
              
              // Navigation Dots
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_content.length, (index) {
                    return Container(
                      width: _currentPage == index ? 12 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? const Color(0xFF7B1FA2)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: item['bgColor'],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      item['icon'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Text(
                  item['title'],
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: item['color'],
                  ),
                ),
              ],
            ),
          ),
          
          // Arabic Text
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: [
                Text(
                  item['arabic'],
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    color: const Color(0xFF333333),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                if (item['transliteration'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    item['transliteration'],
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      color: const Color(0xFF666666),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          
          // Bengali Translation
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item['bgColor'],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item['bengali'],
              style: GoogleFonts.notoSansBengali(
                fontSize: 13,
                color: const Color(0xFF333333),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // English Translation (for Hadith)
          if (item['english'] != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                item['english'],
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: const Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Reference
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: item['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['reference'],
              style: GoogleFonts.notoSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: item['color'],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
