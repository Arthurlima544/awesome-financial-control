import 'package:afc/models/investment_model.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/view_models/investments/investment_bloc.dart';
import 'package:afc/widgets/circular_button/circular_button.dart';
import 'package:afc/widgets/circular_button/circular_button_cubit.dart';
import 'package:afc/widgets/investment_form_sheet/investment_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/animations/fade_in_animation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class InvestmentsScreen extends StatelessWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final percentFormat = NumberFormat.decimalPercentPattern(
      locale: 'pt_BR',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                onPressed: () => context.push('/investments/dashboard'),
                tooltip: 'Análise do Portfólio',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                l10n.investmentsTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(
                left: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: BlocBuilder<InvestmentBloc, InvestmentState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      FadeInAnimation(
                        trigger: StatefulNavigationShell.of(
                          context,
                        ).currentIndex,
                        child: _PortfolioSummaryCard(
                          totalInvested: state.totalInvested,
                          totalCurrentValue: state.totalCurrentValue,
                          totalGainLoss: state.totalGainLoss,
                          totalGainLossPercentage:
                              state.totalGainLossPercentage,
                          currencyFormat: currencyFormat,
                          percentFormat: percentFormat,
                          l10n: l10n,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                },
              ),
            ),
          ),
          BlocBuilder<InvestmentBloc, InvestmentState>(
            builder: (context, state) {
              if (state.status == InvestmentStatus.loading &&
                  state.investments.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.investments.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      l10n.investmentsNoInvestments,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final investment = state.investments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: FadeInAnimation(
                        trigger: StatefulNavigationShell.of(
                          context,
                        ).currentIndex,
                        delay: Duration(milliseconds: 100 + (index * 50)),
                        child: _InvestmentCard(
                          investment: investment,
                          currencyFormat: currencyFormat,
                          percentFormat: percentFormat,
                          onTap: () => _showInvestmentForm(context, investment),
                        ),
                      ),
                    );
                  }, childCount: state.investments.length),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: BlocProvider(
        create: (_) => CircularButtonCubit(),
        child: CircularButton(
          icon: Icons.add,
          onPressed: () => _showInvestmentForm(context),
          semanticLabel: l10n.add,
        ),
      ),
    );
  }

  void _showInvestmentForm(
    BuildContext context, [
    InvestmentModel? investment,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<InvestmentBloc>(),
        child: InvestmentFormSheet(investment: investment),
      ),
    );
  }
}

class _PortfolioSummaryCard extends StatelessWidget {
  final double totalInvested;
  final double totalCurrentValue;
  final double totalGainLoss;
  final double totalGainLossPercentage;
  final NumberFormat currencyFormat;
  final NumberFormat percentFormat;
  final AppLocalizations l10n;

  const _PortfolioSummaryCard({
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.totalGainLoss,
    required this.totalGainLossPercentage,
    required this.currencyFormat,
    required this.percentFormat,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = totalGainLoss >= 0;
    final color = isProfit ? AppColors.success : AppColors.error;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.investmentsCurrentValue,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              currencyFormat.format(totalCurrentValue),
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  isProfit ? Icons.trending_up : Icons.trending_down,
                  color: color,
                  size: AppSpacing.iconSm,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${currencyFormat.format(totalGainLoss.abs())} (${percentFormat.format(totalGainLossPercentage / 100)})',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.investmentsTotalInvested,
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  currencyFormat.format(totalInvested),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final InvestmentModel investment;
  final NumberFormat currencyFormat;
  final NumberFormat percentFormat;
  final VoidCallback onTap;

  const _InvestmentCard({
    required this.investment,
    required this.currencyFormat,
    required this.percentFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = investment.gainLoss >= 0;
    final color = isProfit ? AppColors.success : AppColors.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _InvestmentTypeIcon(type: investment.type),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investment.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (investment.ticker != null &&
                      investment.ticker!.isNotEmpty)
                    Text(investment.ticker!, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(investment.currentValue),
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${isProfit ? '+' : ''}${percentFormat.format(investment.gainLossPercentage / 100)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestmentTypeIcon extends StatelessWidget {
  final InvestmentType type;

  const _InvestmentTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case InvestmentType.stock:
        icon = Icons.show_chart;
        color = AppColors.info;
        break;
      case InvestmentType.fixedIncome:
        icon = Icons.account_balance;
        color = AppColors.success;
        break;
      case InvestmentType.crypto:
        icon = Icons.currency_bitcoin;
        color = AppColors.warning;
        break;
      case InvestmentType.other:
        icon = Icons.category;
        color = AppColors.secondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: AppSpacing.iconMd),
    );
  }
}
