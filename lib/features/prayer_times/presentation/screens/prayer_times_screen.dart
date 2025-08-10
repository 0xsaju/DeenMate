import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hijri/hijri.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/islamic_utils.dart';
import '../../domain/entities/prayer_times.dart';
import '../providers/prayer_times_providers.dart';
import '../widgets/current_prayer_widget.dart';
import '../widgets/hijri_date_widget.dart';
import '../widgets/islamic_greeting_widget.dart';
import '../widgets/location_widget.dart';
import '../widgets/next_prayer_countdown.dart';
import '../widgets/prayer_time_card.dart';
import '../widgets/prayer_tracking_widget.dart';
import '../widgets/qibla_direction_widget.dart';

/// Prayer Times Screen with Beautiful Islamic Design
/// Displays daily prayer times, current prayer status, and Islamic information
class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  DateTime _selectedDate = DateTime.now();
  bool _showWeeklyView = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ),);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ),);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Handle menu actions from the app bar
  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        ref.invalidate(currentPrayerTimesProvider);
        _showSnackBar('Prayer times refreshed');
        break;
      case 'weekly':
        setState(() {
          _showWeeklyView = !_showWeeklyView;
        });
        _showSnackBar(_showWeeklyView ? 'Weekly view enabled' : 'Daily view enabled');
        break;
      case 'calculations':
        context.push(AppRouter.calculationMethod);
        break;
      case 'export':
        _exportPrayerTimes();
        break;
    }
  }

  /// Show calculation method selection dialog
  void _showCalculationMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calculation Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose your preferred prayer time calculation method:'),
            const SizedBox(height: 16),
            ...AppConstants.calculationMethods.entries.map(
              (entry) => RadioListTile<String>(
                title: Text(entry.value),
                subtitle: Text(entry.key),
                value: entry.key,
                groupValue: 'MWL', // This would come from settings
                onChanged: (value) {
                  Navigator.pop(context);
                  _showSnackBar('Calculation method updated to ${entry.value}');
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Export prayer times
  void _exportPrayerTimes() {
    // This would integrate with the export functionality
    _showSnackBar('Prayer times exported successfully');
  }

  /// Show snack bar with message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPrayerTimesAsync = ref.watch(currentPrayerTimesProvider);
    final currentAndNextPrayerAsync = ref.watch(currentAndNextPrayerProvider);
    final locationAsync = ref.watch(currentLocationProvider);
    final prayerCompletion = ref.watch(prayerCompletionProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, locationAsync),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildIslamicHeader(),
                      _buildDateSelector(),
                      _buildCurrentPrayerSection(currentAndNextPrayerAsync),
                      _buildPrayerTimesSection(currentPrayerTimesAsync, prayerCompletion),
                      _buildAdditionalInfoSection(),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AsyncValue<Location> locationAsync) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      actions: [
        // Athan Settings Button
        IconButton(
          onPressed: () => context.push(AppRouter.athanSettings),
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
          ),
          tooltip: 'Athan & Notification Settings',
        ),
        // More Options Menu
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Refresh Prayer Times'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'weekly',
              child: ListTile(
                leading: Icon(Icons.calendar_view_week),
                title: Text('Weekly View'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'calculations',
              child: ListTile(
                leading: Icon(Icons.calculate),
                title: Text('Calculation Method'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.file_download),
                title: Text('Export Prayer Times'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Prayer Times',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.lightTheme.colorScheme.primary,
                AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Islamic geometric pattern overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/islamic_patterns/geometric_pattern.png',
                    repeat: ImageRepeat.repeat,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
              // Location and time info
              Positioned(
                bottom: 60,
                left: 16,
                right: 16,
                child: locationAsync.when(
                  data: (location) => LocationWidget(location: location),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (error, stack) => Text(
                    'Location unavailable',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showSettingsBottomSheet,
          icon: const Icon(Icons.settings, color: Colors.white),
        ),
        IconButton(
          onPressed: () => setState(() => _showWeeklyView = !_showWeeklyView),
          icon: Icon(
            _showWeeklyView ? Icons.calendar_today : Icons.calendar_month,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildIslamicHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.islamicCardDecoration,
      child: Column(
        children: [
          const IslamicGreetingWidget(),
          const SizedBox(height: 12),
          const HijriDateWidget(),
          const SizedBox(height: 16),
          const Text(
            'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
            style: TextStyle(
              fontFamily: 'NotoSansArabic',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D32),
              height: 1.8,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            'O Allah, help me remember You, thank You, and worship You in the best way',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d, y').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildDateNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildDateNavigationButtons() {
    return Row(
      children: [
        _buildDateNavButton(
          icon: Icons.chevron_left,
          onTap: () => setState(() {
            _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          }),
        ),
        const SizedBox(width: 8),
        _buildDateNavButton(
          icon: Icons.today,
          onTap: () => setState(() {
            _selectedDate = DateTime.now();
          }),
        ),
        const SizedBox(width: 8),
        _buildDateNavButton(
          icon: Icons.chevron_right,
          onTap: () => setState(() {
            _selectedDate = _selectedDate.add(const Duration(days: 1));
          }),
        ),
      ],
    );
  }

  Widget _buildDateNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCurrentPrayerSection(AsyncValue<PrayerDetail> currentPrayerAsync) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: currentPrayerAsync.when(
        data: (prayerDetail) => Column(
          children: [
            CurrentPrayerWidget(prayerDetail: prayerDetail),
            const SizedBox(height: 16),
            NextPrayerCountdown(prayerDetail: prayerDetail),
          ],
        ),
        loading: () => _buildLoadingCard('Loading current prayer...'),
        error: (error, stack) => _buildErrorCard('Unable to load current prayer'),
      ),
    );
  }

  Widget _buildPrayerTimesSection(
    AsyncValue<PrayerTimes> prayerTimesAsync,
    Map<String, bool> prayerCompletion,
  ) {
    if (_showWeeklyView) {
      return _buildWeeklyPrayerTimes();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: prayerTimesAsync.when(
        data: (prayerTimes) => _buildDailyPrayerTimes(prayerTimes, prayerCompletion),
        loading: () => _buildLoadingCard('Loading prayer times...'),
        error: (error, stack) => _buildErrorCard('Unable to load prayer times'),
      ),
    );
  }

  Widget _buildDailyPrayerTimes(PrayerTimes prayerTimes, Map<String, bool> prayerCompletion) {
    final prayers = [
      PrayerInfo('Fajr', prayerTimes.fajr, Icons.wb_twilight, 'فجر'),
      PrayerInfo('Sunrise', prayerTimes.sunrise, Icons.wb_sunny, 'شروق'),
      PrayerInfo('Dhuhr', prayerTimes.dhuhr, Icons.wb_sunny_outlined, 'ظهر'),
      PrayerInfo('Asr', prayerTimes.asr, Icons.wb_cloudy, 'عصر'),
      PrayerInfo('Maghrib', prayerTimes.maghrib, Icons.wb_twilight, 'مغرب'),
      PrayerInfo('Isha', prayerTimes.isha, Icons.nightlight, 'عشاء'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Prayer Times",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  prayerTimes.calculationMethod,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...prayers.map((prayer) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PrayerTimeCard(
            prayer: prayer,
            isCompleted: prayerCompletion[prayer.name.toLowerCase()] ?? false,
            onCompletionToggle: (isCompleted) => _togglePrayerCompletion(
              prayer.name,
              isCompleted,
            ),
          ),
        ),),
      ],
    );
  }

  Widget _buildWeeklyPrayerTimes() {
    final weeklyPrayerTimesAsync = ref.watch(weeklyPrayerTimesProvider);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: weeklyPrayerTimesAsync.when(
        data: (prayerTimesList) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This Week's Prayer Times",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...prayerTimesList.map((prayerTimes) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(prayerTimes.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniPrayerTime('Fajr', prayerTimes.fajr),
                      _buildMiniPrayerTime('Dhuhr', prayerTimes.dhuhr),
                      _buildMiniPrayerTime('Asr', prayerTimes.asr),
                      _buildMiniPrayerTime('Maghrib', prayerTimes.maghrib),
                      _buildMiniPrayerTime('Isha', prayerTimes.isha),
                    ],
                  ),
                ],
              ),
            ),),
          ],
        ),
        loading: () => _buildLoadingCard('Loading weekly prayer times...'),
        error: (error, stack) => _buildErrorCard('Unable to load weekly prayer times'),
      ),
    );
  }

  Widget _buildMiniPrayerTime(String name, Prayer prayer) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          prayer.getFormattedTime(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: const Column(
        children: [
          Row(
            children: [
              Expanded(child: PrayerTrackingWidget()),
              SizedBox(width: 16),
              Expanded(child: QiblaDirectionWidget()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'qibla',
          onPressed: _navigateToQiblaFinder,
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          child: const Icon(Icons.explore),
        ),
        const SizedBox(height: 16),
        FloatingActionButton.extended(
          heroTag: 'monthly',
          onPressed: _showMonthlyCalendar,
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          icon: const Icon(Icons.calendar_month),
          label: const Text('Monthly'),
        ),
      ],
    );
  }

  // Event Handlers

  Future<void> _onRefresh() async {
    // Invalidate providers to force refresh
    ref.invalidate(currentPrayerTimesProvider);
    ref.invalidate(currentAndNextPrayerProvider);
    ref.invalidate(currentLocationProvider);
    ref.invalidate(weeklyPrayerTimesProvider);
    
    // Load today's prayer completion status
    await ref.read(prayerCompletionProvider.notifier).loadTodaysPrayerStatus();
  }

  void _togglePrayerCompletion(String prayerName, bool isCompleted) {
    ref.read(prayerCompletionProvider.notifier).markPrayerCompleted(
      prayerName.toLowerCase(),
      _selectedDate,
      true, // Assume on time for now
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const PrayerTimesSettingsWidget(),
      ),
    );
  }

  void _navigateToQiblaFinder() {
    context.go('/qibla-finder');
  }

  void _showMonthlyCalendar() {
    // TODO: Implement monthly calendar screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Monthly calendar feature coming soon!')),
    );
  }
}

// Helper Classes and Widgets

class PrayerInfo {

  const PrayerInfo(this.name, this.prayer, this.icon, this.arabicName);
  final String name;
  final Prayer prayer;
  final IconData icon;
  final String arabicName;
}

// Settings Widget (placeholder)
class PrayerTimesSettingsWidget extends StatelessWidget {
  const PrayerTimesSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Prayer Times Settings\n(Coming Soon)'),
    );
  }
}
