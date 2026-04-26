import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_slider_cubit.dart';

class AdaptiveSlider extends StatelessWidget {
  final bool isRange;
  final double min;
  final double max;
  final int? divisions;
  final bool showLabels;
  final ValueChanged<double>? onChangedSingle;
  final ValueChanged<RangeValues>? onChangedRange;
  final String semanticLabel;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? thumbColor;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? focusNode;

  const AdaptiveSlider({
    super.key,
    required this.semanticLabel,
    this.isRange = false,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.showLabels = false,
    this.onChangedSingle,
    this.onChangedRange,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.customPadding,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdaptiveSliderCubit, AdaptiveSliderState>(
      builder: (context, state) {
        final bool isEffectivelyDisabled =
            state.isDisabled ||
            (!isRange && onChangedSingle == null) ||
            (isRange && onChangedRange == null);

        return LayoutBuilder(
          builder: (context, constraints) {
            // Strictly relative adaptive sizing based on screen's shortest side
            final double shortestSide = MediaQuery.of(
              context,
            ).size.shortestSide;
            final double trackHeight = shortestSide * 0.015;
            final double thumbRadius = shortestSide * 0.035;

            // Design System Colors
            final themeActiveTrack = activeTrackColor ?? AppColors.brandPurple;
            final themeInactiveTrack =
                inactiveTrackColor ?? AppColors.neutral250;
            final themeThumb = thumbColor ?? AppColors.brandPurple;
            final errorColor = Colors.red;

            // State-driven Colors
            Color currentActiveTrackColor = themeActiveTrack;
            Color currentInactiveTrackColor = themeInactiveTrack;
            Color currentThumbColor = themeThumb;

            if (isEffectivelyDisabled) {
              currentActiveTrackColor = themeInactiveTrack;
              currentThumbColor = Colors.grey.shade400;
            } else if (state.errorMessage != null) {
              currentActiveTrackColor = errorColor;
              currentThumbColor = errorColor;
            }

            final sliderTheme = SliderThemeData(
              trackHeight: trackHeight,
              activeTrackColor: currentActiveTrackColor,
              inactiveTrackColor: currentInactiveTrackColor,
              thumbColor: currentThumbColor,
              overlayColor: currentThumbColor.withValues(alpha: 0.12),
              valueIndicatorColor: currentThumbColor,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: thumbRadius,
                elevation: 0, // Flat design to match image
                pressedElevation: 4,
              ),
              rangeThumbShape: RoundRangeSliderThumbShape(
                enabledThumbRadius: thumbRadius,
                elevation: 0,
                pressedElevation: 4,
              ),
              trackShape: const RoundedRectSliderTrackShape(),
              showValueIndicator: showLabels
                  ? ShowValueIndicator.onDrag
                  : ShowValueIndicator.onlyForDiscrete,
            );

            Widget sliderWidget;

            if (isRange) {
              sliderWidget = RangeSlider(
                values: RangeValues(state.startValue, state.endValue),
                min: min,
                max: max,
                divisions: divisions,
                labels: showLabels
                    ? RangeLabels(
                        state.startValue.toStringAsFixed(1),
                        state.endValue.toStringAsFixed(1),
                      )
                    : null,
                onChanged: isEffectivelyDisabled
                    ? null
                    : (RangeValues values) {
                        context.read<AdaptiveSliderCubit>().updateRangeValues(
                          values.start,
                          values.end,
                        );
                        onChangedRange?.call(values);
                      },
              );
            } else {
              sliderWidget = Slider(
                value: state.endValue,
                min: min,
                max: max,
                divisions: divisions,
                label: showLabels ? state.endValue.toStringAsFixed(1) : null,
                onChanged: isEffectivelyDisabled
                    ? null
                    : (double value) {
                        context.read<AdaptiveSliderCubit>().updateSingleValue(
                          value,
                        );
                        onChangedSingle?.call(value);
                      },
              );
            }

            return Padding(
              padding:
                  customPadding ?? EdgeInsets.symmetric(vertical: thumbRadius),
              child: Semantics(
                slider: true,
                enabled: !isEffectivelyDisabled,
                label: semanticLabel,
                value: isRange
                    ? '${state.startValue} to ${state.endValue}'
                    : '${state.endValue}',
                child: Focus(
                  focusNode: focusNode,
                  onFocusChange: (hasFocus) {
                    context.read<AdaptiveSliderCubit>().setFocus(hasFocus);
                  },
                  child: Container(
                    decoration: state.isFocused && !isEffectivelyDisabled
                        ? BoxDecoration(
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(thumbRadius),
                          )
                        : null,
                    child: SliderTheme(data: sliderTheme, child: sliderWidget),
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
