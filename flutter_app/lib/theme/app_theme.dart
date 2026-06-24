import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/project_ledger.dart';

abstract final class AppTheme {
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color accent = Colors.black;

  static ThemeData light() {
    final mono = GoogleFonts.ibmPlexMonoTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
        surface: surface,
      ),
      textTheme: mono.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: textPrimary,
        titleTextStyle: mono.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      dividerColor: border,
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: border),
        ),
      ),
    );
  }

  static Color statusColor(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.ongoing => textPrimary,
      ProjectStatus.delayed => const Color(0xFFB45309),
      ProjectStatus.completed => const Color(0xFF047857),
      ProjectStatus.stalled => const Color(0xFFB91C1C),
      ProjectStatus.unknown => textMuted,
    };
  }
}
