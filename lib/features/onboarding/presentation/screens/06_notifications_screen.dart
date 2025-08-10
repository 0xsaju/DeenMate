import 'package:flutter/material.dart';

import '../../../../core/theme/islamic_theme.dart';
import '../widgets/islamic_decorative_elements.dart';
import '../widgets/islamic_gradient_background.dart';

/// Notifications settings screen for DeenMate onboarding
class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const NotificationsScreen({super.key, this.onNext, this.onPrevious});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _enableNotifications = true;
  bool _enableAthan = true;
  bool _enableReminders = true;
  final List<String> _selectedPrayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicGradientBackground(
        primaryColor: const Color(0xFFE8F5E8),
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
                  currentStep: 6,
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
                            '🔔',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Title
                      Text(
                        'Enable Azan & Salah Notifications?',
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
                        'Get reminded for each prayer time',
                        style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      Text(
                        'with beautiful Azan calls',
                        style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Notification options
                      Expanded(
                        child: ListView(
                          children: [
                            _buildNotificationOption(
                              title: 'Enable',
                              subtitle: 'Receive prayer time notifications',
                              icon: '🕌',
                              isSelected: _enableNotifications,
                              onTap: () {
                                setState(() {
                                  _enableNotifications = true;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildNotificationOption(
                              title: 'Disable',
                              subtitle: 'Use silent mode only',
                              icon: '🔕',
                              isSelected: !_enableNotifications,
                              onTap: () {
                                setState(() {
                                  _enableNotifications = false;
                                });
                              },
                            ),
                            
                            if (_enableNotifications) ...[
                              const SizedBox(height: 24),
                              _buildPrayerSelectionSection(),
                            ],
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

  Widget _buildNotificationOption({
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            // Icon
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
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    subtitle,
                    style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            
            // Toggle switch
            Container(
              width: 50,
              height: 26,
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: isSelected ? 26 : 2,
                    top: 2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerSelectionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC8E6C9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.music_note,
                    color: Color(0xFF2E7D32),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Prayers for Notifications',
                style: IslamicTheme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._selectedPrayers.map(_buildPrayerCheckbox),
        ],
      ),
    );
  }

  Widget _buildPrayerCheckbox(String prayer) {
    final isEnabled = _selectedPrayers.contains(prayer);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: isEnabled,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedPrayers.add(prayer);
                } else {
                  _selectedPrayers.remove(prayer);
                }
              });
            },
            activeColor: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer.replaceAll('_', ' ').toUpperCase(),
                  style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                Text(
                  prayer.replaceAll('_', ' ').toUpperCase(),
                  style: IslamicTheme.arabicMedium.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    // TODO: Save notification preferences
    // await _preferencesService.updatePreferences(
    //   notificationsEnabled: _notificationsEnabled,
    //   enabledPrayers: _enabledPrayers,
    // );
    
    // Navigate to next onboarding screen
    widget.onNext?.call();
  }
}
