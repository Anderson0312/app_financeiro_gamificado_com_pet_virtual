import 'package:flutter/material.dart';

import '../../domain/models/pet_species.dart';

/// Tela de seleção da espécie do pet.
class PetSelectionScreen extends StatelessWidget {
  const PetSelectionScreen({
    super.key,
    required this.selectedSpecies,
    required this.onSpeciesSelected,
    required this.onNext,
  });

  final PetSpecies? selectedSpecies;
  final ValueChanged<PetSpecies> onSpeciesSelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha seu pet')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Qual espécie você quer?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: PetSpecies.values.map((species) {
                    final isSelected = selectedSpecies == species;
                    return _SpeciesCard(
                      species: species,
                      isSelected: isSelected,
                      onTap: () => onSpeciesSelected(species),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: selectedSpecies != null ? onNext : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  const _SpeciesCard({
    required this.species,
    required this.isSelected,
    required this.onTap,
  });

  final PetSpecies species;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 48, color: _color),
            const SizedBox(height: 8),
            Text(species.label, style: Theme.of(context).textTheme.titleSmall),
          ],
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
