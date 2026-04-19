import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/components/custom_progress_bar/custom_progress_bar.dart';
import '../../../shared/components/empty_state/empty_state.dart';
import '../../../shared/components/error_view/error_view.dart';
import '../bloc/limit_bloc.dart';
import '../model/limit_progress_model.dart';

class LimitScreen extends StatelessWidget {
  const LimitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LimitBloc()..add(const LimitProgressLoaded()),
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
            LimitLoading() ||
            LimitInitial() => const Center(child: CircularProgressIndicator()),
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
                        padding: const EdgeInsets.all(16),
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
    final progress = (limit.percentage / 100).clamp(0.0, 1.0);
    final isOver = limit.isOverLimit;
    final barColor = isOver ? AppColors.error : AppColors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  '${limit.percentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomProgressBar(
              key: ValueKey('progress_${limit.id}'),
              initialProgress: progress,
              activeColor: barColor,
              inactiveColor: AppColors.neutral100,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.limitSpent('R\$ ${limit.spent.toStringAsFixed(2)}'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  l10n.limitOf('R\$ ${limit.limitAmount.toStringAsFixed(2)}'),
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
