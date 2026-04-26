import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'custom_snackbar_cubit.dart';

class CustomSnackbar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showLeadingIcon;
  final bool showTrailingIcon;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback? onDismissed;
  final Color backgroundColor;
  final Color textColor;
  final Color actionColor;
  final FocusNode? actionFocusNode;

  const CustomSnackbar({
    super.key,
    required this.title,
    this.subtitle,
    this.showLeadingIcon = false,
    this.showTrailingIcon = false,
    this.actionText,
    this.onAction,
    this.onDismissed,
    this.backgroundColor = AppColors.neutral900,
    this.textColor = Colors.white,
    this.actionColor = AppColors.brandBlueLight,
    this.actionFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomSnackbarCubit(),
      child: _CustomSnackbarView(
        title: title,
        subtitle: subtitle,
        showLeadingIcon: showLeadingIcon,
        showTrailingIcon: showTrailingIcon,
        actionText: actionText,
        onAction: onAction,
        onDismissed: onDismissed,
        backgroundColor: backgroundColor,
        textColor: textColor,
        actionColor: actionColor,
        actionFocusNode: actionFocusNode,
      ),
    );
  }
}

class _CustomSnackbarView extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showLeadingIcon;
  final bool showTrailingIcon;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback? onDismissed;
  final Color backgroundColor;
  final Color textColor;
  final Color actionColor;
  final FocusNode? actionFocusNode;

  const _CustomSnackbarView({
    required this.title,
    this.subtitle,
    required this.showLeadingIcon,
    required this.showTrailingIcon,
    this.actionText,
    this.onAction,
    this.onDismissed,
    required this.backgroundColor,
    required this.textColor,
    required this.actionColor,
    this.actionFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomSnackbarCubit, CustomSnackbarState>(
      listenWhen: (previous, current) =>
          previous.isVisible != current.isVisible,
      listener: (context, state) {
        if (!state.isVisible && onDismissed != null) {
          onDismissed!();
        }
      },
      builder: (context, state) {
        if (!state.isVisible) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive width logic
            final bool isDesktop = constraints.maxWidth > 600;
            final double containerWidth = isDesktop
                ? 400
                : constraints.maxWidth * 0.95;

            // Responsive relative padding based on the constrained width
            final double relativePadding = containerWidth * 0.04;

            return Align(
              alignment: Alignment.center,
              child: Container(
                width: containerWidth,
                padding: EdgeInsets.symmetric(
                  horizontal: relativePadding,
                  vertical: relativePadding * 0.75,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                  border: state.errorMessage != null
                      ? Border.all(color: Colors.red, width: 1.5)
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showLeadingIcon)
                      Padding(
                        padding: EdgeInsets.only(right: relativePadding * 0.8),
                        child: Semantics(
                          label: 'Leading status icon',
                          child: Icon(
                            Icons.radio_button_unchecked,
                            color: textColor.withValues(alpha: 0.7),
                            size: 20.0,
                          ),
                        ),
                      ),

                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: textColor,
                              fontSize: isDesktop ? 16 : containerWidth * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: relativePadding * 0.2),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.6),
                                fontSize: isDesktop
                                    ? 14
                                    : containerWidth * 0.035,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (actionText != null)
                      Padding(
                        padding: EdgeInsets.only(left: relativePadding),
                        child: Semantics(
                          button: true,
                          label: 'Action: $actionText',
                          child: InkWell(
                            focusNode: actionFocusNode,
                            onTap: state.isActionLoading
                                ? null
                                : () {
                                    context
                                        .read<CustomSnackbarCubit>()
                                        .setActionLoading(true);
                                    if (onAction != null) onAction!();
                                    // Reset loading state safely
                                    Future.delayed(
                                      const Duration(milliseconds: 300),
                                      () {
                                        if (context.mounted) {
                                          context
                                              .read<CustomSnackbarCubit>()
                                              .setActionLoading(false);
                                        }
                                      },
                                    );
                                  },
                            child: state.isActionLoading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: actionColor,
                                    ),
                                  )
                                : Text(
                                    actionText!,
                                    style: TextStyle(
                                      color: actionColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: isDesktop
                                          ? 14
                                          : containerWidth * 0.035,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                    if (showTrailingIcon && actionText == null)
                      Padding(
                        padding: EdgeInsets.only(left: relativePadding),
                        child: Semantics(
                          button: true,
                          label: 'Dismiss snackbar',
                          child: GestureDetector(
                            onTap: () =>
                                context.read<CustomSnackbarCubit>().dismiss(),
                            child: Icon(
                              Icons.radio_button_unchecked,
                              color: textColor.withValues(alpha: 0.7),
                              size: 20.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
