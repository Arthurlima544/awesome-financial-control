import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'custom_progress_bar_cubit.dart';

class CustomProgressBar extends StatelessWidget {
  final double initialProgress;
  final int? steps;
  final ValueChanged<double>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final FocusNode? focusNode;

  const CustomProgressBar({
    super.key,
    this.initialProgress = 0.0,
    this.steps,
    this.onChanged,
    this.activeColor = const Color(0xFF2962FF),
    this.inactiveColor = const Color(0xFFE5E7EB),
    this.focusNode,
  }) : assert(
         steps == null || steps > 1,
         'Steps must be greater than 1 if provided',
       );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomProgressBarCubit(initialProgress: initialProgress),
      child: _CustomProgressBarView(
        steps: steps,
        onChanged: onChanged,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        focusNode: focusNode,
      ),
    );
  }
}

class _CustomProgressBarView extends StatelessWidget {
  final int? steps;
  final ValueChanged<double>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final FocusNode? focusNode;

  const _CustomProgressBarView({
    this.steps,
    this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
    this.focusNode,
  });

  void _handleTap(BuildContext context, double dx, double maxWidth) {
    if (onChanged == null) return;

    double percent = (dx / maxWidth).clamp(0.0, 1.0);

    // Snap to nearest step if stepped mode is enabled
    if (steps != null) {
      percent = (percent * steps!).round() / steps!;
    }

    context.read<CustomProgressBarCubit>().setProgress(percent);
    onChanged!(percent);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        // Responsive relative heights
        final double barHeight = (maxWidth * 0.025).clamp(6.0, 16.0);
        final double borderRadius = barHeight / 2;

        return BlocBuilder<CustomProgressBarCubit, CustomProgressBarState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  slider: true,
                  value: '${(state.progress * 100).round()}%',
                  label: steps != null
                      ? 'Stepped progress bar'
                      : 'Continuous progress bar',
                  child: Focus(
                    focusNode: focusNode,
                    child: GestureDetector(
                      onTapDown: (details) => _handleTap(
                        context,
                        details.localPosition.dx,
                        maxWidth,
                      ),
                      onPanUpdate: (details) => _handleTap(
                        context,
                        details.localPosition.dx,
                        maxWidth,
                      ),
                      child: Container(
                        width: maxWidth,
                        height: barHeight,
                        color: Colors
                            .transparent, // Ensures the gesture detector captures the full area
                        child: steps == null
                            ? _buildContinuousBar(
                                state.progress,
                                maxWidth,
                                barHeight,
                                borderRadius,
                              )
                            : _buildSteppedBar(
                                state.progress,
                                barHeight,
                                borderRadius,
                                maxWidth,
                              ),
                      ),
                    ),
                  ),
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: barHeight * 0.5),
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContinuousBar(
    double progress,
    double maxWidth,
    double height,
    double radius,
  ) {
    return Stack(
      children: [
        Container(
          width: maxWidth,
          height: height,
          decoration: BoxDecoration(
            color: inactiveColor,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: maxWidth * progress,
          height: height,
          decoration: BoxDecoration(
            color: activeColor,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ],
    );
  }

  Widget _buildSteppedBar(
    double progress,
    double height,
    double radius,
    double maxWidth,
  ) {
    final int totalSteps = steps!;
    final int activeSteps = (progress * totalSteps).round();
    final double gap = (maxWidth * 0.015).clamp(4.0, 12.0);

    return Row(
      children: List.generate(totalSteps, (index) {
        final bool isActive = index < activeSteps;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: height,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? gap : 0),
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      }),
    );
  }
}
