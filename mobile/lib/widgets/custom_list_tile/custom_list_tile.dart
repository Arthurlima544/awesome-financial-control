import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'custom_list_tile_cubit.dart';

enum CustomListTileLeading { none, icon, avatar }

enum CustomListTileTrailing { none, arrow, toggleSwitch, checkbox, badge }

class CustomListTile extends StatelessWidget {
  final String title;
  final String? description;
  final CustomListTileLeading leadingType;
  final CustomListTileTrailing trailingType;
  final IconData? leadingIcon;
  final Widget? leadingAvatarWidget;
  final String? badgeText;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  // Styling
  final Color primaryColor;
  final Color titleColor;
  final Color descriptionColor;
  final Color backgroundColor;
  final FocusNode? focusNode;

  const CustomListTile({
    super.key,
    required this.title,
    this.description,
    this.leadingType = CustomListTileLeading.icon,
    this.trailingType = CustomListTileTrailing.arrow,
    this.leadingIcon = Icons.favorite,
    this.leadingAvatarWidget,
    this.badgeText,
    this.initialValue = false,
    this.onChanged,
    this.onTap,
    this.primaryColor = AppColors.brandBlue,
    this.titleColor = AppColors.neutral800,
    this.descriptionColor = AppColors.neutral500,
    this.backgroundColor = Colors.white,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomListTileCubit(initialValue: initialValue),
      child: CustomListTileView(
        title: title,
        description: description,
        leadingType: leadingType,
        trailingType: trailingType,
        leadingIcon: leadingIcon,
        leadingAvatarWidget: leadingAvatarWidget,
        badgeText: badgeText,
        onChanged: onChanged,
        onTap: onTap,
        primaryColor: primaryColor,
        titleColor: titleColor,
        descriptionColor: descriptionColor,
        backgroundColor: backgroundColor,
        focusNode: focusNode,
      ),
    );
  }
}

@visibleForTesting
class CustomListTileView extends StatelessWidget {
  final String title;
  final String? description;
  final CustomListTileLeading leadingType;
  final CustomListTileTrailing trailingType;
  final IconData? leadingIcon;
  final Widget? leadingAvatarWidget;
  final String? badgeText;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final Color primaryColor;
  final Color titleColor;
  final Color descriptionColor;
  final Color backgroundColor;
  final FocusNode? focusNode;

  const CustomListTileView({
    super.key,
    required this.title,
    this.description,
    required this.leadingType,
    required this.trailingType,
    this.leadingIcon,
    this.leadingAvatarWidget,
    this.badgeText,
    this.onChanged,
    this.onTap,
    required this.primaryColor,
    required this.titleColor,
    required this.descriptionColor,
    required this.backgroundColor,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adaptive base width sizing
        final double maxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        // Responsive relative units
        final double padding = (maxWidth * 0.04).clamp(12.0, 24.0);
        final double titleFontSize = (maxWidth * 0.045).clamp(14.0, 16.0);
        final double descFontSize = (maxWidth * 0.035).clamp(12.0, 14.0);

        return BlocBuilder<CustomListTileCubit, CustomListTileState>(
          builder: (context, state) {
            final isInteractive = onTap != null || onChanged != null;

            return Semantics(
              button: isInteractive,
              toggled:
                  trailingType == CustomListTileTrailing.toggleSwitch ||
                      trailingType == CustomListTileTrailing.checkbox
                  ? state.isSelected
                  : null,
              label: '$title, ${description ?? ''}',
              child: Material(
                color: backgroundColor,
                child: InkWell(
                  focusNode: focusNode,
                  onTap: isInteractive
                      ? () => _handleTap(context, state)
                      : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: padding * 0.8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (leadingType != CustomListTileLeading.none)
                              Padding(
                                padding: EdgeInsets.only(right: padding),
                                child: _buildLeading(),
                              ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (description != null) ...[
                                    SizedBox(height: padding * 0.2),
                                    Text(
                                      description!,
                                      style: TextStyle(
                                        color: descriptionColor,
                                        fontSize: descFontSize,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            if (trailingType != CustomListTileTrailing.none)
                              Padding(
                                padding: EdgeInsets.only(left: padding * 0.5),
                                child: _buildTrailing(
                                  context,
                                  state,
                                  titleFontSize,
                                ),
                              ),
                          ],
                        ),
                        if (state.errorMessage != null)
                          Padding(
                            padding: EdgeInsets.only(
                              top: padding * 0.5,
                              left: leadingType != CustomListTileLeading.none
                                  ? 40.0 + padding
                                  : 0, // Approx offset
                            ),
                            child: Text(
                              state.errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: descFontSize,
                              ),
                            ),
                          ),
                      ],
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

  void _handleTap(BuildContext context, CustomListTileState state) {
    if (trailingType == CustomListTileTrailing.toggleSwitch ||
        trailingType == CustomListTileTrailing.checkbox) {
      final newValue = !state.isSelected;
      context.read<CustomListTileCubit>().toggleValue(newValue);
      if (onChanged != null) onChanged!(newValue);
    } else {
      if (onTap != null) onTap!();
    }
  }

  Widget _buildLeading() {
    if (leadingType == CustomListTileLeading.icon) {
      return Icon(leadingIcon, color: primaryColor, size: 24.0);
    } else if (leadingType == CustomListTileLeading.avatar) {
      return leadingAvatarWidget ??
          CircleAvatar(
            radius: 20.0,
            backgroundColor: primaryColor.withValues(alpha: 0.15),
            child: Icon(
              Icons.person,
              color: primaryColor.withValues(alpha: 0.5),
            ),
          );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTrailing(
    BuildContext context,
    CustomListTileState state,
    double baseFontSize,
  ) {
    switch (trailingType) {
      case CustomListTileTrailing.arrow:
        return Icon(Icons.chevron_right, color: Colors.grey[400], size: 24.0);

      case CustomListTileTrailing.toggleSwitch:
        return Switch(
          value: state.isSelected,
          onChanged: (val) {
            context.read<CustomListTileCubit>().toggleValue(val);
            if (onChanged != null) onChanged!(val);
          },
          activeThumbColor: primaryColor,
        );

      case CustomListTileTrailing.checkbox:
        return Checkbox(
          value: state.isSelected,
          onChanged: (val) {
            final newValue = val ?? false;
            context.read<CustomListTileCubit>().toggleValue(newValue);
            if (onChanged != null) onChanged!(newValue);
          },
          activeColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        );

      case CustomListTileTrailing.badge:
        return Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            badgeText ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: baseFontSize * 0.7,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      case CustomListTileTrailing.none:
        return const SizedBox.shrink();
    }
  }
}
