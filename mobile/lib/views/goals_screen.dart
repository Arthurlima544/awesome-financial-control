import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/view_models/goals/goal_bloc.dart';
import 'package:afc/view_models/privacy/privacy_cubit.dart';
import 'package:afc/models/goal_model.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/empty_state/empty_state.dart';
import 'package:afc/widgets/error_state/error_state.dart';
import 'package:afc/widgets/skeleton/skeleton_view.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/goal_form_sheet/goal_form_sheet.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:intl/intl.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GoalBloc>()..add(LoadGoals()),
      child: const _GoalsView(),
    );
  }
}

class _GoalsView extends StatelessWidget {
  const _GoalsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      body: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          if (state.status == GoalStatus.loading && state.goals.isEmpty) {
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: 3,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) =>
                  const SkeletonView(width: double.infinity, height: 120),
            );
          }
          if (state.status == GoalStatus.failure) {
            return Center(
              child: ErrorState(
                message: l10n.goalsErrorLoading,
                onRetry: () => context.read<GoalBloc>().add(LoadGoals()),
              ),
            );
          }
          if (state.goals.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.savings_outlined,
                title: l10n.goalsNoGoals,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: state.goals.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) =>
                _GoalCard(goal: state.goals[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'goals_fab',
        onPressed: () => _showAddGoalForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoalForm(BuildContext context, [GoalModel? goal]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GoalBloc>(),
        child: GoalFormSheet(goal: goal),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalModel goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final deadlineFormat = DateFormat.yMMMMd('pt_BR');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.savings, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      PrivacyText(
                        'Meta: ${currencyFormat.format(goal.targetAmount)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showContributionDialog(context),
                  color: AppColors.primary,
                  tooltip: 'Adicionar contribuição',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _showDeleteConfirm(context),
                  color: AppColors.error,
                  tooltip: 'Excluir objetivo',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            BlocBuilder<PrivacyCubit, PrivacyState>(
              builder: (context, privacyState) {
                return LinearProgressIndicator(
                  value: privacyState.isPrivate
                      ? 0.0
                      : goal.progressPercentage / 100,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PrivacyText(
                  '${goal.progressPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${goal.daysRemaining} dias restantes',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 10, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Até ${deadlineFormat.format(goal.deadline)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showContributionDialog(BuildContext context) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Adicionar Contribuição'),
        content: SizedBox(
          width: 300,
          height: 100,
          child: BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              controller: amountController,
              hintText: 'Valor',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leadingIcon: const Icon(Icons.attach_money),
              focusedBorderColor: AppColors.primary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          BlocProvider(
            create: (_) => AdaptiveButtonCubit(),
            child: AdaptiveButton(
              text: 'Adicionar',
              primaryColor: AppColors.primary,
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  context.read<GoalBloc>().add(
                    ContributeToGoal(goalId: goal.id, amount: amount),
                  );
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Objetivo'),
        content: Text('Deseja realmente excluir o objetivo "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          BlocProvider(
            create: (_) => AdaptiveButtonCubit(),
            child: AdaptiveButton(
              text: 'Excluir',
              primaryColor: AppColors.error,
              onPressed: () {
                context.read<GoalBloc>().add(DeleteGoal(goal.id));
                Navigator.pop(dialogContext);
              },
            ),
          ),
        ],
      ),
    );
  }
}
