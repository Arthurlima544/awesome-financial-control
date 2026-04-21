import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'skeleton_view.dart';

class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        children: [
          const SkeletonView(
            width: 48,
            height: 48,
            borderRadius: AppSpacing.radiusLg,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonView(width: 120, height: 16),
                const SizedBox(height: AppSpacing.xs),
                const SkeletonView(width: 80, height: 12),
              ],
            ),
          ),
          const SkeletonView(width: 60, height: 16),
        ],
      ),
    );
  }
}
