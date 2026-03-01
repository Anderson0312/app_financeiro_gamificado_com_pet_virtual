import 'package:flutter/material.dart';

import '../../domain/models/pet_species.dart';
import '../../../pet/domain/models/pet_colors.dart';
import '../../../pet/petbody/pet_cat.dart' as cat_widget;
import '../../../pet/petbody/pet_dog.dart';
import '../../../pet/petbody/pet_dragon.dart';
import '../../../pet/petbody/pet_capybara.dart';
import '../../../pet/domain/models/pet.dart';

/// Tela de personalização de cores durante o onboarding.
class PetColorSelectionScreen extends StatefulWidget {
  const PetColorSelectionScreen({
    super.key,
    required this.species,
    required this.onColorSelected,
    required this.onNext,
    required this.onBack,
  });

  final PetSpecies species;
  final ValueChanged<PetColors?> onColorSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<PetColorSelectionScreen> createState() =>
      _PetColorSelectionScreenState();
}

class _PetColorSelectionScreenState extends State<PetColorSelectionScreen> {
  PetColors? _selectedColors;

  @override
  void initState() {
    super.initState();
    _selectedColors = _getDefaultColors(widget.species);
  }

  PetColors _getDefaultColors(PetSpecies species) {
    switch (species) {
      case PetSpecies.cat:
        return PetColors.defaultCat;
      case PetSpecies.dog:
        return PetColors.defaultDog;
      case PetSpecies.dragon:
        return PetColors.defaultDragon;
      case PetSpecies.capybara:
        return PetColors.defaultCapybara;
    }
  }

  List<ColorPreset> _getColorPresetsForSpecies(PetSpecies species) {
    switch (species) {
      case PetSpecies.cat:
        return [
          ColorPreset(
            name: 'Laranja Clássico',
            colors: PetColors.defaultCat,
          ),
          ColorPreset(
            name: 'Gato Cinza',
            colors: const PetColors(
              primaryColor: Color(0xFF9E9E9E),
              secondaryColor: Color(0xFFE0E0E0),
              outlineColor: Color(0xFF616161),
            ),
          ),
          ColorPreset(
            name: 'Gato Preto',
            colors: const PetColors(
              primaryColor: Color(0xFF424242),
              secondaryColor: Color(0xFF757575),
              outlineColor: Color(0xFF212121),
            ),
          ),
          ColorPreset(
            name: 'Gato Siamês',
            colors: const PetColors(
              primaryColor: Color(0xFFD7CCC8),
              secondaryColor: Color(0xFFF5F5DC),
              outlineColor: Color(0xFF8D6E63),
            ),
          ),
        ];
      case PetSpecies.dog:
        return [
          ColorPreset(
            name: 'Caramelo Clássico',
            colors: PetColors.defaultDog,
          ),
          ColorPreset(
            name: 'Golden Retriever',
            colors: const PetColors(
              primaryColor: Color(0xFFFFD54F),
              secondaryColor: Color(0xFFFFECB3),
              outlineColor: Color(0xFFFFB300),
            ),
          ),
          ColorPreset(
            name: 'Labrador Preto',
            colors: const PetColors(
              primaryColor: Color(0xFF212121),
              secondaryColor: Color(0xFF616161),
              outlineColor: Color(0xFF000000),
            ),
          ),
          ColorPreset(
            name: 'Husky',
            colors: const PetColors(
              primaryColor: Color(0xFF78909C),
              secondaryColor: Color(0xFFECEFF1),
              outlineColor: Color(0xFF455A64),
            ),
          ),
        ];
      case PetSpecies.dragon:
        return [
          ColorPreset(
            name: 'Dragão Verde',
            colors: PetColors.defaultDragon,
          ),
          ColorPreset(
            name: 'Dragão de Fogo',
            colors: const PetColors(
              primaryColor: Color(0xFFFF5722),
              secondaryColor: Color(0xFFFFEB3B),
              outlineColor: Color(0xFFBF360C),
            ),
          ),
          ColorPreset(
            name: 'Dragão de Gelo',
            colors: const PetColors(
              primaryColor: Color(0xFF00BCD4),
              secondaryColor: Color(0xFFB2EBF2),
              outlineColor: Color(0xFF006064),
            ),
          ),
          ColorPreset(
            name: 'Dragão Dourado',
            colors: const PetColors(
              primaryColor: Color(0xFFFFD700),
              secondaryColor: Color(0xFFFFECB3),
              outlineColor: Color(0xFFFF8F00),
            ),
          ),
        ];
      case PetSpecies.capybara:
        return [
          ColorPreset(
            name: 'Capivara Natural',
            colors: PetColors.defaultCapybara,
          ),
          ColorPreset(
            name: 'Capivara Clara',
            colors: const PetColors(
              primaryColor: Color(0xFFBCAAA4),
              secondaryColor: Color(0xFFD7CCC8),
              outlineColor: Color(0xFF8D6E63),
            ),
          ),
          ColorPreset(
            name: 'Capivara Escura',
            colors: const PetColors(
              primaryColor: Color(0xFF5D4037),
              secondaryColor: Color(0xFF8D6E63),
              outlineColor: Color(0xFF3E2723),
            ),
          ),
        ];
    }
  }

  Widget _buildPetPreview() {
    switch (widget.species) {
      case PetSpecies.cat:
        return cat_widget.FullBodyCatWidget(
          mood: cat_widget.PetMood.idle,
          size: 250,
          customColors: _selectedColors,
        );
      case PetSpecies.dog:
        return FullBodyDogWidget(
          mood: PetMood.happy,
          size: 250,
          customColors: _selectedColors,
        );
      case PetSpecies.dragon:
        return FullBodyDragonWidget(
          mood: PetMood.happy,
          size: 250,
          customColors: _selectedColors,
        );
      case PetSpecies.capybara:
        return FullBodyCapybaraWidget(
          mood: PetMood.happy,
          size: 250,
          customColors: _selectedColors,
        );
    }
  }

  void _onConfirm() {
    widget.onColorSelected(_selectedColors);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final presets = _getColorPresetsForSpecies(widget.species);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalize as cores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 300,
                      color: Colors.grey.shade100,
                      child: Center(child: _buildPetPreview()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Escolha uma cor para seu pet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Você pode personalizar depois!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: presets.map((preset) {
                              final isSelected =
                                  _selectedColors == preset.colors;
                              return _ColorPresetCard(
                                preset: preset,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedColors = preset.colors;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _onConfirm,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPreset {
  final String name;
  final PetColors colors;

  const ColorPreset({
    required this.name,
    required this.colors,
  });
}

class _ColorPresetCard extends StatelessWidget {
  const _ColorPresetCard({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final ColorPreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: preset.colors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: preset.colors.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: preset.colors.outlineColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              preset.name,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
