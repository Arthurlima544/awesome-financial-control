import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/generated/app_localizations.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../config/injection.dart';
import '../../../shared/components/empty_state/empty_state.dart';
import '../../../shared/components/error_view/error_view.dart';
import '../bloc/stats_bloc.dart';
import '../model/monthly_stat_model.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StatsBloc>()..add(const StatsLoaded()),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading || state is StatsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StatsError) {
            return Center(
              child: ErrorView(
                message: l10n.statsErrorLoading,
                onRetry: () =>
                    context.read<StatsBloc>().add(const StatsLoaded()),
              ),
            );
          }
          if (state is StatsData) {
            if (state.stats.isEmpty) {
              return Center(
                child: EmptyState(
                  icon: Icons.bar_chart_outlined,
                  title: l10n.statsNoData,
                ),
              );
            }
            return _StatsChart(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatsChart extends StatelessWidget {
  const _StatsChart({required this.state});

  final StatsData state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = state.stats;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Legend(l10n: l10n),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: _BarChart(stats: stats, state: state),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendDot(color: AppColors.primary),
        const SizedBox(width: 6),
        Text(l10n.income, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: AppSpacing.md),
        _LegendDot(color: AppColors.error),
        const SizedBox(width: 6),
        Text(l10n.expense, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.stats, required this.state});

  final List<MonthlyStatModel> stats;
  final StatsData state;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: state.maxValue * 1.2,
        barGroups: _buildGroups(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              interval: state.yInterval,
              getTitlesWidget: (value, meta) => Text(
                state.formatYLabel(value),
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= stats.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    stats[index].monthAbbreviation,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          horizontalInterval: state.yInterval,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
      ),
    );
  }

  List<BarChartGroupData> _buildGroups() {
    return List.generate(stats.length, (i) {
      final s = stats[i];
      return BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: s.income,
            color: AppColors.primary,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: s.expenses,
            color: AppColors.error,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }
}
