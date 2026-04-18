import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_text_field_cubit.dart';

class AdaptiveTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Widget? prefixWidget; // e.g., for the country flag/code
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final TextStyle? customTextStyle;
  final String? semanticLabel;

  const AdaptiveTextField({
    super.key,
    this.hintText = 'Input text',
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.leadingIcon,
    this.trailingIcon,
    this.prefixWidget,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.customTextStyle,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final defaultFocusColor = focusedBorderColor ?? const Color(0xFF624BFF);
    final defaultErrorColor = errorBorderColor ?? const Color(0xFFE53935);

    return BlocBuilder<AdaptiveTextFieldCubit, AdaptiveTextFieldState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive relative padding clamped for extreme screen sizes
            final double rawHPadding = constraints.maxWidth * 0.04;
            final double hPadding = rawHPadding.clamp(12.0, 20.0);

            final double rawVPadding = constraints.maxWidth * 0.035;
            final double vPadding = rawVPadding.clamp(14.0, 18.0);

            final double rawFontSize = constraints.maxWidth * 0.035;
            final double fontSize = rawFontSize.clamp(14.0, 16.0);

            // Determine border and background colors based on state
            Color borderColor = const Color(0xFFE0E0E0); // Default grey
            Color backgroundColor = Colors.transparent;
            double borderWidth = 1.0;

            if (state.isDisabled) {
              backgroundColor = const Color(0xFFF5F5F5);
              borderColor = const Color(0xFFEEEEEE);
            } else if (state.errorMessage != null) {
              borderColor = defaultErrorColor;
              borderWidth = 1.5;
            } else if (state.isFocused) {
              borderColor = defaultFocusColor;
              borderWidth = 2.0;
            }

            return Semantics(
              textField: true,
              enabled: !state.isDisabled,
              label: semanticLabel ?? hintText,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (!state.isDisabled) {
                        context.read<AdaptiveTextFieldCubit>().focusChanged(
                          hasFocus,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: hPadding),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: borderColor,
                          width: borderWidth,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (leadingIcon != null) ...[
                            leadingIcon!,
                            SizedBox(width: hPadding * 0.8),
                          ],
                          if (prefixWidget != null) ...[
                            prefixWidget!,
                            SizedBox(width: hPadding * 0.5),
                          ],
                          Expanded(
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              enabled: !state.isDisabled,
                              onChanged: (val) {
                                context
                                    .read<AdaptiveTextFieldCubit>()
                                    .textChanged(val);
                                onChanged?.call(val);
                              },
                              onSubmitted: onSubmitted,
                              style:
                                  customTextStyle ??
                                  TextStyle(
                                    fontSize: fontSize,
                                    color: state.isDisabled
                                        ? Colors.grey
                                        : Colors.black87,
                                  ),
                              decoration: InputDecoration(
                                hintText: hintText,
                                hintStyle: TextStyle(
                                  fontSize: fontSize,
                                  color: const Color(0xFF9E9E9E),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: vPadding,
                                ),
                              ),
                            ),
                          ),
                          if (trailingIcon != null) ...[
                            SizedBox(width: hPadding * 0.8),
                            trailingIcon!,
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    SizedBox(height: vPadding * 0.4),
                    Padding(
                      padding: EdgeInsets.only(left: hPadding * 0.5),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: defaultErrorColor,
                          fontSize: fontSize * 0.85,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
