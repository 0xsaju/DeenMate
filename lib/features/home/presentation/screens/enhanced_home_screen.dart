import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/islamic_theme.dart';
import '../../../../core/widgets/islamic_greeting_card.dart';
import '../widgets/islamic_bottom_navigation.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/quick_action_card.dart';

/// Enhanced home screen matching the 01_enhanced_home_dashboard_canva.svg design
class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IslamicTheme.backgroundLight,
      body: Column(
        children: [
          // Islamic header with bismillah (matching design)
          const IslamicBismillahHeader(),
          
          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Islamic greeting card (matching design)
                  const IslamicGreetingCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Next prayer countdown card (matching design)
                  NextPrayerCard(
                    nextPrayer: 'Maghrib',
                    nextPrayerArabic: 'مغرب',
                    nextPrayerBengali: 'মাগরিব',
                    prayerTime: '6:45 PM',
                    timeRemaining: '2h 15m',
                    onTap: _navigateToPrayerTimes,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick actions header (matching design)
                  Text(
                    'Quick Actions | দ্রুত কার্যক্রম',
                    style: IslamicTheme.textTheme.headlineMedium?.copyWith(
                      color: IslamicTheme.islamicGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quick actions grid (2x2 - matching design)
                  _buildQuickActionsGrid(),
                  
                  // Bottom padding for navigation
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom navigation (matching design)
      bottomNavigationBar: IslamicBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _handleBottomNavTap(index);
        },
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      children: [
        // Row 1
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: '🧮',
                title: 'Zakat Calculator',
                titleBengali: 'যাকাত ক্যালকুলেটর',
                subtitle: 'Calculate obligation',
                backgroundColor: const Color(0xFFE8F5E8),
                iconBackgroundColor: IslamicTheme.islamicGreen.withOpacity(0.2),
                titleColor: IslamicTheme.islamicGreen,
                onTap: _navigateToZakat,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: QuickActionCard(
                icon: '🕐',
                title: 'Prayer Times',
                titleBengali: 'নামাজের সময়',
                subtitle: "Today's schedule",
                backgroundColor: const Color(0xFFE3F2FD),
                iconBackgroundColor: IslamicTheme.prayerBlue.withOpacity(0.2),
                titleColor: IslamicTheme.prayerBlue,
                onTap: _navigateToPrayerTimes,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Row 2
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: '🧭',
                title: 'Qibla Finder',
                titleBengali: 'কিবলার দিক',
                subtitle: 'Find direction',
                backgroundColor: const Color(0xFFFFF3E0),
                iconBackgroundColor: IslamicTheme.hadithOrange.withOpacity(0.2),
                titleColor: IslamicTheme.hadithOrange,
                onTap: _navigateToQibla,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: QuickActionCard(
                icon: '📖',
                title: 'Islamic Content',
                titleBengali: 'ইসলামিক কন্টেন্ট',
                subtitle: 'Daily Quran & Hadith',
                backgroundColor: const Color(0xFFF3E5F5),
                iconBackgroundColor: IslamicTheme.quranPurple.withOpacity(0.2),
                titleColor: IslamicTheme.quranPurple,
                onTap: _navigateToContent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToPrayerTimes() {
    context.go(AppRouter.prayerTimes);
  }

  void _navigateToZakat() {
    context.go(AppRouter.zakatCalculator);
  }

  void _navigateToQibla() {
    // TODO: Implement Qibla finder navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Qibla Finder - Coming Soon')),
    );
  }

  void _navigateToContent() {
    context.go('/islamic-content');
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0: // Home - already here
        break;
      case 1: // Prayer
        context.go(AppRouter.prayerTimes);
        break;
      case 2: // Zakat
        context.go(AppRouter.zakatCalculator);
        break;
      case 3: // Qibla
        _navigateToQibla();
        break;
      case 4: // More
        // TODO: Navigate to more screen
        break;
    }
  }
}
