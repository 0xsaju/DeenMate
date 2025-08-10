import 'package:flutter/material.dart';

import '../../../../core/theme/islamic_theme.dart';
import '../../domain/entities/user_preferences.dart';
import '../widgets/islamic_decorative_elements.dart';
import '../widgets/islamic_gradient_background.dart';

/// Language selection screen for DeenMate onboarding
class LanguageScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const LanguageScreen({super.key, this.onNext, this.onPrevious});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  AppLanguage selectedLanguage = AppLanguage.english;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicGradientBackground(
        primaryColor: const Color(0xFFF8F9FA),
        secondaryColor: const Color(0xFFFFFFFF),
        child: SafeArea(
          child: Column(
            children: [
              // Status bar area
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.05),
                ),
              ),
              
              // Progress indicator
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: OnboardingProgressIndicator(
                  currentStep: 2,
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
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '🌍',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Title
                      Text(
                        'Choose Your Language',
                        style: IslamicTheme.textTheme.headlineSmall?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E2E2E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'Select your preferred language for the app',
                        style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Language options
                      Expanded(
                        child: ListView(
                          children: [
                            _buildLanguageOption(AppLanguage.english),
                            const SizedBox(height: 16),
                            _buildLanguageOption(AppLanguage.bengali),
                            const SizedBox(height: 16),
                            _buildLanguageOption(AppLanguage.urdu),
                            const SizedBox(height: 16),
                            _buildLanguageOption(AppLanguage.arabic),
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

  Widget _buildLanguageOption(AppLanguage language) {
    final isSelected = selectedLanguage == language;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = language;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFE8F5E8).withOpacity(0.8)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF4CAF50)
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
            // Flag emoji
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _getFlagEmoji(language),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Language info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.nativeName,
                    style: IslamicTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language.englishName,
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
                    ? const Color(0xFF4CAF50)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF4CAF50)
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

  String _getFlagEmoji(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return '🇺🇸';
      case AppLanguage.bengali:
        return '🇧🇩';
      case AppLanguage.urdu:
        return '🇵🇰';
      case AppLanguage.arabic:
        return '🇸🇦';
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
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
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
    // TODO: Save language preference
    // await _preferencesService.updatePreferences(
    //   language: selectedLanguage.code,
    // );
    
    // Navigate to next onboarding screen
    widget.onNext?.call();
  }
}
