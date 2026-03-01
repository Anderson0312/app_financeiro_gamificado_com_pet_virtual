import 'package:flutter/material.dart';

import '../../domain/models/pet.dart';
import '../../../onboarding/domain/models/pet_species.dart';
import '../../petbody/pet_cat.dart' as cat_widget;
import '../../petbody/pet_dog.dart';
import '../../petbody/pet_dragon.dart';
import '../../petbody/pet_capybara.dart';

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
          _buildPetWidget(),
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

  Widget _buildPetWidget() {
    switch (pet.species) {
      case PetSpecies.cat:
        return cat_widget.FullBodyCatWidget(
          mood: _convertToCatMood(pet.mood),
          size: 200,
          customColors: pet.customColors,
        );
      case PetSpecies.dog:
        return FullBodyDogWidget(
          mood: pet.mood,
          size: 200,
          customColors: pet.customColors,
        );
      case PetSpecies.dragon:
        return FullBodyDragonWidget(
          mood: pet.mood,
          size: 200,
          customColors: pet.customColors,
        );
      case PetSpecies.capybara:
        return FullBodyCapybaraWidget(
          mood: pet.mood,
          size: 200,
          customColors: pet.customColors,
        );
    }
  }

  // Converte PetMood (do modelo) para o enum do FullBodyCatWidget
  cat_widget.PetMood _convertToCatMood(PetMood mood) {
    switch (mood) {
      case PetMood.happy:
        return cat_widget.PetMood.happy;
      case PetMood.sad:
      case PetMood.sick:
        return cat_widget.PetMood.sad;
      case PetMood.neutral:
        return cat_widget.PetMood.idle;
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
