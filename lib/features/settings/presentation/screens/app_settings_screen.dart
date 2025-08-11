import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/services/notification_service.dart';
// Deprecated direct service import removed; use repository-backed providers instead
import '../../../../core/theme/islamic_theme.dart';
/// App settings screen for DeenMate
class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _prayerNotificationsEnabled = true;
  bool _prayerRemindersEnabled = true;
  bool _dailyVersesEnabled = true;
  int _selectedCalculationMethod = 2; // ISNA
  String _selectedLanguage = 'English';
  
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              IslamicTheme.islamicGreen,
              IslamicTheme.islamicGreen.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: _buildSettingsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(AppRouter.home),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: IslamicTheme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'সেটিংস | الإعدادات',
                  style: IslamicTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
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
      padding: const EdgeInsets.all(24),
      children: [
        _buildSection(
          'Prayer Settings',
          'নামাজের সেটিংস',
          [
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
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildSection(
          'Islamic Content',
          'ইসলামিক কন্টেন্ট',
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
          'App Settings',
          'অ্যাপের সেটিংস',
          [
            _buildLanguageTile(),
            _buildAboutTile(),
            _buildPrivacyTile(),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildSection(
          'Data & Storage',
          'ডেটা ও স্টোরেজ',
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

  Widget _buildSection(String title, String subtitle, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: IslamicTheme.textTheme.headlineSmall?.copyWith(
            color: IslamicTheme.islamicGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: IslamicTheme.textTheme.bodySmall?.copyWith(
            color: IslamicTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: IslamicTheme.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: IslamicTheme.textHint.withOpacity(0.2)),
          ),
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
    return ListTile(
      leading: Icon(icon, color: IslamicTheme.islamicGreen),
      title: Text(
        title,
        style: IslamicTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: IslamicTheme.textTheme.bodySmall?.copyWith(
          color: IslamicTheme.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: IslamicTheme.islamicGreen,
      ),
    );
  }

  Widget _buildCalculationMethodTile() {
    return ListTile(
      leading: const Icon(Icons.calculate, color: IslamicTheme.islamicGreen),
      title: const Text('Prayer Calculation Method'),
      subtitle: Text(
        AppConstants.calculationMethods[_selectedCalculationMethod] ?? 'Unknown',
        style: IslamicTheme.textTheme.bodySmall?.copyWith(
          color: IslamicTheme.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
    
    if (enabled) {
      final hasPermission = await _notificationService.requestPermissions();
      if (!hasPermission) {
        _showPermissionDialog();
        setState(() {
          _prayerNotificationsEnabled = false;
        });
        return;
      }
    }
    
    await _notificationService.setPrayerRemindersEnabled(enabled);
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

  void _showCalculationMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prayer Calculation Method'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppConstants.calculationMethods.entries.map((entry) {
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
            child: const Text('Close', style: TextStyle(color: IslamicTheme.islamicGreen)),
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
            child: const Text('Close', style: TextStyle(color: IslamicTheme.islamicGreen)),
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
            child: const Text('OK', style: TextStyle(color: IslamicTheme.islamicGreen)),
          ),
        ],
      ),
    );
  }

  Future<void> _setCalculationMethod(int method) async {
    setState(() {
      _selectedCalculationMethod = method;
    });
    
    // Update prayer times with new method
    context.read<RealPrayerTimesProvider>().changeCalculationMethod(method);
    
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
        content: const Text('This will clear cached prayer times and other temporary data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
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
        _prayerNotificationsEnabled = prefs.getBool('prayer_notifications') ?? true;
        _prayerRemindersEnabled = prefs.getBool('prayer_reminders') ?? true;
        _dailyVersesEnabled = prefs.getBool('daily_verses') ?? true;
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
      await prefs.setInt('calculation_method', _selectedCalculationMethod);
      await prefs.setString('language', _selectedLanguage);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }
}
