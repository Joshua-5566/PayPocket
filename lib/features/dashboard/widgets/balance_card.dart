import 'package:flutter/material.dart';
import '../../../core/utils/shadow_utils.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // 动态获取卡片背景色
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
        boxShadow: context.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balance',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${balance.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
