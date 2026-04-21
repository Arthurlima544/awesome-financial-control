import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/services/navigation_service.dart';
import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/view_models/category/category_edit_cubit.dart';
import 'package:afc/models/category_model.dart';

class CategoryEditScreen extends StatelessWidget {
  const CategoryEditScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CategoryBloc, CategoryState, CategoryModel?>(
      selector: (state) {
        if (state is CategoryData) {
          return state.categories.where((c) => c.id == categoryId).firstOrNull;
        }
        return null;
      },
      builder: (context, category) {
        return BlocProvider(
          create: (_) => CategoryEditCubit(initialCategory: category),
          child: CategoryEditForm(categoryId: categoryId),
        );
      },
    );
  }
}

class CategoryEditForm extends StatefulWidget {
  const CategoryEditForm({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<CategoryEditForm> createState() => _CategoryEditFormState();
}

class _CategoryEditFormState extends State<CategoryEditForm> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CategoryEditCubit>();
    _nameController = TextEditingController(text: cubit.state.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<CategoryEditCubit>();
    if (!cubit.state.isValid) {
      _formKey.currentState!.validate();
      return;
    }

    context.read<CategoryBloc>().add(
      CategoryUpdateRequested(
        id: widget.categoryId,
        name: cubit.state.name.trim(),
      ),
    );

    cubit.saved();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<CategoryEditCubit, CategoryEditState>(
      listenWhen: (previous, current) =>
          current.status == CategoryEditStatus.success,
      listener: (context, state) {
        sl<NavigationService>().pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.categoryEditTitle)),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                BlocBuilder<CategoryEditCubit, CategoryEditState>(
                  buildWhen: (p, c) => p.name != c.name,
                  builder: (context, state) => TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.categoryNameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        context.read<CategoryEditCubit>().nameChanged(v),
                    validator: (_) =>
                        state.isNameValid ? null : l10n.categoryNameLabel,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
