import 'package:afc/view_models/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_config.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/dev_tools_sheet/dev_tools_sheet.dart';
import 'package:afc/view_models/limit/limit_bloc.dart';
import 'package:afc/views/month_limit_view.dart';
import 'package:afc/widgets/empty_state/empty_state.dart';
import 'package:afc/widgets/error_state/error_state.dart';
import 'package:afc/widgets/skeleton/card_skeleton.dart';
import 'package:afc/widgets/skeleton/skeleton_list.dart';
import 'package:afc/widgets/skeleton/skeleton_view.dart';
import 'package:afc/widgets/transaction_list_item/transaction_list_item.dart';
import 'package:afc/widgets/month_summary_card/month_summary_card.dart';
import 'package:afc/view_models/home/home_bloc.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/view_models/investments/investment_bloc.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/view_models/health_score/health_score_bloc.dart';
import 'package:afc/widgets/health_score_card/health_score_card.dart';
import 'package:afc/widgets/animations/fade_in_animation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<LimitBloc>()..add(const LimitProgressLoaded()),
        ),
        BlocProvider(
          create: (_) => sl<InvestmentBloc>()..add(LoadInvestments()),
        ),
        BlocProvider(
          create: (_) => sl<HealthScoreBloc>()..add(const LoadHealthScore()),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  bool _hasShownAlert = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: context.watch<ThemeCubit>().state == ThemeMode.dark
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: l10n.settingsTitle,
          ),
          if (AppConfig.isLocal)
            IconButton(
              icon: const Icon(Icons.developer_mode),
              tooltip: l10n.devToolsTitle,
              onPressed: () {
                final homeBloc = context.read<HomeBloc>();
                final limitBloc = context.read<LimitBloc>();
                showDevToolsSheet(
                  context,
                  onSuccess: () {
                    homeBloc.add(const HomeDashboardLoaded());
                    limitBloc.add(const LimitProgressLoaded());
                  },
                );
              },
            ),
        ],
      ),
      body: BlocListener<LimitBloc, LimitState>(
        listenWhen: (p, c) => p is! LimitLoaded && c is LimitLoaded,
        listener: (context, state) {
          if (state is LimitLoaded && !_hasShownAlert) {
            final overspent = state.limits.where((l) => l.isOverLimit).toList();
            if (overspent.isNotEmpty) {
              _hasShownAlert = true;
              final limitNames = overspent
                  .map((e) => e.categoryName)
                  .join(', ');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Limite excedido: $limitNames')),
                    ],
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const HomeDashboardLoaded());
            context.read<LimitBloc>().add(const LimitProgressLoaded());
            context.read<InvestmentBloc>().add(LoadInvestments());
            context.read<HealthScoreBloc>().add(const LoadHealthScore());
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return switch (state) {
                HomeLoading() || HomeInitial() => ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: const [
                    SkeletonView(width: double.infinity, height: 180),
                    SizedBox(height: AppSpacing.lg),
                    SkeletonView(width: 150, height: 24),
                    SizedBox(height: 12),
                    SkeletonList(itemCount: 3, padding: EdgeInsets.zero),
                  ],
                ),
                HomeError() => ErrorState(
                  key: const ValueKey('homeError'),
                  message: l10n.homeErrorLoading,
                  onRetry: () =>
                      context.read<HomeBloc>().add(const HomeDashboardLoaded()),
                ),
                HomeLoaded(
                  :final transactions,
                  :final totalIncomeFormatted,
                  :final totalExpensesFormatted,
                  :final savingsRate,
                ) =>
                  ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      Text(
                        l10n.homeSummaryTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      FadeInAnimation(
                        trigger: StatefulNavigationShell.of(
                          context,
                        ).currentIndex,
                        child: MonthSummaryCard(
                          key: const ValueKey('summaryCard'),
                          totalIncome: totalIncomeFormatted,
                          totalExpenses: totalExpensesFormatted,
                          savingsRate: savingsRate,
                          onViewReport: () =>
                              StatefulNavigationShell.of(context).goBranch(3),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BlocBuilder<HealthScoreBloc, HealthScoreState>(
                        builder: (context, healthState) {
                          if (healthState.status == HealthScoreStatus.loading &&
                              healthState.healthScore == null) {
                            return const CardSkeleton();
                          }
                          if (healthState.healthScore != null) {
                            return FadeInAnimation(
                              trigger: StatefulNavigationShell.of(
                                context,
                              ).currentIndex,
                              delay: const Duration(milliseconds: 100),
                              child: HealthScoreCard(
                                score: healthState.healthScore!,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FadeInAnimation(
                        trigger: StatefulNavigationShell.of(
                          context,
                        ).currentIndex,
                        delay: const Duration(milliseconds: 200),
                        child: const _NetWorthCard(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.homeRecentTransactions,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      if (transactions.isEmpty)
                        EmptyState(
                          key: const ValueKey('homeEmptyTransactions'),
                          icon: Icons.receipt_long_outlined,
                          title: l10n.homeNoTransactions,
                        )
                      else
                        ...List.generate(transactions.length, (index) {
                          final t = transactions[index];
                          return FadeInAnimation(
                            trigger: StatefulNavigationShell.of(
                              context,
                            ).currentIndex,
                            delay: Duration(milliseconds: 300 + (index * 50)),
                            child: TransactionListItem(
                              key: ValueKey(t.id),
                              description: t.description,
                              amount: t.amount,
                              type: t.type == TransactionType.income
                                  ? TransactionItemType.income
                                  : TransactionItemType.expense,
                              category: t.category,
                              occurredAt: t.occurredAt,
                            ),
                          );
                        }),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Limites',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<LimitBloc, LimitState>(
                        builder: (context, limitState) {
                          return switch (limitState) {
                            LimitLoading() || LimitInitial() => const Column(
                              children: [
                                CardSkeleton(),
                                SizedBox(height: AppSpacing.sm),
                                CardSkeleton(),
                              ],
                            ),
                            LimitError() => ErrorState(
                              message: l10n.limitErrorLoading,
                              onRetry: () => context.read<LimitBloc>().add(
                                const LimitProgressLoaded(),
                              ),
                            ),
                            LimitLoaded(:final limits) =>
                              limits.isEmpty
                                  ? EmptyState(
                                      icon: Icons.price_change_outlined,
                                      title: l10n.limitNoLimits,
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: limits
                                          .map(
                                            (limit) => MonthLimitView(
                                              key: ValueKey(limit.id),
                                              limit: limit,
                                            ),
                                          )
                                          .toList(),
                                    ),
                            _ => const SizedBox.shrink(),
                          };
                        },
                      ),
                      const SizedBox(height: 80), // Padding for FAB
                    ],
                  ),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }
}

// MonthSummaryCard is now a separate reusable widget

class _NetWorthCard extends StatelessWidget {
  const _NetWorthCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return BlocBuilder<InvestmentBloc, InvestmentState>(
      builder: (context, state) {
        if (state.status == InvestmentStatus.loading &&
            state.investments.isEmpty) {
          return const SkeletonView(width: double.infinity, height: 80);
        }

        final totalInvestments = state.totalCurrentValue;

        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            double balance = 0;
            if (homeState is HomeLoaded) {
              balance = homeState.summary.balance;
            }

            final totalNetWorth = balance + totalInvestments;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              elevation: 0,
              color: AppColors.primary.withValues(alpha: 0.05),
              child: InkWell(
                onTap: () => context.push('/investments'),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          size: AppSpacing.iconMd,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.totalNetWorth,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.neutral700,
                              ),
                            ),
                            Text(
                              currencyFormat.format(totalNetWorth),
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.neutral500,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
