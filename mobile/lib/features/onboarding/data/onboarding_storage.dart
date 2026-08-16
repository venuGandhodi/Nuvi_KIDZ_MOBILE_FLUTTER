import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  static const String _onboardingKey = 'has_completed_onboarding';
  final SharedPreferences? _injectedPrefs;

  OnboardingStorage({SharedPreferences? preferences})
    : _injectedPrefs = preferences;

  Future<SharedPreferences> get _prefs async =>
      _injectedPrefs ?? await SharedPreferences.getInstance();

  Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setCompletedOnboarding([bool completed = true]) async {
    try {
      final prefs = await _prefs;
      await prefs.setBool(_onboardingKey, completed);
    } catch (_) {
      // Graceful fallback
    }
  }
}

final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  return OnboardingStorage();
});
