// Web 平台的导出实现
import 'dart:html' as html;
import 'dart:convert';
import 'package:intl/intl.dart';
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
  final bytes = utf8.encode('\uFEFF' + csv);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute(
        'download', 'transactions_${DateTime.now().millisecondsSinceEpoch}.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}
