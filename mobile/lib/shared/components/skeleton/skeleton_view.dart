import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';

class SkeletonView extends StatelessWidget {
  const SkeletonView({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppSpacing.radiusMd,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral100,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.neutral300,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
