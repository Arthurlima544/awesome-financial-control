import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'action_sheet_cubit.dart';

class ActionSheet extends StatelessWidget {
  final List<ActionSheetOption> options;
  final ValueChanged<ActionSheetOption> onOptionSelected;
  final VoidCallback? onCancel;
  final String title;
  final String cancelText;
  final Color selectedColor;
  final Color unselectedColor;
  final Color backgroundColor;
  final FocusNode? focusNode;

  const ActionSheet({
    super.key,
    required this.options,
    required this.onOptionSelected,
    this.onCancel,
    this.title = 'Select action',
    this.cancelText = 'Cancel',
    this.selectedColor = Colors.purple,
    this.unselectedColor = Colors.black87,
    this.backgroundColor = Colors.white,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActionSheetCubit(options: options),
      child: _ActionSheetView(
        onOptionSelected: onOptionSelected,
        onCancel: onCancel,
        title: title,
        cancelText: cancelText,
        selectedColor: selectedColor,
        unselectedColor: unselectedColor,
        backgroundColor: backgroundColor,
        focusNode: focusNode,
      ),
    );
  }
}

class _ActionSheetView extends StatelessWidget {
  final ValueChanged<ActionSheetOption> onOptionSelected;
  final VoidCallback? onCancel;
  final String title;
  final String cancelText;
  final Color selectedColor;
  final Color unselectedColor;
  final Color backgroundColor;
  final FocusNode? focusNode;

  const _ActionSheetView({
    required this.onOptionSelected,
    this.onCancel,
    required this.title,
    required this.cancelText,
    required this.selectedColor,
    required this.unselectedColor,
    required this.backgroundColor,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Adaptive sizing logic
          final isDesktop = constraints.maxWidth > 600;
          final maxWidth = isDesktop ? 500.0 : constraints.maxWidth;

          // Responsive relative dimensions
          final padding = maxWidth * 0.05;
          final titleFontSize = maxWidth * 0.055;
          final optionFontSize = maxWidth * 0.04;
          final cancelFontSize = maxWidth * 0.04;

          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: maxWidth,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24.0),
                ),
              ),
              child: BlocBuilder<ActionSheetCubit, ActionSheetState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          padding,
                          padding * 1.5,
                          padding,
                          padding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: titleFontSize.clamp(18.0, 24.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            if (state.errorMessage != null)
                              Padding(
                                padding: EdgeInsets.only(top: padding * 0.5),
                                child: Text(
                                  state.errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: optionFontSize.clamp(12.0, 16.0),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Options
                      ...state.options.map((option) {
                        final isSelected = state.selectedOptionId == option.id;
                        final currentColor = isSelected
                            ? selectedColor
                            : unselectedColor;

                        return Semantics(
                          button: true,
                          selected: isSelected,
                          label: 'Select ${option.label}',
                          child: InkWell(
                            onTap: () {
                              context.read<ActionSheetCubit>().selectOption(
                                option.id,
                              );
                              onOptionSelected(option);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: padding,
                                vertical: padding * 0.6,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: currentColor,
                                    size: 24.0, // Hardcoded allowed for icons
                                  ),
                                  SizedBox(width: padding * 0.8),
                                  Expanded(
                                    child: Text(
                                      option.label,
                                      style: TextStyle(
                                        fontSize: optionFontSize.clamp(
                                          14.0,
                                          18.0,
                                        ),
                                        color: currentColor,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      SizedBox(height: padding),

                      // Divider
                      Divider(
                        height: 1.0,
                        thickness: 1.0,
                        color: Colors.grey[200],
                      ),

                      // Cancel Button
                      Semantics(
                        button: true,
                        label: cancelText,
                        child: InkWell(
                          onTap: onCancel,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: padding),
                            alignment: Alignment.center,
                            child: Text(
                              cancelText,
                              style: TextStyle(
                                fontSize: cancelFontSize.clamp(14.0, 18.0),
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // iOS style bottom handle/spacing
                      SizedBox(height: padding * 0.5),
                      Center(
                        child: Container(
                          width: maxWidth * 0.3,
                          height: 4.0, // Hardcoded allowed for borders/handles
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                      SizedBox(height: padding * 0.5),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
