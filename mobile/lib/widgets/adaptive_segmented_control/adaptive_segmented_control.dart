import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_segmented_control_cubit.dart';

class AdaptiveSegmentedControl extends StatelessWidget {
  final List<String> segments;
  final ValueChanged<int>? onChanged;
  final String semanticLabel;
  final Color? backgroundColor;
  final Color? thumbColor;
  final Color? activeTextColor;
  final Color? inactiveTextColor;
  final TextStyle? customTextStyle;
  final EdgeInsetsGeometry? customMargin;
  final FocusNode? focusNode;

  const AdaptiveSegmentedControl({
    super.key,
    required this.segments,
    required this.semanticLabel,
    this.onChanged,
    this.backgroundColor,
    this.thumbColor,
    this.activeTextColor,
    this.inactiveTextColor,
    this.customTextStyle,
    this.customMargin,
    this.focusNode,
  }) : assert(segments.length > 1, 'Must have at least 2 segments');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      AdaptiveSegmentedControlCubit,
      AdaptiveSegmentedControlState
    >(
      builder: (context, state) {
        final bool isEffectivelyDisabled =
            state.isDisabled || onChanged == null;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive scaling relative to the screen's shortest side
            final double shortestSide = MediaQuery.of(
              context,
            ).size.shortestSide;
            final double rawHeight = shortestSide * 0.12;
            final double containerHeight = rawHeight.clamp(40.0, 56.0);

            // Relative units derived from container height
            final double padding = containerHeight * 0.1;
            final double borderRadius = containerHeight * 0.2;
            final double fontSize = containerHeight * 0.35;

            // Width calculations for the animated thumb
            final double availableWidth = constraints.maxWidth;
            final double segmentWidth =
                (availableWidth - (padding * 2)) / segments.length;

            // Colors based on the design
            final themeBgColor = backgroundColor ?? AppColors.neutral100;
            final themeThumbColor = thumbColor ?? Colors.white;
            final themeActiveText = activeTextColor ?? Colors.black;
            final themeInactiveText = inactiveTextColor ?? AppColors.neutral450;

            // Error visualization
            final Color currentBgColor = state.errorMessage != null
                ? Colors.red.withValues(alpha: 0.1)
                : themeBgColor;
            final Border? currentBorder = state.errorMessage != null
                ? Border.all(color: Colors.red, width: 1.5)
                : (state.isFocused
                      ? Border.all(color: Colors.blueAccent, width: 2.0)
                      : null);

            return Padding(
              padding: customMargin ?? EdgeInsets.zero,
              child: Semantics(
                label: semanticLabel,
                child: Focus(
                  focusNode: focusNode,
                  onFocusChange: (hasFocus) {
                    context.read<AdaptiveSegmentedControlCubit>().setFocus(
                      hasFocus,
                    );
                  },
                  child: Container(
                    height: containerHeight,
                    width: availableWidth,
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      color: currentBgColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: currentBorder,
                    ),
                    child: Stack(
                      children: [
                        // Animated Sliding Thumb
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          left: state.selectedIndex * segmentWidth,
                          top: 0,
                          bottom: 0,
                          width: segmentWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isEffectivelyDisabled
                                  ? Colors.grey.shade300
                                  : themeThumbColor,
                              borderRadius: BorderRadius.circular(
                                borderRadius * 0.8,
                              ),
                              boxShadow: isEffectivelyDisabled
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 4.0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                          ),
                        ),

                        // Interactive Segments Row
                        Row(
                          children: List.generate(segments.length, (index) {
                            final bool isSelected =
                                state.selectedIndex == index;

                            return Expanded(
                              child: Semantics(
                                button: true,
                                selected: isSelected,
                                inMutuallyExclusiveGroup: true,
                                label: segments[index],
                                enabled: !isEffectivelyDisabled,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (!isEffectivelyDisabled && !isSelected) {
                                      context
                                          .read<AdaptiveSegmentedControlCubit>()
                                          .setSelectedIndex(index);
                                      final newState = context
                                          .read<AdaptiveSegmentedControlCubit>()
                                          .state;
                                      onChanged?.call(newState.selectedIndex);
                                    }
                                  },
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      style:
                                          customTextStyle ??
                                          TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isEffectivelyDisabled
                                                ? Colors.grey.shade500
                                                : (isSelected
                                                      ? themeActiveText
                                                      : themeInactiveText),
                                          ),
                                      child: Text(
                                        segments[index],
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
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
