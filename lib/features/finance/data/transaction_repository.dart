import '../domain/models/transaction.dart';

/// Repositório de transações.
abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<List<Transaction>> getTransactionsByMonth(DateTime month);
  Future<void> addTransaction(Transaction transaction);
  Future<void> removeTransaction(String id);
}
