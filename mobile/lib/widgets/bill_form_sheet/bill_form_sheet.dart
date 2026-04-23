import 'package:afc/models/bill_model.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/bills/bill_bloc.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BillFormSheet extends StatefulWidget {
  final BillModel? bill;

  const BillFormSheet({super.key, this.bill});

  @override
  State<BillFormSheet> createState() => _BillFormSheetState();
}

class _BillFormSheetState extends State<BillFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _dueDayController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bill?.name);
    _amountController = TextEditingController(
      text: widget.bill?.amount.toString(),
    );
    _dueDayController = TextEditingController(
      text: widget.bill?.dueDay.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.bill != null;

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
                isEditing ? l10n.edit : l10n.add,
                style: AppTextStyles.titleLarge,
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: () {
                    context.read<BillBloc>().add(DeleteBill(widget.bill!.id));
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
              hintText: l10n.billName,
              keyboardType: TextInputType.text,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              controller: _amountController,
              hintText: l10n.billAmount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              controller: _dueDayController,
              hintText: l10n.billDueDay,
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocProvider(
            create: (_) => AdaptiveButtonCubit(),
            child: AdaptiveButton(
              text: l10n.save,
              onPressed: () {
                final data = {
                  'name': _nameController.text,
                  'amount': double.tryParse(_amountController.text) ?? 0,
                  'dueDay': int.tryParse(_dueDayController.text) ?? 1,
                };

                if (isEditing) {
                  context.read<BillBloc>().add(
                    UpdateBill(widget.bill!.id, data),
                  );
                } else {
                  context.read<BillBloc>().add(CreateBill(data));
                }
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
