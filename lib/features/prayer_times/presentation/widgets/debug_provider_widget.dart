import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/state/prayer_settings_state.dart';
import '../providers/prayer_times_providers.dart';

class DebugProviderWidget extends ConsumerStatefulWidget {
  const DebugProviderWidget({super.key});

  @override
  ConsumerState<DebugProviderWidget> createState() => _DebugProviderWidgetState();
}

class _DebugProviderWidgetState extends ConsumerState<DebugProviderWidget> {
  String debugInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    try {
      await PrayerSettingsState.instance.loadSettings();
      
      final settings = await ref.read(prayerSettingsProvider.future);
      final currentPrayer = await ref.read(currentAndNextPrayerProvider.future);
      final prayerTimes = await ref.read(currentPrayerTimesProvider.future);
      
      setState(() {
        debugInfo = '''
=== DEBUG INFO ===
Global State Method: ${PrayerSettingsState.instance.calculationMethod}
Settings Provider Method: ${settings.calculationMethod}
Current Prayer: ${currentPrayer.currentPrayer}
Next Prayer: ${currentPrayer.nextPrayer}
Time Until Next: ${currentPrayer.timeUntilNextPrayer}
Prayer Times:
- Fajr: ${prayerTimes.fajr.time}
- Dhuhr: ${prayerTimes.dhuhr.time}
- Asr: ${prayerTimes.asr.time}
- Maghrib: ${prayerTimes.maghrib.time}
- Isha: ${prayerTimes.isha.time}
Current Time: ${DateTime.now()}
================
        ''';
      });
    } catch (e) {
      setState(() {
        debugInfo = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD32F2F),
              Color(0xFFF44336),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DEBUG INFO',
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: _loadDebugInfo,
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
              ],
            ),
            const SizedBox(height: 12),
            Text(
              debugInfo,
              style: GoogleFonts.monospace(
                color: Colors.white,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
