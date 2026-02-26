import 'package:flutter/material.dart';

import '../../domain/models/pet_species.dart';

/// Tela final do onboarding - pet nasceu.
class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({
    super.key,
    required this.petName,
    required this.species,
    required this.onFinish,
  });

  final String petName;
  final PetSpecies species;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _icon,
                size: 100,
                color: _color,
              ),
              const SizedBox(height: 24),
              Text(
                '$petName nasceu!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Sua jornada financeira começa agora. '
                'Registre suas receitas e despesas para ver seu pet crescer!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: onFinish,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Começar a usar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    switch (species) {
      case PetSpecies.dog:
        return Icons.pets;
      case PetSpecies.cat:
        return Icons.pets;
      case PetSpecies.dragon:
        return Icons.whatshot;
      case PetSpecies.capybara:
        return Icons.face;
    }
  }

  Color get _color {
    switch (species) {
      case PetSpecies.dog:
        return Colors.brown;
      case PetSpecies.cat:
        return Colors.orange;
      case PetSpecies.dragon:
        return Colors.deepOrange;
      case PetSpecies.capybara:
        return Colors.brown.shade700;
    }
  }
}
