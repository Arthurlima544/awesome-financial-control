import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.neutral200),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        error: AppColors.error,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.onSurfaceDark,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        titleSmall: AppTextStyles.titleSmall.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.neutral400,
        ),
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColors.neutral400,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.neutral800),
        ),
      ),
    );
  }
}
