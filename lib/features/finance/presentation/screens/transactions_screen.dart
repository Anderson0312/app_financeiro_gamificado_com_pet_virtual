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
    final summaryAsync = ref.watch(financialSummaryProvider);
    final filterPeriod = ref.watch(transactionFilterPeriodProvider);

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
          final theme = Theme.of(context);

          final now = DateTime.now();
          final startOfThisMonth = DateTime(now.year, now.month, 1);
          final isThisMonthFilter = filterPeriod == TransactionFilterPeriod.thisMonth;

          final filtered = isThisMonthFilter
              ? transactions
                  .where((t) => !t.date.isBefore(startOfThisMonth))
                  .toList()
              : List<Transaction>.from(transactions);

          filtered.sort((a, b) => b.date.compareTo(a.date));

          if (transactions.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SummaryCard(summaryAsync: summaryAsync),
                  const SizedBox(height: 32),
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma transação registrada',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comece registrando sua primeira receita ou despesa para acompanhar suas finanças.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/transactions/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar primeira transação'),
                  ),
                ],
              ),
            );
          }

          final groupedByDate = <DateTime, List<Transaction>>{};
          for (final t in filtered) {
            final key = DateTime(t.date.year, t.date.month, t.date.day);
            groupedByDate.putIfAbsent(key, () => []).add(t);
          }

          final sortedDates = groupedByDate.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          final items = <_TransactionListItem>[];
          for (final date in sortedDates) {
            items.add(_TransactionListItem.header(date));
            for (final t in groupedByDate[date]!) {
              items.add(_TransactionListItem.transaction(t));
            }
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SummaryCard(summaryAsync: summaryAsync),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ToggleButtons(
                        isSelected: [
                          filterPeriod == TransactionFilterPeriod.all,
                          filterPeriod == TransactionFilterPeriod.thisMonth,
                        ],
                        onPressed: (index) {
                          final value = index == 0
                              ? TransactionFilterPeriod.all
                              : TransactionFilterPeriod.thisMonth;
                          ref
                              .read(transactionFilterPeriodProvider.notifier)
                              .state = value;
                        },
                        borderRadius: BorderRadius.circular(16),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text('Todos'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text('Este mês'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Não há transações para o período selecionado.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return switch (item.type) {
                        _TransactionListItemType.header => Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 4,
                            ),
                            child: Text(
                              app_utils.AppDateUtils.formatDate(item.date!),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        _TransactionListItemType.transaction => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                item.transaction!.type ==
                                        TransactionType.income
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: item.transaction!.type ==
                                        TransactionType.income
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(item.transaction!.category),
                              subtitle: Text(
                                app_utils.AppDateUtils
                                    .formatDate(item.transaction!.date),
                              ),
                              trailing: Text(
                                '${item.transaction!.type == TransactionType.income ? '+' : '-'} ${app_utils.AppDateUtils.formatCurrency(item.transaction!.amount)}',
                                style: TextStyle(
                                  color: item.transaction!.type ==
                                          TransactionType.income
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      };
                    },
                  ),
                ),
            ],
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summaryAsync,
  });

  final AsyncValue<FinancialSummary> summaryAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return summaryAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Text('Erro ao carregar saldo: $e'),
      data: (summary) {
        final isPositive = summary.balance >= 0;
        final balanceColor =
            isPositive ? Colors.green : Colors.red;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                theme.colorScheme.surfaceVariant.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo atual',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                app_utils.AppDateUtils.formatCurrency(
                  summary.balance.abs(),
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: balanceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryValue(
                    label: 'Receitas',
                    value: app_utils.AppDateUtils
                        .formatCurrency(summary.incomeTotal),
                    color: Colors.green,
                  ),
                  _SummaryValue(
                    label: 'Despesas',
                    value: app_utils.AppDateUtils
                        .formatCurrency(summary.expenseTotal),
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

enum _TransactionListItemType {
  header,
  transaction,
}

class _TransactionListItem {
  _TransactionListItem.header(this.date)
      : type = _TransactionListItemType.header,
        transaction = null;

  _TransactionListItem.transaction(this.transaction)
      : type = _TransactionListItemType.transaction,
        date = null;

  final _TransactionListItemType type;
  final DateTime? date;
  final Transaction? transaction;
}
