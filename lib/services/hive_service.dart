import 'package:hive_flutter/hive_flutter.dart';
import '../core/adapters/transaction_adapter.dart';
import '../features/transaction/models/transaction.dart';

class HiveService {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter()); // Register the adapter
    await Hive.openBox<ExpenseTransaction>(
        'transactions'); // Now the type is known
  }
}
