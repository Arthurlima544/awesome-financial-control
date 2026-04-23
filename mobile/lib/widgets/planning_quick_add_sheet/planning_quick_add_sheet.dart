import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/utils/config/app_icons.dart';

class PlanningQuickAddSheet extends StatelessWidget {
  const PlanningQuickAddSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(l10n.add, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          _QuickAddOption(
            icon: AppIcons.limits,
            title: l10n.limitTitle,
            onTap: () {
              Navigator.pop(context);
              context.push('/limits/manage');
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _QuickAddOption(
            icon: AppIcons.goals,
            title: l10n.goalsTitle,
            onTap: () {
              Navigator.pop(context);
              context.push('/goals');
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _QuickAddOption(
            icon: AppIcons.bills,
            title: l10n.billsTitle,
            onTap: () {
              Navigator.pop(context);
              context.push('/bills');
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _QuickAddOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAddOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.neutral400),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: AppColors.neutral200),
      ),
    );
  }
}
