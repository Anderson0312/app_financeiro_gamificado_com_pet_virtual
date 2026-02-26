import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_providers.dart';
import '../../data/onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingRepository(prefs);
});

final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(onboardingRepositoryProvider);
  return repo.hasCompletedOnboarding();
});
