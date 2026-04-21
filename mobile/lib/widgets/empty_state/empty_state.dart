import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'empty_state_cubit.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final double? iconSize;
  final EdgeInsetsGeometry? customPadding;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
    this.iconSize,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmptyStateCubit(),
      child: _EmptyStateView(
        icon: icon,
        title: title,
        subtitle: subtitle,
        iconColor: iconColor,
        titleColor: titleColor,
        subtitleColor: subtitleColor,
        iconSize: iconSize,
        customPadding: customPadding,
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final double? iconSize;
  final EdgeInsetsGeometry? customPadding;

  const _EmptyStateView({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
    this.iconSize,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmptyStateCubit, EmptyStateState>(
      builder: (context, state) {
        if (!state.isVisible) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = MediaQuery.of(context).size.width;
            final double resolvedIconSize =
                iconSize ?? (screenWidth * 0.18).clamp(56.0, 96.0);
            final double titleSize = (screenWidth * 0.045).clamp(16.0, 22.0);
            final double subtitleSize = (screenWidth * 0.038).clamp(13.0, 16.0);
            final double spacing = resolvedIconSize * 0.25;

            final themeIconColor =
                iconColor ?? Theme.of(context).colorScheme.outline;
            final themeTitleColor =
                titleColor ?? Theme.of(context).colorScheme.onSurface;
            final themeSubtitleColor =
                subtitleColor ?? Theme.of(context).colorScheme.onSurfaceVariant;

            return Semantics(
              label: title,
              child: Center(
                child: Padding(
                  padding:
                      customPadding ??
                      EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: spacing * 2,
                      ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: resolvedIconSize, color: themeIconColor),
                      SizedBox(height: spacing),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                          color: themeTitleColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: spacing * 0.5),
                        Text(
                          subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: themeSubtitleColor,
                            height: 1.4,
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
