import 'category.dart';

enum TransactionType { income, expense }

class ExpenseTransaction {
  const ExpenseTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.icon,
    required this.category, // new field
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String icon; // we might still keep it or derive from category
  final TransactionCategory category;
}
