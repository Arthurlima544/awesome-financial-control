import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:afc/repositories/market_repository.dart';
import 'package:afc/view_models/market_opportunity/market_opportunity_bloc.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:afc/widgets/app_tooltip_icon/app_tooltip_icon.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';

class OportunidadesScreen extends StatelessWidget {
  const OportunidadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oportunidades de Mercado')),
      body: BlocBuilder<MarketOpportunityBloc, MarketOpportunityState>(
        builder: (context, state) {
          if (state.status == MarketOpportunityStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MarketOpportunityStatus.failure) {
            return Center(
              child: Text(
                'Erro: ${state.errorMessage}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<MarketOpportunityBloc>();
              bloc.add(RefreshMarketOpportunities());
              // Wait for completion
              await bloc.stream.firstWhere(
                (state) =>
                    state.status == MarketOpportunityStatus.success ||
                    state.status == MarketOpportunityStatus.failure,
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (state.opportunities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      'Última atualização: ${DateFormat('dd/MM/yyyy HH:mm').format(state.opportunities.first.lastUpdated.toLocal())}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (state.benchmarks != null)
                  _buildBenchmarkBanner(context, state.benchmarks!),
                const SizedBox(height: AppSpacing.lg),
                _buildFilters(context, state),
                const SizedBox(height: AppSpacing.md),
                _buildSortOptions(context, state),
                const SizedBox(height: AppSpacing.lg),
                ...state.filteredOpportunities.map(
                  (o) => _buildOpportunityCard(o),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenchmarkBanner(
    BuildContext context,
    MarketBenchmarks benchmarks,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benchmarks Fixos',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBenchmarkItem(
                context,
                'CDI',
                '${benchmarks.cdiRate.toStringAsFixed(2)}%',
                hasInfo: true,
              ),
              _buildBenchmarkItem(
                context,
                'Selic',
                '${benchmarks.selicRate.toStringAsFixed(2)}%',
              ),
              _buildBenchmarkItem(context, 'IPCA (est.)', '4.50%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkItem(
    BuildContext context,
    String label,
    String value, {
    bool hasInfo = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.labelSmall),
            if (hasInfo)
              AppTooltipIcon(
                title: label,
                description: l10n.tooltipCDIDesc,
                iconSize: 12,
              ),
          ],
        ),
        PrivacyText(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, MarketOpportunityState state) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        FilterChip(
          label: const Text('Todos'),
          selected: state.filter == MarketFilter.all,
          onSelected: (_) => context.read<MarketOpportunityBloc>().add(
            MarketFilterChanged(MarketFilter.all),
          ),
        ),
        FilterChip(
          label: const Text('Ações'),
          selected: state.filter == MarketFilter.stocks,
          onSelected: (_) => context.read<MarketOpportunityBloc>().add(
            MarketFilterChanged(MarketFilter.stocks),
          ),
        ),
        FilterChip(
          label: const Text('FIIs'),
          selected: state.filter == MarketFilter.fiis,
          onSelected: (_) => context.read<MarketOpportunityBloc>().add(
            MarketFilterChanged(MarketFilter.fiis),
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions(BuildContext context, MarketOpportunityState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSortChip(context, 'Maior DY', MarketSort.dyDesc, state.sort),
          const SizedBox(width: AppSpacing.sm),
          _buildSortChip(
            context,
            'DY vs CDI',
            MarketSort.dyVsCdiDesc,
            state.sort,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildSortChip(context, 'Menor P/L', MarketSort.peAsc, state.sort),
        ],
      ),
    );
  }

  Widget _buildSortChip(
    BuildContext context,
    String label,
    MarketSort value,
    MarketSort current,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: current == value,
      onSelected: (selected) {
        if (selected) {
          context.read<MarketOpportunityBloc>().add(MarketSortChanged(value));
        }
      },
    );
  }

  Widget _buildOpportunityCard(MarketOpportunity o) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        o.ticker,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      if (o.isFii)
                        const Badge(
                          label: Text('FII'),
                          backgroundColor: Colors.orange,
                        ),
                    ],
                  ),
                  Text(
                    o.name,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PrivacyText(
                  currencyFormat.format(o.price),
                  style: AppTextStyles.labelLarge,
                ),
                PrivacyText(
                  '${o.changePercent > 0 ? '+' : ''}${o.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: o.changePercent >= 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('DY (ano)', style: AppTextStyles.labelSmall),
                PrivacyText(
                  '${o.dividendYield.toStringAsFixed(2)}%',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (o.dyVsCdi > 0)
                  PrivacyText(
                    '${(o.dyVsCdi * 100).toStringAsFixed(0)}% do CDI',
                    style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
