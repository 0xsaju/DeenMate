import 'package:flutter/material.dart';
import '../../../home/presentation/screens/home_screen.dart';

/// Backwards-compatible wrapper so legacy references still work.
class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) => const HomeScreen();
}
