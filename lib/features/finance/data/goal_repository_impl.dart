import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/providers/app_providers.dart';
import 'goal_repository.dart';
import '../domain/models/goal.dart';

const _goalsKey = 'goals_data';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GoalRepositoryImpl(prefs);
});

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  List<Goal> _parseGoals(String? json) {
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveGoals(List<Goal> list) async {
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_goalsKey, encoded);
  }

  @override
  Future<List<Goal>> getGoals() async {
    return _parseGoals(_prefs.getString(_goalsKey));
  }

  @override
  Future<Goal?> getActiveMonthlyGoal() async {
    final goals = await getGoals();
    final now = DateTime.now();
    try {
      return goals.firstWhere(
        (g) => g.isMonthly && (g.deadline == null || g.deadline!.isAfter(now)),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    final list = await getGoals();
    final idx = list.indexWhere((g) => g.id == goal.id);
    if (idx >= 0) {
      list[idx] = goal;
    } else {
      list.add(goal);
    }
    await _saveGoals(list);
  }

  @override
  Future<void> removeGoal(String id) async {
    final list = await getGoals();
    list.removeWhere((g) => g.id == id);
    await _saveGoals(list);
  }
}
