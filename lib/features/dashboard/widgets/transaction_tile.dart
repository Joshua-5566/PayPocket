import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/shadow_utils.dart';
import '../../transaction/models/category.dart';
import '../../transaction/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final ExpenseTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          // 类别图标（圆形背景）
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: context.softShadow,
            ),
            child: Text(transaction.category.icon,
                style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          // 中间：标题 + 类别名称
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  transaction.category.displayName,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // 金额
          Text(
            '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
