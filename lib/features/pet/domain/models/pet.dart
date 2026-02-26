import 'package:equatable/equatable.dart';

import '../../../onboarding/domain/models/pet_species.dart';

/// Estágio de evolução do pet.
enum PetStage { egg, baby, child, teenager, adult }

/// Humor do pet (reflete saúde financeira).
enum PetMood { happy, neutral, sad, sick }

/// Modelo do pet virtual.
class Pet extends Equatable {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    this.stage = PetStage.baby,
    this.mood = PetMood.neutral,
    this.xp = 0,
    this.unlockedAccessories = const [],
  });

  final String id;
  final String name;
  final PetSpecies species;
  final PetStage stage;
  final PetMood mood;
  final int xp;
  final List<String> unlockedAccessories;

  Pet copyWith({
    String? id,
    String? name,
    PetSpecies? species,
    PetStage? stage,
    PetMood? mood,
    int? xp,
    List<String>? unlockedAccessories,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      stage: stage ?? this.stage,
      mood: mood ?? this.mood,
      xp: xp ?? this.xp,
      unlockedAccessories: unlockedAccessories ?? this.unlockedAccessories,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species.name,
        'stage': stage.name,
        'mood': mood.name,
        'xp': xp,
        'unlockedAccessories': unlockedAccessories,
      };

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        id: json['id'] as String,
        name: json['name'] as String,
        species: PetSpecies.values.byName(json['species'] as String),
        stage: PetStage.values.byName(json['stage'] as String),
        mood: PetMood.values.byName(json['mood'] as String),
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        unlockedAccessories:
            (json['unlockedAccessories'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  @override
  List<Object?> get props =>
      [id, name, species, stage, mood, xp, unlockedAccessories];
}
