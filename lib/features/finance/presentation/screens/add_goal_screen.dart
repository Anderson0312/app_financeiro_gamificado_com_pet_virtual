import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../data/goal_repository_impl.dart';
import '../../domain/models/goal.dart';
import '../providers/finance_provider.dart';

/// Tela para criar meta de economia.
class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();

  bool _isMonthly = true;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final target = double.tryParse(_targetController.text.replaceAll(',', '.')) ?? 0;
    if (target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meta deve ser maior que zero')),
      );
      return;
    }

    final goal = Goal(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      targetAmount: target,
      currentAmount: 0,
      isMonthly: _isMonthly,
      deadline: _isMonthly ? _endOfCurrentMonth() : null,
    );

    final repo = ref.read(goalRepositoryProvider);
    await repo.saveGoal(goal);

    ref.invalidate(goalsProvider);
    ref.invalidate(activeMonthlyGoalProvider);

    if (mounted) context.pop();
  }

  DateTime _endOfCurrentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova meta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nome da meta',
                  hintText: 'Ex: Reserva de emergência',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Digite o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor alvo (R\$)',
                  prefixText: 'R\$ ',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Digite o valor';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Meta mensal'),
                subtitle: const Text('Renova a cada mês'),
                value: _isMonthly,
                onChanged: (v) => setState(() => _isMonthly = v),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Criar meta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
