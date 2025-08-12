import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routing/app_router.dart';
import '../widgets/islamic_bottom_navigation.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../../prayer_times/presentation/providers/prayer_times_providers.dart';
import '../../../../core/state/prayer_settings_state.dart';
import '../../../prayer_times/presentation/widgets/direct_prayer_widget.dart';


/// Final enhanced home screen with optimized layout
/// Matches the exact UI/UX design from app-screens directory
class FinalEnhancedHomeScreen extends ConsumerStatefulWidget {
  const FinalEnhancedHomeScreen({super.key});

  @override
  ConsumerState<FinalEnhancedHomeScreen> createState() => _FinalEnhancedHomeScreenState();
}

class _FinalEnhancedHomeScreenState extends ConsumerState<FinalEnhancedHomeScreen> {
  String? nextPrayer = 'Maghrib';
  String? nextPrayerTime = '6:45 PM';
  String? remainingTime = '2h 15m';
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Islamic Header - Matches design exactly
              _buildIslamicHeader(),
              
              // Islamic Greeting Card
                              _buildIslamicGreetingCard(),
                

                
                // Next Prayer Countdown Card
              _buildWorkingPrayerCard(),
              
              // Quick Actions Section
              _buildQuickActionsSection(),
              
              const Spacer(),
              
              // Bottom Navigation
              IslamicBottomNavigation(
                currentIndex: _currentIndex,
                onTap: _handleBottomNavTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0: // Home - already here
        break;
      case 1: // Prayer
        _navigateToPrayerTimes();
        break;
      case 2: // Zakat
        _navigateToZakat();
        break;
      case 2: // Qibla
        _navigateToQibla();
        break;
      case 3: // More
        // TODO: Navigate to more screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⋯ More Features - Coming Soon | আরও ফিচার শীঘ্রই'),
            backgroundColor: const Color(0xFF5D4037),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        break;
    }
  }

  Widget _buildIslamicHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Header with reset button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - empty for balance
              const SizedBox(width: 40),
              
              // Center - App Title
              Expanded(
                child: Text(
                  'DeenMate',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Right side - Reset buttons
              Row(
                children: [
                  // Complete Reset button
                  GestureDetector(
                    onTap: _completeReset,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reset button
                  GestureDetector(
                    onTap: _resetOnboarding,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                                              // Hot reload button
                            GestureDetector(
                              onTap: () async {
                                // Force clear all cached data
                                await PrayerSettingsState.instance.loadSettings();
                                
                                // Invalidate all providers
                                ref.invalidate(prayerSettingsProvider);
                                ref.invalidate(currentAndNextPrayerProvider);
                                ref.invalidate(currentPrayerTimesProvider);
                                ref.invalidate(prayerTimesRepositoryProvider);
                                ref.invalidate(currentLocationProvider);
                                
                                // Force rebuild
                                setState(() {});
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All data cleared and refreshed!'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.sync,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Arabic Bismillah
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          // English translation
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          // Bengali translation
          Text(
            'পরম করুণাময় ও অসীম দয়ালু আল্লাহর নামে',
            style: GoogleFonts.notoSansBengali(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicGreetingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E8).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Arabic greeting
            Text(
              'السَّلاَمُ عَلَيْكُمْ وَرَحْمَةُ اللهِ وَبَرَكَاتُهُ',
              style: GoogleFonts.amiri(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // English translation
            Text(
              'Peace be upon you and Allah\'s mercy and blessings',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // Bengali translation
            Text(
              'আপনার উপর শান্তি ও আল্লাহর রহমত ও বরকত হোক',
              style: GoogleFonts.notoSansBengali(
                fontSize: 12,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingPrayerCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1565C0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Current Prayer | বর্তমান নামাজ',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              // Prayer icon
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
          
          const SizedBox(height: 12),
          
          // Prayer name
          Row(
            children: [
              Text(
                'Dhuhr',
                style: GoogleFonts.notoSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ظهر', // Arabic name for Dhuhr
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Bengali name
          Text(
            'যোহর',
            style: GoogleFonts.notoSansBengali(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Time info container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Prayer time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prayer Time | সময়',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '12:30 PM',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Remaining time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remaining | বাকি',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '2h 30m',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              _buildActionChip(Icons.mosque, 'Direction Qibla'),
              const SizedBox(width: 8),
              _buildActionChip(Icons.volume_up, 'Athan Enabled'),
              const SizedBox(width: 8),
              _buildActionChip(Icons.notifications, 'Reminder 10m'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1565C0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Next Prayer | পরবর্তী নামাজ',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              // Prayer icon
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
          
          const SizedBox(height: 12),
          
          // Prayer name
          Row(
            children: [
              Text(
                nextPrayer ?? 'Next Prayer',
                style: GoogleFonts.notoSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'مغرب', // Arabic name for Maghrib
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Bengali name
          Text(
            'মাগরিব',
            style: GoogleFonts.notoSansBengali(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Time info container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Prayer time
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Prayer Time | সময়',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextPrayerTime ?? 'Tap to view times',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Separator
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.3),
                ),
                
                // Remaining time
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Remaining | বাকি',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        remainingTime ?? '--',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Quick Actions | দ্রুত কার্যক্রম',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Row 1
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Zakat Calculator
              Expanded(
                child: _buildActionCard(
                  icon: '🧮',
                  title: 'Zakat Calculator',
                  subtitle: 'যাকাত ক্যালকুলেটর',
                  description: 'Calculate obligation',
                  color: const Color(0xFF2E7D32),
                  onTap: _navigateToZakat,
                ),
              ),

              const SizedBox(width: 16),

              // Prayer Times
              Expanded(
                child: _buildActionCard(
                  icon: '🕐',
                  title: 'Prayer Times',
                  subtitle: 'নামাজের সময়',
                  description: 'Today\'s schedule',
                  color: const Color(0xFF1565C0),
                  onTap: _navigateToPrayerTimes,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Row 2
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Qibla Finder
              Expanded(
                child: _buildActionCard(
                  icon: '🧭',
                  title: 'Qibla Finder',
                  subtitle: 'কিবলার দিক',
                  description: 'Find direction',
                  color: const Color(0xFFFF8F00),
                  onTap: _navigateToQibla,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Islamic Content
              Expanded(
                child: _buildActionCard(
                  icon: '📖',
                  title: 'Islamic Content',
                  subtitle: 'ইসলামিক কন্টেন্ট',
                  description: 'Daily Quran & Hadith',
                  color: const Color(0xFF7B1FA2),
                  onTap: _navigateToIslamicContent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90, // Reduced from 100 to prevent overflow
        padding: const EdgeInsets.all(10), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title row
            Row(
              children: [
                Container(
                  width: 28, // Reduced from 32
                  height: 28, // Reduced from 32
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6), // Reduced from 8
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 16), // Reduced from 18
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 6), // Reduced from 8
            
            // Title
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 13, // Reduced from 14
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 1), // Reduced from 2
            
            // Subtitle
            Text(
              subtitle,
              style: GoogleFonts.notoSansBengali(
                fontSize: 10, // Reduced from 11
                color: const Color(0xFF666666),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 1), // Reduced from 2
            
            // Description
            Text(
              description,
              style: GoogleFonts.notoSans(
                fontSize: 8, // Reduced from 9
                color: const Color(0xFF999999),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPrayerTimes() {
    context.go(AppRouter.prayerTimes);
  }

  void _navigateToZakat() {
    context.go(AppRouter.zakatCalculator);
  }

  void _navigateToQibla() {
    context.go(AppRouter.qiblaFinder);
  }

  void _navigateToIslamicContent() {
    context.go('/islamic-content');
  }

  void _resetOnboarding() async {
    try {
      await ref.read(onboardingProvider.notifier).resetOnboarding();
      await PrayerSettingsState.instance.reset();
      
      // Invalidate all prayer-related providers to force refresh
      ref.invalidate(prayerSettingsProvider);
      ref.invalidate(currentAndNextPrayerProvider);
      ref.invalidate(currentPrayerTimesProvider);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Onboarding reset! App will refresh with new settings.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting onboarding: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _completeReset() async {
    try {
      // Complete reset - clear everything
      await PrayerSettingsState.instance.reset();
      await ref.read(onboardingProvider.notifier).resetOnboarding();
      
      // Clear all SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Invalidate ALL providers
      ref.invalidate(prayerSettingsProvider);
      ref.invalidate(currentAndNextPrayerProvider);
      ref.invalidate(currentPrayerTimesProvider);
      ref.invalidate(prayerTimesRepositoryProvider);
      ref.invalidate(currentLocationProvider);
      ref.invalidate(onboardingProvider);
      
      // Force rebuild
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('COMPLETE RESET! All data cleared. Please restart the app manually.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      
      // Force app restart after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        SystemNavigator.pop();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during complete reset: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
