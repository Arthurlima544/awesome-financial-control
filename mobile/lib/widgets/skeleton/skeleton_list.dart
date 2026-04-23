import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'list_item_skeleton.dart';

class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.itemBuilder,
  });

  final int itemCount;
  final EdgeInsetsGeometry padding;
  final Widget Function(BuildContext, int)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder ?? (context, index) => const ListItemSkeleton(),
    );
  }
}
