import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../prayer_times/domain/entities/prayer_times.dart'
    as prayer_entities;
import '../../../prayer_times/domain/entities/prayer_tracking.dart';
import '../../../prayer_times/presentation/providers/prayer_times_providers.dart';
import '../../../prayer_times/domain/entities/athan_settings.dart';

/// Home Screen (replaces old home) — shows live prayer times, countdown, etc.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  AppColors get _colors =>
      Theme.of(context).extension<AppColors>() ?? AppColors.light;

  @override
  Widget build(BuildContext context) {
    // Fast-path cached data for instant render, while live fetch updates
    final cachedAsync = ref.watch(cachedCurrentPrayerTimesProvider);
    final cachedDetail = ref.watch(cachedCurrentAndNextPrayerProvider);
    final prayerTimesAsync = ref.watch(currentPrayerTimesProvider);
    final currentAndNextPrayerAsync = ref.watch(currentAndNextPrayerOfflineAwareProvider);
    // Keep providers warm for midnight refresh and countdown
    ref.watch(prayerTimesMidnightRefreshProvider);
    final countdownAsync = ref.watch(alertBannerStateProvider);
    final use24hPref = ref.watch(timeFormat24hProvider);
    final bool use24h = use24hPref.maybeWhen(
      data: (v) => v,
      orElse: () => MediaQuery.of(context).alwaysUse24HourFormat,
    );

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
                  _buildHeader(
                    // header prefers live; fallback to cached PT for instant
                    prayerTimesAsync.hasValue
                        ? prayerTimesAsync
                        : (cachedAsync.value == null
                            ? prayerTimesAsync
                            : AsyncValue.data(cachedAsync.value!)),
                  ),
                  _buildAlertPill(
                    // use cached derivation for immediate pill text
                    countdownAsync,
                    currentAndNextPrayerAsync.hasValue
                        ? currentAndNextPrayerAsync
                        : (cachedDetail == null
                            ? currentAndNextPrayerAsync
                            : AsyncValue.data(cachedDetail)),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                  _buildPrayerCards(currentAndNextPrayerAsync,
                              prayerTimesAsync, use24h),
                          const SizedBox(height: 4),
                          _buildSuhoorIftaarSection(prayerTimesAsync, use24h),
                          const SizedBox(height: 4),
                          _buildLocationCard(),
                          const SizedBox(height: 4),
                          _buildPrayerTimesList(
                            // Prefer live data; fallback to cached for instant boot
                            prayerTimesAsync.hasValue
                                ? prayerTimesAsync
                                : (cachedAsync.value == null
                                    ? prayerTimesAsync
                                    : AsyncValue.data(cachedAsync.value!)),
                            use24h,
                          ),
                          const SizedBox(height: 14),
                          _buildAdditionalTimingsHorizontal(
                              prayerTimesAsync, use24h),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 110),
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

  Widget _buildHeader(
      AsyncValue<prayer_entities.PrayerTimes> prayerTimesAsync) {
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    prayerTimesAsync.when(
                      data: (p) {
                        final parts = p.hijriDate.split('-');
                        String hijriText;
                        if (parts.length == 3) {
                          final day = parts[0];
                          final monthNum = int.tryParse(parts[1]) ?? 1;
                          final year = parts[2];
                          const months = [
                            'Muharram',
                            'Safar',
                            'Rabi al-Awwal',
                            'Rabi al-Thani',
                            'Jumada al-Awwal',
                            'Jumada al-Thani',
                            'Rajab',
                            "Sha'ban",
                            'Ramadan',
                            'Shawwal',
                            'Dhu al-Qadah',
                            'Dhu al-Hijjah',
                          ];
                          final month = months[(monthNum - 1).clamp(0, 11)];
                          hijriText = '$month $day $year';
                        } else {
                          hijriText = p.hijriDate;
                        }
                        return Text(
                          hijriText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3E2A1F),
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                      loading: () => const SizedBox(height: 24, width: 120),
                      error: (_, __) => const Text(
                        '—',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3E2A1F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('EEEE, d MMM').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B5E56),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatBengaliDate(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B5E56),
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<String?>(
                future: _loadUserName(),
                builder: (context, snap) {
                  final name = (snap.data ?? '').trim();
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'As-salāmu ‘alaykum,',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B5E56),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name.isEmpty ? '—' : name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E2A1F),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertPill(AsyncValue<AlertBannerState> countdownAsync,
      AsyncValue<PrayerDetail> detailAsync) {
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
                child: countdownAsync.when(
                  data: (AlertBannerState alert) {
                    String prefix = '';
                    String value = '';
                    switch (alert.kind) {
                      case AlertKind.forbiddenSunrise:
                        prefix = '';
                        value = alert.message ?? 'Salah is forbidden during sunrise';
                        break;
                      case AlertKind.forbiddenZenith:
                        prefix = '';
                        value = alert.message ?? 'Salah is forbidden during solar noon (zenith)';
                        break;
                      case AlertKind.forbiddenSunset:
                        prefix = '';
                        value = alert.message ?? 'Salah is forbidden during sunset';
                        break;
                      case AlertKind.upcoming:
                        prefix = '${_capitalize(alert.prayerName ?? '—')} in ';
                        final dur = alert.remaining ?? Duration.zero;
                        final h = dur.inHours;
                        final m = dur.inMinutes.remainder(60);
                        final s = dur.inSeconds.remainder(60);
                        value = h > 0 ? '${h}h ${m}m ${s}s' : '${m}m ${s}s';
                        break;
                      case AlertKind.remaining:
                        prefix = '${_capitalize(alert.prayerName ?? '—')} remaining ';
                        final dur = alert.remaining ?? Duration.zero;
                        final h = dur.inHours;
                        final m = dur.inMinutes.remainder(60);
                        final s = dur.inSeconds.remainder(60);
                        value = h > 0 ? '${h}h ${m}m ${s}s' : '${m}m ${s}s';
                        break;
                    }
                    return Row(
                      children: [
                        if (prefix.isNotEmpty)
                          Text(prefix,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, color: _colors.headerPrimary)),
                        Flexible(
                          child: Text(
                            value,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _colors.headerPrimary),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => Text('—',
                      style: TextStyle(
                          fontSize: 14, color: _colors.headerPrimary)),
                  error: (_, __) => Text('—',
                      style: TextStyle(
                          fontSize: 14, color: _colors.headerPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCards(AsyncValue<PrayerDetail> currentAndNextPrayerAsync,
      AsyncValue<prayer_entities.PrayerTimes> prayerTimesAsync, bool use24h) {
    const double cardHeight = 156;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: cardHeight,
            child: currentAndNextPrayerAsync.when(
              data: (d) {
                final pt = d.prayerTimes as prayer_entities.PrayerTimes;
                final currentName = d.currentPrayer ?? '—';
                final currentTime =
                    _formatTime(_getPrayerTimeByName(pt, currentName), use24h);
                final endTime =
                    _formatTime(_getPrayerEndTime(pt, currentName), use24h);
                final azan = currentTime;
                final jamaat = _formatTime(
                    _getPrayerTimeByName(pt, currentName)
                        ?.add(const Duration(minutes: 15)),
                    use24h);
                return _buildPrayerCard(
                  title: 'Now time is',
                  prayerName: currentName,
                  time: currentTime ?? '—',
                  endTime: endTime,
                  azanTime: azan,
                  jamaatTime: jamaat,
                  isCurrent: true,
                  backgroundColor: const Color(0xFFFFE7D6),
                  silhouetteColor: const Color(0xFFCC6E3C),
                );
              },
              loading: () => _buildPrayerCard(
                title: 'Now time is',
                prayerName: '—',
                time: '—',
                isCurrent: true,
                backgroundColor: const Color(0xFFFFE7D6),
                silhouetteColor: const Color(0xFFCC6E3C),
              ),
              error: (_, __) => _buildPrayerCard(
                title: 'Now time is',
                prayerName: '—',
                time: '—',
                isCurrent: true,
                backgroundColor: const Color(0xFFFFE7D6),
                silhouetteColor: const Color(0xFFCC6E3C),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: cardHeight,
            child: currentAndNextPrayerAsync.when(
              data: (d) {
                final pt = d.prayerTimes as prayer_entities.PrayerTimes;
                final nextName = d.nextPrayer ?? '—';
                final nextTime =
                    _formatTime(_getPrayerTimeByName(pt, nextName), use24h);
                final azan = nextTime;
                final jamaat = _formatTime(
                    _getPrayerTimeByName(pt, nextName)
                        ?.add(const Duration(minutes: 15)),
                    use24h);
                return _buildPrayerCard(
                  title: 'Next prayer is',
                  prayerName: nextName,
                  time: nextTime ?? '—',
                  azanTime: azan,
                  jamaatTime: jamaat,
                  isCurrent: false,
                  backgroundColor: const Color(0xFFEAF4E6),
                  silhouetteColor: const Color.fromARGB(255, 118, 172, 122),
                );
              },
              loading: () => _buildPrayerCard(
                title: 'Next prayer is',
                prayerName: '—',
                time: '—',
                isCurrent: false,
                backgroundColor: const Color(0xFFEAF4E6),
                silhouetteColor: const Color.fromARGB(255, 118, 172, 122),
              ),
              error: (_, __) => _buildPrayerCard(
                title: 'Next prayer is',
                prayerName: '—',
                time: '—',
                isCurrent: false,
                backgroundColor: const Color(0xFFEAF4E6),
                silhouetteColor: const Color.fromARGB(255, 118, 172, 122),
              ),
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
          final bool hasSecondaryLines =
              (endTime != null) || (azanTime != null) || (jamaatTime != null);
          final int secondaryCount =
              (endTime != null ? 1 : 0) + (azanTime != null ? 1 : 0) + (jamaatTime != null ? 1 : 0);

          // Base scale relative to available height, then shrink more if many lines
          double scale = (h / 140).clamp(0.74, 1.0);
          final double extraShrink = secondaryCount >= 3
              ? 0.08
              : (secondaryCount == 2
                  ? 0.05
                  : (secondaryCount == 1 ? 0.02 : 0.0));
          scale = (scale - extraShrink).clamp(0.70, 1.0);

          final double nameSize = 18 * scale * (hasSecondaryLines ? 0.90 : 1.0);
          final double subtitleSize =
              (secondaryCount >= 3 ? 9.5 : secondaryCount == 2 ? 10.0 : 10.5) * scale;
          final double gapSmall = (secondaryCount >= 3 ? 1.0 : secondaryCount == 2 ? 1.5 : 2.0) * scale;
          final double gapTiny = (secondaryCount >= 3 ? 0.8 : 1.0) * scale;
          final double gapTop = (secondaryCount >= 3 ? 4.0 : secondaryCount == 2 ? 5.0 : 6.0) * scale;
          final double silhouetteSize = 84 * scale;

          return Container(
            padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 12 * scale),
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
                    ? [const Color(0xFFFFE3CF), const Color(0xFFFFE9D9)]
                    : [const Color(0xFFF4F8F2), const Color(0xFFEFF6EB)],
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
                          color: const Color(0xFF7F8C8D)),
                    ),
                    SizedBox(height: gapTop),
                    Text(
                      prayerName,
                      style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.w600,
                          color:
                              isCurrent ? _colors.accent : _colors.textPrimary),
                    ),
                    SizedBox(height: gapSmall),
                    _buildTimeWithMeridiem(
                      time,
                      mainSize: 32 * scale,
                      meridiemSize: 15 * scale,
                    ),
                    if (endTime != null) ...[
                      SizedBox(height: gapTiny),
                      _buildSecondaryInfo('End time - $endTime',
                          fontSize: subtitleSize),
                    ],
                    if (azanTime != null) ...[
                      SizedBox(height: (gapTiny - 1).clamp(0, 6).toDouble()),
                      _buildSecondaryInfo('Azan - $azanTime',
                          fontSize: subtitleSize),
                    ],
                    if (jamaatTime != null) ...[
                      SizedBox(height: (gapTiny - 1).clamp(0, 6).toDouble()),
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
                  fontSize: mainSize,
                  fontWeight: FontWeight.w700,
                  color: color)),
          if (meridiem.isNotEmpty)
            TextSpan(
                text: ' $meridiem',
                style: TextStyle(
                    fontSize: meridiemSize,
                    fontWeight: FontWeight.w600,
                    color: color)),
        ],
      ),
    );
  }

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
                  fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          if (meridiem.isNotEmpty)
            TextSpan(
                text: ' $meridiem',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildSecondaryInfo(String text, {double fontSize = 12}) {
    return Text(text,
        style: TextStyle(
            fontSize: fontSize,
            color: Theme.of(context).extension<AppColors>()?.textSecondary ??
                const Color(0xFF7F8C8D)));
  }

  Widget _buildSuhoorIftaarSection(
      AsyncValue<prayer_entities.PrayerTimes> prayerTimesAsync, bool use24h) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColors>()?.card ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Consumer(builder: (context, ref, _) {
                  // Fajr notifications toggle
                  final settings = ref.watch(athanSettingsNotifierProvider);
                  final enabled = settings?.isPrayerEnabled('fajr') ?? true;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      ref
                          .read(athanSettingsNotifierProvider.notifier)
                          .togglePrayer('fajr');
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: (enabled ? const Color(0xFFFF6B35) : Colors.grey)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                          enabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color:
                              enabled ? const Color(0xFFFF6B35) : Colors.grey,
                          size: 22),
                    ),
                  );
                }),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Suhoor',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50))),
                    prayerTimesAsync.when(
                      data: (p) => _buildSmallTimeWithMeridiem(
                          _formatTime(p.fajr.time, use24h)!),
                      loading: () => _buildSmallTimeWithMeridiem('—'),
                      error: (_, __) => _buildSmallTimeWithMeridiem('—'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 52,
            color: Theme.of(context).extension<AppColors>()?.divider ??
                const Color(0xFFD6CBB3),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Iftaar',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50))),
                    prayerTimesAsync.when(
                      data: (p) => _buildSmallTimeWithMeridiem(
                          _formatTime(p.maghrib.time, use24h)!),
                      loading: () => _buildSmallTimeWithMeridiem('—'),
                      error: (_, __) => _buildSmallTimeWithMeridiem('—'),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Consumer(builder: (context, ref, _) {
                  final settings = ref.watch(athanSettingsNotifierProvider);
                  final enabled = settings?.isPrayerEnabled('maghrib') ?? true;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      ref
                          .read(athanSettingsNotifierProvider.notifier)
                          .togglePrayer('maghrib');
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: (enabled
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF7F8C8D))
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                          enabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: enabled
                              ? const Color(0xFFFF6B35)
                              : const Color(0xFF7F8C8D),
                          size: 22),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF2C3E50), size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Consumer(builder: (context, ref, _) {
              final settingsAsync = ref.watch(prayerSettingsProvider);
              final ptAsync = ref.watch(currentPrayerTimesProvider);
              final isOffline = ptAsync.maybeWhen(
                data: (p) =>
                    (p.metadata['source']?.toString().toLowerCase() ?? '')
                        .contains('offline'),
                orElse: () => false,
              );

              return Row(
                children: [
                  Expanded(
                    child: settingsAsync.when(
                      data: (s) => Text(
                        '${s.calculationMethod} method · timings from AlAdhan',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF7F8C8D)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      loading: () => const Text('timings from AlAdhan',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF7F8C8D))),
                      error: (_, __) => const Text('timings from AlAdhan',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF7F8C8D))),
                    ),
                  ),
                  if (isOffline) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB00020).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Offline',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFFB00020)),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(
      AsyncValue<prayer_entities.PrayerTimes> prayerTimesAsync, bool use24h) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColors>()?.card ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: prayerTimesAsync.when(
        data: (prayerTimes) => _buildPrayerTimesListView(prayerTimes, use24h),
        loading: () => const Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFFFF6B35)))),
        error: (error, stack) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildPrayerTimesListView(
      prayer_entities.PrayerTimes prayerTimes, bool use24h) {
    final String? currentPrayerName =
        prayerTimes.currentPrayer?.name.capitalize();
    final double rowVerticalPadding = 6;
    final prayers = [
      {
        'name': 'Fajr',
        'time': _formatTime(prayerTimes.fajr.time, use24h)!,
        'icon': Icons.nightlight_round
      },
      {
        'name': 'Dhuhr',
        'time': _formatTime(prayerTimes.dhuhr.time, use24h)!,
        'icon': Icons.wb_sunny
      },
      {
        'name': 'Asr',
        'time': _formatTime(prayerTimes.asr.time, use24h)!,
        'icon': Icons.wb_sunny_outlined
      },
      {
        'name': 'Maghrib',
        'time': _formatTime(prayerTimes.maghrib.time, use24h)!,
        'icon': Icons.wb_sunny_outlined
      },
      {
        'name': 'Isha',
        'time': _formatTime(prayerTimes.isha.time, use24h)!,
        'icon': Icons.nightlight_round
      },
    ];

    return Column(
      children: prayers.asMap().entries.map((entry) {
        final index = entry.key;
        final prayer = entry.value;
        final isCurrentPrayer =
            currentPrayerName != null && prayer['name'] == currentPrayerName;

        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: rowVerticalPadding, horizontal: 16),
              child: Row(
                children: [
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
                    child: Icon(prayer['icon'] as IconData,
                        color: isCurrentPrayer
                            ? const Color(0xFFFF6B35)
                            : const Color(0xFF7F8C8D),
                        size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      prayer['name'] as String,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCurrentPrayer
                              ? const Color(0xFFFF6B35)
                              : const Color(0xFF2C3E50)),
                    ),
                  ),
                  _buildSmallTimeWithMeridiem(prayer['time'] as String,
                      color: isCurrentPrayer
                          ? const Color(0xFFFF6B35)
                          : const Color(0xFF2C3E50)),
                  const SizedBox(width: 12),
                  Consumer(builder: (context, ref, _) {
                    final settings = ref.watch(athanSettingsNotifierProvider);
                    final prayerName = (prayer['name'] as String).toLowerCase();
                    final enabled =
                        settings?.isPrayerEnabled(prayerName) ?? true;
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        ref
                            .read(athanSettingsNotifierProvider.notifier)
                            .togglePrayer(prayerName);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: (enabled
                                    ? const Color(0xFFFF6B35)
                                    : Colors.grey)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(
                            enabled
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color:
                                enabled ? const Color(0xFFFF6B35) : Colors.grey,
                            size: 16),
                      ),
                    );
                  }),
                ],
              ),
            ),
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
      AsyncValue<prayer_entities.PrayerTimes> prayerTimesAsync, bool use24h) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColors>()?.card ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: prayerTimesAsync.when(
              data: (p) => _buildTimingColumn('Sunrise',
                  _formatTime(p.sunrise.time, use24h)!, Icons.wb_sunny),
              loading: () => _buildTimingColumn('Sunrise', '—', Icons.wb_sunny),
              error: (_, __) =>
                  _buildTimingColumn('Sunrise', '—', Icons.wb_sunny),
            ),
          ),
          Container(
              width: 2,
              height: 48,
              color: Theme.of(context).extension<AppColors>()?.divider ??
                  const Color(0xFFD6CBB3)),
          Expanded(
            child: prayerTimesAsync.when(
              data: (p) => _buildTimingColumn('Mid Day',
                  _formatTime(p.dhuhr.time, use24h)!, Icons.access_time),
              loading: () =>
                  _buildTimingColumn('Mid Day', '—', Icons.access_time),
              error: (_, __) =>
                  _buildTimingColumn('Mid Day', '—', Icons.access_time),
            ),
          ),
          Container(
              width: 2,
              height: 48,
              color: Theme.of(context).extension<AppColors>()?.divider ??
                  const Color(0xFFD6CBB3)),
          Expanded(
            child: prayerTimesAsync.when(
              data: (p) => _buildTimingColumn(
                  'Sunset',
                  _formatTime(p.maghrib.time, use24h)!,
                  Icons.wb_sunny_outlined),
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
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50))),
            const SizedBox(height: 2),
            _buildSmallTimeWithMeridiem(time),
          ],
        ),
      ],
    );
  }

  String? _formatTime(DateTime? time, bool use24h) {
    if (time == null) return null;
    if (use24h) {
      return DateFormat('HH:mm').format(time);
    }
    return DateFormat('h:mm a').format(time).toLowerCase();
  }

  // Simple Bengali date formatter using localized month/day names
  String _formatBengaliDate(DateTime date) {
    const bengaliMonths = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর',
    ];
    const bengaliWeekdays = [
      'সোমবার',
      'মঙ্গলবার',
      'বুধবার',
      'বৃহস্পতিবার',
      'শুক্রবার',
      'শনিবার',
      'রবিবার',
    ];
    final weekday = bengaliWeekdays[(date.weekday % 7)];
    final month = bengaliMonths[date.month - 1];
    final day = date.day.toString();
    final year = (date.year).toString();
    return '$weekday, $day $month $year';
  }

  Future<String?> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_name');
    } catch (_) {
      return null;
    }
  }

  DateTime? _getPrayerTimeByName(
      prayer_entities.PrayerTimes pt, String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return pt.fajr.time;
      case 'sunrise':
        return pt.sunrise.time;
      case 'dhuhr':
        return pt.dhuhr.time;
      case 'asr':
        return pt.asr.time;
      case 'maghrib':
        return pt.maghrib.time;
      case 'isha':
        return pt.isha.time;
      case 'midnight':
        return pt.midnight.time;
    }
    return null;
  }

  DateTime? _getPrayerEndTime(
      prayer_entities.PrayerTimes pt, String currentName) {
    switch (currentName.toLowerCase()) {
      case 'fajr':
        return pt.sunrise.time;
      case 'dhuhr':
        return pt.asr.time;
      case 'asr':
        return pt.maghrib.time;
      case 'maghrib':
        return pt.isha.time;
      case 'isha':
        // Isha continues until Fajr
        return pt.fajr.time;
    }
    return null;
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1).toLowerCase();
}

String _capitalize(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}
