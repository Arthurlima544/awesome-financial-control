import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:afc/models/category_model.dart';

class CategoryFormSheet extends StatefulWidget {
  final CategoryModel? category;
  final Function(String)? onCategoryCreated;

  const CategoryFormSheet({super.key, this.category, this.onCategoryCreated});

  static Future<void> show(
    BuildContext context, {
    CategoryModel? category,
    Function(String)? onCategoryCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoryBloc>(),
        child: CategoryFormSheet(
          category: category,
          onCategoryCreated: onCategoryCreated,
        ),
      ),
    );
  }

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (widget.category != null) {
      context.read<CategoryBloc>().add(
        CategoryUpdateRequested(id: widget.category!.id, name: name),
      );
    } else {
      context.read<CategoryBloc>().add(CategoryCreateRequested(name));
      widget.onCategoryCreated?.call(name);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.category != null;

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
          Text(
            isEditing ? l10n.categoryEditTitle : l10n.categoryListTitle,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              controller: _nameController,
              hintText: l10n.categoryNameLabel,
              keyboardType: TextInputType.text,
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocProvider(
            create: (_) => AdaptiveButtonCubit(),
            child: AdaptiveButton(
              text: l10n.save,
              size: AdaptiveButtonSize.fullWidth,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
