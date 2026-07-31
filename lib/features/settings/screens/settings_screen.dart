import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/shadow_utils.dart';
import '../../transaction/providers/transaction_provider.dart';
import '../../transaction/models/transaction.dart';
import '../services/export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final transactions = ref.watch(transactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionHeader(context, 'Appearance'),
            _buildCard(
              context,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    subtitle: Text(
                      'Switch between light and dark theme',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primary,
                    ),
                    value: isDarkMode,
                    onChanged: (value) {
                      ref.read(darkModeProvider.notifier).state = value;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Preferences'),
            _buildCard(
              context,
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.language, color: AppColors.primary),
                    title: Text(
                      'Language',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    subtitle: Text(
                      'English',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Language selection coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Data Management'),
            _buildCard(
              context,
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.download, color: AppColors.primary),
                    title: Text(
                      'Export to CSV',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    subtitle: Text(
                      'Export all transactions as CSV file',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                    onTap: () => _exportToCSV(context, transactions),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.delete_outline, color: Colors.red),
                    title: Text(
                      'Clear All Data',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    subtitle: Text(
                      'Delete all transactions permanently',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                    onTap: () => _confirmClearData(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'About'),
            _buildCard(
              context,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline,
                        color: AppColors.primary),
                    title: Text(
                      'About PocketPay',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    subtitle: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.feedback, color: AppColors.primary),
                    title: Text(
                      'Feedback',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    subtitle: Text(
                      'Share your feedback with us',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback feature coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'PocketPay v1.0.0',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey.shade400 : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: context.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }

  //
  void _exportToCSV(
      BuildContext context, List<ExpenseTransaction> transactions) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No transactions to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      await exportToCSV(transactions);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Exported ${transactions.length} transactions'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error exporting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmClearData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your transactions. This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final transactions = ref.read(transactionsProvider);
        final notifier = ref.read(transactionsProvider.notifier);
        for (var tx in transactions) {
          await notifier.delete(tx.id);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About PocketPay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PocketPay v1.0.0',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'A personal expense tracker built with Flutter.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              '• Track income and expenses\n'
              '• Categorize transactions\n'
              '• View spending analytics\n'
              '• Dark mode support\n'
              '• Offline storage with Hive',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.code,
                  size: 16,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'First Flutter Project',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Dark Mode Provider
final darkModeProvider = StateProvider<bool>((ref) => false);
