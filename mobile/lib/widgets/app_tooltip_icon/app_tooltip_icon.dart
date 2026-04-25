import 'package:flutter/material.dart';
import 'package:afc/widgets/custom_tooltip/custom_tooltip.dart';
export 'package:afc/widgets/custom_tooltip/custom_tooltip.dart';
import 'package:afc/utils/config/app_colors.dart';

class AppTooltipIcon extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final TooltipPosition position;

  const AppTooltipIcon({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.info_outline,
    this.iconSize = 16.0,
    this.iconColor,
    this.position = TooltipPosition.top,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTooltip(
      title: title,
      description: description,
      position: position,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? AppColors.neutral500,
        ),
      ),
    );
  }
}
