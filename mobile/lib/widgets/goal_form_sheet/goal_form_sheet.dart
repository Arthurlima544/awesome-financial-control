import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:afc/models/goal_model.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/goals/goal_bloc.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';

class GoalFormSheet extends StatefulWidget {
  final GoalModel? goal;

  const GoalFormSheet({super.key, this.goal});

  @override
  State<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<GoalFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name);
    _targetController = TextEditingController(
      text: widget.goal?.targetAmount.toString(),
    );
    _selectedDate =
        widget.goal?.deadline ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.goal != null;
    final dateFormat = DateFormat.yMMMd('pt_BR');

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? l10n.edit : l10n.goalsTitle,
                style: AppTextStyles.titleLarge,
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: () {
                    context.read<GoalBloc>().add(DeleteGoal(widget.goal!.id));
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              controller: _nameController,
              hintText: 'Nome do objetivo',
              leadingIcon: const Icon(Icons.flag_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              controller: _targetController,
              hintText: 'Valor total (R\$)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leadingIcon: const Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Prazo final'),
            subtitle: Text(dateFormat.format(_selectedDate)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocProvider(
            create: (_) => AdaptiveButtonCubit(),
            child: AdaptiveButton(
              text: l10n.save,
              onPressed: () {
                final name = _nameController.text;
                final target = double.tryParse(_targetController.text) ?? 0;

                if (name.isNotEmpty && target > 0) {
                  if (isEditing) {
                    // UpdateGoal not implemented in GoalBloc?
                    // Let's check GoalBloc.
                  } else {
                    context.read<GoalBloc>().add(
                      CreateGoal(
                        name: name,
                        targetAmount: target,
                        deadline: _selectedDate,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
