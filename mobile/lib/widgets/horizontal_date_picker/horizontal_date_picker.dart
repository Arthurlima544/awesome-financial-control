import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'horizontal_date_picker_cubit.dart';

class HorizontalDatePicker extends StatelessWidget {
  final DateTime startDate;
  final int daysCount;
  final DateTime? initialSelectedDate;
  final ValueChanged<DateTime>? onChanged;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color unselectedDayColor;
  final FocusNode? focusNode;

  const HorizontalDatePicker({
    super.key,
    required this.startDate,
    this.daysCount = 7,
    this.initialSelectedDate,
    this.onChanged,
    this.selectedColor = const Color(0xFF2962FF),
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = const Color(0xFF1F2937),
    this.unselectedDayColor = const Color(0xFF9CA3AF),
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HorizontalDatePickerCubit(initialDate: initialSelectedDate),
      child: _HorizontalDatePickerView(
        startDate: startDate,
        daysCount: daysCount,
        onChanged: onChanged,
        selectedColor: selectedColor,
        selectedTextColor: selectedTextColor,
        unselectedTextColor: unselectedTextColor,
        unselectedDayColor: unselectedDayColor,
        focusNode: focusNode,
      ),
    );
  }
}

class _HorizontalDatePickerView extends StatelessWidget {
  final DateTime startDate;
  final int daysCount;
  final ValueChanged<DateTime>? onChanged;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color unselectedDayColor;
  final FocusNode? focusNode;

  const _HorizontalDatePickerView({
    required this.startDate,
    required this.daysCount,
    this.onChanged,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.unselectedDayColor,
    this.focusNode,
  });

  static const List<String> _weekDays = [
    'MO',
    'TU',
    'WE',
    'TH',
    'FR',
    'SA',
    'SU',
  ];

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adaptive sizing based on container width
        final double maxWidth = constraints.maxWidth;
        final double itemWidth = (maxWidth * 0.12).clamp(48.0, 80.0);
        final double itemHeight = (itemWidth * 1.5).clamp(72.0, 110.0);
        final double spacing = (maxWidth * 0.02).clamp(8.0, 16.0);

        final double dayFontSize = (itemWidth * 0.25).clamp(12.0, 16.0);
        final double dateFontSize = (itemWidth * 0.4).clamp(18.0, 24.0);

        return BlocBuilder<
          HorizontalDatePickerCubit,
          HorizontalDatePickerState
        >(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: itemHeight,
                  child: Focus(
                    focusNode: focusNode,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: daysCount,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: spacing),
                      itemBuilder: (context, index) {
                        final currentDate = startDate.add(
                          Duration(days: index),
                        );
                        final isSelected =
                            state.selectedDate != null &&
                            _isSameDay(currentDate, state.selectedDate!);
                        final dayName = _weekDays[currentDate.weekday - 1];

                        return Semantics(
                          button: true,
                          selected: isSelected,
                          label: 'Select $dayName, ${currentDate.day}',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              itemWidth * 0.3,
                            ),
                            onTap: () {
                              context
                                  .read<HorizontalDatePickerCubit>()
                                  .selectDate(currentDate);
                              if (onChanged != null) {
                                onChanged!(currentDate);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: itemWidth,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? selectedColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  itemWidth * 0.3,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? selectedTextColor.withValues(
                                              alpha: 0.9,
                                            )
                                          : unselectedDayColor,
                                      fontSize: dayFontSize,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: itemHeight * 0.05),
                                  Text(
                                    '${currentDate.day}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? selectedTextColor
                                          : unselectedTextColor,
                                      fontSize: dateFontSize,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
