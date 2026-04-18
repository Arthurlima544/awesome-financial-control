import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'custom_stepper_cubit.dart';

class CustomStepper extends StatelessWidget {
  final List<String> steps;
  final int initialStep;
  final ValueChanged<int>? onStepTapped;

  // Theme styling
  final Color activeColor;
  final Color activeTextColor;
  final Color completedBackgroundColor;
  final Color completedIconColor;
  final Color inactiveBackgroundColor;
  final Color inactiveNumberColor;
  final Color activeLabelColor;
  final Color inactiveLabelColor;
  final FocusNode? focusNode;

  const CustomStepper({
    super.key,
    required this.steps,
    this.initialStep = 0,
    this.onStepTapped,
    this.activeColor = const Color(0xFF2962FF),
    this.activeTextColor = Colors.white,
    this.completedBackgroundColor = const Color(0xFFC6D8FF), // Light blue tint
    this.completedIconColor = const Color(0xFF2962FF),
    this.inactiveBackgroundColor = const Color(0xFFF3F4F6),
    this.inactiveNumberColor = const Color(0xFF9CA3AF),
    this.activeLabelColor = Colors.black,
    this.inactiveLabelColor = const Color(0xFF9CA3AF),
    this.focusNode,
  }) : assert(steps.length > 0);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomStepperCubit(
        initialStep: initialStep,
        totalSteps: steps.length,
      ),
      child: _CustomStepperView(
        steps: steps,
        onStepTapped: onStepTapped,
        activeColor: activeColor,
        activeTextColor: activeTextColor,
        completedBackgroundColor: completedBackgroundColor,
        completedIconColor: completedIconColor,
        inactiveBackgroundColor: inactiveBackgroundColor,
        inactiveNumberColor: inactiveNumberColor,
        activeLabelColor: activeLabelColor,
        inactiveLabelColor: inactiveLabelColor,
        focusNode: focusNode,
      ),
    );
  }
}

class _CustomStepperView extends StatelessWidget {
  final List<String> steps;
  final ValueChanged<int>? onStepTapped;
  final Color activeColor;
  final Color activeTextColor;
  final Color completedBackgroundColor;
  final Color completedIconColor;
  final Color inactiveBackgroundColor;
  final Color inactiveNumberColor;
  final Color activeLabelColor;
  final Color inactiveLabelColor;
  final FocusNode? focusNode;

  const _CustomStepperView({
    required this.steps,
    this.onStepTapped,
    required this.activeColor,
    required this.activeTextColor,
    required this.completedBackgroundColor,
    required this.completedIconColor,
    required this.inactiveBackgroundColor,
    required this.inactiveNumberColor,
    required this.activeLabelColor,
    required this.inactiveLabelColor,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        // Responsive relative units
        final double circleSize = (maxWidth / (steps.length * 2.5)).clamp(
          28.0,
          48.0,
        );
        final double labelFontSize = (circleSize * 0.35).clamp(10.0, 16.0);
        final double numberFontSize = (circleSize * 0.45).clamp(12.0, 20.0);
        final double iconSize = (circleSize * 0.6).clamp(16.0, 24.0);

        return BlocBuilder<CustomStepperCubit, CustomStepperState>(
          builder: (context, state) {
            return Focus(
              focusNode: focusNode,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(steps.length, (index) {
                      final bool isActive = index == state.currentStep;
                      final bool isCompleted = index < state.currentStep;
                      final bool isInteractive = onStepTapped != null;

                      Color circleBgColor = inactiveBackgroundColor;
                      Color circleContentColor = inactiveNumberColor;
                      Color textLabelColor = inactiveLabelColor;
                      FontWeight textWeight = FontWeight.w500;

                      if (isActive) {
                        circleBgColor = activeColor;
                        circleContentColor = activeTextColor;
                        textLabelColor = activeLabelColor;
                        textWeight = FontWeight.bold;
                      } else if (isCompleted) {
                        circleBgColor = completedBackgroundColor;
                        circleContentColor = completedIconColor;
                      }

                      return Expanded(
                        child: Semantics(
                          button: isInteractive,
                          label:
                              'Step ${index + 1}: ${steps[index]}, ${isActive
                                  ? 'Active'
                                  : isCompleted
                                  ? 'Completed'
                                  : 'Inactive'}',
                          child: InkWell(
                            onTap: isInteractive
                                ? () {
                                    context.read<CustomStepperCubit>().setStep(
                                      index,
                                    );
                                    onStepTapped!(index);
                                  }
                                : null,
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: circleSize,
                                  height: circleSize,
                                  decoration: BoxDecoration(
                                    color: circleBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: isCompleted
                                      ? Icon(
                                          Icons.check,
                                          color: circleContentColor,
                                          size:
                                              iconSize, // Icon size strictly specified per constraint rules
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: circleContentColor,
                                            fontSize: numberFontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                                SizedBox(height: circleSize * 0.3),
                                Text(
                                  steps[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textLabelColor,
                                    fontSize: labelFontSize,
                                    fontWeight: textWeight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
