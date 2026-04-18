import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF10B981);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD1FAE5);
  static const Color onPrimaryContainer = Color(0xFF065F46);

  // Secondary
  static const Color secondary = Color(0xFF6366F1);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Surface
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF111827);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // Background
  static const Color background = Color(0xFFF9FAFB);
  static const Color onBackground = Color(0xFF111827);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Neutral
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral900 = Color(0xFF111827);

  // Dark theme surfaces
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color onSurfaceDark = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF111827);
}
