import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../data/transaction_repository_impl.dart';
import '../../domain/models/transaction.dart';
import '../providers/finance_provider.dart';

/// Tela para adicionar receita ou despesa.
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _category = 'Outros';
  DateTime _date = DateTime.now();

  static const _categories = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Lazer',
    'Saúde',
    'Educação',
    'Salário',
    'Freelance',
    'Outros',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor deve ser maior que zero')),
      );
      return;
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      type: _type,
      category: _category,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      date: _date,
    );

    final repo = ref.read(transactionRepositoryProvider);
    await repo.addTransaction(transaction);

    ref.invalidate(transactionsProvider);
    ref.invalidate(transactionsByMonthProvider(DateTime(_date.year, _date.month)));

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova transação')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.income,
                    icon: Icon(Icons.arrow_downward),
                    label: Text('Receita'),
                  ),
                  ButtonSegment(
                    value: TransactionType.expense,
                    icon: Icon(Icons.arrow_upward),
                    label: Text('Despesa'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
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
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data'),
                subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
