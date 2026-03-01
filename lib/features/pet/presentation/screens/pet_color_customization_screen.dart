import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../onboarding/domain/models/pet_species.dart';
import '../../domain/models/pet_colors.dart';
import '../../domain/models/pet.dart';
import '../providers/pet_provider.dart';
import '../../petbody/pet_cat.dart' as cat_widget;
import '../../petbody/pet_dog.dart';
import '../../petbody/pet_dragon.dart';
import '../../petbody/pet_capybara.dart';

/// Tela de personalização de cores do pet.
class PetColorCustomizationScreen extends ConsumerStatefulWidget {
  const PetColorCustomizationScreen({super.key});

  @override
  ConsumerState<PetColorCustomizationScreen> createState() =>
      _PetColorCustomizationScreenState();
}

class _PetColorCustomizationScreenState
    extends ConsumerState<PetColorCustomizationScreen> {
  PetColors? _currentColors;
  PetSpecies? _species;

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
          ColorPreset(
            name: 'Gato Tigrado',
            colors: const PetColors(
              primaryColor: Color(0xFFCD853F),
              secondaryColor: Color(0xFFFFE4B5),
              outlineColor: Color(0xFF8B4513),
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
            name: 'Beagle',
            colors: const PetColors(
              primaryColor: Color(0xFF8D6E63),
              secondaryColor: Color(0xFFFFFFFF),
              outlineColor: Color(0xFF5D4037),
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
            name: 'Dragão Negro',
            colors: const PetColors(
              primaryColor: Color(0xFF37474F),
              secondaryColor: Color(0xFF9E9E9E),
              outlineColor: Color(0xFF000000),
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
          ColorPreset(
            name: 'Capivara Dourada',
            colors: const PetColors(
              primaryColor: Color(0xFFD4AF37),
              secondaryColor: Color(0xFFFFE082),
              outlineColor: Color(0xFF9C7C2A),
            ),
          ),
        ];
    }
  }

  void _saveColors() {
    final petAsync = ref.read(petProvider);
    petAsync.whenData((pet) {
      if (pet != null && _currentColors != null) {
        final updatedPet = pet.copyWith(customColors: _currentColors);
        ref.read(petProvider.notifier).updatePet(updatedPet);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cores salvas com sucesso!')),
        );
      }
    });
  }

  void _resetToDefault() {
    if (_species != null) {
      setState(() {
        _currentColors = _getDefaultColors(_species!);
      });
    }
  }

  Widget _buildPetPreview() {
    if (_species == null || _currentColors == null) {
      return const CircularProgressIndicator();
    }
    
    switch (_species!) {
      case PetSpecies.cat:
        return cat_widget.FullBodyCatWidget(
          mood: cat_widget.PetMood.idle,
          size: 250,
          customColors: _currentColors,
        );
      case PetSpecies.dog:
        return FullBodyDogWidget(
          mood: PetMood.happy,
          size: 250,
          customColors: _currentColors,
        );
      case PetSpecies.dragon:
        return FullBodyDragonWidget(
          mood: PetMood.happy,
          size: 250,
          customColors: _currentColors,
        );
      case PetSpecies.capybara:
        return FullBodyCapybaraWidget(
          mood: PetMood.happy,
          size: 250,
          customColors: _currentColors,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final petAsync = ref.watch(petProvider);

    return petAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Personalizar Cores')),
        body: Center(child: Text('Erro: $error')),
      ),
      data: (pet) {
        if (pet == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Personalizar Cores')),
            body: const Center(child: Text('Pet não encontrado')),
          );
        }

        // Inicializa as cores se ainda não foram inicializadas
        if (_species == null) {
          _species = pet.species;
          _currentColors = pet.customColors ?? _getDefaultColors(_species!);
        }

        final presets = _getColorPresetsForSpecies(_species!);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Personalizar Cores'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _resetToDefault,
                tooltip: 'Restaurar padrão',
              ),
            ],
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
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Presets de Cores',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: presets.length,
                                  itemBuilder: (context, index) {
                                    final preset = presets[index];
                                    final isSelected = _currentColors == preset.colors;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _ColorPresetCard(
                                        preset: preset,
                                        isSelected: isSelected,
                                        onTap: () {
                                          setState(() {
                                            _currentColors = preset.colors;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Personalização Manual',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              if (_currentColors != null) ...[
                                _ColorPicker(
                                  label: 'Cor Principal',
                                  color: _currentColors!.primaryColor,
                                  onColorChanged: (color) {
                                    setState(() {
                                      _currentColors = _currentColors!.copyWith(
                                        primaryColor: color,
                                      );
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                _ColorPicker(
                                  label: 'Cor Secundária',
                                  color: _currentColors!.secondaryColor,
                                  onColorChanged: (color) {
                                    setState(() {
                                      _currentColors = _currentColors!.copyWith(
                                        secondaryColor: color,
                                      );
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                _ColorPicker(
                                  label: 'Cor do Contorno',
                                  color: _currentColors!.outlineColor,
                                  onColorChanged: (color) {
                                    setState(() {
                                      _currentColors = _currentColors!.copyWith(
                                        outlineColor: color,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FilledButton(
                    onPressed: _saveColors,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Salvar Cores'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        width: 120,
        padding: const EdgeInsets.all(8),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: preset.colors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: preset.colors.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 20,
                  height: 20,
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
              style: Theme.of(context).textTheme.bodySmall,
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

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  static final List<Color> _colorOptions = [
    // Tons de marrom
    const Color(0xFF8D6E63),
    const Color(0xFFD48F3B),
    const Color(0xFF5D4037),
    const Color(0xFFBCAAA4),
    // Tons de laranja
    const Color(0xFFFFAB00),
    const Color(0xFFFF9600),
    const Color(0xFFFF6F00),
    // Tons de cinza
    const Color(0xFF9E9E9E),
    const Color(0xFF616161),
    const Color(0xFF424242),
    const Color(0xFF212121),
    // Tons de verde
    const Color(0xFF4CAF50),
    const Color(0xFF2E7D32),
    const Color(0xFFC6FF00),
    const Color(0xFF66BB6A),
    // Tons de vermelho/fogo
    const Color(0xFFFF5722),
    const Color(0xFFBF360C),
    const Color(0xFFFFEB3B),
    // Tons de azul
    const Color(0xFF00BCD4),
    const Color(0xFF0097A7),
    const Color(0xFFB2EBF2),
    const Color(0xFF78909C),
    // Tons especiais
    const Color(0xFFFFD700), // Dourado
    const Color(0xFFFFFFFF), // Branco
    const Color(0xFFD7CCC8), // Bege
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorOptions.map((colorOption) {
              final isSelected = color.value == colorOption.value;
              return InkWell(
                onTap: () => onColorChanged(colorOption),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorOption,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade400,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
