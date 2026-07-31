import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transaction/models/transaction.dart';
import '../../transaction/providers/transaction_provider.dart';

final totalIncomeProvider = Provider<double>((ref) {
  final txs = ref.watch(transactionsProvider);
  return txs
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  final txs = ref.watch(transactionsProvider);
  return txs
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);
  return income - expense;
});
