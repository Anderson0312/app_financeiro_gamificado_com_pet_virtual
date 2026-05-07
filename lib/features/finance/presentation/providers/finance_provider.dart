import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/goal_repository_impl.dart';
import '../../data/transaction_repository_impl.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/transaction.dart';

final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactions();
});

final transactionsByMonthProvider =
    FutureProvider.family<List<Transaction>, DateTime>((ref, month) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionsByMonth(month);
});

final goalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.getGoals();
});

final activeMonthlyGoalProvider = FutureProvider<Goal?>((ref) async {
  final repo = ref.watch(goalRepositoryProvider);
  final goal = await repo.getActiveMonthlyGoal();
  if (goal == null) return null;

  final now = DateTime.now();
  final month = DateTime(now.year, now.month);
  final transactions = await ref.read(transactionsByMonthProvider(month).future);
  final income = transactions
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0, (s, t) => s + t.amount);
  final expense = transactions
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0, (s, t) => s + t.amount);
  final currentAmount = (income - expense).clamp(0.0, double.infinity);

  return goal.copyWith(currentAmount: currentAmount);
});

class FinancialSummary {
  const FinancialSummary({
    required this.incomeTotal,
    required this.expenseTotal,
    required this.balance,
  });

  final double incomeTotal;
  final double expenseTotal;
  final double balance;
}

enum TransactionFilterPeriod {
  all,
  thisMonth,
}

final transactionFilterPeriodProvider =
    StateProvider<TransactionFilterPeriod>((ref) {
  return TransactionFilterPeriod.all;
});

final financialSummaryProvider =
    Provider<AsyncValue<FinancialSummary>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.whenData((transactions) {
    final incomeTotal = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expenseTotal = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final balance = incomeTotal - expenseTotal;

    return FinancialSummary(
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
      balance: balance,
    );
  });
});
