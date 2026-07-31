import 'package:go_router/go_router.dart';

import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/dashboard/screens/splash_screen.dart';
import '../features/transaction/screens/add_transaction_screen.dart';
import '../features/transaction/screens/transaction_history_screen.dart';
import '../features/analytics/screens/analytics_screen.dart';
import '../features/settings/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
