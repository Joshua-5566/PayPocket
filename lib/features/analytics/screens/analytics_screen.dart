import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/shadow_utils.dart';
import '../../transaction/models/transaction.dart';
import '../../transaction/models/category.dart';
import '../../transaction/providers/transaction_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(transactionsProvider);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final monthTransactions = allTransactions
        .where((t) =>
            t.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
            t.date.isBefore(monthEnd.add(const Duration(days: 1))))
        .toList();

    final monthIncome = monthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final monthExpense = monthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final netChange = monthIncome - monthExpense;

    // 按类别汇总支出
    final expenseByCategory = <TransactionCategory, double>{};
    for (var tx
        in monthTransactions.where((t) => t.type == TransactionType.expense)) {
      expenseByCategory[tx.category] =
          (expenseByCategory[tx.category] ?? 0) + tx.amount;
    }

    // 排序：从大到小
    final sortedEntries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 生成饼图数据
    final List<PieChartSectionData> pieSections = [];
    final List<Map<String, dynamic>> legendData = [];

    for (var entry in sortedEntries) {
      final color = _getCategoryColor(entry.key);
      final percentage = (entry.value / monthExpense * 100);
      pieSections.add(
        PieChartSectionData(
          value: entry.value,
          title: '${percentage.toStringAsFixed(0)}%',
          color: color,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      legendData.add({
        'label': entry.key.displayName,
        'color': color,
        'percentage': percentage,
      });
    }

    // 最近7天收支趋势
    final last7Days =
        List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final dailyIncome = <double>[];
    final dailyExpense = <double>[];
    for (var day in last7Days) {
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final dayTxs = allTransactions
          .where((t) =>
              t.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(dayEnd))
          .toList();
      dailyIncome.add(dayTxs
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount));
      dailyExpense.add(dayTxs
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 摘要卡片
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Income',
                    amount: monthIncome,
                    color: AppColors.income,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Expense',
                    amount: monthExpense,
                    color: AppColors.expense,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Net',
                    amount: netChange,
                    color:
                        netChange >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 支出饼图 + 图例
            if (pieSections.isNotEmpty) ...[
              const Text(
                'Expense by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildPieChartWithLegend(context, pieSections, legendData),
            ] else ...[
              _buildEmptyState(context, 'No expenses this month'),
            ],
            const SizedBox(height: 24),

            // 趋势柱状图
            const Text(
              'Daily Trend (Last 7 Days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _buildBarChart(context, last7Days, dailyIncome, dailyExpense),
          ],
        ),
      ),
    );
  }

  // 饼图 + 图例
  Widget _buildPieChartWithLegend(
    BuildContext context,
    List<PieChartSectionData> sections,
    List<Map<String, dynamic>> legendData,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: context.softShadow,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 图例
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: legendData.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item['label']} (${item['percentage'].toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    BuildContext context,
    List<DateTime> days,
    List<double> incomes,
    List<double> expenses,
  ) {
    final allValues = [...incomes, ...expenses];
    final maxValue =
        allValues.isNotEmpty ? allValues.reduce((a, b) => a > b ? a : b) : 0;
    final double maxY = maxValue * 1.2; // ✅ 必须声明 maxY

    return Container(
      height: 250,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade200,
        ),
        boxShadow: context.softShadow,
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY > 0 ? maxY : 100, // ✅ 使用 maxY
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('dd').format(days[index]),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: false),
          barGroups: List.generate(days.length, (i) {
            return BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: incomes[i],
                  color: AppColors.income,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: expenses[i],
                  color: AppColors.expense,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

// 空状态
  Widget _buildEmptyState(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: context.softShadow,
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  // ✅ 改进的颜色分配 - 每个类别有独特的颜色
  Color _getCategoryColor(TransactionCategory category) {
    const colors = {
      TransactionCategory.food: Color(0xFFFF6B6B),
      TransactionCategory.groceries: Color(0xFF4ECDC4),
      TransactionCategory.travel: Color(0xFF45B7D1),
      TransactionCategory.transport: Color(0xFF96CEB4),
      TransactionCategory.bills: Color(0xFFFFEAA7),
      TransactionCategory.utilities: Color(0xFFDDA0DD),
      TransactionCategory.shopping: Color(0xFFF7DC6F),
      TransactionCategory.entertainment: Color(0xFFBB8FCE),
      TransactionCategory.subscriptions: Color(0xFF85C1E9),
      TransactionCategory.salary: Color(0xFF58D68D),
    };
    return colors[category] ?? Colors.grey;
  }
}

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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // ✅ 动态获取
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: context.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
