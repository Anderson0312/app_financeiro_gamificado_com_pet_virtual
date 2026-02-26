import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/pet_service.dart';
import '../../../finance/domain/models/transaction.dart';
import '../../../finance/domain/models/goal.dart';
import '../../../finance/presentation/providers/finance_provider.dart';

/// Provedor que calcula a saúde financeira (0.0 a 1.0) com base em
/// metas e transações do mês atual.
final financialHealthProvider = Provider<double>((ref) {
  final month = DateTime(DateTime.now().year, DateTime.now().month);
  final transactionsAsync = ref.watch(transactionsByMonthProvider(month));
  final goalAsync = ref.watch(activeMonthlyGoalProvider);

  final transactions = transactionsAsync.valueOrNull ?? [];
  final goal = goalAsync.valueOrNull;

  if (transactionsAsync.isLoading || goalAsync.isLoading) {
    return 0.5;
  }

  return _computeHealth(transactions, goal);
});

double _computeHealth(List<Transaction> transactions, Goal? goal) {
  final income = transactions
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0, (s, t) => s + t.amount);
  final expense = transactions
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0, (s, t) => s + t.amount);

  double goalProgress = 0.5;
  if (goal != null && goal.targetAmount > 0) {
    goalProgress = goal.progress;
  }

  // overspendRatio: 1 = gastou tudo e mais; 0 = não gastou nada
  double overspendRatio = 0;
  if (income > 0) {
    overspendRatio = (expense / income).clamp(0.0, 1.5);
    if (overspendRatio > 1) overspendRatio = 1; // penalizar fortemente
  }

  return PetService.computeFinancialHealth(
    goalProgress: goalProgress,
    overspendRatio: overspendRatio,
  );
}
