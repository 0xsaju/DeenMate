import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/islamic_theme.dart';
import '../../../../core/state/prayer_settings_state.dart';
import '../../../prayer_times/domain/entities/calculation_method.dart';
import '../widgets/islamic_decorative_elements.dart';
import '../widgets/islamic_gradient_background.dart';

/// Calculation method selection screen for DeenMate onboarding
class CalculationMethodScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const CalculationMethodScreen({super.key, this.onNext, this.onPrevious});

  @override
  State<CalculationMethodScreen> createState() => _CalculationMethodScreenState();
}

class _CalculationMethodScreenState extends State<CalculationMethodScreen> {
  CalculationMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = CalculationMethod.mwl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicGradientBackground(
        primaryColor: const Color(0xFFF0F4FF),
        secondaryColor: const Color(0xFFFFFFFF),
        child: SafeArea(
          child: Column(
            children: [
              // Status bar area
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.05),
                ),
              ),
              
              // Progress indicator
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: OnboardingProgressIndicator(
                  currentStep: 4,
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
                          color: const Color(0xFF42A5F5).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF42A5F5).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '🕌',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Title
                      Text(
                        'Select your Salah Time Server',
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
                        'Choose a reliable source for accurate',
                        style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      Text(
                        'prayer times calculation',
                        style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Calculation methods
                      Expanded(
                        child: ListView(
                          children: [
                            // Show all calculation methods
                            ...CalculationMethod.values.map(_buildMethodOption),
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

  Widget _buildMethodOption(CalculationMethod method) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFE3F2FD).withOpacity(0.8)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF1565C0)
                : const Color(0xFFE0E0E0),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF1565C0).withOpacity(0.1)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getMethodIcon(method.name),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Method info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.displayName,
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
                        method.name.toUpperCase(),
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
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF1565C0)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF1565C0)
                          : const Color(0xFFE0E0E0),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              _getMethodDescription(method),
              style: IslamicTheme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: const Color(0xFF666666),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Region
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Method',
                style: IslamicTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: const Color(0xFF1565C0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMethodIcon(String methodName) {
    switch (methodName.toLowerCase()) {
      case 'mwl':
        return '🌍';
      case 'isna':
        return '🇺🇸';
      case 'egypt':
        return '🇪🇬';
      case 'makkah':
        return '🕋';
      case 'karachi':
        return '🇵🇰';
      case 'tehran':
        return '🇮🇷';
      case 'jafari':
        return '🕌';
      default:
        return '🕌';
    }
  }

  String _getMethodDescription(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.mwl:
        return 'Muslim World League - Standard method used worldwide';
      case CalculationMethod.isna:
        return 'Islamic Society of North America - Popular in North America';
      case CalculationMethod.egypt:
        return 'Egyptian General Authority - Used in Egypt and nearby regions';
      case CalculationMethod.makkah:
        return 'Umm Al-Qura University - Official method of Saudi Arabia';
      case CalculationMethod.karachi:
        return 'University of Islamic Sciences - Popular in Pakistan';
      case CalculationMethod.tehran:
        return 'Institute of Geophysics - Used in Iran and Shia communities';
      case CalculationMethod.jafari:
        return 'Shia Ithna Ashari - Used by Shia Muslims worldwide';
    }
  }

  Widget _buildContinueButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToNext(context),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
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

  void _navigateToNext(BuildContext context) async {
    // Save calculation method preference
    if (_selectedMethod != null) {
      await PrayerSettingsState.instance.setCalculationMethod(_selectedMethod!.name.toUpperCase());
      print('Saved calculation method: ${_selectedMethod!.name.toUpperCase()}');
    }
    
    // Navigate to next onboarding screen
    widget.onNext?.call();
  }
}
