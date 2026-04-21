import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_button_cubit.dart';

enum AdaptiveButtonVariant { solid, tonal, outlined, text }

enum AdaptiveButtonSize { wrap, fullWidth }

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AdaptiveButtonVariant variant;
  final AdaptiveButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? primaryColor;
  final TextStyle? customTextStyle;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? focusNode;
  final String? semanticLabel;

  const AdaptiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AdaptiveButtonVariant.solid,
    this.size = AdaptiveButtonSize.wrap,
    this.leadingIcon,
    this.trailingIcon,
    this.primaryColor,
    this.customTextStyle,
    this.customPadding,
    this.focusNode,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor =
        primaryColor ??
        const Color(0xFF624BFF); // Default purple from the image
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<AdaptiveButtonCubit, AdaptiveButtonState>(
      builder: (context, state) {
        final bool isEffectivelyDisabled =
            state.isDisabled || state.isLoading || onPressed == null;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive responsive padding based on screen width
            final double horizontalPadding = screenWidth * 0.06;
            final double verticalPadding = screenWidth * 0.035;
            final double fontSize = screenWidth * 0.04;

            // Constrain adaptive values for extremely large screens (tablet/desktop)
            final double clampedHPadding = horizontalPadding > 32.0
                ? 32.0
                : horizontalPadding;
            final double clampedVPadding = verticalPadding > 18.0
                ? 18.0
                : verticalPadding;
            final double clampedFontSize = fontSize > 18.0
                ? 18.0
                : (fontSize < 14.0 ? 14.0 : fontSize);

            final resolvedPadding =
                customPadding ??
                EdgeInsets.symmetric(
                  horizontal: clampedHPadding,
                  vertical: clampedVPadding,
                );

            // Determine colors based on variant and state
            Color backgroundColor;
            Color foregroundColor;
            Color borderColor = Colors.transparent;

            if (isEffectivelyDisabled) {
              backgroundColor =
                  variant == AdaptiveButtonVariant.solid ||
                      variant == AdaptiveButtonVariant.tonal
                  ? Colors.grey.shade300
                  : Colors.transparent;
              foregroundColor = Colors.grey.shade500;
              if (variant == AdaptiveButtonVariant.outlined) {
                borderColor = Colors.grey.shade300;
              }
            } else {
              switch (variant) {
                case AdaptiveButtonVariant.solid:
                  backgroundColor = baseColor;
                  foregroundColor = Colors.white;
                  break;
                case AdaptiveButtonVariant.tonal:
                  backgroundColor = baseColor.withValues(alpha: 0.15);
                  foregroundColor = baseColor;
                  break;
                case AdaptiveButtonVariant.outlined:
                  backgroundColor = Colors.transparent;
                  foregroundColor = baseColor;
                  borderColor = baseColor;
                  break;
                case AdaptiveButtonVariant.text:
                  backgroundColor = Colors.transparent;
                  foregroundColor = baseColor;
                  break;
              }
            }

            // Error override
            if (state.errorMessage != null && !isEffectivelyDisabled) {
              foregroundColor = Colors.red;
              if (variant == AdaptiveButtonVariant.outlined ||
                  variant == AdaptiveButtonVariant.text) {
                borderColor = Colors.red;
              } else {
                backgroundColor = Colors.red.withValues(alpha: 0.15);
              }
            }

            final buttonContent = Row(
              mainAxisSize: size == AdaptiveButtonSize.fullWidth
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.isLoading) ...[
                  SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        foregroundColor,
                      ),
                    ),
                  ),
                  SizedBox(width: clampedHPadding * 0.5),
                ] else if (leadingIcon != null) ...[
                  Icon(leadingIcon, color: foregroundColor, size: 20.0),
                  SizedBox(width: clampedHPadding * 0.5),
                ],
                Text(
                  text,
                  style:
                      customTextStyle ??
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: clampedFontSize,
                        color: foregroundColor,
                      ),
                ),
                if (!state.isLoading && trailingIcon != null) ...[
                  SizedBox(width: clampedHPadding * 0.5),
                  Icon(trailingIcon, color: foregroundColor, size: 20.0),
                ],
              ],
            );

            return Semantics(
              button: true,
              enabled: !isEffectivelyDisabled,
              label: semanticLabel ?? 'Button: $text',
              child: Focus(
                focusNode: focusNode,
                onFocusChange: (hasFocus) {
                  context.read<AdaptiveButtonCubit>().setFocus(hasFocus);
                },
                child: Material(
                  color: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      50.0,
                    ), // Pill shape from image
                    side: BorderSide(
                      color: borderColor,
                      width: variant == AdaptiveButtonVariant.outlined
                          ? 1.5
                          : 0.0,
                    ),
                  ),
                  child: InkWell(
                    onTap: isEffectivelyDisabled ? null : onPressed,
                    borderRadius: BorderRadius.circular(50.0),
                    hoverColor: baseColor.withValues(alpha: 0.08),
                    highlightColor: baseColor.withValues(alpha: 0.12),
                    child: Container(
                      padding: resolvedPadding,
                      decoration: state.isFocused && !isEffectivelyDisabled
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 2.0,
                              ),
                            )
                          : null,
                      child: buttonContent,
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
