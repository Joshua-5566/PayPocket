import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/shadow_utils.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.transaction});

  final ExpenseTransaction? transaction;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();

  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;
  TransactionCategory? _selectedCategory;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transaction != null;
    if (_isEditing) {
      final tx = widget.transaction!;
      _amountController.text = tx.amount.toString();
      _titleController.text = tx.title;
      _selectedDate = tx.date;
      _selectedType = tx.type;
      _selectedCategory = tx.category;
    }

    _amountFocus.addListener(() {
      if (_amountFocus.hasFocus) _scrollToWidget(_amountFocus);
    });
    _titleFocus.addListener(() {
      if (_titleFocus.hasFocus) _scrollToWidget(_titleFocus);
    });
    _noteFocus.addListener(() {
      if (_noteFocus.hasFocus) _scrollToWidget(_noteFocus);
    });
  }

  void _scrollToWidget(FocusNode focusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = focusNode.context;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    _titleFocus.dispose();
    _noteFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final title = _titleController.text.trim();

    final transaction = ExpenseTransaction(
      id: _isEditing
          ? widget.transaction!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: _selectedType,
      date: _selectedDate,
      icon: _selectedCategory!.icon,
      category: _selectedCategory!,
    );

    final notifier = ref.read(transactionsProvider.notifier);
    if (_isEditing) {
      await notifier.update(transaction);
    } else {
      await notifier.add(transaction);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Transaction updated' : 'Transaction saved'),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? 'Edit ${_selectedType == TransactionType.expense ? 'Expense' : 'Income'}'
            : '${_selectedType == TransactionType.expense ? 'Add' : 'Add'} ${_selectedType == TransactionType.expense ? 'Expense' : 'Income'}'),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _amountController.clear();
                  _titleController.clear();
                  _noteController.clear();
                  _selectedDate = DateTime.now();
                  _selectedType = TransactionType.expense;
                  _selectedCategory = null;
                  _isEditing = false;
                });
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                //  Type 卡片（选择收入/支出）
                _buildSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft, // ✅ 强制左对齐
                        child: SegmentedButton<TransactionType>(
                          segments: const [
                            ButtonSegment(
                              value: TransactionType.expense,
                              label: Text('Expense'),
                              icon: Icon(Icons.arrow_downward, size: 18),
                            ),
                            ButtonSegment(
                              value: TransactionType.income,
                              label: Text('Income'),
                              icon: Icon(Icons.arrow_upward, size: 18),
                            ),
                          ],
                          selected: {_selectedType},
                          onSelectionChanged:
                              (Set<TransactionType> newSelection) {
                            setState(() {
                              _selectedType = newSelection.first;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color?>(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.primary;
                                }
                                return null;
                              },
                            ),
                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color?>(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.white;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ Amount 卡片
                _buildSection(
                  child: TextFormField(
                    controller: _amountController,
                    focusNode: _amountFocus,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefix: const Text('\$ ', style: TextStyle(fontSize: 16)),
                      border: const OutlineInputBorder(),
                      hintText: '0.00',
                      labelText: 'Amount',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),

                // ✅ Title 卡片
                _buildSection(
                  child: TextFormField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Lunch at Cafe',
                      border: OutlineInputBorder(),
                      labelText: 'Title',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ),

                // ✅ Date 卡片
                _buildSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy').format(_selectedDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color:
                                    isDark ? Colors.grey.shade500 : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ Category 卡片
                _buildSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 8,
                          runSpacing: 8,
                          children: TransactionCategory.values.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return ChoiceChip(
                              label: Text(cat.displayName),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected ? cat : null;
                                });
                              },
                              selectedColor: AppColors.primary,
                              backgroundColor: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.grey.shade300
                                        : Colors.black87),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                              avatar: Text(cat.icon,
                                  style: const TextStyle(fontSize: 16)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ Note 卡片
                _buildSection(
                  child: TextFormField(
                    controller: _noteController,
                    focusNode: _noteFocus,
                    decoration: const InputDecoration(
                      hintText: 'Add a note...',
                      border: OutlineInputBorder(),
                      labelText: 'Note (optional)',
                    ),
                    maxLines: 3,
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_isEditing ? 'Update' : 'Save'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 卡片包装器：适配暗黑模式
  Widget _buildSection({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
        boxShadow: context.softShadow,
      ),
      child: child,
    );
  }
}
