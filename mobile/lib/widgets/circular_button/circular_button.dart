import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'circular_button_cubit.dart';

enum CircularButtonVariant { solid, tonal, outlined, ghost }

enum CircularButtonSize { small, medium, large }

class CircularButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final CircularButtonVariant variant;
  final CircularButtonSize size;
  final Color? primaryColor;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? focusNode;
  final String semanticLabel;

  const CircularButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.variant = CircularButtonVariant.solid,
    this.size = CircularButtonSize.medium,
    this.primaryColor,
    this.customPadding,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor =
        primaryColor ?? AppColors.brandPurple; // Default purple from the image
    final screenShortestSide = MediaQuery.of(context).size.shortestSide;

    return BlocBuilder<CircularButtonCubit, CircularButtonState>(
      builder: (context, state) {
        final bool isEffectivelyDisabled =
            state.isDisabled || state.isLoading || onPressed == null;

        // Responsive sizing logic based on screen's shortest side
        double diameterRatio;
        switch (size) {
          case CircularButtonSize.small:
            diameterRatio = 0.10;
            break;
          case CircularButtonSize.medium:
            diameterRatio = 0.15;
            break;
          case CircularButtonSize.large:
            diameterRatio = 0.20;
            break;
        }

        // Calculate diameter and clamp for extreme screen sizes
        final double rawDiameter = screenShortestSide * diameterRatio;
        final double clampedDiameter = rawDiameter.clamp(32.0, 96.0);
        final double iconSize = clampedDiameter * 0.45;

        // Determine colors based on variant and state
        Color backgroundColor;
        Color foregroundColor;
        Color borderColor = Colors.transparent;

        if (isEffectivelyDisabled) {
          backgroundColor =
              variant == CircularButtonVariant.solid ||
                  variant == CircularButtonVariant.tonal
              ? Theme.of(context).disabledColor.withValues(alpha: 0.12)
              : Colors.transparent;
          foregroundColor = Theme.of(context).disabledColor;
          if (variant == CircularButtonVariant.outlined) {
            borderColor = Theme.of(
              context,
            ).disabledColor.withValues(alpha: 0.2);
          }
        } else {
          switch (variant) {
            case CircularButtonVariant.solid:
              backgroundColor = baseColor;
              foregroundColor = Colors.white;
              break;
            case CircularButtonVariant.tonal:
              backgroundColor = baseColor.withValues(alpha: 0.15);
              foregroundColor = baseColor;
              break;
            case CircularButtonVariant.outlined:
              backgroundColor = Colors.transparent;
              foregroundColor = baseColor;
              borderColor = baseColor.withValues(alpha: 0.5);
              break;
            case CircularButtonVariant.ghost:
              backgroundColor = Colors.transparent;
              foregroundColor = baseColor;
              break;
          }
        }

        // Error state overrides
        if (state.errorMessage != null && !isEffectivelyDisabled) {
          foregroundColor = Colors.red;
          if (variant == CircularButtonVariant.outlined ||
              variant == CircularButtonVariant.ghost) {
            borderColor = Colors.red;
          } else {
            backgroundColor = Colors.red.withValues(alpha: 0.15);
          }
        }

        return Semantics(
          button: true,
          enabled: !isEffectivelyDisabled,
          label: semanticLabel,
          child: Focus(
            focusNode: focusNode,
            onFocusChange: (hasFocus) {
              context.read<CircularButtonCubit>().setFocus(hasFocus);
            },
            child: Container(
              width: clampedDiameter,
              height: clampedDiameter,
              padding: customPadding,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Add an outer ring if focused
                border: state.isFocused && !isEffectivelyDisabled
                    ? Border.all(color: Colors.blueAccent, width: 2.0)
                    : null,
              ),
              child: Material(
                color: backgroundColor,
                shape: CircleBorder(
                  side: BorderSide(
                    color: borderColor,
                    width: variant == CircularButtonVariant.outlined
                        ? 1.5
                        : 0.0,
                  ),
                ),
                child: InkWell(
                  onTap: isEffectivelyDisabled ? null : onPressed,
                  customBorder: const CircleBorder(),
                  hoverColor: baseColor.withValues(alpha: 0.08),
                  highlightColor: baseColor.withValues(alpha: 0.12),
                  child: Center(
                    child: state.isLoading
                        ? SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                foregroundColor,
                              ),
                            ),
                          )
                        : Icon(icon, color: foregroundColor, size: iconSize),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
