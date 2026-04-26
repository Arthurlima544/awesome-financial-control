import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_date_picker_cubit.dart';

class AdaptiveDatePicker extends StatelessWidget {
  final ValueChanged<DateTime>? onDateSelected;
  final String semanticLabel;
  final Color? activeColor;
  final Color? activeTextColor;
  final Color? defaultTextColor;
  final Color? weekdayTextColor;
  final TextStyle? customTextStyle;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? focusNode;

  const AdaptiveDatePicker({
    super.key,
    required this.semanticLabel,
    this.onDateSelected,
    this.activeColor,
    this.activeTextColor,
    this.defaultTextColor,
    this.weekdayTextColor,
    this.customTextStyle,
    this.customPadding,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final themeActiveColor = activeColor ?? AppColors.brandPurple;
    final themeActiveText = activeTextColor ?? Colors.white;
    final themeDefaultText = defaultTextColor ?? Colors.black87;
    final themeWeekdayText = weekdayTextColor ?? AppColors.neutral450;

    const List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return BlocBuilder<AdaptiveDatePickerCubit, AdaptiveDatePickerState>(
      builder: (context, state) {
        final bool isEffectivelyDisabled =
            state.isDisabled || onDateSelected == null;

        // Calculate grid dimensions
        final int daysInMonth = DateTime(
          state.displayedMonth.year,
          state.displayedMonth.month + 1,
          0,
        ).day;
        final int firstDayOffset =
            DateTime(
              state.displayedMonth.year,
              state.displayedMonth.month,
              1,
            ).weekday %
            7; // 0 = Sunday
        final int totalCells = daysInMonth + firstDayOffset;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive sizing based on available width
            final double availableWidth = constraints.maxWidth;
            final double cellSize = availableWidth / 7;
            final double fontSize = cellSize * 0.35;
            final double circleSize = cellSize * 0.7;

            final baseTextStyle =
                customTextStyle ??
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.w400);

            return Semantics(
              label: semanticLabel,
              child: Focus(
                focusNode: focusNode,
                onFocusChange: (hasFocus) {
                  context.read<AdaptiveDatePickerCubit>().setFocus(hasFocus);
                },
                child: Container(
                  padding: customPadding ?? EdgeInsets.all(cellSize * 0.2),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: state.errorMessage != null
                        ? Border.all(color: Colors.red, width: 1.5)
                        : (state.isFocused
                              ? Border.all(color: Colors.blueAccent, width: 2.0)
                              : null),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Navigation Header (Minimalist support to change month)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              size: cellSize * 0.6,
                            ),
                            onPressed: isEffectivelyDisabled
                                ? null
                                : () {
                                    final prevMonth = DateTime(
                                      state.displayedMonth.year,
                                      state.displayedMonth.month - 1,
                                      1,
                                    );
                                    context
                                        .read<AdaptiveDatePickerCubit>()
                                        .changeMonth(prevMonth);
                                  },
                          ),
                          Text(
                            '${_getMonthName(state.displayedMonth.month)} ${state.displayedMonth.year}',
                            style: baseTextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: themeDefaultText,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              size: cellSize * 0.6,
                            ),
                            onPressed: isEffectivelyDisabled
                                ? null
                                : () {
                                    final nextMonth = DateTime(
                                      state.displayedMonth.year,
                                      state.displayedMonth.month + 1,
                                      1,
                                    );
                                    context
                                        .read<AdaptiveDatePickerCubit>()
                                        .changeMonth(nextMonth);
                                  },
                          ),
                        ],
                      ),
                      SizedBox(height: cellSize * 0.2),

                      // Weekdays Header
                      Row(
                        children: weekdays
                            .map(
                              (day) => Expanded(
                                child: Center(
                                  child: Text(
                                    day,
                                    style: baseTextStyle.copyWith(
                                      color: themeWeekdayText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: cellSize * 0.2),

                      // Days Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: totalCells,
                        itemBuilder: (context, index) {
                          if (index < firstDayOffset) {
                            return const SizedBox.shrink(); // Empty cells before the 1st
                          }

                          final int day = index - firstDayOffset + 1;
                          final DateTime currentDate = DateTime(
                            state.displayedMonth.year,
                            state.displayedMonth.month,
                            day,
                          );

                          final bool isSelected =
                              state.selectedDate != null &&
                              state.selectedDate!.year == currentDate.year &&
                              state.selectedDate!.month == currentDate.month &&
                              state.selectedDate!.day == currentDate.day;

                          return Semantics(
                            button: true,
                            label:
                                'Select ${currentDate.day} ${_getMonthName(currentDate.month)}',
                            selected: isSelected,
                            enabled: !isEffectivelyDisabled,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (!isEffectivelyDisabled) {
                                  context
                                      .read<AdaptiveDatePickerCubit>()
                                      .selectDate(currentDate);
                                  onDateSelected?.call(currentDate);
                                }
                              },
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: circleSize,
                                  height: circleSize,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isEffectivelyDisabled
                                              ? Colors.grey
                                              : themeActiveColor)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$day',
                                    style: baseTextStyle.copyWith(
                                      color: isSelected
                                          ? themeActiveText
                                          : (isEffectivelyDisabled
                                                ? Colors.grey.shade400
                                                : themeDefaultText),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
