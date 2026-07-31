import 'package:flutter/material.dart';

extension ShadowExtension on BuildContext {
  List<BoxShadow> get softShadow {
    final isLight = Theme.of(this).brightness == Brightness.light;
    final color = isLight
        ? Theme.of(this).colorScheme.primary.withValues(alpha: 0.2) // 略微提高不透明度
        : Colors.white.withValues(alpha: 0.08);
    return [
      BoxShadow(
        color: color,
        blurRadius: 14,
        offset: const Offset(0, 4),
        spreadRadius: -2,
      ),
    ];
  }
}
