import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/view_models/net_worth/net_worth_bloc.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:afc/view_models/privacy/privacy_cubit.dart';
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:afc/services/currency_service.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/currency_formatter.dart';
import 'package:afc/models/currency.dart';
import 'package:afc/widgets/error_state/error_state.dart';

class NetWorthScreen extends StatelessWidget {
  const NetWorthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.calcPatrimonioEvolutionTitle)),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final currency = settingsState.selectedCurrency;
          final currencyService = sl<CurrencyService>();

          return BlocBuilder<NetWorthBloc, NetWorthState>(
            builder: (context, state) {
              if (state.status == NetWorthStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == NetWorthStatus.failure) {
                return ErrorState(
                  message: l10n.calcErrorMessage(state.errorMessage ?? ''),
                  onRetry: () {
                    context.read<NetWorthBloc>().add(LoadNetWorthEvolution());
                  },
                );
              }

              if (state.data.isEmpty) {
                return Center(child: Text(l10n.screenNoDataAvailable));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NetWorthBloc>().add(LoadNetWorthEvolution());
                },
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _buildSummary(
                      context,
                      state.data.last,
                      currency,
                      currencyService,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildEvolutionChart(
                      context,
                      state.data,
                      currency,
                      currencyService,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildDetailsList(
                      context,
                      state.data,
                      currency,
                      currencyService,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    dynamic latest,
    Currency currency,
    CurrencyService currencyService,
  ) {
    final l10n = AppLocalizations.of(context)!;
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
            Text(l10n.netWorthNetWorthLabel, style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            PrivacyText(
              CurrencyFormatter.format(
                currencyService.convert(latest.total, currency),
                currency,
              ),
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  l10n.netWorthAssetsLabel,
                  latest.assets,
                  AppColors.success,
                  currency,
                  currencyService,
                ),
                _buildMiniStat(
                  l10n.netWorthLiabilitiesLabel,
                  latest.liabilities,
                  AppColors.error,
                  currency,
                  currencyService,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    double value,
    Color color,
    Currency currency,
    CurrencyService currencyService,
  ) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        PrivacyText(
          CurrencyFormatter.format(
            currencyService.convert(value, currency),
            currency,
          ),
          style: AppTextStyles.titleSmall.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildEvolutionChart(
    BuildContext context,
    List<dynamic> data,
    Currency currency,
    CurrencyService currencyService,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.calcPatrimonioEvolutionTitle,
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
              height: 250,
              child: BlocBuilder<PrivacyCubit, PrivacyState>(
                builder: (context, privacyState) {
                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 &&
                                  index < data.length &&
                                  index % 2 == 0) {
                                final parts = data[index].month.split('-');
                                if (parts.length == 2) {
                                  final month = parts[1];
                                  final year = parts[0].substring(2);
                                  final monthNames = [
                                    '',
                                    'Jan',
                                    'Fev',
                                    'Mar',
                                    'Abr',
                                    'Mai',
                                    'Jun',
                                    'Jul',
                                    'Ago',
                                    'Set',
                                    'Out',
                                    'Nov',
                                    'Dez',
                                  ];
                                  final monthName =
                                      monthNames[int.parse(month)];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '$monthName/$year',
                                      style: const TextStyle(fontSize: 9),
                                    ),
                                  );
                                }
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
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.asMap().entries.map((e) {
                            return FlSpot(
                              e.key.toDouble(),
                              currencyService.convert(e.value.total, currency),
                            );
                          }).toList(),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 4,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) =>
                              Colors.blueGrey.withValues(alpha: 0.8),
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              final index = touchedSpot.x.toInt();
                              String monthInfo = '';
                              if (index >= 0 && index < data.length) {
                                monthInfo =
                                    '${_formatMonth(data[index].month)}\n';
                              }

                              final displayValue = privacyState.isPrivate
                                  ? '•••••'
                                  : CurrencyFormatter.format(
                                      touchedSpot.y,
                                      currency,
                                    );
                              return LineTooltipItem(
                                '$monthInfo$displayValue',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatMonth(String monthStr) {
    try {
      final parts = monthStr.split('-');
      if (parts.length == 2) {
        final year = parts[0];
        final month = int.parse(parts[1]);
        final monthNames = [
          '',
          'Janeiro',
          'Fevereiro',
          'Março',
          'Abril',
          'Maio',
          'Junho',
          'Julho',
          'Agosto',
          'Setembro',
          'Outubro',
          'Novembro',
          'Dezembro',
        ];
        return '${monthNames[month]} $year';
      }
    } catch (e) {
      debugPrint('Error formatting month: $e');
    }
    return monthStr;
  }

  Widget _buildDetailsList(
    BuildContext context,
    List<dynamic> data,
    Currency currency,
    CurrencyService currencyService,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final reversedData = data.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.netWorthMonthlyHistoryTitle,
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        ...reversedData.map(
          (p) => ListTile(
            title: Text(
              _formatMonth(p.month),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: PrivacyText(
              l10n.netWorthAssetsSubtitle(
                CurrencyFormatter.format(
                  currencyService.convert(p.assets, currency),
                  currency,
                ),
              ),
            ),
            trailing: PrivacyText(
              CurrencyFormatter.format(
                currencyService.convert(p.total, currency),
                currency,
              ),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: p.total >= 0 ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
