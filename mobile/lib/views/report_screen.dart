import 'package:afc/models/monthly_report_model.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/view_models/report/report_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:afc/widgets/animations/fade_in_animation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:afc/view_models/privacy/privacy_cubit.dart';
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:afc/services/currency_service.dart';
import 'package:afc/widgets/error_state/error_state.dart';
import 'package:afc/utils/currency_formatter.dart';
import 'package:afc/models/currency.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ReportBloc>()..add(LoadReport(DateTime.now())),
      child: const ReportView(),
    );
  }
}

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              context.read<ReportBloc>().add(ExportToPdf());
            },
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final currency = settingsState.selectedCurrency;
          final currencyService = sl<CurrencyService>();

          return BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              if (state.status == ReportStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == ReportStatus.failure) {
                return ErrorState(
                  message: state.errorMessage ?? l10n.genericError,
                  onRetry: () {
                    context.read<ReportBloc>().add(
                      LoadReport(state.selectedMonth),
                    );
                  },
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MonthPicker(selectedMonth: state.selectedMonth),
                    const SizedBox(height: 24),
                    if (state.report != null) ...[
                      FadeInAnimation(
                        trigger: StatefulNavigationShell.of(
                          context,
                        ).currentIndex,
                        child: _SummaryRow(
                          income: state.report!.totalIncome,
                          expenses: state.report!.totalExpenses,
                          savingsRate: state.report!.savingsRate,
                          currency: currency,
                          currencyService: currencyService,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n.reportCategorySpending,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInAnimation(
                        trigger: StatefulNavigationShell.of(
                          context,
                        ).currentIndex,
                        delay: const Duration(milliseconds: 200),
                        child: _CategoryPieChart(
                          categories: state.report!.categories,
                          currency: currency,
                          currencyService: currencyService,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n.reportMoMComparison,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInAnimation(
                        trigger: StatefulNavigationShell.of(
                          context,
                        ).currentIndex,
                        delay: const Duration(milliseconds: 400),
                        child: _ComparisonBarChart(
                          comparison: state.report!.comparison,
                          currency: currency,
                          currencyService: currencyService,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ] else
                      Center(child: Text(l10n.reportNoData)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  final DateTime selectedMonth;

  const _MonthPicker({required this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            context.read<ReportBloc>().add(
              ChangeMonth(
                DateTime(selectedMonth.year, selectedMonth.month - 1),
              ),
            );
          },
        ),
        Text(
          DateFormat('MMMM yyyy', 'pt_BR').format(selectedMonth).toUpperCase(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            context.read<ReportBloc>().add(
              ChangeMonth(
                DateTime(selectedMonth.year, selectedMonth.month + 1),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final double income;
  final double expenses;
  final double savingsRate;
  final Currency currency;
  final CurrencyService currencyService;

  const _SummaryRow({
    required this.income,
    required this.expenses,
    required this.savingsRate,
    required this.currency,
    required this.currencyService,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              label: l10n.homeTotalIncome,
              value: CurrencyFormatter.format(
                currencyService.convert(income, currency),
                currency,
              ),
              color: Colors.green,
            ),
            _SummaryItem(
              label: l10n.homeTotalExpenses,
              value: CurrencyFormatter.format(
                currencyService.convert(expenses, currency),
                currency,
              ),
              color: Colors.red,
            ),
            _SummaryItem(
              label: l10n.reportSavingsRate,
              value: '${savingsRate.toStringAsFixed(1)}%',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        PrivacyText(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<CategoryBreakdownModel> categories;
  final Currency currency;
  final CurrencyService currencyService;

  const _CategoryPieChart({
    required this.categories,
    required this.currency,
    required this.currencyService,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (categories.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(l10n.reportNoExpenses)),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: Semantics(
            label: l10n.reportsChartLabel,
            child: BlocBuilder<PrivacyCubit, PrivacyState>(
              builder: (context, privacyState) {
                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: categories.map((c) {
                      final index = categories.indexOf(c);
                      final isSmall = c.percentage < 5;
                      final displayTitle = privacyState.isPrivate
                          ? '•••••'
                          : (isSmall
                                ? ''
                                : '${c.percentage.toStringAsFixed(0)}%');
                      return PieChartSectionData(
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                        value: c.amount,
                        title: displayTitle,
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 2),
                          ],
                        ),
                        badgeWidget: isSmall
                            ? null
                            : _Badge(
                                c.category ?? 'Outros',
                                color: Colors
                                    .primaries[index % Colors.primaries.length],
                              ),
                        badgePositionPercentageOffset: 1.5,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.reportLegend,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: categories.map((c) {
            final index = categories.indexOf(c);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: Colors.primaries[index % Colors.primaries.length],
                ),
                const SizedBox(width: 4),
                PrivacyText(
                  '${c.category ?? 'Outros'}: ${c.percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ComparisonBarChart extends StatelessWidget {
  final List<CategoryComparisonModel> comparison;
  final Currency currency;
  final CurrencyService currencyService;

  const _ComparisonBarChart({
    required this.comparison,
    required this.currency,
    required this.currencyService,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (comparison.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(l10n.reportNoDataSimple)),
      );
    }

    // Show only top 5 for better visualization
    final sorted = List<CategoryComparisonModel>.from(comparison)
      ..sort((a, b) => b.currentAmount.compareTo(a.currentAmount));
    final displayList = sorted.take(5).toList();

    return AspectRatio(
      aspectRatio: 1.5,
      child: Semantics(
        label: l10n.reportsChartLabel,
        child: BlocBuilder<PrivacyCubit, PrivacyState>(
          builder: (context, privacyState) {
            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    (displayList.fold<double>(0, (max, c) {
                              final currentConverted = currencyService.convert(
                                c.currentAmount,
                                currency,
                              );
                              final previousConverted = currencyService.convert(
                                c.previousAmount,
                                currency,
                              );
                              final highestInGroup =
                                  currentConverted > previousConverted
                                  ? currentConverted
                                  : previousConverted;
                              return highestInGroup > max
                                  ? highestInGroup
                                  : max;
                            }) *
                            1.15)
                        .ceilToDouble(),
                barGroups: displayList.map((c) {
                  final index = displayList.indexOf(c);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: currencyService.convert(
                          c.previousAmount,
                          currency,
                        ),
                        color: Colors.grey[300],
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: currencyService.convert(c.currentAmount, currency),
                        color: Colors.blue,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < displayList.length) {
                          return SideTitleWidget(
                            meta: meta,
                            space: 10,
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                displayList[value.toInt()].category ?? 'Outros',
                                style: const TextStyle(fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 4,
                          child: PrivacyText(
                            CurrencyFormatter.formatCompact(
                              currencyService.convert(value, currency),
                              currency,
                            ),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        Colors.blueGrey.withValues(alpha: 0.8),
                    tooltipBorderRadius: BorderRadius.circular(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final displayValue = privacyState.isPrivate
                          ? '•••••'
                          : CurrencyFormatter.format(rod.toY, currency);
                      return BarTooltipItem(
                        displayValue,
                        const TextStyle(color: Colors.white, fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
