import 'package:shared_preferences/shared_preferences.dart';

class PrayerSettingsState {
  static PrayerSettingsState? _instance;
  static PrayerSettingsState get instance =>
      _instance ??= PrayerSettingsState._();

  PrayerSettingsState._();

  String _calculationMethod = 'MWL';
  String _madhhab = 'shafi';

  String get calculationMethod => _calculationMethod;
  String get madhhab => _madhhab;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMethod = prefs.getString('calculation_method');
      final savedMadhhab = prefs.getString('madhhab');
      if (savedMethod != null) {
        _calculationMethod = savedMethod;
        print('PrayerSettingsState: Loaded method: $_calculationMethod');
      }
      if (savedMadhhab != null) {
        _madhhab = savedMadhhab;
        print('PrayerSettingsState: Loaded madhhab: $_madhhab');
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

  Future<void> setMadhhab(String madhhab) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('madhhab', madhhab);
      _madhhab = madhhab;
      print('PrayerSettingsState: Saved madhhab: $_madhhab');
    } catch (e) {
      print('PrayerSettingsState: Error saving madhhab: $e');
    }
  }

  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('calculation_method');
      await prefs.remove('onboarding_completed');
      await prefs.remove('madhhab');
      _calculationMethod = 'MWL';
      _madhhab = 'shafi';
      print('PrayerSettingsState: Reset to default: $_calculationMethod');
    } catch (e) {
      print('PrayerSettingsState: Error resetting: $e');
    }
  }
}
