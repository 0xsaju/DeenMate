import 'package:flutter/material.dart';

import '../../../../core/theme/islamic_theme.dart';
import '../../../prayer_times/domain/entities/prayer_calculation_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/islamic_decorative_elements.dart';
import '../widgets/islamic_gradient_background.dart';

/// Madhhab selection screen for DeenMate onboarding
class MadhhabScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const MadhhabScreen({super.key, this.onNext, this.onPrevious});

  @override
  State<MadhhabScreen> createState() => _MadhhabScreenState();
}

class _MadhhabScreenState extends State<MadhhabScreen> {
  Madhab _selectedMadhhab = Madhab.hanafi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicGradientBackground(
        primaryColor: const Color(0xFFF3E5F5),
        secondaryColor: const Color(0xFFFFFFFF),
        child: SafeArea(
          child: Column(
            children: [
              // Status bar area
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF7B1FA2).withOpacity(0.05),
                ),
              ),

              // Progress indicator
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: OnboardingProgressIndicator(
                  currentStep: 5,
                  totalSteps: 8,
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Header icon
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBA68C8).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFBA68C8).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '📚',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Title
                      Text(
                        'Select Your Mazhab',
                        style: IslamicTheme.textTheme.headlineSmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E2E2E),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Choose your school of Islamic',
                        style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      Text(
                        'jurisprudence for prayer calculations',
                        style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Madhhab options (two choices)
                      Expanded(
                        child: ListView(
                          children: [
                            // First: Shafi, Maliki, Hanbali group
                            _buildMadhhabOption(Madhab.shafi),
                            const SizedBox(height: 16),
                            // Second: Hanafi
                            _buildMadhhabOption(Madhab.hanafi),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Continue button
                      _buildContinueButton(context),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMadhhabOption(Madhab madhhab) {
    final isSelected = _selectedMadhhab == madhhab;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMadhhab = madhhab;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE1BEE7).withOpacity(0.8)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF7B1FA2) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
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
            Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF7B1FA2).withOpacity(0.1)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getMadhhabIcon(madhhab),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Madhhab info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMadhhabTitle(madhhab),
                        style: IslamicTheme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF1565C0)
                              : const Color(0xFF2E2E2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMadhhabDetails(madhhab),
                        style: IslamicTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF7B1FA2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF7B1FA2)
                          : const Color(0xFFE0E0E0),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              _getMadhhabTitle(madhhab),
              style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
            ),

            const SizedBox(height: 8),

            // Additional info based on madhhab
            Text(
              _getMadhhabDetails(madhhab),
              style: IslamicTheme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: const Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMadhhabIcon(Madhab madhhab) {
    return madhhab == Madhab.hanafi ? '🕌' : '📖';
  }

  String _getMadhhabDetails(Madhab madhhab) {
    return madhhab == Madhab.hanafi
        ? 'Most widely followed mazhab'
        : 'Other major schools of thought';
  }

  String _getMadhhabTitle(Madhab madhhab) {
    return madhhab == Madhab.hanafi ? 'Hanafi' : "Shafi'i, Maliki, Hanbali";
  }

  Widget _buildContinueButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToNext(context),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _navigateToNext(BuildContext context) {
    _saveMadhhab().then((_) => widget.onNext?.call());
  }

  Future<void> _saveMadhhab() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('madhhab', _selectedMadhhab.name);
    } catch (_) {}
  }
}
