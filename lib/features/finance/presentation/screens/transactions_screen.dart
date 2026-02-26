import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/transaction.dart';
import '../providers/finance_provider.dart';
import '../../../../core/utils/date_utils.dart' as app_utils;

/// Tela de listagem de transações.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () => context.push('/goals'),
            tooltip: 'Metas',
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma transação registrada',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          final sorted =
              List<Transaction>.from(transactions)..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final t = sorted[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    t.type == TransactionType.income
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: t.type == TransactionType.income
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(t.category),
                  subtitle: Text(app_utils.AppDateUtils.formatDate(t.date)),
                  trailing: Text(
                    '${t.type == TransactionType.income ? '+' : '-'} ${app_utils.AppDateUtils.formatCurrency(t.amount)}',
                    style: TextStyle(
                      color: t.type == TransactionType.income
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
