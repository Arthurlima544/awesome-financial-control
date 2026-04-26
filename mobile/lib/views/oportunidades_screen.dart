import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/repositories/market_repository.dart';
import 'package:afc/view_models/market_opportunity/market_opportunity_bloc.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:afc/widgets/app_tooltip_icon/app_tooltip_icon.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/error_state/error_state.dart';
import 'package:afc/utils/app_formatters.dart';

class OportunidadesScreen extends StatelessWidget {
  const OportunidadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.marketScreenTitle)),
      body: BlocBuilder<MarketOpportunityBloc, MarketOpportunityState>(
        builder: (context, state) {
          if (state.status == MarketOpportunityStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MarketOpportunityStatus.failure) {
            return ErrorState(
              message: l10n.calcErrorMessage(state.errorMessage ?? ''),
              onRetry: () {
                context.read<MarketOpportunityBloc>().add(
                  RefreshMarketOpportunities(),
                );
              },
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
                      l10n.marketLastUpdated(
                        AppFormatters.dayMonthYear.format(
                          state.opportunities.first.lastUpdated.toLocal(),
                        ),
                      ),
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
                  (o) => _buildOpportunityCard(context, o),
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
    final l10n = AppLocalizations.of(context)!;
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
            l10n.marketBenchmarksTitle,
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
                l10n.tooltipCDITitle,
                '${benchmarks.cdiRate.toStringAsFixed(2)}%',
                hasInfo: true,
                description: l10n.tooltipCDIDesc,
              ),
              _buildBenchmarkItem(
                context,
                l10n.tooltipSelicTitle,
                '${benchmarks.selicRate.toStringAsFixed(2)}%',
                hasInfo: true,
                description: l10n.tooltipSelicDesc,
              ),
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
    String? description,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.labelSmall),
            if (hasInfo && description != null)
              AppTooltipIcon(
                title: label,
                description: description,
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
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        FilterChip(
          label: Text(l10n.marketFilterAll),
          selected: state.filter == MarketFilter.all,
          onSelected: (_) => context.read<MarketOpportunityBloc>().add(
            MarketFilterChanged(MarketFilter.all),
          ),
        ),
        FilterChip(
          label: Text(l10n.marketFilterStocks),
          selected: state.filter == MarketFilter.stocks,
          onSelected: (_) => context.read<MarketOpportunityBloc>().add(
            MarketFilterChanged(MarketFilter.stocks),
          ),
        ),
        FilterChip(
          label: Text(l10n.marketFilterFiis),
          selected: state.filter == MarketFilter.fiis,
          onSelected: (_) => context.read<MarketOpportunityBloc>().add(
            MarketFilterChanged(MarketFilter.fiis),
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions(BuildContext context, MarketOpportunityState state) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSortChip(
            context,
            l10n.marketSortHighestDy,
            MarketSort.dyDesc,
            state.sort,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildSortChip(
            context,
            l10n.marketSortDyVsCdi,
            MarketSort.dyVsCdiDesc,
            state.sort,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildSortChip(
            context,
            l10n.marketSortLowestPe,
            MarketSort.peAsc,
            state.sort,
          ),
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

  Widget _buildOpportunityCard(BuildContext context, MarketOpportunity o) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            if (o.logoUrl != null && o.logoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Image.network(
                    o.logoUrl!,
                    width: 32,
                    height: 32,
                    errorBuilder: (_, _, _) => _buildLogoPlaceholder(o.ticker),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: _buildLogoPlaceholder(o.ticker),
              ),
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
                  AppFormatters.currencyPtBR.format(o.price),
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
                Text(
                  l10n.marketDyColumnHeader,
                  style: AppTextStyles.labelSmall,
                ),
                PrivacyText(
                  '${o.dividendYield.toStringAsFixed(2)}%',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (o.dyVsCdi > 0)
                  PrivacyText(
                    l10n.marketDyVsCdiPercent((o.dyVsCdi * 100).toInt()),
                    style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder(String ticker) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Center(
        child: Text(
          ticker.substring(0, ticker.length > 2 ? 2 : ticker.length),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
