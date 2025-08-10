import 'package:flutter/material.dart';

import '../../../../core/theme/islamic_theme.dart';
import '../../domain/entities/user_preferences.dart';
import '../widgets/islamic_decorative_elements.dart';
import '../widgets/islamic_gradient_background.dart';

/// Theme selection screen for DeenMate onboarding
class ThemeScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const ThemeScreen({super.key, this.onNext, this.onPrevious});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  AppTheme _selectedTheme = AppTheme.system;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicGradientBackground(
        primaryColor: const Color(0xFFF5F5F5),
        secondaryColor: const Color(0xFFFFFFFF),
        child: SafeArea(
          child: Column(
            children: [
              // Status bar area
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF424242).withOpacity(0.05),
                ),
              ),
              
              // Progress indicator
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: OnboardingProgressIndicator(
                  currentStep: 7,
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
                          color: const Color(0xFF757575).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF757575).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '🎨',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Title
                      Text(
                        'Choose Your Theme',
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
                        'Select your preferred app appearance',
                        style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Theme options
                      Expanded(
                        child: ListView(
                          children: [
                            _buildThemeOption(AppTheme.light),
                            const SizedBox(height: 16),
                            _buildThemeOption(AppTheme.dark),
                            const SizedBox(height: 16),
                            _buildThemeOption(AppTheme.system),
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

  Widget _buildThemeOption(AppTheme theme) {
    final isSelected = _selectedTheme == theme;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = theme;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFE0E0E0).withOpacity(0.8)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF424242)
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
        child: Row(
          children: [
            // Theme preview
            Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: _getThemePreviewColor(theme),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                ),
              ),
              child: Center(
                child: Icon(
                  _getThemeIcon(theme),
                  color: _getThemeIconColor(theme),
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Theme info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.displayName,
                    style: IslamicTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? const Color(0xFF424242)
                          : const Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getThemeDescription(theme),
                    style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
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
                    ? const Color(0xFF424242)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF424242)
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
      ),
    );
  }

  Color _getThemePreviewColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return const Color(0xFFF5F5F5);
      case AppTheme.dark:
        return const Color(0xFF424242);
      case AppTheme.system:
        return const Color(0xFFE0E0E0);
    }
  }

  IconData _getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Icons.wb_sunny;
      case AppTheme.dark:
        return Icons.nightlight_round;
      case AppTheme.system:
        return Icons.settings_system_daydream;
    }
  }

  Color _getThemeIconColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return const Color(0xFFFFA000);
      case AppTheme.dark:
        return const Color(0xFFE0E0E0);
      case AppTheme.system:
        return const Color(0xFF757575);
    }
  }

  String _getThemeDescription(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Clean and bright interface';
      case AppTheme.dark:
        return 'Easy on the eyes in low light';
      case AppTheme.system:
        return 'Follows your device settings';
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
            colors: [Color(0xFF424242), Color(0xFF757575)],
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
    // TODO: Save theme preference
    // await _preferencesService.updatePreferences(
    //   theme: _selectedTheme.value,
    // );
    
    // Navigate to next onboarding screen
    widget.onNext?.call();
  }
}
