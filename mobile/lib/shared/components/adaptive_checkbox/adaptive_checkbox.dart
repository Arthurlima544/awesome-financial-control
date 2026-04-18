import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_checkbox_cubit.dart';

class AdaptiveCheckbox extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  final String semanticLabel;
  final Color? activeColor;
  final Color? checkColor;
  final Color? inactiveBorderColor;
  final Color? disabledActiveColor;
  final Color? disabledInactiveBorderColor;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? focusNode;

  const AdaptiveCheckbox({
    super.key,
    required this.semanticLabel,
    this.onChanged,
    this.activeColor,
    this.checkColor,
    this.inactiveBorderColor,
    this.disabledActiveColor,
    this.disabledInactiveBorderColor,
    this.customPadding,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdaptiveCheckboxCubit, AdaptiveCheckboxState>(
      builder: (context, state) {
        final bool isEffectivelyDisabled =
            state.isDisabled || onChanged == null;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive sizing based on screen constraints
            final double shortestSide = MediaQuery.of(
              context,
            ).size.shortestSide;
            final double rawSize = shortestSide * 0.06;
            final double size = rawSize.clamp(24.0, 40.0);

            final double borderRadius =
                size * 0.25; // 25% for a smooth rounded square
            final double iconSize = size * 0.7;
            final double borderWidth = size * 0.08;

            // Define thematic colors based on the design
            final themeActive = activeColor ?? const Color(0xFF624BFF);
            final themeCheck = checkColor ?? Colors.white;
            final themeInactiveBorder =
                inactiveBorderColor ?? const Color(0xFFBDBDBD);
            final themeDisabledActive =
                disabledActiveColor ?? const Color(0xFFE0E0E0);
            final themeDisabledInactiveBorder =
                disabledInactiveBorderColor ?? const Color(0xFFEEEEEE);

            // Determine visual properties based on state
            Color fillColor = Colors.transparent;
            Color currentBorderColor = Colors.transparent;
            Color currentCheckColor = Colors.transparent;

            if (isEffectivelyDisabled) {
              if (state.isChecked) {
                fillColor = themeDisabledActive;
                currentCheckColor =
                    Colors.white; // Faint check inside light grey fill
              } else {
                currentBorderColor = themeDisabledInactiveBorder;
              }
            } else {
              if (state.isChecked) {
                fillColor = themeActive;
                currentCheckColor = themeCheck;
              } else {
                currentBorderColor = state.errorMessage != null
                    ? Colors.red
                    : themeInactiveBorder;
              }
            }

            return Padding(
              padding: customPadding ?? const EdgeInsets.all(8.0),
              child: Semantics(
                button: true,
                checked: state.isChecked,
                enabled: !isEffectivelyDisabled,
                label: semanticLabel,
                child: Focus(
                  focusNode: focusNode,
                  onFocusChange: (hasFocus) {
                    context.read<AdaptiveCheckboxCubit>().setFocus(hasFocus);
                  },
                  child: GestureDetector(
                    onTap: () {
                      if (!isEffectivelyDisabled) {
                        context.read<AdaptiveCheckboxCubit>().toggle();
                        // Read the updated state from the cubit
                        final updatedState = context
                            .read<AdaptiveCheckboxCubit>()
                            .state;
                        onChanged?.call(updatedState.isChecked);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: state.isFocused && !isEffectivelyDisabled
                              ? Colors.blueAccent
                              : currentBorderColor,
                          width: state.isFocused
                              ? borderWidth + 1.0
                              : (currentBorderColor != Colors.transparent
                                    ? borderWidth
                                    : 0.0),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: state.isChecked ? 1.0 : 0.0,
                        child: Icon(
                          Icons.check,
                          size: iconSize,
                          color: currentCheckColor,
                        ),
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
