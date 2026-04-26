import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_radio_button_cubit.dart';

class AdaptiveRadioButton extends StatelessWidget {
  final VoidCallback? onSelected;
  final String semanticLabel;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? disabledActiveColor;
  final Color? disabledInactiveColor;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? focusNode;

  const AdaptiveRadioButton({
    super.key,
    required this.semanticLabel,
    this.onSelected,
    this.activeColor,
    this.inactiveColor,
    this.disabledActiveColor,
    this.disabledInactiveColor,
    this.customPadding,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdaptiveRadioButtonCubit, AdaptiveRadioButtonState>(
      builder: (context, state) {
        final bool isEffectivelyDisabled =
            state.isDisabled || onSelected == null;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive sizing based on screen constraints
            final double shortestSide = MediaQuery.of(
              context,
            ).size.shortestSide;
            final double rawSize = shortestSide * 0.06;
            final double size = rawSize.clamp(24.0, 48.0);

            final double innerDotSize = size * 0.4;
            final double borderWidth = size * 0.1;

            // Define thematic colors
            final themeActive = activeColor ?? AppColors.brandPurple;
            final themeInactive = inactiveColor ?? AppColors.neutral350;
            final themeDisabledActiveOuter =
                disabledActiveColor ?? AppColors.neutral250;
            final themeDisabledActiveInner = AppColors.neutral150;
            final themeDisabledInactive =
                disabledInactiveColor ?? AppColors.neutral150;

            // Determine visual properties based on state
            Color outerColor;
            Color innerColor = Colors.transparent;
            Color borderColor = Colors.transparent;

            if (isEffectivelyDisabled) {
              if (state.isSelected) {
                outerColor = themeDisabledActiveOuter;
                innerColor = themeDisabledActiveInner;
              } else {
                outerColor = Colors.transparent;
                borderColor = themeDisabledInactive;
              }
            } else {
              if (state.isSelected) {
                outerColor = themeActive;
                innerColor = Colors.white;
              } else {
                outerColor = Colors.transparent;
                borderColor = state.errorMessage != null
                    ? Colors.red
                    : themeInactive;
              }
            }

            return Padding(
              padding: customPadding ?? const EdgeInsets.all(8.0),
              child: Semantics(
                button: true,
                inMutuallyExclusiveGroup: true,
                checked: state.isSelected,
                enabled: !isEffectivelyDisabled,
                label: semanticLabel,
                child: Focus(
                  focusNode: focusNode,
                  onFocusChange: (hasFocus) {
                    context.read<AdaptiveRadioButtonCubit>().setFocus(hasFocus);
                  },
                  child: GestureDetector(
                    onTap: () {
                      if (!isEffectivelyDisabled && !state.isSelected) {
                        context.read<AdaptiveRadioButtonCubit>().select();
                        onSelected?.call();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: outerColor,
                        border: Border.all(
                          color: state.isFocused
                              ? Colors.blueAccent
                              : borderColor,
                          width: state.isFocused
                              ? borderWidth + 1.0
                              : (borderColor != Colors.transparent
                                    ? borderWidth
                                    : 0.0),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: state.isSelected
                          ? AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: innerDotSize,
                              height: innerDotSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: innerColor,
                              ),
                            )
                          : null,
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
