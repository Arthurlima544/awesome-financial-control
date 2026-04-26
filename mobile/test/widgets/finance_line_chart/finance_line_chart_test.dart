import 'package:afc/models/currency.dart';
import 'package:afc/widgets/finance_line_chart/finance_line_chart.dart';
import 'package:afc/view_models/privacy/privacy_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider(
          create: (_) => PrivacyCubit(),
          child: SizedBox(height: 300, width: 400, child: child),
        ),
      ),
    );
  }

  group('FinanceLineChart Widget Tests', () {
    testWidgets('Renders LineChart with provided data', (tester) async {
      final lineBarsData = [
        LineChartBarData(
          spots: const [FlSpot(0, 1000), FlSpot(1, 2000), FlSpot(2, 1500)],
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          child: FinanceLineChart(
            lineBarsData: lineBarsData,
            currency: Currency.brl,
          ),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('Renders custom bottom titles when provided', (tester) async {
      final lineBarsData = [
        LineChartBarData(spots: const [FlSpot(0, 1000), FlSpot(1, 2000)]),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          child: FinanceLineChart(
            lineBarsData: lineBarsData,
            currency: Currency.usd,
            bottomInterval: 1,
            bottomTitleWidget: (value, meta) {
              return Text('Year ${value.toInt()}');
            },
          ),
        ),
      );

      expect(find.text('Year 0'), findsOneWidget);
      expect(find.text('Year 1'), findsOneWidget);
    });
  });
}
