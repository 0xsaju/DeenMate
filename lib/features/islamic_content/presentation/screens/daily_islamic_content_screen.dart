import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/islamic_theme.dart';
import '../../data/islamic_content_data.dart';

class DailyIslamicContentScreen extends StatefulWidget {
  const DailyIslamicContentScreen({super.key});

  @override
  State<DailyIslamicContentScreen> createState() => _DailyIslamicContentScreenState();
}

class _DailyIslamicContentScreenState extends State<DailyIslamicContentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, dynamic>> _getContent() {
    final todaysVerse = IslamicContentData.getTodaysVerse();
    final todaysHadith = IslamicContentData.getTodaysHadith();
    final currentDua = IslamicContentData.getCurrentDua();
    
    return [
      {
        'type': 'Quran',
        'title': 'Daily Quran Verse',
        'subtitle': 'আজকের কুরআন আয়াত',
        'content': '${todaysVerse['arabic']}\n"${todaysVerse['english']}"\n- ${todaysVerse['reference']}',
        'icon': '📖',
        'backgroundColor': const Color(0xFFE8F5E8),
      },
      {
        'type': 'Hadith',
        'title': 'Daily Hadith',
        'subtitle': 'আজকের হাদীস',
        'content': '${todaysHadith['arabic']}\n"${todaysHadith['english']}"\n- ${todaysHadith['source']}',
        'icon': '📚',
        'backgroundColor': const Color(0xFFFFF3E0),
      },
      {
        'type': 'Dua',
        'title': 'Daily Dua',
        'subtitle': 'আজকের দোয়া',
        'content': '${currentDua['arabic']}\n"${currentDua['english']}"\nBenefit: ${currentDua['benefit']}',
        'icon': '🤲',
        'backgroundColor': const Color(0xFFF3E5F5),
      },
    ];
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
                    'Islamic Content | ইসলামিক বিষয়বস্তু',
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
                    // Share functionality
                  },
                  icon: const Icon(Icons.share, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Column(
              children: [
                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _getContent().length,
                    itemBuilder: (context, index) {
                      final content = _getContent();
                      final item = content[index];
                      return _buildContentCard(item);
                    },
                  ),
                ),
                
                // Navigation Dots
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _getContent().length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? IslamicTheme.islamicGreen
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: item['backgroundColor'] as Color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Text(
            item['icon']!,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            item['title']!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: IslamicTheme.islamicGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            item['subtitle']!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Content
          Text(
            item['content']!,
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
