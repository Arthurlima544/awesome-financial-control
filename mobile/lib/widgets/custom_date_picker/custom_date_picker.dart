import 'package:flutter/material.dart' hide DatePickerMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'custom_date_picker_cubit.dart';

class CustomDatePicker extends StatelessWidget {
  final DatePickerMode mode;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime?, DateTime?) onChanged;
  final Color primaryColor;
  final TextStyle? textStyle;
  final String placeholder;

  const CustomDatePicker({
    super.key,
    this.mode = DatePickerMode.range,
    this.initialStartDate,
    this.initialEndDate,
    required this.onChanged,
    this.primaryColor = const Color(0xFF7B39FD),
    this.textStyle,
    this.placeholder = "Select Date",
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomDatePickerCubit(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        mode: mode,
      ),
      child: _DatePickerTrigger(
        primaryColor: primaryColor,
        textStyle: textStyle,
        placeholder: placeholder,
        onChanged: onChanged,
      ),
    );
  }
}

class _DatePickerTrigger extends StatelessWidget {
  final Color primaryColor;
  final TextStyle? textStyle;
  final String placeholder;
  final Function(DateTime?, DateTime?) onChanged;

  const _DatePickerTrigger({
    required this.primaryColor,
    this.textStyle,
    required this.placeholder,
    required this.onChanged,
  });

  String _formatDisplay(CustomDatePickerState state) {
    if (state.startDate == null) return placeholder;
    final startStr =
        "${state.startDate!.day}/${state.startDate!.month}/${state.startDate!.year}";
    if (state.mode == DatePickerMode.single ||
        state.endDate == null ||
        state.startDate == state.endDate) {
      return startStr;
    }
    final endStr =
        "${state.endDate!.day}/${state.endDate!.month}/${state.endDate!.year}";
    return "$startStr - $endStr";
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomDatePickerCubit, CustomDatePickerState>(
      listener: (context, state) {
        if (state.isConfirmed) onChanged(state.startDate, state.endDate);
      },
      builder: (context, state) {
        return Semantics(
          label: "Open date picker",
          button: true,
          child: InkWell(
            onTap: () => _showPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 18, color: primaryColor),
                  const SizedBox(width: 12),
                  Text(_formatDisplay(state), style: textStyle),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPicker(BuildContext context) {
    final cubit = context.read<CustomDatePickerCubit>();
    showDialog(
      context: context,
      builder: (innerContext) => BlocProvider.value(
        value: cubit,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: _DatePickerContent(primaryColor: primaryColor),
        ),
      ),
    );
  }
}

class _DatePickerContent extends StatelessWidget {
  final Color primaryColor;

  const _DatePickerContent({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CustomDatePickerCubit>();
    final state = cubit.state;
    final color = primaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 400;
        return Container(
          width: isMobile ? constraints.maxWidth : 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, state, cubit),
              const SizedBox(height: 20),
              _buildGrid(state, cubit, color),
              const SizedBox(height: 24),
              _buildFooter(context, cubit, color),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    CustomDatePickerState state,
    CustomDatePickerCubit cubit,
  ) {
    final months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return Row(
      children: [
        Expanded(
          child: DropdownButton<int>(
            value: state.viewingMonth.month,
            items: List.generate(
              12,
              (i) => DropdownMenuItem(value: i + 1, child: Text(months[i])),
            ),
            onChanged: (m) => cubit.changeMonth(state.viewingMonth.year, m!),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButton<int>(
            value: state.viewingMonth.year,
            items: List.generate(
              10,
              (i) =>
                  DropdownMenuItem(value: 2020 + i, child: Text("${2020 + i}")),
            ),
            onChanged: (y) => cubit.changeMonth(y!, state.viewingMonth.month),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(
    CustomDatePickerState state,
    CustomDatePickerCubit cubit,
    Color color,
  ) {
    final daysInMonth = DateUtils.getDaysInMonth(
      state.viewingMonth.year,
      state.viewingMonth.month,
    );
    final firstDayOffset =
        DateTime(state.viewingMonth.year, state.viewingMonth.month, 1).weekday -
        1;
    final labels = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: labels
              .map(
                (l) => Text(
                  l,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: daysInMonth + firstDayOffset,
          itemBuilder: (context, index) {
            if (index < firstDayOffset) return const SizedBox.shrink();
            final day = index - firstDayOffset + 1;
            final date = DateTime(
              state.viewingMonth.year,
              state.viewingMonth.month,
              day,
            );

            bool isStart = state.startDate == date;
            bool isEnd = state.endDate == date;
            bool inRange =
                state.startDate != null &&
                state.endDate != null &&
                date.isAfter(state.startDate!) &&
                date.isBefore(state.endDate!);

            return GestureDetector(
              onTap: () => cubit.selectDate(date),
              child: Semantics(
                label: "Select $day",
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: (isStart || isEnd)
                        ? color
                        : (inRange
                              ? color.withValues(alpha: 0.1)
                              : Colors.transparent),
                    shape: (isStart || isEnd)
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$day",
                    style: TextStyle(
                      color: (isStart || isEnd)
                          ? Colors.white
                          : (inRange ? color : Colors.black),
                      fontWeight: (isStart || isEnd)
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter(
    BuildContext context,
    CustomDatePickerCubit cubit,
    Color color,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => cubit.reset(),
            child: const Text("Reset"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              cubit.confirm();
              Navigator.pop(context);
            },
            child: const Text("Done"),
          ),
        ),
      ],
    );
  }
}
