import 'package:afc/models/recurring_transaction_model.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/recurring/recurring_bloc.dart';
import 'package:afc/view_models/recurring/recurring_form_cubit.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_date_picker/adaptive_date_picker.dart';
import 'package:afc/widgets/adaptive_date_picker/adaptive_date_picker_cubit.dart';
import 'package:afc/widgets/adaptive_segmented_control/adaptive_segmented_control.dart';
import 'package:afc/widgets/adaptive_segmented_control/adaptive_segmented_control_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:afc/repositories/recurring_repository.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurringFormSheet extends StatelessWidget {
  final RecurringTransactionModel? initial;

  const RecurringFormSheet({super.key, this.initial});

  static Future<void> show(
    BuildContext context, {
    RecurringTransactionModel? initial,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (modalContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<RecurringBloc>()),
          BlocProvider(create: (_) => RecurringFormCubit(initial: initial)),
        ],
        child: RecurringFormSheet(initial: initial),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<RecurringFormCubit>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.recurringFormTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            BlocProvider(
              create: (_) =>
                  AdaptiveTextFieldCubit()
                    ..textChanged(cubit.state.description),
              child: AdaptiveTextField(
                hintText: l10n.transactionDescriptionLabel,
                onChanged: cubit.onDescriptionChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BlocProvider(
              create: (_) =>
                  AdaptiveTextFieldCubit()..textChanged(cubit.state.amount),
              child: AdaptiveTextField(
                hintText: l10n.transactionAmountLabel,
                onChanged: cubit.onAmountChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BlocProvider(
              create: (_) => AdaptiveSegmentedControlCubit(
                initialIndex: cubit.state.type.index,
              ),
              child: AdaptiveSegmentedControl(
                semanticLabel: 'Tipo',
                segments: [l10n.income, l10n.expense],
                onChanged: (index) =>
                    cubit.onTypeChanged(TransactionType.values[index]),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.recurringFormFrequencyLabel,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            BlocProvider(
              create: (_) => AdaptiveSegmentedControlCubit(
                initialIndex: cubit.state.frequency.index,
              ),
              child: AdaptiveSegmentedControl(
                semanticLabel: l10n.recurringFormFrequencyLabel,
                segments: [
                  l10n.recurringFrequencyDaily,
                  l10n.recurringFrequencyWeekly,
                  l10n.recurringFrequencyMonthly,
                ],
                onChanged: (index) =>
                    cubit.onFrequencyChanged(RecurrenceFrequency.values[index]),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.recurringFormNextDueLabel,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            BlocProvider(
              create: (_) => AdaptiveDatePickerCubit(
                initialMonth: cubit.state.nextDueAt,
                initialSelectedDate: cubit.state.nextDueAt,
              ),
              child: AdaptiveDatePicker(
                semanticLabel: l10n.recurringFormNextDueLabel,
                onDateSelected: cubit.onNextDueAtChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BlocBuilder<RecurringFormCubit, RecurringFormState>(
              builder: (context, state) {
                return BlocProvider(
                  create: (_) =>
                      AdaptiveButtonCubit()..setLoading(state.isSubmitting),
                  child: AdaptiveButton(
                    text: l10n.save,
                    onPressed: () => _submit(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final cubit = context.read<RecurringFormCubit>();
    final state = cubit.state;

    if (state.description.isEmpty || state.amount.isEmpty) return;

    cubit.setSubmitting(true);
    try {
      final repo = sl<RecurringRepository>();
      final rule = RecurringTransactionModel(
        id: initial?.id ?? '',
        description: state.description,
        amount: double.parse(state.amount),
        type: state.type,
        category: state.category,
        frequency: state.frequency,
        nextDueAt: state.nextDueAt,
        active: state.active,
      );

      if (initial == null) {
        await repo.create(rule);
      } else {
        await repo.update(rule);
      }
      sl<AppRefreshBloc>().add(DataChanged());
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      cubit.setError(e.toString());
    } finally {
      cubit.setSubmitting(false);
    }
  }
}
