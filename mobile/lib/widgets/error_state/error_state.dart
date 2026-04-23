import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../adaptive_button/adaptive_button.dart';
import '../adaptive_button/adaptive_button_cubit.dart';
import 'error_state_cubit.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;
  final Color? primaryColor;
  final Color? messageColor;
  final IconData? icon;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? retryFocusNode;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText,
    this.primaryColor,
    this.messageColor,
    this.icon = Icons.error_outline,
    this.customPadding,
    this.retryFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ErrorStateCubit(),
      child: _ErrorStateContent(
        message: message,
        onRetry: onRetry,
        retryText: retryText,
        primaryColor: primaryColor,
        messageColor: messageColor,
        icon: icon,
        customPadding: customPadding,
        retryFocusNode: retryFocusNode,
      ),
    );
  }
}

class _ErrorStateContent extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;
  final Color? primaryColor;
  final Color? messageColor;
  final IconData? icon;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? retryFocusNode;

  const _ErrorStateContent({
    required this.message,
    this.onRetry,
    this.retryText,
    this.primaryColor,
    this.messageColor,
    this.icon,
    this.customPadding,
    this.retryFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ErrorStateCubit, ErrorStateViewState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = MediaQuery.of(context).size.width;
            final double iconSize = (screenWidth * 0.15).clamp(48.0, 80.0);
            final double fontSize = (screenWidth * 0.042).clamp(14.0, 18.0);
            final double spacing = iconSize * 0.3;

            final themeError =
                primaryColor ?? Theme.of(context).colorScheme.error;
            final themeMessage =
                messageColor ?? Theme.of(context).colorScheme.onSurfaceVariant;

            return Semantics(
              label: message,
              child: Center(
                child: Padding(
                  padding:
                      customPadding ??
                      EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null)
                        Icon(icon, size: iconSize, color: themeError),
                      SizedBox(height: spacing),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: themeMessage,
                          height: 1.4,
                        ),
                      ),
                      if (onRetry != null) ...[
                        SizedBox(height: spacing * 1.5),
                        BlocProvider(
                          create: (_) => AdaptiveButtonCubit(),
                          child: AdaptiveButton(
                            key: const ValueKey('errorRetryButton'),
                            text: retryText ?? 'Tentar novamente',
                            primaryColor: themeError,
                            focusNode: retryFocusNode,
                            onPressed: state.isRetrying
                                ? null
                                : () {
                                    context.read<ErrorStateCubit>().setRetrying(
                                      true,
                                    );
                                    onRetry!();
                                  },
                          ),
                        ),
                      ],
                    ],
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
