import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/custom_progress_bar/custom_progress_bar.dart';
import 'package:afc/widgets/empty_state/empty_state.dart';
import 'package:afc/widgets/error_view/error_view.dart';
import 'package:afc/widgets/skeleton/card_skeleton.dart';
import 'package:afc/view_models/limit/limit_bloc.dart';
import 'package:afc/models/limit_progress_model.dart';

class LimitScreen extends StatelessWidget {
  const LimitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LimitBloc>()..add(const LimitProgressLoaded()),
      child: const _LimitView(),
    );
  }
}

class _LimitView extends StatelessWidget {
  const _LimitView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.limitTitle)),
      body: BlocBuilder<LimitBloc, LimitState>(
        builder: (context, state) {
          return switch (state) {
            LimitLoading() || LimitInitial() => ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) => const CardSkeleton(),
            ),
            LimitError() => ErrorView(
              key: const ValueKey('limitError'),
              message: l10n.limitErrorLoading,
              onRetry: () =>
                  context.read<LimitBloc>().add(const LimitProgressLoaded()),
            ),
            LimitLoaded(:final limits) =>
              limits.isEmpty
                  ? EmptyState(
                      key: const ValueKey('limitEmpty'),
                      icon: Icons.price_change_outlined,
                      title: l10n.limitNoLimits,
                    )
                  : RefreshIndicator(
                      onRefresh: () async => context.read<LimitBloc>().add(
                        const LimitProgressLoaded(),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: limits.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _LimitCard(
                          key: ValueKey(limits[index].id),
                          limit: limits[index],
                        ),
                      ),
                    ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({super.key, required this.limit});

  final LimitProgressModel limit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOver = limit.isOverLimit;
    final barColor = isOver ? AppColors.error : AppColors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  limit.categoryName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  limit.percentageFormatted,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            CustomProgressBar(
              key: ValueKey('progress_${limit.id}'),
              initialProgress: limit.progress,
              activeColor: barColor,
              inactiveColor: AppColors.neutral100,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.limitSpent(limit.spentFormatted),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  l10n.limitOf(limit.limitAmountFormatted),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
