import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(radius: 34, backgroundColor: AppColors.primary, child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 34)),
            SizedBox(height: 16),
            Text('PocketPay', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.ink)),
            SizedBox(height: 6),
            Text('Your money, clearly.', style: TextStyle(color: AppColors.muted)),
          ]),
        ),
      );
}
