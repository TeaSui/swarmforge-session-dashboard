import 'package:flutter/material.dart';

class DashboardTheme {
  static ThemeData build() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      useMaterial3: true,
    );
  }
}
