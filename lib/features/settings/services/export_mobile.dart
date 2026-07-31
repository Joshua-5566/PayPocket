// 移动端/桌面端的导出实现
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../transaction/models/transaction.dart';
import '../../transaction/models/category.dart'; 

String _buildCSVContent(List<ExpenseTransaction> transactions) {
  String csv = 'Date,Type,Category,Title,Amount\n';
  for (var tx in transactions) {
    final date = DateFormat('yyyy-MM-dd HH:mm').format(tx.date.toLocal());
    csv +=
        '$date,${tx.type.name},${tx.category.displayName},${tx.title},\$${tx.amount.toStringAsFixed(2)}\n';
  }
  return csv;
}

Future<void> exportToCSV(List<ExpenseTransaction> transactions) async {
  final csv = _buildCSVContent(transactions);
  final directory = await getTemporaryDirectory();
  final fileName = 'transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
  final file = File('${directory.path}/$fileName');
  final bytes = utf8.encode('\uFEFF' + csv);
  await file.writeAsBytes(bytes);

  await Share.shareXFiles(
    [XFile(file.path)],
    text: '📊 Here are my transactions from PocketPay',
  );
}
