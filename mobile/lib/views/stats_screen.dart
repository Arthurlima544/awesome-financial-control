import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/widgets/empty_state/empty_state.dart';
import 'package:afc/widgets/error_state/error_state.dart';
import 'package:afc/widgets/skeleton/skeleton_view.dart';
import 'package:afc/view_models/stats/stats_bloc.dart';
import 'package:afc/models/monthly_stat_model.dart';
import 'package:afc/widgets/animations/fade_in_animation.dart';
import 'package:afc/widgets/insight_card/insight_card.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(
        title: Text(l10n.statsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            onPressed: () => context.go('/stats/report'),
            tooltip: l10n.reportFullReport,
          ),
        ],
      ),
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading || state is StatsInitial) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: SkeletonView(width: double.infinity, height: 300),
            );
          }
          if (state is StatsError) {
            return Center(
              child: ErrorState(
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
            return _StatsDashboard(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatsDashboard extends StatelessWidget {
  const _StatsDashboard({required this.state});

  final StatsData state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        FadeInAnimation(
          trigger: StatefulNavigationShell.of(context).currentIndex,
          child: Column(
            children: [
              _MetricCard(
                label: l10n.statsSummaryTotal,
                value: currencyFormat.format(state.totalSavings),
                color: AppColors.success,
                icon: Icons.account_balance_wallet_outlined,
                isPrimary: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: l10n.statsSummarySavings,
                      value: '${state.averageSavingsRate.toStringAsFixed(0)}%',
                      color: AppColors.primary,
                      icon: Icons.savings_outlined,
                      isPrivate: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _MetricCard(
                      label: l10n.statsSummaryBest,
                      value: state.bestMonth?.monthAbbreviation ?? '-',
                      color: AppColors.secondary,
                      icon: Icons.star_outline,
                      isPrivate: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FadeInAnimation(
          trigger: StatefulNavigationShell.of(context).currentIndex,
          delay: const Duration(milliseconds: 100),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              side: BorderSide(color: AppColors.neutral200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.statsTitle,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Legend(l10n: l10n),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 250,
                    child: _BarChart(stats: state.stats, state: state),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Insights Financeiros',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FadeInAnimation(
          trigger: StatefulNavigationShell.of(context).currentIndex,
          delay: const Duration(milliseconds: 200),
          child: state.isTrendPositive
              ? InsightCard(
                  title: l10n.statsInsightPositiveTrend,
                  message: l10n.statsInsightPositiveTrendMsg,
                  icon: Icons.trending_up,
                  variant: InsightVariant.success,
                )
              : InsightCard(
                  title: l10n.statsInsightNegativeTrend,
                  message: l10n.statsInsightNegativeTrendMsg,
                  icon: Icons.trending_down,
                  variant: InsightVariant.warning,
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.bestMonth != null)
          FadeInAnimation(
            trigger: StatefulNavigationShell.of(context).currentIndex,
            delay: const Duration(milliseconds: 300),
            child: InsightCard(
              title: l10n.statsInsightBestMonth,
              message: l10n.statsInsightBestMonthMsg(
                state.bestMonth!.monthAbbreviation,
              ),
              icon: Icons.emoji_events_outlined,
              variant: InsightVariant.info,
            ),
          ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.isPrimary = false,
    this.isPrivate = true,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isPrimary;
  final bool isPrivate;

  @override
  Widget build(BuildContext context) {
    return isPrimary ? _buildPrimary(context) : _buildSecondary(context);
  }

  Widget _buildPrimary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppSpacing.iconMd),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: isPrivate
                      ? PrivacyText(
                          value,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        )
                      : Text(
                          value,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppSpacing.iconSm),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: isPrivate
                ? PrivacyText(
                    value,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  )
                : Text(
                    value,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.neutral500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    return TweenAnimationBuilder<double>(
      key: ValueKey(StatefulNavigationShell.of(context).currentIndex),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        final l10n = AppLocalizations.of(context)!;
        return Semantics(
          label: l10n.statsChartLabel,
          child: BarChart(
            BarChartData(
              maxY: state.maxValue * 1.2,
              barGroups: _buildGroups(value),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    interval: state.yInterval,
                    getTitlesWidget: (value, meta) => PrivacyText(
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
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      Colors.blueGrey.withValues(alpha: 0.8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final currencyFormat = NumberFormat.simpleCurrency(
                      locale: 'pt_BR',
                    );
                    return BarTooltipItem(
                      currencyFormat.format(rod.toY),
                      const TextStyle(color: Colors.white, fontSize: 10),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _buildGroups(double animationValue) {
    return List.generate(stats.length, (i) {
      final s = stats[i];
      return BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: s.income * animationValue,
            color: AppColors.primary,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: s.expenses * animationValue,
            color: AppColors.error,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }
}
