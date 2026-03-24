import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF1A73E8);
  static const secondary = Color(0xFF34A853);

  // Urgency
  static const urgencyHigh = Colors.red;
  static const urgencyMedium = Colors.orange;
  static const urgencyLow = Colors.green;

  // Status
  static const successBackground = Color(0xFFE8F5E9);
  static const successForeground = Color(0xFF43A047);

  // Shadow
  static const shadow = Color(0x0D000000);

  static Color urgencyColor(String level) {
    switch (level) {
      case 'high':
        return urgencyHigh;
      case 'medium':
        return urgencyMedium;
      default:
        return urgencyLow;
    }
  }
}
