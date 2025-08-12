import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/state/prayer_settings_state.dart';
import '../../data/datasources/aladhan_api.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/prayer_calculation_settings.dart';

class DirectPrayerWidget extends ConsumerStatefulWidget {
  const DirectPrayerWidget({super.key});

  @override
  ConsumerState<DirectPrayerWidget> createState() => _DirectPrayerWidgetState();
}

class _DirectPrayerWidgetState extends ConsumerState<DirectPrayerWidget> {
  String? currentPrayer;
  String? nextPrayer;
  String? remainingTime;
  String? calculationMethod;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPrayerData();
  }

  Future<void> _loadPrayerData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load calculation method from global state
      await PrayerSettingsState.instance.loadSettings();
      final method = PrayerSettingsState.instance.calculationMethod;
      
      setState(() {
        calculationMethod = method;
      });

      // Create API instance
      final api = AladhanApi(null); // We'll make direct HTTP calls
      
      // Mock location for testing (you can replace with actual location)
      final location = Location(
        latitude: 37.4219983,
        longitude: -122.084,
        country: 'United States',
        city: 'Mountain View',
        region: 'California',
        timezone: 'America/Los_Angeles',
      );

      // Create settings
      final settings = PrayerCalculationSettings(
        calculationMethod: method,
        madhab: Madhab.shafi,
      );

      print('DirectPrayerWidget: Calling API with method: $method');
      
      // Call API directly
      final result = await api.getPrayerTimes(
        date: DateTime.now(),
        location: location,
        settings: settings,
      );

      if (result.isRight()) {
        final prayerTimes = result.getOrElse(() => throw Exception('No data'));
        
        // Calculate current and next prayer
        final now = DateTime.now();
        final prayers = [
          {'name': 'Fajr', 'time': prayerTimes.fajr.time},
          {'name': 'Sunrise', 'time': prayerTimes.sunrise.time},
          {'name': 'Dhuhr', 'time': prayerTimes.dhuhr.time},
          {'name': 'Asr', 'time': prayerTimes.asr.time},
          {'name': 'Maghrib', 'time': prayerTimes.maghrib.time},
          {'name': 'Isha', 'time': prayerTimes.isha.time},
        ];

        // Find current and next prayer
        String? current;
        String? next;
        Duration? remaining;

        for (int i = 0; i < prayers.length; i++) {
          final prayer = prayers[i];
          
          if (now.isBefore(prayer['time'] as DateTime)) {
            // This is the next prayer
            next = prayer['name'] as String;
            
            // Find the current prayer (the one that just passed)
            if (i > 0) {
              current = prayers[i - 1]['name'] as String;
            }
            
            // Calculate remaining time
            remaining = (prayer['time'] as DateTime).difference(now);
            break;
          }
        }

        // If no next prayer found, we're after Isha
        if (next == null) {
          current = 'Isha';
          // Next prayer would be tomorrow's Fajr
        }

        setState(() {
          currentPrayer = current;
          nextPrayer = next;
          remainingTime = remaining != null 
              ? '${remaining.inHours}h ${remaining.inMinutes % 60}m'
              : null;
          isLoading = false;
        });

        print('DirectPrayerWidget: Current: $current, Next: $next, Remaining: $remainingTime');
      } else {
        setState(() {
          error = 'Failed to load prayer times';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
      print('DirectPrayerWidget: Error: $e');
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Direct Prayer Data',
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Method: ${calculationMethod ?? 'Loading...'}',
                  style: GoogleFonts.notoSans(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else if (error != null)
              Text(
                error!,
                style: GoogleFonts.notoSans(
                  color: Colors.red[100],
                  fontSize: 14,
                ),
              )
            else ...[
              // Current Prayer
              Text(
                'Current: ${currentPrayer ?? 'None'}',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Next Prayer
              Text(
                'Next: ${nextPrayer ?? 'None'}',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Remaining Time
              if (remainingTime != null)
                Text(
                  'Remaining: $remainingTime',
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
            
            const SizedBox(height: 16),
            
            // Refresh Button
            ElevatedButton(
              onPressed: _loadPrayerData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1565C0),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
