import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/view_models/net_worth/net_worth_bloc.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:afc/view_models/privacy/privacy_cubit.dart';

class NetWorthScreen extends StatelessWidget {
  const NetWorthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evolução do Patrimônio')),
      body: BlocBuilder<NetWorthBloc, NetWorthState>(
        builder: (context, state) {
          if (state.status == NetWorthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NetWorthStatus.failure) {
            return Center(child: Text('Erro: ${state.errorMessage}'));
          }

          if (state.data.isEmpty) {
            return const Center(child: Text('Nenhum dado disponível'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NetWorthBloc>().add(LoadNetWorthEvolution());
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _buildSummary(state.data.last),
                const SizedBox(height: AppSpacing.xl),
                _buildEvolutionChart(state.data),
                const SizedBox(height: AppSpacing.xl),
                _buildDetailsList(state.data),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(dynamic latest) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
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
            Text('Patrimônio Líquido Atual', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            PrivacyText(
              currencyFormat.format(latest.total),
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Ativos', latest.assets, AppColors.success),
                _buildMiniStat('Passivos', latest.liabilities, AppColors.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, double value, Color color) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        PrivacyText(
          currencyFormat.format(value),
          style: AppTextStyles.titleSmall.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildEvolutionChart(List<dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Evolução do Patrimônio', style: AppTextStyles.titleMedium),
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
                            return FlSpot(e.key.toDouble(), e.value.total);
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
                            final currencyFormat = NumberFormat.simpleCurrency(
                              locale: 'pt_BR',
                            );
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              final index = touchedSpot.x.toInt();
                              String monthInfo = '';
                              if (index >= 0 && index < data.length) {
                                monthInfo =
                                    '${_formatMonth(data[index].month)}\n';
                              }

                              final displayValue = privacyState.isPrivate
                                  ? '•••••'
                                  : currencyFormat.format(touchedSpot.y);
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
    } catch (_) {}
    return monthStr;
  }

  Widget _buildDetailsList(List<dynamic> data) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final reversedData = data.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Histórico Mensal', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.md),
        ...reversedData.map(
          (p) => ListTile(
            title: Text(
              _formatMonth(p.month),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: PrivacyText('Ativos: ${currencyFormat.format(p.assets)}'),
            trailing: PrivacyText(
              currencyFormat.format(p.total),
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
