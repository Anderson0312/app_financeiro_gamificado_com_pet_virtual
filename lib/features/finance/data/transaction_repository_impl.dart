import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/providers/app_providers.dart';
import 'transaction_repository.dart';
import '../domain/models/transaction.dart';

const _transactionsKey = 'transactions_data';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TransactionRepositoryImpl(prefs);
});

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  List<Transaction> _parseTransactions(String? json) {
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveTransactions(List<Transaction> list) async {
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_transactionsKey, encoded);
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    return _parseTransactions(_prefs.getString(_transactionsKey));
  }

  @override
  Future<List<Transaction>> getTransactionsByMonth(DateTime month) async {
    final all = await getTransactions();
    return all.where((t) {
      return t.date.year == month.year && t.date.month == month.month;
    }).toList();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final list = await getTransactions();
    list.add(transaction);
    await _saveTransactions(list);
  }

  @override
  Future<void> removeTransaction(String id) async {
    final list = await getTransactions();
    list.removeWhere((t) => t.id == id);
    await _saveTransactions(list);
  }
}
