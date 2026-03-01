import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/pet_repository_impl.dart';
import '../../domain/models/pet.dart';

final petProvider = AsyncNotifierProvider<PetNotifier, Pet?>(PetNotifier.new);

class PetNotifier extends AsyncNotifier<Pet?> {
  @override
  Future<Pet?> build() async {
    final repo = ref.read(petRepositoryProvider);
    return repo.getPet();
  }

  Future<void> savePet(Pet pet) async {
    final repo = ref.read(petRepositoryProvider);
    await repo.savePet(pet);
    ref.invalidateSelf();
  }

  Future<void> updatePet(Pet pet) async {
    final repo = ref.read(petRepositoryProvider);
    await repo.savePet(pet);
    ref.invalidateSelf();
  }
}
