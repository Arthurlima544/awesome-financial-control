import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'action_card_cubit.dart';

enum ActionCardStyle { imageHeader, iconHeader }

class ActionCard extends StatelessWidget {
  final ActionCardStyle style;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback? onAction;
  final String? subtitle;
  final String? tagText;
  final IconData? leadingIcon;
  final Widget? imageWidget;
  final Color primaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final FocusNode? buttonFocusNode;

  const ActionCard({
    super.key,
    required this.style,
    required this.title,
    required this.description,
    required this.buttonText,
    this.onAction,
    this.subtitle,
    this.tagText,
    this.leadingIcon,
    this.imageWidget,
    this.primaryColor = Colors.purple,
    this.backgroundColor = AppColors.cardBackground,
    this.surfaceColor = Colors.white,
    this.buttonFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActionCardCubit(),
      child: _ActionCardView(
        style: style,
        title: title,
        description: description,
        buttonText: buttonText,
        onAction: onAction,
        subtitle: subtitle,
        tagText: tagText,
        leadingIcon: leadingIcon,
        imageWidget: imageWidget,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        surfaceColor: surfaceColor,
        buttonFocusNode: buttonFocusNode,
      ),
    );
  }
}

class _ActionCardView extends StatelessWidget {
  final ActionCardStyle style;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback? onAction;
  final String? subtitle;
  final String? tagText;
  final IconData? leadingIcon;
  final Widget? imageWidget;
  final Color primaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final FocusNode? buttonFocusNode;

  const _ActionCardView({
    required this.style,
    required this.title,
    required this.description,
    required this.buttonText,
    this.onAction,
    this.subtitle,
    this.tagText,
    this.leadingIcon,
    this.imageWidget,
    required this.primaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    this.buttonFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth > 400
            ? 320
            : constraints.maxWidth;
        final double relativePadding = cardWidth * 0.06;
        final double titleSize = (cardWidth * 0.06).clamp(16.0, 22.0);
        final double subtitleSize = (cardWidth * 0.045).clamp(12.0, 16.0);
        final double bodySize = (cardWidth * 0.045).clamp(14.0, 16.0);

        return Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER SECTION
              if (style == ActionCardStyle.imageHeader)
                _buildImageHeader(cardWidth, relativePadding)
              else if (style == ActionCardStyle.iconHeader)
                _buildIconHeader(relativePadding),

              // CONTENT SECTION
              Padding(
                padding: EdgeInsets.symmetric(horizontal: relativePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (style != ActionCardStyle.iconHeader)
                      SizedBox(height: relativePadding),
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: relativePadding * 0.2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    SizedBox(height: relativePadding),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: bodySize,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ACTION SECTION
              Padding(
                padding: EdgeInsets.all(relativePadding),
                child: _buildActionButton(context, bodySize),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageHeader(double width, double padding) {
    return Stack(
      children: [
        Container(
          width: width,
          height: width * 0.5,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
          ),
          child: Center(
            child:
                imageWidget ??
                Icon(
                  Icons.image,
                  size: width * 0.15,
                  color: primaryColor.withValues(alpha: 0.4),
                ),
          ),
        ),
        if (tagText != null)
          Positioned(
            top: padding,
            right: padding,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                tagText!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIconHeader(double padding) {
    return Padding(
      padding: EdgeInsets.only(
        left: padding,
        top: padding,
        bottom: padding * 0.5,
      ),
      child: CircleAvatar(
        radius: 24.0,
        backgroundColor: primaryColor.withValues(alpha: 0.15),
        child: Icon(
          leadingIcon ?? Icons.favorite,
          color: primaryColor,
          size: 24.0,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, double fontSize) {
    return BlocBuilder<ActionCardCubit, ActionCardState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            Semantics(
              button: true,
              label: buttonText,
              enabled: !state.isActionLoading,
              child: OutlinedButton(
                focusNode: buttonFocusNode,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: state.isActionLoading
                    ? null
                    : () async {
                        if (onAction != null) {
                          context.read<ActionCardCubit>().setActionLoading(
                            true,
                          );
                          onAction!();
                          // Simulating async completion clearing the loading state
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (context.mounted) {
                              context.read<ActionCardCubit>().setActionLoading(
                                false,
                              );
                            }
                          });
                        }
                      },
                child: state.isActionLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: primaryColor,
                        ),
                      )
                    : Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
