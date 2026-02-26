import '../domain/models/pet.dart';

/// Repositório de dados do pet.
abstract class PetRepository {
  Future<Pet?> getPet();
  Future<void> savePet(Pet pet);
  Future<void> deletePet();
}
