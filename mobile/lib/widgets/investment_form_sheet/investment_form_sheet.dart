import 'package:afc/models/investment_model.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/view_models/investments/investment_bloc.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_segmented_control/adaptive_segmented_control.dart';
import 'package:afc/widgets/adaptive_segmented_control/adaptive_segmented_control_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';

class InvestmentFormSheet extends StatefulWidget {
  final InvestmentModel? investment;

  const InvestmentFormSheet({super.key, this.investment});

  @override
  State<InvestmentFormSheet> createState() => _InvestmentFormSheetState();
}

class _InvestmentFormSheetState extends State<InvestmentFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _tickerController;
  late final TextEditingController _quantityController;
  late final TextEditingController _avgCostController;
  late final TextEditingController _currentPriceController;
  InvestmentType _selectedType = InvestmentType.stock;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.investment?.name);
    _tickerController = TextEditingController(text: widget.investment?.ticker);
    _quantityController = TextEditingController(
      text: widget.investment?.quantity.toString(),
    );
    _avgCostController = TextEditingController(
      text: widget.investment?.avgCost.toString(),
    );
    _currentPriceController = TextEditingController(
      text: widget.investment?.currentPrice.toString(),
    );
    _selectedType = widget.investment?.type ?? InvestmentType.stock;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tickerController.dispose();
    _quantityController.dispose();
    _avgCostController.dispose();
    _currentPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.investment != null;

    final types = [
      l10n.investmentTypeStock,
      l10n.investmentTypeFixedIncome,
      l10n.investmentTypeCrypto,
      l10n.investmentTypeOther,
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () {
                    context.read<InvestmentBloc>().add(
                      DeleteInvestment(widget.investment!.id),
                    );
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          BlocProvider(
            create: (_) => AdaptiveSegmentedControlCubit(
              initialIndex: _selectedType.index,
            ),
            child: AdaptiveSegmentedControl(
              segments: types,
              semanticLabel: l10n.investmentType,
              onChanged: (index) {
                setState(() {
                  _selectedType = InvestmentType.values[index];
                });
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              controller: _nameController,
              hintText: l10n.investmentName,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              controller: _tickerController,
              hintText: l10n.investmentTicker,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: BlocProvider(
                  create: (_) => AdaptiveTextFieldCubit(),
                  child: AdaptiveTextField(
                    controller: _quantityController,
                    hintText: l10n.investmentQuantity,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BlocProvider(
                  create: (_) => AdaptiveTextFieldCubit(),
                  child: AdaptiveTextField(
                    controller: _avgCostController,
                    hintText: l10n.investmentAvgCost,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              controller: _currentPriceController,
              hintText: l10n.investmentCurrentPrice,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
                  'ticker': _tickerController.text,
                  'type': _selectedType.toJson(),
                  'quantity': double.tryParse(_quantityController.text) ?? 0,
                  'avgCost': double.tryParse(_avgCostController.text) ?? 0,
                  'currentPrice':
                      double.tryParse(_currentPriceController.text) ?? 0,
                };

                if (isEditing) {
                  context.read<InvestmentBloc>().add(
                    UpdateInvestment(widget.investment!.id, data),
                  );
                } else {
                  context.read<InvestmentBloc>().add(CreateInvestment(data));
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
