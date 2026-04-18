import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_badge_cubit.dart';

enum AdaptiveBadgeType { status, count, dot }

class AdaptiveBadge extends StatelessWidget {
  final AdaptiveBadgeType type;
  final String semanticLabel;
  final VoidCallback? onTap;
  final Color? baseColor;
  final Color? textColor;
  final TextStyle? customTextStyle;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? focusNode;

  const AdaptiveBadge({
    super.key,
    required this.type,
    required this.semanticLabel,
    this.onTap,
    this.baseColor,
    this.textColor,
    this.customTextStyle,
    this.customPadding,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdaptiveBadgeCubit, AdaptiveBadgeState>(
      builder: (context, state) {
        if (!state.isVisible) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive sizing based on available width/screen size
            final screenWidth = MediaQuery.of(context).size.width;

            // Relative sizes
            final double rawFontSize = screenWidth * 0.035;
            final double fontSize = rawFontSize.clamp(12.0, 16.0);

            final double rawPaddingX = fontSize * 1.2;
            final double rawPaddingY = fontSize * 0.4;

            final double dotSize = fontSize * 0.6;

            // Determine thematic colors
            final themeBaseColor =
                baseColor ?? const Color(0xFFE57373); // Default red
            Color backgroundColor;
            Color contentColor;

            if (type == AdaptiveBadgeType.status) {
              // Status badges (Success, Warning, etc.) use pastel background with dark text
              backgroundColor = themeBaseColor.withValues(alpha: 0.15);
              contentColor = textColor ?? themeBaseColor;
            } else {
              // Count and Dot badges use solid background with white text
              backgroundColor = themeBaseColor;
              contentColor = textColor ?? Colors.white;
            }

            // Error visualization override
            Border? border;
            if (state.errorMessage != null) {
              border = Border.all(color: Colors.red, width: 1.5);
              if (type == AdaptiveBadgeType.status) {
                backgroundColor = Colors.red.withValues(alpha: 0.1);
                contentColor = Colors.red;
              }
            } else if (state.isFocused) {
              border = Border.all(color: Colors.blueAccent, width: 2.0);
            }

            Widget badgeContent;
            EdgeInsetsGeometry padding = EdgeInsets.zero;
            BoxShape shape = BoxShape.rectangle;
            BorderRadiusGeometry? borderRadius;

            switch (type) {
              case AdaptiveBadgeType.dot:
                shape = BoxShape.circle;
                badgeContent = SizedBox(width: dotSize, height: dotSize);
                break;
              case AdaptiveBadgeType.count:
                shape = BoxShape.circle;
                padding = customPadding ?? EdgeInsets.all(fontSize * 0.5);
                badgeContent = Text(
                  '${state.count ?? 0}',
                  style:
                      customTextStyle ??
                      TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: contentColor,
                      ),
                  textAlign: TextAlign.center,
                );
                break;
              case AdaptiveBadgeType.status:
                borderRadius = BorderRadius.circular(fontSize * 2);
                padding =
                    customPadding ??
                    EdgeInsets.symmetric(
                      horizontal: rawPaddingX,
                      vertical: rawPaddingY,
                    );
                badgeContent = Text(
                  state.label ?? '',
                  style:
                      customTextStyle ??
                      TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: contentColor,
                      ),
                  textAlign: TextAlign.center,
                );
                break;
            }

            return Semantics(
              label: semanticLabel,
              button: onTap != null,
              child: Focus(
                focusNode: focusNode,
                onFocusChange: (hasFocus) {
                  context.read<AdaptiveBadgeCubit>().setFocus(hasFocus);
                },
                child: GestureDetector(
                  onTap: onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: padding,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      shape: shape,
                      borderRadius: borderRadius,
                      border: border,
                    ),
                    child: badgeContent,
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
