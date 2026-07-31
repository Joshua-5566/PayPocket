import '../models/transaction.dart';

abstract interface class TransactionRepository {
  Future<List<ExpenseTransaction>> getAll();
  Future<void> save(ExpenseTransaction transaction);
  Future<void> delete(String id);
  Future<void> update(ExpenseTransaction transaction);
}
