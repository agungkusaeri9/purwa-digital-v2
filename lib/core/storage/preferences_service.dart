import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _onboardingKey = 'has_seen_onboarding';
  Future<bool> hasSeenOnboarding() async =>
      (await SharedPreferences.getInstance()).getBool(_onboardingKey) ?? false;
  Future<void> setHasSeenOnboarding() async =>
      (await SharedPreferences.getInstance()).setBool(_onboardingKey, true);
}
