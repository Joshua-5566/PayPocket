import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../repository/transaction_repository.dart';
import 'transaction_notifier.dart';
import '/services/hive_transaction_repository.dart';

// Provide the repository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return HiveTransactionRepository();
});

// StateNotifier provider for transactions
final transactionsProvider =
    StateNotifierProvider<TransactionNotifier, List<ExpenseTransaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repo);
});

final loadTransactionsProvider = FutureProvider<void>((ref) async {
  final notifier = ref.watch(transactionsProvider.notifier);
  await notifier.load();
});
