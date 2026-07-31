import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/settings/screens/settings_screen.dart';
import 'routes/app_router.dart';

class PocketPayApp extends ConsumerWidget {
  const PocketPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);

    return MaterialApp.router(
      title: 'PocketPay',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? AppTheme.dark : AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
