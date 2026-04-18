import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_switch_cubit.dart';

class AdaptiveSwitch extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  final String semanticLabel;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? thumbColor;
  final Color? disabledTrackColor;
  final Color? disabledThumbColor;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? focusNode;

  const AdaptiveSwitch({
    super.key,
    required this.semanticLabel,
    this.onChanged,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.disabledTrackColor,
    this.disabledThumbColor,
    this.customPadding,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    // Relative sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<AdaptiveSwitchCubit, AdaptiveSwitchState>(
      builder: (context, state) {
        final bool isEffectivelyDisabled =
            state.isDisabled || onChanged == null;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive scaling factor, clamped for tablet/desktop bounds
            final double rawWidth = screenWidth * 0.12;
            final double switchWidth = rawWidth.clamp(44.0, 72.0);
            final double switchHeight = switchWidth * 0.55; // Aspect ratio
            final double padding = switchHeight * 0.1;
            final double thumbSize = switchHeight - (padding * 2);

            // Theme fallback colors matching the provided design
            final baseActiveColor = activeTrackColor ?? const Color(0xFF624BFF);
            final baseInactiveColor =
                inactiveTrackColor ?? const Color(0xFFE0E0E0);
            final baseThumbColor = thumbColor ?? Colors.white;

            // Determine visual colors based on state
            Color currentTrackColor;
            Color currentThumbColor;
            Color borderColor = Colors.transparent;

            if (isEffectivelyDisabled) {
              currentTrackColor = disabledTrackColor ?? const Color(0xFFF0F0F0);
              currentThumbColor = disabledThumbColor ?? const Color(0xFFE8E8E8);
              if (!state.isOn) {
                borderColor = const Color(
                  0xFFE0E0E0,
                ); // Outline for disabled off state
              }
            } else {
              currentTrackColor = state.isOn
                  ? baseActiveColor
                  : baseInactiveColor;
              currentThumbColor = baseThumbColor;
              if (state.errorMessage != null) {
                borderColor = Colors.red;
              }
            }

            return Padding(
              padding: customPadding ?? EdgeInsets.zero,
              child: Semantics(
                toggled: state.isOn,
                enabled: !isEffectivelyDisabled,
                label: semanticLabel,
                child: Focus(
                  focusNode: focusNode,
                  onFocusChange: (hasFocus) {
                    context.read<AdaptiveSwitchCubit>().setFocus(hasFocus);
                  },
                  child: GestureDetector(
                    onTap: () {
                      if (!isEffectivelyDisabled) {
                        context.read<AdaptiveSwitchCubit>().toggle();
                        // Notice we read the *new* state immediately after toggle
                        final newState = context
                            .read<AdaptiveSwitchCubit>()
                            .state;
                        onChanged?.call(newState.isOn);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: switchWidth,
                      height: switchHeight,
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        color: currentTrackColor,
                        borderRadius: BorderRadius.circular(switchHeight / 2),
                        border: Border.all(
                          color: state.isFocused
                              ? Colors.blueAccent
                              : borderColor,
                          width: state.isFocused
                              ? 2.0
                              : (borderColor != Colors.transparent ? 1.5 : 0.0),
                        ),
                      ),
                      // Move the thumb depending on the active state
                      alignment: state.isOn
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentThumbColor,
                          boxShadow: isEffectivelyDisabled
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
