enum TransactionCategory {
  food,
  groceries,
  travel,
  transport,
  bills,
  utilities,
  shopping,
  entertainment,
  subscriptions,
  salary,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    switch (this) {
      case TransactionCategory.food:
        return 'Food';
      case TransactionCategory.groceries:
        return 'Groceries';
      case TransactionCategory.travel:
        return 'Travel';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.bills:
        return 'Bills';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.subscriptions:
        return 'Subscriptions';
      case TransactionCategory.salary:
        return 'Salary';
    }
  }

  String get icon {
    switch (this) {
      case TransactionCategory.food:
        return '🍔';
      case TransactionCategory.groceries:
        return '🛒';
      case TransactionCategory.travel:
        return '✈️';
      case TransactionCategory.transport:
        return '🚗';
      case TransactionCategory.bills:
        return '📄';
      case TransactionCategory.utilities:
        return '💡';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.entertainment:
        return '🎬';
      case TransactionCategory.subscriptions:
        return '📺';
      case TransactionCategory.salary:
        return '💰';
    }
  }
}
