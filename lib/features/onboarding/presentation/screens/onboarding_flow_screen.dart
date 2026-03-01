import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../pet/data/pet_repository_impl.dart';
import '../../../pet/presentation/providers/pet_provider.dart';
import '../../../pet/domain/models/pet_colors.dart';
import '../providers/onboarding_provider.dart';
import '../../../pet/domain/models/pet.dart';
import '../../../user/data/user_repository_impl.dart';
import '../../../user/domain/models/user.dart';
import '../../domain/models/pet_species.dart';
import 'onboarding_complete_screen.dart';
import 'pet_naming_screen.dart';
import 'pet_selection_screen.dart';
import 'pet_color_selection_screen.dart';
import 'welcome_screen.dart';

/// Orquestra o fluxo completo do onboarding.
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  int _step = 0;
  PetSpecies? _selectedSpecies;
  String? _petName;
  PetColors? _selectedColors;

  void _completeOnboarding() async {
    if (_selectedSpecies == null || _petName == null) return;

    final uuid = const Uuid().v4();
    final now = DateTime.now();

    final pet = Pet(
      id: uuid,
      name: _petName!,
      species: _selectedSpecies!,
      stage: PetStage.baby,
      mood: PetMood.neutral,
      xp: 0,
      customColors: _selectedColors,
    );

    final user = User(
      id: uuid,
      totalXp: 0,
      virtualCoins: 0,
      createdAt: now,
    );

    final petRepo = ref.read(petRepositoryProvider);
    final userRepo = ref.read(userRepositoryProvider);
    final onboardingRepo = ref.read(onboardingRepositoryProvider);

    await petRepo.savePet(pet);
    await userRepo.saveUser(user);
    await onboardingRepo.setOnboardingComplete();

    if (mounted) {
      ref.invalidate(petProvider);
      ref.invalidate(hasCompletedOnboardingProvider);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 0:
        return WelcomeScreen(onNext: () => setState(() => _step = 1));
      case 1:
        return PetSelectionScreen(
          selectedSpecies: _selectedSpecies,
          onSpeciesSelected: (s) => setState(() => _selectedSpecies = s),
          onNext: () => setState(() => _step = 2),
        );
      case 2:
        return PetColorSelectionScreen(
          species: _selectedSpecies!,
          onColorSelected: (colors) => setState(() => _selectedColors = colors),
          onNext: () => setState(() => _step = 3),
        );
      case 3:
        return PetNamingScreen(
          species: _selectedSpecies!,
          onComplete: (name) {
            setState(() {
              _petName = name;
              _step = 4;
            });
          },
        );
      case 4:
        return OnboardingCompleteScreen(
          petName: _petName!,
          species: _selectedSpecies!,
          onFinish: _completeOnboarding,
        );
      default:
        return WelcomeScreen(onNext: () => setState(() => _step = 1));
    }
  }
}
