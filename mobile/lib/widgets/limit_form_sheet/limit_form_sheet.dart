import 'package:afc/models/category_model.dart';
import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/widgets/custom_snackbar/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:afc/models/limit_model.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/limit_list/limit_list_bloc.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';

class LimitFormSheet extends StatefulWidget {
  final LimitModel? limit;

  const LimitFormSheet({super.key, this.limit});

  @override
  State<LimitFormSheet> createState() => _LimitFormSheetState();
}

class _LimitFormSheetState extends State<LimitFormSheet> {
  String? _selectedCategoryId;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.limit?.amount.toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.limit != null;

    return BlocProvider(
      create: (_) => sl<CategoryBloc>()..add(const CategoryFetchRequested()),
      child: BlocListener<LimitListBloc, LimitListState>(
        listener: (context, state) {
          if (state is LimitListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomSnackbar(
                  title: state.message,
                  backgroundColor: AppColors.error,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            );
          }
        },
        child: Container(
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
                    isEditing ? l10n.limitEditTitle : l10n.limitListTitle,
                    style: AppTextStyles.titleLarge,
                  ),
                  if (isEditing)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () {
                        context.read<LimitListBloc>().add(
                          LimitListDeleteRequested(widget.limit!.id),
                        );
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (isEditing)
                Text(
                  widget.limit!.categoryName,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.grey),
                )
              else
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    List<CategoryModel> categories = [];
                    if (state is CategoryData) {
                      categories = state.categories;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration: InputDecoration(
                        hintText: l10n.categoryNameLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                      ),
                      items: categories.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value);
                      },
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.md),
              BlocProvider(
                create: (_) => AdaptiveTextFieldCubit(),
                child: AdaptiveTextField(
                  controller: _amountController,
                  hintText: l10n.limitAmountLabel,
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
                    final amount = double.tryParse(_amountController.text) ?? 0;

                    if (isEditing) {
                      context.read<LimitListBloc>().add(
                        LimitListUpdateRequested(
                          id: widget.limit!.id,
                          amount: amount,
                        ),
                      );
                    } else {
                      if (_selectedCategoryId == null) return;
                      context.read<LimitListBloc>().add(
                        LimitListCreateRequested(
                          categoryId: _selectedCategoryId!,
                          amount: amount,
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
