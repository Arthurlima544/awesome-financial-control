import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';

enum InsightVariant { success, info, warning, error }

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.variant = InsightVariant.info,
  });

  final String title;
  final String message;
  final IconData icon;
  final InsightVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = _getVariantColor();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      color: color.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: AppSpacing.iconSm),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.onSurface
                          : AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.neutral400
                          : AppColors.neutral700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getVariantColor() {
    switch (variant) {
      case InsightVariant.success:
        return AppColors.success;
      case InsightVariant.info:
        return AppColors.primary;
      case InsightVariant.warning:
        return AppColors.warning;
      case InsightVariant.error:
        return AppColors.error;
    }
  }
}
