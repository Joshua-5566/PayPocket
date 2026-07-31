import 'package:hive/hive.dart';
import '../features/transaction/models/transaction.dart';
import '../features/transaction/repository/transaction_repository.dart';

class HiveTransactionRepository implements TransactionRepository {
  static const String _boxName = 'transactions';

  Future<Box<ExpenseTransaction>> _getBox() async {
    return await Hive.openBox<ExpenseTransaction>(_boxName);
  }

  @override
  Future<List<ExpenseTransaction>> getAll() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<void> save(ExpenseTransaction transaction) async {
    final box = await _getBox();
    await box.put(transaction.id, transaction);
  }

  @override
  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<void> update(ExpenseTransaction transaction) async {
    final box = await _getBox();
    await box.put(transaction.id, transaction);
  }
}