import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/utils/islamic_utils.dart' as islamic_utils;
import '../../domain/entities/prayer_times.dart' as prayer_entities;
import '../../domain/entities/prayer_tracking.dart';

import '../providers/prayer_times_providers.dart';

/// Prayer Times Screen with New Design
/// Displays daily prayer times, current prayer status, and Islamic information
class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  // Unused in this design implementation; keep minimal state only
  // Soft warm card fill to match mock (slightly off-white)
  // Removed: using theme extension colors instead

  AppColors get _colors =>
      Theme.of(context).extension<AppColors>() ?? AppColors.light;

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(currentPrayerTimesProvider);
    final currentAndNextPrayerAsync = ref.watch(currentAndNextPrayerProvider);

    return Scaffold(
      backgroundColor: _colors.background,
      body: SafeArea(
        top: true,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: constraints.maxHeight),
              child: Column(
                children: [
                  // Header with Islamic date, current prayer, and attached alert pill
                  _buildHeader(),
                  _buildAlertPill(),

                  // Main content area with proper scrolling
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          // Current and Next Prayer Cards
                          _buildPrayerCards(currentAndNextPrayerAsync),

                          const SizedBox(height: 4),

                          // Suhoor and Iftaar Times
                          _buildSuhoorIftaarSection(prayerTimesAsync),

                          const SizedBox(height: 4),

                          // Small source line for server/provider
                          _buildLocationCard(),

                          const SizedBox(height: 4),

                          // Prayer Times List
                          _buildPrayerTimesList(prayerTimesAsync),

                          // Additional Daily Timings (horizontal) at bottom like the mock
                          const SizedBox(height: 14),
                          _buildAdditionalTimingsHorizontal(prayerTimesAsync),
                          // Bottom safe padding to avoid overlap with custom 70px nav bar
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 110,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: _colors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // Left: Hijri + Gregorian + Local date
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safar 19 1447',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3E2A1F),
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Wednesday, 13 Aug 2025',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B5E56),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '29 Srabon 1432',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B5E56),
                      ),
                    ),
                  ],
                ),
              ),
              // Right: Greeting
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'As-salāmu ‘alaykum,',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B5E56),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sazzad',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2A1F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Standalone subtle alert pill under the header (matches mock)
  Widget _buildAlertPill() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: _colors.alertPill,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.timer, size: 18, color: _colors.headerSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Dhuhr in 10 min, get ready to go to mosque!',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: _colors.headerPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCards(AsyncValue<PrayerDetail> currentAndNextPrayerAsync) {
    const double cardHeight = 156;
    return Row(
      children: [
        // Current Prayer Card
        Expanded(
          child: SizedBox(
            height: cardHeight,
            child: _buildPrayerCard(
              title: 'Now time is',
              prayerName: 'Dhuhr',
              time: '12:27 pm',
              endTime: '3:54pm',
              isCurrent: true,
              backgroundColor: const Color(0xFFFFE7D6),
              silhouetteColor: const Color(0xFFCC6E3C),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Next Prayer Card
        Expanded(
          child: SizedBox(
            height: cardHeight,
            child: _buildPrayerCard(
              title: 'Next prayer is',
              prayerName: 'Asr',
              time: '03:54 pm',
              azanTime: '5:15pm',
              jamaatTime: '5:30pm',
              isCurrent: false,
              backgroundColor: const Color(0xFFEAF4E6),
              silhouetteColor: const Color.fromARGB(255, 118, 172, 122),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerCard({
    required String title,
    required String prayerName,
    required String time,
    String? endTime,
    String? azanTime,
    String? jamaatTime,
    required bool isCurrent,
    Color backgroundColor = Colors.white,
    Color silhouetteColor = const Color(0xFF2C3E50),
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double h =
              constraints.hasBoundedHeight ? constraints.maxHeight : 140;
          final double scale = (h / 140).clamp(0.78, 1.0);
          final bool hasSecondaryLines =
              (endTime != null) || (azanTime != null) || (jamaatTime != null);
          final double adjust = hasSecondaryLines ? 0.88 : 1.0;
          final double nameSize = 18 * scale * adjust;
          // final double timeSize = 24 * scale * adjust; // replaced by fixed design sizes below
          // final double meridiemSize = 11 * scale * adjust; // replaced by fixed design sizes below
          final double subtitleSize = 10.5 * scale; // keep small for multi-line
          final double gapSmall = (hasSecondaryLines ? 2.0 : 3.0) * scale;
          final double gapTiny = 1 * scale;
          final double gapTop = (hasSecondaryLines ? 5.0 : 6.0) * scale;
          final double silhouetteSize = 84 * scale;

          return Container(
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCurrent
                    ? [
                        const Color(0xFFFFE3CF),
                        const Color(0xFFFFE9D9),
                      ]
                    : [
                        const Color(0xFFF4F8F2),
                        const Color(0xFFEFF6EB),
                      ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: 0.18,
                    child: SvgPicture.asset(
                      isCurrent
                          ? 'assets/images/cards/peach_skyline.svg'
                          : 'assets/images/cards/mint_skyline.svg',
                      width: silhouetteSize * 1.8,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                    SizedBox(height: gapTop),
                    Text(
                      prayerName,
                      style: TextStyle(
                        fontSize: nameSize,
                        fontWeight: FontWeight.w600,
                        color: isCurrent ? _colors.accent : _colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: gapSmall),
                    _buildTimeWithMeridiem(
                      time,
                      mainSize: 34 * scale,
                      meridiemSize: 16 * scale,
                    ),
                    if (endTime != null) ...[
                      SizedBox(height: gapTiny),
                      _buildSecondaryInfo('End time - $endTime',
                          fontSize: subtitleSize),
                    ],
                    if (azanTime != null) ...[
                      SizedBox(height: (gapTiny - 1).clamp(0, 8).toDouble()),
                      _buildSecondaryInfo('Azan - $azanTime',
                          fontSize: subtitleSize),
                    ],
                    if (jamaatTime != null) ...[
                      SizedBox(height: (gapTiny - 1).clamp(0, 8).toDouble()),
                      _buildSecondaryInfo("Jama'at - $jamaatTime",
                          fontSize: subtitleSize),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Renders time like 12:27 pm with smaller meridiem to match the mock
  Widget _buildTimeWithMeridiem(String time,
      {double mainSize = 26,
      double meridiemSize = 13,
      Color color = const Color(0xFF2C3E50)}) {
    final parts = time.trim().split(' ');
    final mainTime = parts.isNotEmpty ? parts[0] : time;
    final meridiem = parts.length > 1 ? parts[1] : '';
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: mainTime,
            style: TextStyle(
                fontSize: mainSize, fontWeight: FontWeight.w700, color: color),
          ),
          if (meridiem.isNotEmpty)
            TextSpan(
              text: ' $meridiem',
              style: TextStyle(
                  fontSize: meridiemSize,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
        ],
      ),
    );
  }

  // Smaller variant for list/footer chips with optional color override
  Widget _buildSmallTimeWithMeridiem(String time,
      {Color color = const Color(0xFF2C3E50)}) {
    final parts = time.trim().split(' ');
    final mainTime = parts.isNotEmpty ? parts[0] : time;
    final meridiem = parts.length > 1 ? parts[1] : '';
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: mainTime,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (meridiem.isNotEmpty)
            TextSpan(
              text: ' $meridiem',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecondaryInfo(String text, {double fontSize = 12}) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize,
          color: Theme.of(context).extension<AppColors>()?.textSecondary ??
              const Color(0xFF7F8C8D)),
    );
  }

  Widget _buildSuhoorIftaarSection(
      AsyncValue<prayer_entities.PrayerTimes> prayerTimesAsync) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColors>()?.card ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Suhoor
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Color(0xFFFF6B35),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suhoor',
                      style: TextStyle(
                        fontSize: 15, // Larger font
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    prayerTimesAsync.when(
                      data: (p) => _buildSmallTimeWithMeridiem(
                        DateFormat('h:mm a').format(p.fajr.time).toLowerCase(),
                      ),
                      loading: () => _buildSmallTimeWithMeridiem('—'),
                      error: (_, __) => _buildSmallTimeWithMeridiem('—'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 2,
            height: 52,
            color: Theme.of(context).extension<AppColors>()?.divider ??
                const Color(0xFFD6CBB3),
          ),

          // Iftaar
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Iftaar',
                      style: TextStyle(
                        fontSize: 15, // Larger font
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    prayerTimesAsync.when(
                      data: (p) => _buildSmallTimeWithMeridiem(
                        DateFormat('h:mm a')
                            .format(p.maghrib.time)
                            .toLowerCase(),
                      ),
                      loading: () => _buildSmallTimeWithMeridiem('—'),
                      error: (_, __) => _buildSmallTimeWithMeridiem('—'),
                    ),
                  ],
                ),
                const SizedBox(width: 16), // Increased spacing
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F8C8D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_off,
                    color: Color(0xFF7F8C8D),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    // Render as a slim helper row to indicate server/source beneath the section title
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
      child: Row(
        children: const [
          Icon(Icons.location_on, color: Color(0xFF2C3E50), size: 16),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Al Masjid an Nabawi · prayer times source',
              style: TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(
      AsyncValue<prayer_entities.PrayerTimes> prayerTimesAsync) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColors>()?.card ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: prayerTimesAsync.when(
        data: (prayerTimes) => _buildPrayerTimesListView(prayerTimes),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: Color(0xFFFF6B35),
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFF7F8C8D),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading prayer times',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesListView(prayer_entities.PrayerTimes prayerTimes) {
    // Set Dhuhr as current prayer visually (can be dynamic later)
    const String currentPrayerName = 'Dhuhr';

    final double rowVerticalPadding =
        6; // slightly tighter to reduce row height
    final prayers = [
      {
        'name': 'Fajr',
        'time':
            DateFormat('h:mm a').format(prayerTimes.fajr.time).toLowerCase(),
        'icon': Icons.nightlight_round,
      },
      {
        'name': 'Dhuhr',
        'time':
            DateFormat('h:mm a').format(prayerTimes.dhuhr.time).toLowerCase(),
        'icon': Icons.wb_sunny,
      },
      {
        'name': 'Asr',
        'time': DateFormat('h:mm a').format(prayerTimes.asr.time).toLowerCase(),
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'name': 'Maghrib',
        'time':
            DateFormat('h:mm a').format(prayerTimes.maghrib.time).toLowerCase(),
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'name': 'Isha',
        'time':
            DateFormat('h:mm a').format(prayerTimes.isha.time).toLowerCase(),
        'icon': Icons.nightlight_round,
      },
    ];

    return Column(
      children: prayers.asMap().entries.map((entry) {
        final index = entry.key;
        final prayer = entry.value;
        final isCurrentPrayer = prayer['name'] == currentPrayerName;

        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: rowVerticalPadding, horizontal: 16),
              child: Row(
                children: [
                  // Prayer Icon
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrentPrayer
                          ? const Color(0xFFFF6B35).withOpacity(0.1)
                          : const Color(0xFF7F8C8D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      prayer['icon'] as IconData,
                      color: isCurrentPrayer
                          ? const Color(0xFFFF6B35)
                          : const Color(0xFF7F8C8D),
                      size: 16,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Prayer Name
                  Expanded(
                    child: Text(
                      prayer['name'] as String,
                      style: TextStyle(
                        fontSize: 14, // Reduced to compact row
                        fontWeight: FontWeight.w600,
                        color: isCurrentPrayer
                            ? const Color(0xFFFF6B35)
                            : const Color(0xFF2C3E50),
                      ),
                    ),
                  ),

                  // Prayer Time (aligned to the right)
                  _buildSmallTimeWithMeridiem(
                    prayer['time'] as String,
                    color: isCurrentPrayer
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFF2C3E50),
                  ),

                  const SizedBox(width: 12),

                  // Notification Bell
                  Container(
                    padding: const EdgeInsets.all(6), // tighter padding
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8), // Smaller radius
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFFFF6B35),
                      size: 16, // compact icon
                    ),
                  ),
                ],
              ),
            ),
            // Add divider between prayers (except after the last one)
            if (index < prayers.length - 1)
              Container(
                height: 2,
                color: Theme.of(context).extension<AppColors>()?.divider ??
                    const Color(0xFFD6CBB3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAdditionalTimingsHorizontal(
      AsyncValue<prayer_entities.PrayerTimes> prayerTimesAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColors>()?.card ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sunrise
          Expanded(
            child: prayerTimesAsync.when(
              data: (p) => _buildTimingColumn(
                'Sunrise',
                DateFormat('h:mm a').format(p.sunrise.time).toLowerCase(),
                Icons.wb_sunny,
              ),
              loading: () => _buildTimingColumn('Sunrise', '—', Icons.wb_sunny),
              error: (_, __) =>
                  _buildTimingColumn('Sunrise', '—', Icons.wb_sunny),
            ),
          ),

          // Divider
          Container(
            width: 2,
            height: 48,
            color: Theme.of(context).extension<AppColors>()?.divider ??
                const Color(0xFFD6CBB3),
          ),

          // Mid Day
          Expanded(
            child: prayerTimesAsync.when(
              data: (p) => _buildTimingColumn(
                'Mid Day',
                DateFormat('h:mm a').format(p.dhuhr.time).toLowerCase(),
                Icons.access_time,
              ),
              loading: () =>
                  _buildTimingColumn('Mid Day', '—', Icons.access_time),
              error: (_, __) =>
                  _buildTimingColumn('Mid Day', '—', Icons.access_time),
            ),
          ),

          // Divider
          Container(
            width: 2,
            height: 48,
            color: Theme.of(context).extension<AppColors>()?.divider ??
                const Color(0xFFD6CBB3),
          ),

          // Sunset
          Expanded(
            child: prayerTimesAsync.when(
              data: (p) => _buildTimingColumn(
                'Sunset',
                DateFormat('h:mm a').format(p.maghrib.time).toLowerCase(),
                Icons.wb_sunny_outlined,
              ),
              loading: () =>
                  _buildTimingColumn('Sunset', '—', Icons.wb_sunny_outlined),
              error: (_, __) =>
                  _buildTimingColumn('Sunset', '—', Icons.wb_sunny_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingColumn(String label, String time, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7F8C8D)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 2),
            _buildSmallTimeWithMeridiem(time),
          ],
        ),
      ],
    );
  }

  // Helper methods for icon/color were unused; removed for lints.

  String _getHijriDate() {
    final hijri = islamic_utils.IslamicUtils.getCurrentHijriDate();
    final monthNames = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qadah',
      'Dhu al-Hijjah'
    ];

    return '${monthNames[hijri.hMonth - 1]} ${hijri.hDay}';
  }

  // Snackbar helper not used in this screen; removed.
}
