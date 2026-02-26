import 'package:flutter/material.dart';

import '../../domain/models/pet.dart';
import '../../../onboarding/domain/models/pet_species.dart';

/// Widget que exibe a representação visual do pet baseada em espécie, estágio e humor.
class PetAvatar extends StatelessWidget {
  const PetAvatar({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatarPlaceholder(context),
          const SizedBox(height: 8),
          Text(
            _moodLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: _moodColor.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(color: _moodColor, width: 3),
      ),
      child: Icon(
        _speciesIcon,
        size: 64,
        color: _speciesColor,
      ),
    );
  }

  IconData get _speciesIcon {
    switch (pet.species) {
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

  Color get _speciesColor {
    switch (pet.species) {
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

  Color get _moodColor {
    switch (pet.mood) {
      case PetMood.happy:
        return Colors.green;
      case PetMood.neutral:
        return Colors.blue;
      case PetMood.sad:
        return Colors.blueGrey;
      case PetMood.sick:
        return Colors.red;
    }
  }

  String get _moodLabel {
    switch (pet.mood) {
      case PetMood.happy:
        return 'Feliz!';
      case PetMood.neutral:
        return 'Tranquilo';
      case PetMood.sad:
        return 'Triste...';
      case PetMood.sick:
        return 'Doente...';
    }
  }
}
