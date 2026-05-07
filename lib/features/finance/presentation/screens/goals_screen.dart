import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/goal_repository_impl.dart';
import '../../domain/models/goal.dart';
import '../providers/finance_provider.dart';
import '../../../../core/utils/date_utils.dart' as app_utils;

/// Tela de metas de economia.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de economia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/goals/add'),
          ),
        ],
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma meta definida',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Defina metas para acompanhar sua economia',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            goal.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (goal.isMonthly)
                            Chip(
                              label: const Text('Mensal'),
                              labelStyle: Theme.of(context).textTheme.labelSmall,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${app_utils.AppDateUtils.formatCurrency(goal.currentAmount)} / ${app_utils.AppDateUtils.formatCurrency(goal.targetAmount)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                _showAddAmountDialog(context, ref, goal),
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar valor'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/goals/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> _showAddAmountDialog(
  BuildContext context,
  WidgetRef ref,
  Goal goal,
) async {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Adicionar valor à meta "${goal.title}"'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Valor a adicionar (R\$)',
              prefixText: 'R\$ ',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Digite um valor';
              }
              final n = double.tryParse(v.replaceAll(',', '.'));
              if (n == null || n <= 0) {
                return 'Valor inválido';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              final value = double.tryParse(
                    controller.text.replaceAll(',', '.'),
                  ) ??
                  0;
              if (value <= 0) return;

              final newAmount = (goal.currentAmount + value)
                  .clamp(0.0, goal.targetAmount);

              final repo = ref.read(goalRepositoryProvider);
              await repo.saveGoal(
                goal.copyWith(currentAmount: newAmount),
              );

              ref.invalidate(goalsProvider);
              ref.invalidate(activeMonthlyGoalProvider);

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      );
    },
  );
}
