import 'package:afc/shared/components/adaptative_nav_bar/adaptive_nav_bar_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdaptiveNavBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBackTapped;
  final VoidCallback? onSettingsTapped;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry? customPadding;

  const AdaptiveNavBar({
    super.key,
    required this.title,
    this.onBackTapped,
    this.onSettingsTapped,
    this.backgroundColor,
    this.iconColor,
    this.titleStyle,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    // Relative sizing based on screen height for a responsive app bar height
    final double screenHeight = MediaQuery.of(context).size.height;
    final double defaultHeight = screenHeight * 0.08 < 60.0
        ? 60.0
        : screenHeight * 0.08;

    return BlocBuilder<AdaptiveNavBarCubit, AdaptiveNavBarState>(
      builder: (context, state) {
        return Container(
          height: defaultHeight,
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Adaptive padding based on screen width (Mobile vs Tablet/Desktop)
              final bool isWideScreen = constraints.maxWidth > 600;
              final EdgeInsetsGeometry padding =
                  customPadding ??
                  EdgeInsets.symmetric(horizontal: isWideScreen ? 32.0 : 16.0);

              return Padding(
                padding: padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Action (Back)
                    Semantics(
                      button: true,
                      label: 'Go back',
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: iconColor ?? Theme.of(context).iconTheme.color,
                        ),
                        onPressed: onBackTapped,
                        tooltip: 'Back',
                      ),
                    ),

                    // Center Title
                    Expanded(
                      child: Semantics(
                        header: true,
                        label: 'Navigation title: $title',
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style:
                              titleStyle ??
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Right Action (Settings)
                    Semantics(
                      button: true,
                      label: 'Settings action',
                      enabled: !state.isActionDisabled,
                      child: _buildRightAction(context, state),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRightAction(BuildContext context, AdaptiveNavBarState state) {
    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    final Color effectiveIconColor = state.isActionDisabled
        ? Colors.grey
        : (state.errorMessage != null
              ? Colors.red
              : (iconColor ?? Theme.of(context).iconTheme.color!));

    return IconButton(
      icon: Icon(Icons.settings_outlined, color: effectiveIconColor),
      onPressed: state.isActionDisabled ? null : onSettingsTapped,
      tooltip: 'Settings',
    );
  }
}
