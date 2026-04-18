import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_search_bar_cubit.dart';

class AdaptiveSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool showCancelButton;
  final bool showMicrophone;
  final VoidCallback? onCancelTapped;
  final VoidCallback? onMicrophoneTapped;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? customPadding;

  const AdaptiveSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText = 'Search',
    this.showCancelButton = false,
    this.showMicrophone = false,
    this.onCancelTapped,
    this.onMicrophoneTapped,
    this.onChanged,
    this.onSubmitted,
    this.backgroundColor,
    this.iconColor,
    this.textStyle,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Relative sizing logic
    final double horizontalPadding = screenSize.width * 0.04 > 24.0
        ? 24.0
        : screenSize.width * 0.04;
    final double verticalPadding = screenSize.height * 0.015 > 16.0
        ? 16.0
        : screenSize.height * 0.015;
    final double spacing = screenSize.width * 0.03 > 16.0
        ? 16.0
        : screenSize.width * 0.03;
    final double relativeFontSize = screenSize.width * 0.04 > 18.0
        ? 18.0
        : screenSize.width * 0.04;

    return BlocBuilder<AdaptiveSearchBarCubit, AdaptiveSearchBarState>(
      builder: (context, state) {
        final bool hasError = state.errorMessage != null;
        final Color defaultBgColor = Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest;
        final Color effectiveBgColor = hasError
            ? Colors.red.withValues(alpha: 0.1)
            : (backgroundColor ?? defaultBgColor);

        return Padding(
          padding:
              customPadding ??
              EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Semantics(
                  textField: true,
                  label: 'Search Input Field',
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      context.read<AdaptiveSearchBarCubit>().setFocus(hasFocus);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: effectiveBgColor,
                        borderRadius: BorderRadius.circular(16.0),
                        border: hasError
                            ? Border.all(color: Colors.red, width: 1.5)
                            : Border.all(color: Colors.transparent, width: 0.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color:
                                iconColor ??
                                Theme.of(
                                  context,
                                ).iconTheme.color?.withValues(alpha: 0.6),
                            size: 24.0,
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onChanged: (value) {
                                context
                                    .read<AdaptiveSearchBarCubit>()
                                    .updateQuery(value);
                                onChanged?.call(value);
                              },
                              onSubmitted: onSubmitted,
                              style:
                                  textStyle ??
                                  TextStyle(fontSize: relativeFontSize),
                              decoration: InputDecoration(
                                hintText: hintText,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: verticalPadding * 1.2,
                                ),
                              ),
                            ),
                          ),
                          if (state.query.isNotEmpty)
                            Semantics(
                              button: true,
                              label: 'Clear search',
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 20.0),
                                color: iconColor,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  controller.clear();
                                  context
                                      .read<AdaptiveSearchBarCubit>()
                                      .clear();
                                  onChanged?.call('');
                                },
                              ),
                            )
                          else if (showMicrophone)
                            Semantics(
                              button: true,
                              label: 'Voice search',
                              child: IconButton(
                                icon: const Icon(Icons.mic_none, size: 22.0),
                                color: iconColor,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: onMicrophoneTapped,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (showCancelButton) ...[
                SizedBox(width: spacing),
                Semantics(
                  button: true,
                  label: 'Cancel search',
                  child: GestureDetector(
                    onTap: () {
                      focusNode.unfocus();
                      onCancelTapped?.call();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: relativeFontSize,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
