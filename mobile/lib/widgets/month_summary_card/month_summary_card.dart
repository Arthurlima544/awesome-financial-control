import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';

class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.savingsRate,
    this.onViewReport,
  });

  final String totalIncome;
  final String totalExpenses;
  final int savingsRate;
  final VoidCallback? onViewReport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final insightText = _getInsightText(l10n);
    final insightColor = _getInsightColor();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(
          color: isDark ? AppColors.neutral800 : AppColors.neutral200,
        ),
      ),
      elevation: 0,
      color: isDark ? AppColors.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SavingsRing(rate: savingsRate),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeSavingsRate,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      Text(
                        '$savingsRate%',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onViewReport != null)
                  TextButton(
                    onPressed: onViewReport,
                    child: Text(
                      l10n.homeViewReport,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            Row(
              children: [
                _AmountColumn(
                  label: l10n.homeTotalIncome,
                  amount: totalIncome,
                  color: AppColors.success,
                  icon: Icons.trending_up,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                ),
                _AmountColumn(
                  label: l10n.homeTotalExpenses,
                  amount: totalExpenses,
                  color: AppColors.error,
                  icon: Icons.trending_down,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: insightColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    color: insightColor,
                    size: AppSpacing.iconSm,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      insightText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: insightColor,
                        fontWeight: FontWeight.w500,
                      ),
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

  String _getInsightText(AppLocalizations l10n) {
    if (savingsRate >= 30) {
      return l10n.homeInsightExcellent(savingsRate.toString());
    } else if (savingsRate >= 10) {
      return l10n.homeInsightGood(savingsRate.toString());
    } else {
      return l10n.homeInsightAttention(savingsRate.toString());
    }
  }

  Color _getInsightColor() {
    if (savingsRate >= 30) {
      return AppColors.success;
    } else if (savingsRate >= 10) {
      return AppColors.primary;
    } else {
      return AppColors.warning;
    }
  }
}

class _SavingsRing extends StatelessWidget {
  const _SavingsRing({required this.rate});

  final int rate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 6,
            color: AppColors.neutral200,
          ),
          CircularProgressIndicator(
            value: rate / 100,
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
            color: AppColors.primary,
          ),
          Icon(
            Icons.savings_outlined,
            color: AppColors.primary,
            size: AppSpacing.iconMd,
          ),
        ],
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
