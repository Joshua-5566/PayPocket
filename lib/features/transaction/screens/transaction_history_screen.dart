import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/shadow_utils.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  String _searchQuery = '';
  TransactionCategory? _selectedCategory;
  TransactionType? _selectedType;

  List<ExpenseTransaction> _filterTransactions(List<ExpenseTransaction> all) {
    var filtered = all;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
              (t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategory != null) {
      filtered =
          filtered.where((t) => t.category == _selectedCategory).toList();
    }

    if (_selectedType != null) {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Map<String, List<ExpenseTransaction>> _groupByDate(
      List<ExpenseTransaction> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<ExpenseTransaction>> groups = {};

    for (var tx in transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String label;
      if (txDate == today) {
        label = 'Today';
      } else if (txDate == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('dd MMM yyyy').format(txDate);
      }
      groups.putIfAbsent(label, () => []).add(tx);
    }
    return groups;
  }

  Future<void> _deleteTransaction(String id) async {
    await ref.read(transactionsProvider.notifier).delete(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editTransaction(ExpenseTransaction tx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: tx),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TransactionCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return FilterChip(
                      label: Text(cat.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setStateModal(() {
                          _selectedCategory = selected ? cat : null;
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Type',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Income'),
                      selected: _selectedType == TransactionType.income,
                      onSelected: (selected) {
                        setStateModal(() {
                          _selectedType =
                              selected ? TransactionType.income : null;
                        });
                      },
                      selectedColor: AppColors.income.withOpacity(0.2),
                      checkmarkColor: AppColors.income,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Expense'),
                      selected: _selectedType == TransactionType.expense,
                      onSelected: (selected) {
                        setStateModal(() {
                          _selectedType =
                              selected ? TransactionType.expense : null;
                        });
                      },
                      selectedColor: AppColors.expense.withOpacity(0.2),
                      checkmarkColor: AppColors.expense,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setStateModal(() {
                          _selectedCategory = null;
                          _selectedType = null;
                        });
                      },
                      child: const Text('Clear all'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionsProvider);
    final filtered = _filterTransactions(allTransactions);
    final grouped = _groupByDate(filtered);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ 搜索框 - 适配暗黑模式
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
                boxShadow: context.softShadow,
              ),
              child: TextField(
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey.shade500 : Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          if (_selectedCategory != null || _selectedType != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Filters:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_selectedCategory != null)
                    Chip(
                      label: Text(_selectedCategory!.displayName),
                      onDeleted: () {
                        setState(() => _selectedCategory = null);
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  if (_selectedType != null)
                    Chip(
                      label: Text(
                        _selectedType == TransactionType.income
                            ? 'Income'
                            : 'Expense',
                      ),
                      onDeleted: () {
                        setState(() => _selectedType = null);
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                      backgroundColor: _selectedType == TransactionType.income
                          ? AppColors.income.withOpacity(0.1)
                          : AppColors.expense.withOpacity(0.1),
                    ),
                ],
              ),
            ),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(context)
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color:
                                    isDark ? Colors.grey.shade400 : Colors.grey,
                              ),
                            ),
                          ),
                          ...entry.value.map((tx) {
                            return Dismissible(
                              key: Key(tx.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Transaction'),
                                    content: const Text(
                                        'Are you sure you want to delete this transaction?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(
                                            foregroundColor: Colors.red),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                return confirmed ?? false;
                              },
                              onDismissed: (direction) {
                                _deleteTransaction(tx.id);
                              },
                              child: _buildTransactionItem(context, tx),
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // ✅ 空状态 - 适配暗黑模式
  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction by tapping the + button',
            style: TextStyle(
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ 交易项卡片 - 适配暗黑模式
  Widget _buildTransactionItem(BuildContext context, ExpenseTransaction tx) {
    final isIncome = tx.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: context.softShadow,
      ),
      child: InkWell(
        onTap: () => _editTransaction(tx),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tx.category.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.category.displayName,
                    style: TextStyle(
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
