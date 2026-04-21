import 'package:flutter/material.dart';
import '../../../config/app_spacing.dart';
import 'skeleton_view.dart';

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonView(
                  width: 40,
                  height: 40,
                  borderRadius: AppSpacing.radiusLg,
                ),
                const SizedBox(width: AppSpacing.md),
                const SkeletonView(width: 100, height: 16),
                const Spacer(),
                const SkeletonView(width: 60, height: 16),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const SkeletonView(width: double.infinity, height: 12),
            const SizedBox(height: AppSpacing.sm),
            const SkeletonView(width: 80, height: 12),
          ],
        ),
      ),
    );
  }
}
