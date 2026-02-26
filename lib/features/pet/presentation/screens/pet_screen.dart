import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../onboarding/domain/models/pet_species.dart';
import '../../domain/models/pet.dart';
import '../../domain/pet_service.dart';
import '../../petbody/pet_capybara.dart';
import '../../petbody/pet_cat.dart' as cat;
import '../../petbody/pet_dog.dart';
import '../../petbody/pet_dragon.dart';
import '../providers/financial_health_provider.dart';
import '../providers/pet_provider.dart';

/// Tela principal onde o pet é exibido.
class PetScreen extends ConsumerWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsync = ref.watch(petProvider);
    final financialHealth = ref.watch(financialHealthProvider);

    return petAsync.when(
      loading: () => const _LoadingPetScreen(),
      error: (error, _) => _ErrorPetScreen(error: error.toString()),
      data: (pet) {
        if (pet == null) {
          return const _ErrorPetScreen(
            error: 'Nenhum pet encontrado. Complete o onboarding.',
          );
        }
        final mood = PetService.computeMoodFromFinancialHealth(financialHealth);
        final petWithMood = pet.copyWith(mood: mood);

        return Scaffold(
          appBar: AppBar(
            title: Text(petWithMood.name),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _PetBodyBySpecies(pet: petWithMood, size: 260),
                  ),
                ),
                _QuickStats(xp: pet.xp, stage: pet.stage),
                const SizedBox(height: 24),
                _ActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Exibe o widget de corpo do pet conforme a espécie escolhida.
class _PetBodyBySpecies extends StatelessWidget {
  const _PetBodyBySpecies({required this.pet, this.size = 260});

  final Pet pet;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (pet.species) {
      case PetSpecies.dog:
        return FullBodyDogWidget(mood: pet.mood, size: size);
      case PetSpecies.cat:
        return cat.FullBodyCatWidget(
          mood: _PetBodyBySpecies._mapToCatMood(pet.mood),
          size: size,
        );
      case PetSpecies.dragon:
        return FullBodyDragonWidget(mood: pet.mood, size: size);
      case PetSpecies.capybara:
        return FullBodyCapybaraWidget(mood: pet.mood, size: size);
    }
  }

  static cat.PetMood _mapToCatMood(PetMood mood) {
    switch (mood) {
      case PetMood.happy:
        return cat.PetMood.happy;
      case PetMood.sad:
      case PetMood.sick:
        return cat.PetMood.sad;
      case PetMood.neutral:
      default:
        return cat.PetMood.idle;
    }
  }
}

class _LoadingPetScreen extends StatelessWidget {
  const _LoadingPetScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorPetScreen extends StatelessWidget {
  const _ErrorPetScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.xp, required this.stage});

  final int xp;
  final PetStage stage;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'XP',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text('$xp', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            Column(
              children: [
                Text(
                  'Estágio',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  _stageLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _stageLabel {
    switch (stage) {
      case PetStage.egg:
        return 'Ovo';
      case PetStage.baby:
        return 'Bebê';
      case PetStage.child:
        return 'Criança';
      case PetStage.teenager:
        return 'Adolescente';
      case PetStage.adult:
        return 'Adulto';
    }
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          FilledButton.icon(
            onPressed: () => context.push('/transactions'),
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Ver Finanças'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => context.push('/goals'),
            icon: const Icon(Icons.flag),
            label: const Text('Ver Metas'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Loja - implementação futura
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Loja'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/education'),
            icon: const Icon(Icons.school),
            label: const Text('Educação Financeira'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}
