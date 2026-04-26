import 'package:afc/models/currency.dart';
import 'package:afc/utils/currency_formatter.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FinanceLineChart extends StatelessWidget {
  final List<LineChartBarData> lineBarsData;
  final ExtraLinesData? extraLinesData;
  final Currency currency;
  final Widget Function(double value, TitleMeta meta)? bottomTitleWidget;
  final double? minY;
  final double? maxY;
  final double reservedSizeLeft;

  const FinanceLineChart({
    super.key,
    required this.lineBarsData,
    required this.currency,
    this.extraLinesData,
    this.bottomTitleWidget,
    this.minY,
    this.maxY,
    this.reservedSizeLeft = 60,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey.withValues(alpha: 0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  CurrencyFormatter.format(spot.y, currency),
                  const TextStyle(color: Colors.white, fontSize: 10),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: reservedSizeLeft,
              getTitlesWidget: (value, meta) {
                final symbol = currency.symbol;
                if (value == 0) {
                  return PrivacyText(
                    '$symbol 0',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                if (value >= 1000000) {
                  return PrivacyText(
                    '$symbol ${(value / 1000000).toStringAsFixed(1)} mi',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                if (value >= 1000) {
                  return PrivacyText(
                    '$symbol ${(value / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                return PrivacyText(
                  '$symbol ${value.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: bottomTitleWidget ?? _defaultBottomTitle,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: lineBarsData,
        extraLinesData: extraLinesData,
      ),
    );
  }

  Widget _defaultBottomTitle(double value, TitleMeta meta) {
    return Text(
      value.toInt().toString(),
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }
}
