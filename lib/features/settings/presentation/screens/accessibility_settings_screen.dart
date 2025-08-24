import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/accessibility/accessibility_service.dart';
import '../../../../core/theme/theme_helper.dart';

class AccessibilitySettingsScreen extends ConsumerStatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  ConsumerState<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends ConsumerState<AccessibilitySettingsScreen> {
  
  @override
  void initState() {
    super.initState();
    // Initialize accessibility service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accessibilityServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityService = ref.watch(accessibilityServiceProvider);
    final preferences = accessibilityService.preferences;
    final featuresAsync = ref.watch(accessibilityFeaturesProvider);

    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.getBackgroundColor(context),
        elevation: 0,
        title: accessibilityService.enhanceWidget(
          child: Text(
            'Accessibility Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          semanticLabel: 'Accessibility Settings',
          isHeader: true,
        ),
        leading: accessibilityService.enhanceWidget(
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: ThemeHelper.getTextPrimaryColor(context)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          semanticLabel: 'Go back',
          hint: 'Returns to previous screen',
          isButton: true,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction card
            _buildIntroductionCard(accessibilityService),
            
            const SizedBox(height: 24),
            
            // Visual accessibility section
            _buildVisualAccessibilitySection(accessibilityService, preferences),
            
            const SizedBox(height: 24),
            
            // Audio accessibility section
            _buildAudioAccessibilitySection(accessibilityService, preferences),
            
            const SizedBox(height: 24),
            
            // Navigation accessibility section
            _buildNavigationAccessibilitySection(accessibilityService, preferences),
            
            const SizedBox(height: 24),
            
            // System features section
            _buildSystemFeaturesSection(featuresAsync),
            
            const SizedBox(height: 24),
            
            // Tutorial and help section
            _buildTutorialSection(accessibilityService),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroductionCard(AccessibilityService service) {
    return service.enhanceWidget(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
              ThemeHelper.getPrimaryColor(context).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.accessibility,
                    color: ThemeHelper.getPrimaryColor(context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accessibility',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.getTextPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Make DeenMate work better for you',
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeHelper.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'DeenMate is designed to be accessible for all users. Customize these settings to improve your experience with the app.',
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getTextSecondaryColor(context),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      semanticLabel: 'Accessibility introduction. DeenMate is designed to be accessible for all users. Customize these settings to improve your experience with the app.',
    );
  }

  Widget _buildVisualAccessibilitySection(AccessibilityService service, AccessibilityPreferences preferences) {
    return _buildSection(
      service: service,
      title: 'Visual Accessibility',
      icon: Icons.visibility,
      children: [
        // High contrast toggle
        _buildToggleTile(
          service: service,
          title: 'High Contrast',
          subtitle: 'Increase color contrast for better visibility',
          value: preferences.highContrast,
          onChanged: (value) => service.enableHighContrast(value),
        ),
        
        const SizedBox(height: 16),
        
        // Font size slider
        _buildSliderTile(
          service: service,
          title: 'Font Size',
          subtitle: 'Adjust text size throughout the app',
          value: preferences.fontScale,
          min: 0.8,
          max: 3.0,
          divisions: 22,
          onChanged: (value) => service.setFontScale(value),
          valueFormatter: (value) => '${(value * 100).round()}%',
        ),
        
        const SizedBox(height: 16),
        
        // Reduce motion toggle
        _buildToggleTile(
          service: service,
          title: 'Reduce Motion',
          subtitle: 'Minimize animations and transitions',
          value: preferences.reduceMotion,
          onChanged: (value) => service.enableReducedMotion(value),
        ),
        
        const SizedBox(height: 16),
        
        // Simplified interface toggle
        _buildToggleTile(
          service: service,
          title: 'Simplified Interface',
          subtitle: 'Show fewer elements on screen at once',
          value: preferences.simplifiedInterface,
          onChanged: (value) async {
            final newPrefs = preferences.copyWith(simplifiedInterface: value);
            await service.updatePreferences(newPrefs);
          },
        ),
      ],
    );
  }

  Widget _buildAudioAccessibilitySection(AccessibilityService service, AccessibilityPreferences preferences) {
    return _buildSection(
      service: service,
      title: 'Audio Accessibility',
      icon: Icons.volume_up,
      children: [
        // Voice announcements toggle
        _buildToggleTile(
          service: service,
          title: 'Voice Announcements',
          subtitle: 'Announce important information using text-to-speech',
          value: preferences.enableVoiceAnnouncements,
          onChanged: (value) => service.enableVoiceAnnouncements(value),
        ),
        
        const SizedBox(height: 16),
        
        // Screen reader language
        _buildDropdownTile(
          service: service,
          title: 'Screen Reader Language',
          subtitle: 'Language for screen reader and voice announcements',
          value: preferences.screenReaderLanguage,
          items: const [
            {'value': 'en', 'label': 'English'},
            {'value': 'ar', 'label': 'Arabic'},
            {'value': 'ur', 'label': 'Urdu'},
            {'value': 'bn', 'label': 'Bengali'},
            {'value': 'tr', 'label': 'Turkish'},
            {'value': 'fr', 'label': 'French'},
            {'value': 'es', 'label': 'Spanish'},
          ],
          onChanged: (value) => service.setScreenReaderLanguage(value),
        ),
        
        const SizedBox(height: 16),
        
        // Extended timeouts toggle
        _buildToggleTile(
          service: service,
          title: 'Extended Timeouts',
          subtitle: 'Give more time for interactions and responses',
          value: preferences.extendedTimeouts,
          onChanged: (value) async {
            final newPrefs = preferences.copyWith(extendedTimeouts: value);
            await service.updatePreferences(newPrefs);
          },
        ),
      ],
    );
  }

  Widget _buildNavigationAccessibilitySection(AccessibilityService service, AccessibilityPreferences preferences) {
    return _buildSection(
      service: service,
      title: 'Navigation Accessibility',
      icon: Icons.touch_app,
      children: [
        // Tap to navigate toggle
        _buildToggleTile(
          service: service,
          title: 'Tap to Navigate',
          subtitle: 'Enable single tap navigation instead of double tap',
          value: preferences.tapToNavigate,
          onChanged: (value) async {
            final newPrefs = preferences.copyWith(tapToNavigate: value);
            await service.updatePreferences(newPrefs);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Navigation hints
        _buildInfoTile(
          service: service,
          title: 'Navigation Hints',
          subtitle: 'Learn how to navigate different parts of the app',
          onTap: () => _showNavigationHints(service),
        ),
      ],
    );
  }

  Widget _buildSystemFeaturesSection(AsyncValue<AccessibilityFeatures> featuresAsync) {
    return featuresAsync.when(
      data: (features) => _buildSection(
        service: ref.read(accessibilityServiceProvider),
        title: 'System Features',
        icon: Icons.settings_accessibility,
        children: [
          _buildFeatureIndicator('Screen Reader', features.accessibleNavigation),
          _buildFeatureIndicator('Bold Text', features.boldText),
          _buildFeatureIndicator('High Contrast', features.highContrast),
          _buildFeatureIndicator('Reduce Motion', features.reduceMotion),
          _buildFeatureIndicator('Invert Colors', features.invertColors),
          if (features.textScaleFactor != 1.0)
            _buildFeatureIndicator(
              'System Text Scale', 
              true, 
              subtitle: '${(features.textScaleFactor * 100).round()}%',
            ),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTutorialSection(AccessibilityService service) {
    return _buildSection(
      service: service,
      title: 'Help & Tutorial',
      icon: Icons.help_outline,
      children: [
        _buildActionTile(
          service: service,
          title: 'Accessibility Tutorial',
          subtitle: 'Learn how to use DeenMate with assistive technologies',
          icon: Icons.school,
          onTap: () => _showAccessibilityTutorial(service),
        ),
        
        const SizedBox(height: 16),
        
        _buildActionTile(
          service: service,
          title: 'Test Voice Announcements',
          subtitle: 'Test text-to-speech functionality',
          icon: Icons.record_voice_over,
          onTap: () => _testVoiceAnnouncements(service),
        ),
        
        const SizedBox(height: 16),
        
        _buildActionTile(
          service: service,
          title: 'Reset to Defaults',
          subtitle: 'Reset all accessibility settings to default values',
          icon: Icons.restore,
          onTap: () => _resetToDefaults(service),
        ),
      ],
    );
  }

  Widget _buildSection({
    required AccessibilityService service,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return service.enhanceWidget(
      child: Container(
        decoration: BoxDecoration(
          color: ThemeHelper.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeHelper.getDividerColor(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: ThemeHelper.getPrimaryColor(context),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.getTextPrimaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            
            // Section content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: children,
              ),
            ),
          ],
        ),
      ),
      semanticLabel: title,
      isHeader: true,
    );
  }

  Widget _buildToggleTile({
    required AccessibilityService service,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return service.enhanceWidget(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ThemeHelper.getTextPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeHelper.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
      semanticLabel: '$title. $subtitle. Currently ${value ? 'enabled' : 'disabled'}',
      hint: 'Double tap to ${value ? 'disable' : 'enable'}',
      isButton: true,
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildSliderTile({
    required AccessibilityService service,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String Function(double) valueFormatter,
  }) {
    return service.enhanceWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                valueFormatter(value),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeHelper.getPrimaryColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
      semanticLabel: '$title. $subtitle. Current value: ${valueFormatter(value)}',
      hint: 'Swipe up to increase, swipe down to decrease',
      value: valueFormatter(value),
      onIncrease: () {
        final newValue = (value + (max - min) / divisions).clamp(min, max);
        onChanged(newValue);
      },
      onDecrease: () {
        final newValue = (value - (max - min) / divisions).clamp(min, max);
        onChanged(newValue);
      },
    );
  }

  Widget _buildDropdownTile({
    required AccessibilityService service,
    required String title,
    required String subtitle,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String> onChanged,
  }) {
    final selectedItem = items.firstWhere((item) => item['value'] == value);
    
    return service.enhanceWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(item['label']!),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ],
      ),
      semanticLabel: '$title. $subtitle. Currently selected: ${selectedItem['label']}',
      hint: 'Double tap to change selection',
      isButton: true,
    );
  }

  Widget _buildActionTile({
    required AccessibilityService service,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return service.enhanceWidget(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
            ],
          ),
        ),
      ),
      semanticLabel: '$title. $subtitle',
      hint: 'Double tap to activate',
      isButton: true,
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required AccessibilityService service,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _buildActionTile(
      service: service,
      title: title,
      subtitle: subtitle,
      icon: Icons.info_outline,
      onTap: onTap,
    );
  }

  Widget _buildFeatureIndicator(String name, bool enabled, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.circle_outlined,
            color: enabled ? Colors.green : ThemeHelper.getTextSecondaryColor(context),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeHelper.getTextPrimaryColor(context),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeHelper.getTextSecondaryColor(context),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            enabled ? 'Enabled' : 'Disabled',
            style: TextStyle(
              fontSize: 12,
              color: enabled ? Colors.green : ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // Action handlers

  void _showNavigationHints(AccessibilityService service) {
    final hints = [
      service.getNavigationHint(AccessibilityNavigationContext.verseList),
      service.getNavigationHint(AccessibilityNavigationContext.chapterList),
      service.getNavigationHint(AccessibilityNavigationContext.bookmarks),
      service.getNavigationHint(AccessibilityNavigationContext.search),
      service.getNavigationHint(AccessibilityNavigationContext.audioPlayer),
      service.getNavigationHint(AccessibilityNavigationContext.readingPlan),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigation Hints'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: hints.map((hint) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(hint),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAccessibilityTutorial(AccessibilityService service) {
    final tutorial = service.getAccessibilityTutorial();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AccessibilityTutorialScreen(tutorial: tutorial),
      ),
    );
  }

  void _testVoiceAnnouncements(AccessibilityService service) {
    service.announceText(
      'This is a test of voice announcements. If you can hear this, voice announcements are working correctly.',
      type: AccessibilityAnnouncement.assertive,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice announcement test sent. Check if you can hear it.'),
      ),
    );
  }

  void _resetToDefaults(AccessibilityService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Accessibility Settings'),
        content: const Text(
          'Are you sure you want to reset all accessibility settings to their default values?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await service.updatePreferences(const AccessibilityPreferences());
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Accessibility settings reset to defaults'),
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _AccessibilityTutorialScreen extends StatelessWidget {
  const _AccessibilityTutorialScreen({required this.tutorial});
  
  final List<AccessibilityTutorialStep> tutorial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Tutorial'),
      ),
      body: PageView.builder(
        itemCount: tutorial.length,
        itemBuilder: (context, index) {
          final step = tutorial[index];
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    step.action,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
