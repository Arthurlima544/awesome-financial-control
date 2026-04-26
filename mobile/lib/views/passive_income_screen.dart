import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/view_models/passive_income/passive_income_bloc.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:afc/view_models/privacy/privacy_cubit.dart';

class PassiveIncomeScreen extends StatelessWidget {
  const PassiveIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.passiveIncomeTitle)),
      body: BlocBuilder<PassiveIncomeBloc, PassiveIncomeState>(
        builder: (context, state) {
          if (state.status == PassiveIncomeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PassiveIncomeStatus.failure) {
            return Center(
              child: Text(l10n.calcErrorMessage(state.errorMessage ?? '')),
            );
          }

          if (state.data == null) {
            return Center(child: Text(l10n.screenNoDataAvailable));
          }

          final data = state.data!;
          return RefreshIndicator(
            onRefresh: () async {
              context.read<PassiveIncomeBloc>().add(
                LoadPassiveIncomeDashboard(),
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _buildFreedomGauge(
                  context,
                  data['freedomIndex'],
                  data['totalPassiveIncomeCurrentMonth'],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildProgressionChart(context, data['monthlyProgression']),
                const SizedBox(height: AppSpacing.xl),
                _buildIncomeBySource(context, data['incomeByInvestment']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFreedomGauge(
    BuildContext context,
    double index,
    dynamic amount,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final isComplete = index >= 100;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text(
              l10n.passiveIncomeFreedomIndexTitle,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            BlocBuilder<PrivacyCubit, PrivacyState>(
              builder: (context, privacyState) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 180,
                      width: 180,
                      child: CircularProgressIndicator(
                        value: privacyState.isPrivate ? 0.0 : index / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        PrivacyText(
                          '${index.toStringAsFixed(1)}%',
                          style: AppTextStyles.displaySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isComplete
                                ? AppColors.success
                                : AppColors.onSurface,
                          ),
                        ),
                        Text(
                          l10n.passiveIncomeFreedomIndexGoal,
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            PrivacyText(
              l10n.passiveIncomeReceivedThisMonth(
                currencyFormat.format(amount),
              ),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isComplete)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  l10n.passiveIncomeGoalCovered,
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionChart(
    BuildContext context,
    List<dynamic> progression,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.passiveIncomeMonthlyEvolutionTitle,
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          Colors.blueGrey.withValues(alpha: 0.8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final format = NumberFormat.simpleCurrency(
                          locale: 'pt_BR',
                        );
                        return BarTooltipItem(
                          format.format(rod.toY),
                          const TextStyle(color: Colors.white, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(progression),
                  barGroups: progression.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: (e.value['amount'] as num).toDouble(),
                          color: AppColors.primary,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < progression.length) {
                            final month = progression[index]['month']
                                .toString()
                                .split('-')
                                .last;
                            return Text(
                              month,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
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
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getMaxY(List<dynamic> progression) {
    double max = 0;
    for (var p in progression) {
      if ((p['amount'] as num).toDouble() > max) {
        max = (p['amount'] as num).toDouble();
      }
    }
    return max == 0 ? 100 : max * 1.2;
  }

  Widget _buildIncomeBySource(
    BuildContext context,
    Map<dynamic, dynamic> sources,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    if (sources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.passiveIncomeSourcesTitle, style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.md),
        ...sources.entries.map(
          (e) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.arrow_circle_up,
                color: AppColors.success,
              ),
              title: Text(
                e.key.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: PrivacyText(
                currencyFormat.format(e.value),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
