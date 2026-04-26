import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_chip_cubit.dart';

enum AdaptiveChipVariant { filled, tonal, outlined }

enum AdaptiveChipSize { wrap, fullWidth }

enum AdaptiveChipIconPosition { none, leading, trailing }

class AdaptiveChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onIconPressed;
  final AdaptiveChipVariant variant;
  final AdaptiveChipSize size;
  final AdaptiveChipIconPosition iconPosition;
  final IconData? icon;
  final Color? primaryColor;
  final TextStyle? customTextStyle;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? focusNode;
  final String? semanticLabel;
  final bool? isSelected;

  const AdaptiveChip({
    super.key,
    required this.label,
    this.onPressed,
    this.onIconPressed,
    this.variant = AdaptiveChipVariant.tonal,
    this.size = AdaptiveChipSize.wrap,
    this.iconPosition = AdaptiveChipIconPosition.none,
    this.icon,
    this.primaryColor,
    this.customTextStyle,
    this.customPadding,
    this.focusNode,
    this.semanticLabel,
    this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseColor = primaryColor ?? AppColors.brandPurple; // Default purple

    return BlocBuilder<AdaptiveChipCubit, AdaptiveChipState>(
      builder: (context, state) {
        final bool effectivelySelected = isSelected ?? state.isSelected;
        final bool isEffectivelyDisabled =
            state.isDisabled || (onPressed == null && onIconPressed == null);

        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive scaling clamped for extreme screen sizes
            final double rawHPadding = screenWidth * 0.04;
            final double hPadding = rawHPadding.clamp(12.0, 24.0);

            final double rawVPadding = screenWidth * 0.02;
            final double vPadding = rawVPadding.clamp(8.0, 14.0);

            final double rawFontSize = screenWidth * 0.035;
            final double fontSize = rawFontSize.clamp(13.0, 16.0);

            final double spacing = hPadding * 0.5;

            // Determine colors based on variant and selection state
            Color backgroundColor = Colors.transparent;
            Color foregroundColor = Colors.black87;
            Color borderColor = Colors.transparent;

            if (isEffectivelyDisabled) {
              backgroundColor = variant == AdaptiveChipVariant.outlined
                  ? Colors.transparent
                  : Colors.grey.shade200;
              foregroundColor = Colors.grey.shade500;
              borderColor = variant == AdaptiveChipVariant.outlined
                  ? Colors.grey.shade300
                  : Colors.transparent;
            } else if (state.errorMessage != null) {
              foregroundColor = Colors.red;
              borderColor = Colors.red;
              if (variant != AdaptiveChipVariant.outlined) {
                backgroundColor = Colors.red.withValues(alpha: 0.1);
              }
            } else {
              if (effectivelySelected) {
                switch (variant) {
                  case AdaptiveChipVariant.filled:
                    backgroundColor = baseColor;
                    foregroundColor = Colors.white;
                    break;
                  case AdaptiveChipVariant.tonal:
                    backgroundColor = baseColor.withValues(alpha: 0.15);
                    foregroundColor = baseColor;
                    break;
                  case AdaptiveChipVariant.outlined:
                    backgroundColor = Colors.transparent;
                    foregroundColor = baseColor;
                    borderColor = baseColor;
                    break;
                }
              } else {
                switch (variant) {
                  case AdaptiveChipVariant.filled:
                  case AdaptiveChipVariant.tonal:
                    backgroundColor = Colors.grey.shade100;
                    foregroundColor = Colors.black87;
                    break;
                  case AdaptiveChipVariant.outlined:
                    backgroundColor = Colors.transparent;
                    foregroundColor = Colors.black87;
                    borderColor = Colors.grey.shade300;
                    break;
                }
              }
            }

            Widget iconWidget = const SizedBox.shrink();
            if (icon != null && iconPosition != AdaptiveChipIconPosition.none) {
              iconWidget = Semantics(
                button: onIconPressed != null,
                label: 'Chip Action Icon',
                child: GestureDetector(
                  onTap: isEffectivelyDisabled
                      ? null
                      : (onIconPressed ?? onPressed),
                  child: Icon(
                    icon,
                    size: 18.0, // Fixed icon size standard for chips
                    color: foregroundColor,
                  ),
                ),
              );
            }

            final labelWidget = Text(
              label,
              textAlign: TextAlign.center,
              style:
                  customTextStyle ??
                  TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: foregroundColor,
                  ),
            );

            Widget content;
            if (size == AdaptiveChipSize.fullWidth) {
              // Centered text with icons placed at edges like in the image
              content = Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                  ), // Force Stack to take full width
                  labelWidget,
                  if (iconPosition == AdaptiveChipIconPosition.leading)
                    Positioned(left: 0, child: iconWidget),
                  if (iconPosition == AdaptiveChipIconPosition.trailing)
                    Positioned(right: 0, child: iconWidget),
                ],
              );
            } else {
              content = Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconPosition == AdaptiveChipIconPosition.leading) ...[
                    iconWidget,
                    SizedBox(width: spacing),
                  ],
                  labelWidget,
                  if (iconPosition == AdaptiveChipIconPosition.trailing) ...[
                    SizedBox(width: spacing),
                    iconWidget,
                  ],
                ],
              );
            }

            return Semantics(
              button: true,
              selected: effectivelySelected,
              enabled: !isEffectivelyDisabled,
              label: semanticLabel ?? 'Chip: $label',
              child: Focus(
                focusNode: focusNode,
                onFocusChange: (hasFocus) {
                  context.read<AdaptiveChipCubit>().setFocus(hasFocus);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0), // Pill shape
                      side: BorderSide(
                        color: state.isFocused && !isEffectivelyDisabled
                            ? Colors.blueAccent
                            : borderColor,
                        width: state.isFocused
                            ? 2.0
                            : (borderColor != Colors.transparent ? 1.0 : 0.0),
                      ),
                    ),
                    child: InkWell(
                      onTap: isEffectivelyDisabled ? null : onPressed,
                      borderRadius: BorderRadius.circular(50.0),
                      hoverColor: foregroundColor.withValues(alpha: 0.08),
                      highlightColor: foregroundColor.withValues(alpha: 0.12),
                      child: Padding(
                        padding:
                            customPadding ??
                            EdgeInsets.symmetric(
                              horizontal: hPadding,
                              vertical: vPadding,
                            ),
                        child: content,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
