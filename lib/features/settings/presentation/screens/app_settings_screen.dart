import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Legacy notification service removed; notifications are managed via
// prayer notification providers and repository-backed services.
import '../../../../core/constants/app_constants.dart';
// Deprecated direct service import removed; use repository-backed providers instead
import '../../../../core/theme/islamic_theme.dart';
import '../../../../core/theme/theme_selector_widget.dart';

// Demo screen removed per product decision to avoid extra widgets on Home

/// App settings screen for DeenMate
class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  bool _prayerNotificationsEnabled = true;
  bool _prayerRemindersEnabled = true;
  bool _dailyVersesEnabled = true;
  bool _islamicMidnightEnabled = true; // Default to Islamic midnight
  int _selectedCalculationMethod = 2; // ISNA
  String _selectedLanguage = 'English';

  // Notifications are managed via providers; no direct service instance here.

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildSettingsList(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: IslamicTheme.textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'সেটিংস | الإعدادات',
                  style: IslamicTheme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          'Prayer Settings',
          [
            _buildNavTile(
              title: 'Athan Settings',
              subtitle: 'Reciter, volume, preview',
              icon: Icons.volume_up,
              route: '/athan-settings',
            ),
            _buildSwitchTile(
              'Prayer Notifications',
              'Get notified at prayer times',
              _prayerNotificationsEnabled,
              _setPrayerNotifications,
              Icons.notifications,
            ),
            _buildSwitchTile(
              'Prayer Reminders',
              '10 minutes before prayer time',
              _prayerRemindersEnabled,
              _setPrayerReminders,
              Icons.alarm,
            ),
            _buildCalculationMethodTile(),
            _buildSwitchTile(
              'Islamic Midnight Calculation',
              'Use authentic hadith-based midnight (Sahih Muslim 612)',
              _islamicMidnightEnabled,
              _setIslamicMidnight,
              Icons.nightlight_round,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Islamic Content',
          [
            _buildSwitchTile(
              'Daily Verses',
              'Receive daily Quranic verses',
              _dailyVersesEnabled,
              _setDailyVerses,
              Icons.menu_book,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Quran Settings',
          [
            _buildNavTile(
              title: 'Reading Preferences',
              subtitle: 'Font size, translations, layout',
              icon: Icons.text_fields,
              route: '/quran', // For now, goes to Quran home
            ),
            _buildNavTile(
              title: 'Offline Content',
              subtitle: 'Download content for offline use',
              icon: Icons.cloud_download,
              route: '/quran/offline-management',
            ),
            _buildNavTile(
              title: 'Audio Downloads',
              subtitle: 'Download recitations for offline use',
              icon: Icons.download,
              route: '/quran/audio-downloads',
            ),
            _buildNavTile(
              title: 'Accessibility',
              subtitle: 'Screen reader, high contrast, text scaling',
              icon: Icons.accessibility,
              route: '/settings/accessibility',
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'App Settings',
          [
            _buildLanguageTile(),
            _buildAboutTile(),
            _buildPrivacyTile(),
          ],
        ),
        const SizedBox(height: 24),
        // New theme selector section
        const ThemeSelectorWidget(),
        // User Preferences section temporarily removed until proper route is implemented
        const SizedBox(height: 24),
        _buildSection(
          'Data & Storage',
          [
            _buildClearCacheTile(),
            _buildExportDataTile(),
          ],
        ),
        const SizedBox(height: 40),
        _buildVersionInfo(),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildNavTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: () => context.go(route),
    );
  }

  Widget _buildCalculationMethodTile() {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(Icons.calculate, color: theme.colorScheme.primary),
      title: Text(
        'Prayer Calculation Method',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        AppConstants.calculationMethods.values.elementAt(
          _selectedCalculationMethod.clamp(
              0, AppConstants.calculationMethods.length - 1),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: _showCalculationMethodDialog,
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: const Icon(Icons.language, color: IslamicTheme.islamicGreen),
      title: const Text('Language'),
      subtitle: Text(
        _selectedLanguage,
        style: IslamicTheme.textTheme.bodySmall?.copyWith(
          color: IslamicTheme.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: _showLanguageDialog,
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      leading: const Icon(Icons.info, color: IslamicTheme.islamicGreen),
      title: const Text('About DeenMate'),
      subtitle: const Text('Version, credits, and more'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: _showAboutDialog,
    );
  }

  Widget _buildPrivacyTile() {
    return ListTile(
      leading: const Icon(Icons.privacy_tip, color: IslamicTheme.islamicGreen),
      title: const Text('Privacy Policy'),
      subtitle: const Text('How we protect your data'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: _showPrivacyDialog,
    );
  }

  Widget _buildClearCacheTile() {
    return ListTile(
      leading: const Icon(Icons.delete_sweep, color: Colors.orange),
      title: const Text('Clear Cache'),
      subtitle: const Text('Free up storage space'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: _clearCache,
    );
  }

  Widget _buildExportDataTile() {
    return ListTile(
      leading: const Icon(Icons.download, color: IslamicTheme.prayerBlue),
      title: const Text('Export Data'),
      subtitle: const Text('Backup your settings and data'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: _exportData,
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IslamicTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            '🌙 DeenMate',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: IslamicTheme.textTheme.bodyMedium?.copyWith(
              color: IslamicTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Islamic Utility Super App',
            style: IslamicTheme.textTheme.bodySmall?.copyWith(
              color: IslamicTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Settings actions
  Future<void> _setPrayerNotifications(bool enabled) async {
    setState(() {
      _prayerNotificationsEnabled = enabled;
    });

    // Permissions and scheduling are handled in Athan Settings via providers.
    await _saveSettings();
  }

  Future<void> _setPrayerReminders(bool enabled) async {
    setState(() {
      _prayerRemindersEnabled = enabled;
    });
    await _saveSettings();
  }

  Future<void> _setDailyVerses(bool enabled) async {
    setState(() {
      _dailyVersesEnabled = enabled;
    });
    await _saveSettings();
  }

  Future<void> _setIslamicMidnight(bool enabled) async {
    setState(() {
      _islamicMidnightEnabled = enabled;
    });
    await _saveSettings();
  }

  void _showCalculationMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prayer Calculation Method'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppConstants.calculationMethods.values
                .toList()
                .asMap()
                .entries
                .map((entry) {
              return RadioListTile<int>(
                title: Text(
                  entry.value,
                  style: const TextStyle(fontSize: 12),
                ),
                value: entry.key,
                groupValue: _selectedCalculationMethod,
                onChanged: (value) {
                  context.pop();
                  _setCalculationMethod(value!);
                },
                activeColor: IslamicTheme.islamicGreen,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    const languages = ['English', 'বাংলা', 'العربية'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                context.pop();
                _setLanguage(value!);
              },
              activeColor: IslamicTheme.islamicGreen,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About DeenMate'),
        content: const Text(
          'DeenMate is a comprehensive Islamic utility app designed to help Muslims in their daily religious practices.\n\n'
          'Features:\n'
          '• Prayer Times with multiple calculation methods\n'
          '• Qibla Compass\n'
          '• Zakat Calculator\n'
          '• Daily Quran verses and Hadith\n'
          '• Islamic Calendar\n'
          '• Prayer tracking and reminders\n\n'
          'May Allah accept our efforts and make this beneficial for the Ummah.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close',
                style: TextStyle(color: IslamicTheme.islamicGreen)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'Your privacy is important to us. This app:\n\n'
          '• Only uses location for prayer times and Qibla direction\n'
          '• Stores data locally on your device\n'
          '• Does not collect personal information\n'
          '• Does not share data with third parties\n'
          '• Uses prayer time APIs for accuracy\n\n'
          'All data remains on your device and under your control.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close',
                style: TextStyle(color: IslamicTheme.islamicGreen)),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'To send prayer time notifications, this app needs notification permissions. '
          'Please enable notifications in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('OK',
                style: TextStyle(color: IslamicTheme.islamicGreen)),
          ),
        ],
      ),
    );
  }

  Future<void> _setCalculationMethod(int method) async {
    setState(() {
      _selectedCalculationMethod = method;
    });

    // TODO: Wire calculation method change via repository-backed providers

    await _saveSettings();
  }

  Future<void> _setLanguage(String language) async {
    setState(() {
      _selectedLanguage = language;
    });
    await _saveSettings();

    // TODO: Implement language change
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Language change will take effect on app restart'),
        backgroundColor: IslamicTheme.islamicGreen,
      ),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'This will clear cached prayer times and other temporary data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text('Clear', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear cache logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          backgroundColor: IslamicTheme.islamicGreen,
        ),
      );
    }
  }

  Future<void> _exportData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
        backgroundColor: IslamicTheme.islamicGreen,
      ),
    );
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _prayerNotificationsEnabled =
            prefs.getBool('prayer_notifications') ?? true;
        _prayerRemindersEnabled = prefs.getBool('prayer_reminders') ?? true;
        _dailyVersesEnabled = prefs.getBool('daily_verses') ?? true;
        _islamicMidnightEnabled = prefs.getBool('islamic_midnight') ?? true;
        _selectedCalculationMethod = prefs.getInt('calculation_method') ?? 2;
        _selectedLanguage = prefs.getString('language') ?? 'English';
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('prayer_notifications', _prayerNotificationsEnabled);
      await prefs.setBool('prayer_reminders', _prayerRemindersEnabled);
      await prefs.setBool('daily_verses', _dailyVersesEnabled);
      await prefs.setBool('islamic_midnight', _islamicMidnightEnabled);
      await prefs.setInt('calculation_method', _selectedCalculationMethod);
      await prefs.setString('language', _selectedLanguage);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }
}
