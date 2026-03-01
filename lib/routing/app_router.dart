import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/education/presentation/screens/education_placeholder_screen.dart';
import '../features/finance/presentation/screens/add_goal_screen.dart';
import '../features/finance/presentation/screens/add_transaction_screen.dart';
import '../features/finance/presentation/screens/goals_screen.dart';
import '../features/finance/presentation/screens/transactions_screen.dart';
import '../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../features/pet/presentation/screens/pet_screen.dart';
import '../features/pet/presentation/screens/pet_color_customization_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) async {
      final completed = await ref.read(hasCompletedOnboardingProvider.future);
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!completed && !isOnboarding) {
        return '/onboarding';
      }
      if (completed && isOnboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PetScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingFlowScreen(
          onComplete: () => context.go('/'),
        ),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: '/transactions/add',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/goals/add',
        builder: (context, state) => const AddGoalScreen(),
      ),
      GoRoute(
        path: '/education',
        builder: (context, state) => const EducationPlaceholderScreen(),
      ),
      GoRoute(
        path: '/pet/customize-colors',
        builder: (context, state) => const PetColorCustomizationScreen(),
      ),
    ],
  );

  ref.listen(hasCompletedOnboardingProvider, (_, __) {
    router.refresh();
  });

  return router;
});
