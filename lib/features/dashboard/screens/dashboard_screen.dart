import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/shadow_utils.dart';
import '../../transaction/providers/transaction_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final balance = ref.watch(balanceProvider);
    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                ),
              ],
            ),
            const SizedBox(height: 24),
            BalanceCard(balance: balance),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Income',
                    amount: income,
                    color: AppColors.income,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    label: 'Expense',
                    amount: expense,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...transactions.map(
              (tx) => TransactionTile(transaction: tx),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) context.push('/history');
          if (index == 2) context.push('/analytics');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

// ✅ _SummaryCard 已适配暗黑模式
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: context.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
