import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_stepper_cubit.dart';

class AdaptiveStepper extends StatelessWidget {
  final ValueChanged<int>? onChanged;
  final String semanticLabel;
  final Color? activeIconColor;
  final Color? inactiveIconColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? customPadding;
  final TextStyle? customTextStyle;
  final FocusNode? focusNode;

  const AdaptiveStepper({
    super.key,
    required this.semanticLabel,
    this.onChanged,
    this.activeIconColor,
    this.inactiveIconColor,
    this.textColor,
    this.borderColor,
    this.customPadding,
    this.customTextStyle,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdaptiveStepperCubit, AdaptiveStepperState>(
      builder: (context, state) {
        final bool isEffectivelyDisabled =
            state.isDisabled || onChanged == null;

        final canDecrement = !isEffectivelyDisabled && state.value > state.min;
        final canIncrement = !isEffectivelyDisabled && state.value < state.max;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive sizing based on screen constraints
            final double screenWidth = MediaQuery.of(context).size.width;
            final double rawHeight = screenWidth * 0.12;
            final double containerHeight = rawHeight.clamp(36.0, 56.0);

            final double iconSize = containerHeight * 0.45;
            final double fontSize = containerHeight * 0.4;
            final double horizontalPadding = containerHeight * 0.3;
            final double minWidth = containerHeight * 2.5;

            // Colors based on the provided design
            final themeActive = activeIconColor ?? AppColors.brandPurple;
            final themeInactive = inactiveIconColor ?? AppColors.neutral350;
            final themeBorder = borderColor ?? AppColors.neutral250;
            final themeText = textColor ?? Colors.black;

            final currentBorderColor = state.errorMessage != null
                ? Colors.red
                : (state.isFocused ? Colors.blueAccent : themeBorder);

            return Semantics(
              label: semanticLabel,
              value: '${state.value}',
              child: Focus(
                focusNode: focusNode,
                onFocusChange: (hasFocus) {
                  context.read<AdaptiveStepperCubit>().setFocus(hasFocus);
                },
                child: Container(
                  height: containerHeight,
                  constraints: BoxConstraints(minWidth: minWidth),
                  padding:
                      customPadding ??
                      EdgeInsets.symmetric(horizontal: horizontalPadding),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      containerHeight / 2,
                    ), // Perfect pill shape
                    border: Border.all(
                      color: currentBorderColor,
                      width: state.isFocused ? 2.0 : 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Decrement Button
                      Semantics(
                        button: true,
                        enabled: canDecrement,
                        label: 'Decrease value',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: canDecrement
                              ? () {
                                  context
                                      .read<AdaptiveStepperCubit>()
                                      .decrement();
                                  final newState = context
                                      .read<AdaptiveStepperCubit>()
                                      .state;
                                  onChanged?.call(newState.value);
                                }
                              : null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding * 0.5,
                            ),
                            child: Icon(
                              Icons.remove,
                              size: iconSize,
                              color: canDecrement ? themeActive : themeInactive,
                            ),
                          ),
                        ),
                      ),

                      // Value Text
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Text(
                          '${state.value}',
                          style:
                              customTextStyle ??
                              TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: isEffectivelyDisabled
                                    ? themeInactive
                                    : themeText,
                              ),
                        ),
                      ),

                      // Increment Button
                      Semantics(
                        button: true,
                        enabled: canIncrement,
                        label: 'Increase value',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: canIncrement
                              ? () {
                                  context
                                      .read<AdaptiveStepperCubit>()
                                      .increment();
                                  final newState = context
                                      .read<AdaptiveStepperCubit>()
                                      .state;
                                  onChanged?.call(newState.value);
                                }
                              : null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding * 0.5,
                            ),
                            child: Icon(
                              Icons.add,
                              size: iconSize,
                              color: canIncrement ? themeActive : themeInactive,
                            ),
                          ),
                        ),
                      ),
                    ],
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
