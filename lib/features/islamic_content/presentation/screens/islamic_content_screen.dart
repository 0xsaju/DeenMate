import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_router.dart';
import '../../data/islamic_content_data.dart';
import '../widgets/daily_dua_card.dart';
import '../widgets/daily_hadith_card.dart';
import '../widgets/daily_verse_card.dart';
import '../widgets/islamic_calendar_card.dart';
import '../widgets/names_of_allah_card.dart';

/// Islamic content screen with daily verses, hadith, and reminders using Material 3 design
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(AppRouter.home),
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Islamic Content',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Daily spiritual guidance',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Share content
            },
            icon: Icon(Icons.share, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(theme),
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(theme),
                _buildQuranTab(theme),
                _buildHadithTab(theme),
                _buildDuasTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(ThemeData theme) {
    final now = DateTime.now();
    final gregorianDate = DateFormat('EEEE, MMMM dd, yyyy').format(now);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  gregorianDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.onSurface,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
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

  Widget _buildTodayTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Islamic Date
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const IslamicCalendarCard(),
          ),
          const SizedBox(height: 16),

          // Today's Verse
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: DailyVerseCard(verse: IslamicContentData.getTodaysVerse()),
          ),
          const SizedBox(height: 16),

          // Today's Hadith
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                DailyHadithCard(hadith: IslamicContentData.getTodaysHadith()),
          ),
          const SizedBox(height: 16),

          // Today's Dua
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: DailyDuaCard(dua: IslamicContentData.getCurrentDua()),
          ),
          const SizedBox(height: 16),

          // Names of Allah
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: NamesOfAllahCard(
                name: IslamicContentData.getRandomNameOfAllah()),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quranic Verses',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Featured verses
          ...IslamicContentData.dailyVerses.take(3).map(
                (verse) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DailyVerseCard(verse: verse),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildHadithTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hadith Collection',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Featured hadiths
          ...IslamicContentData.dailyHadith.take(3).map(
                (hadith) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DailyHadithCard(hadith: hadith),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildDuasTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Duas',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Featured duas
          ...IslamicContentData.dailyDuas.take(3).map(
                (dua) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DailyDuaCard(dua: dua),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
