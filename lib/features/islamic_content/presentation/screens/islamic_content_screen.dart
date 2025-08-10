import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/islamic_theme.dart';
import '../../data/islamic_content_data.dart';
import '../widgets/daily_dua_card.dart';
import '../widgets/daily_hadith_card.dart';
import '../widgets/daily_verse_card.dart';
import '../widgets/islamic_calendar_card.dart';
import '../widgets/names_of_allah_card.dart';
/// Islamic content screen with daily verses, hadith, and reminders
class IslamicContentScreen extends StatefulWidget {
  const IslamicContentScreen({super.key});

  @override
  State<IslamicContentScreen> createState() => _IslamicContentScreenState();
}

class _IslamicContentScreenState extends State<IslamicContentScreen>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  final PageController _pageController = PageController();
  final int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              IslamicTheme.quranPurple,
              IslamicTheme.quranPurple.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildDateHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTodayTab(),
                    _buildQuranTab(),
                    _buildHadithTab(),
                    _buildDuasTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(AppRouter.home),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Islamic Content',
                  style: IslamicTheme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ইসলামিক কন্টেন্ট | المحتوى الإسلامي',
                  style: IslamicTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Share content
            },
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final gregorianDate = DateFormat('EEEE, MMMM dd, yyyy').format(now);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: IslamicTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  gregorianDate,
                  style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelStyle: IslamicTheme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        tabs: const [
          Tab(text: 'Today'),
          Tab(text: 'Quran'),
          Tab(text: 'Hadith'),
          Tab(text: 'Duas'),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Islamic Date
          const IslamicCalendarCard(),
          const SizedBox(height: 16),
          
          // Today's Verse
          DailyVerseCard(verse: IslamicContentData.getTodaysVerse()),
          const SizedBox(height: 16),
          
          // Today's Hadith
          DailyHadithCard(hadith: IslamicContentData.getTodaysHadith()),
          const SizedBox(height: 16),
          
          // Current Dua
          DailyDuaCard(dua: IslamicContentData.getCurrentDua()),
          const SizedBox(height: 16),
          
          // Name of Allah for contemplation
          NamesOfAllahCard(name: IslamicContentData.getRandomNameOfAllah()),
        ],
      ),
    );
  }

  Widget _buildQuranTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Daily Verses', 'আজকের আয়াত'),
          const SizedBox(height: 16),
          
          // Show multiple verses
          ...IslamicContentData.dailyVerses.take(5).map((verse) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DailyVerseCard(verse: verse),
            );
          }),
          
          const SizedBox(height: 24),
          
          _buildComingSoonCard('Full Quran', 'Complete Quran with recitation and tafsir'),
        ],
      ),
    );
  }

  Widget _buildHadithTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Authentic Hadith', 'সহিহ হাদিস'),
          const SizedBox(height: 16),
          
          // Show multiple hadith
          ...IslamicContentData.dailyHadith.take(5).map((hadith) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DailyHadithCard(hadith: hadith),
            );
          }),
          
          const SizedBox(height: 24),
          
          _buildComingSoonCard('Hadith Collections', 'Bukhari, Muslim, and other authentic collections'),
        ],
      ),
    );
  }

  Widget _buildDuasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Daily Duas', 'দৈনিক দোয়া'),
          const SizedBox(height: 16),
          
          // Show all duas
          ...IslamicContentData.dailyDuas.map((dua) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DailyDuaCard(dua: dua),
            );
          }),
          
          const SizedBox(height: 24),
          
          _buildComingSoonCard('Dua Collections', 'Complete collection of prophetic supplications'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: IslamicTheme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: IslamicTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoonCard(String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.upcoming,
            size: 48,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: IslamicTheme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: IslamicTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Coming Soon',
              style: IslamicTheme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
