import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/view_models/investments/investment_dashboard_bloc.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:afc/models/investment_dashboard_data.dart';
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:afc/services/currency_service.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/currency_formatter.dart';
import 'package:afc/models/currency.dart';
import 'package:afc/widgets/error_state/error_state.dart';

class InvestmentDashboardScreen extends StatelessWidget {
  const InvestmentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.investmentDashboardTitle)),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final currency = settingsState.selectedCurrency;
          final currencyService = sl<CurrencyService>();

          return BlocBuilder<InvestmentDashboardBloc, InvestmentDashboardState>(
            builder: (context, state) {
              if (state.status == InvestmentDashboardStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == InvestmentDashboardStatus.failure) {
                return ErrorState(
                  message: l10n.calcErrorMessage(state.errorMessage ?? ''),
                  onRetry: () {
                    context.read<InvestmentDashboardBloc>().add(
                      LoadInvestmentDashboard(),
                    );
                  },
                );
              }

              if (state.data == null) {
                return Center(child: Text(l10n.screenNoDataAvailable));
              }

              final data = state.data!;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<InvestmentDashboardBloc>().add(
                    LoadInvestmentDashboard(),
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _buildSummaryCards(
                      context,
                      data,
                      currency,
                      currencyService,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildAllocationChart(context, data.allocationByType),
                    const SizedBox(height: AppSpacing.xl),
                    _buildPerformanceList(
                      context,
                      data.assetPerformance,
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

  Widget _buildSummaryCards(
    BuildContext context,
    InvestmentDashboardData data,
    Currency currency,
    CurrencyService currencyService,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final profit = data.totalProfitLoss;
    final percentage = data.totalProfitLossPercentage;
    final isPositive = profit >= 0;

    return Column(
      children: [
        Card(
          elevation: 0,
          color: AppColors.primary.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.totalNetWorth, style: AppTextStyles.labelLarge),
                    PrivacyText(
                      CurrencyFormatter.format(
                        currencyService.convert(
                          data.currentTotalValue,
                          currency,
                        ),
                        currency,
                      ),
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      PrivacyText(
                        '${percentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildSmallCard(
                l10n.investmentsTotalInvested,
                CurrencyFormatter.format(
                  currencyService.convert(data.totalInvested, currency),
                  currency,
                ),
                Colors.grey,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildSmallCard(
                l10n.investmentDashboardProfitLossLabel,
                CurrencyFormatter.format(
                  currencyService.convert(profit, currency),
                  currency,
                ),
                isPositive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallCard(String title, String value, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            PrivacyText(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationChart(
    BuildContext context,
    Map<String, double> allocation,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (allocation.isEmpty) return const SizedBox.shrink();

    final sections = <PieChartSectionData>[];
    final colors = [
      const Color(0xFF00BFA5),
      const Color(0xFF2979FF),
      const Color(0xFFFF9100),
      const Color(0xFF651FFF),
    ];

    int index = 0;
    allocation.forEach((type, value) {
      sections.add(
        PieChartSectionData(
          value: (value as num).toDouble(),
          color: colors[index % colors.length],
          radius: 50,
          showTitle: false,
        ),
      );
      index++;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.investmentDashboardAllocationTitle,
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
            child: Row(
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(allocation.length, (i) {
                      final key = allocation.keys.elementAt(i);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildLegendItem(
                          colors[i % colors.length],
                          key.toString().split('.').last,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }

  Widget _buildPerformanceList(
    BuildContext context,
    List<AssetPerformance> performances,
    Currency currency,
    CurrencyService currencyService,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.investmentDashboardPerformanceTitle,
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        ...performances.map((p) {
          final isPositive = p.profitLoss >= 0;
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              title: Text(
                (p.ticker != null && p.ticker!.isNotEmpty) ? p.ticker! : p.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: (p.ticker != null && p.ticker!.isNotEmpty)
                  ? Text(p.name)
                  : null,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PrivacyText(
                    CurrencyFormatter.format(
                      currencyService.convert(p.profitLoss, currency),
                      currency,
                    ),
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PrivacyText(
                    '${p.percentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
