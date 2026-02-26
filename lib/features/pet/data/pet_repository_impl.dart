import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/providers/app_providers.dart';
import '../domain/models/pet.dart';
import 'pet_repository.dart';

const _petKey = 'pet_data';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PetRepositoryImpl(prefs);
});

class PetRepositoryImpl implements PetRepository {
  PetRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<Pet?> getPet() async {
    final json = _prefs.getString(_petKey);
    if (json == null) return null;
    try {
      return Pet.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePet(Pet pet) async {
    await _prefs.setString(_petKey, jsonEncode(pet.toJson()));
  }

  @override
  Future<void> deletePet() async {
    await _prefs.remove(_petKey);
  }
}
