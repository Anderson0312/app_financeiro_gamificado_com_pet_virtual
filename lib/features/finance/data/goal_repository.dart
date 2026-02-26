import '../domain/models/goal.dart';

/// Repositório de metas.
abstract class GoalRepository {
  Future<List<Goal>> getGoals();
  Future<Goal?> getActiveMonthlyGoal();
  Future<void> saveGoal(Goal goal);
  Future<void> removeGoal(String id);
}
