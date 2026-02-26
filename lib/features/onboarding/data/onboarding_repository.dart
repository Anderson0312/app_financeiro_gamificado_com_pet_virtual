import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

/// Repositório para estado do onboarding.
class OnboardingRepository {
  OnboardingRepository(this._prefs);

  final SharedPreferences _prefs;

  Future<bool> hasCompletedOnboarding() async {
    return _prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(AppConstants.onboardingCompleteKey, true);
  }
}
