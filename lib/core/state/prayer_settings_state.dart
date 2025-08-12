import 'package:shared_preferences/shared_preferences.dart';

class PrayerSettingsState {
  static PrayerSettingsState? _instance;
  static PrayerSettingsState get instance => _instance ??= PrayerSettingsState._();
  
  PrayerSettingsState._();
  
  String _calculationMethod = 'MWL';
  
  String get calculationMethod => _calculationMethod;
  
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMethod = prefs.getString('calculation_method');
      if (savedMethod != null) {
        _calculationMethod = savedMethod;
        print('PrayerSettingsState: Loaded method: $_calculationMethod');
      }
    } catch (e) {
      print('PrayerSettingsState: Error loading settings: $e');
    }
  }
  
  Future<void> setCalculationMethod(String method) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('calculation_method', method);
      _calculationMethod = method;
      print('PrayerSettingsState: Saved method: $_calculationMethod');
    } catch (e) {
      print('PrayerSettingsState: Error saving settings: $e');
    }
  }
  
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('calculation_method');
      await prefs.remove('onboarding_completed');
      _calculationMethod = 'MWL';
      print('PrayerSettingsState: Reset to default: $_calculationMethod');
    } catch (e) {
      print('PrayerSettingsState: Error resetting: $e');
    }
  }
}
