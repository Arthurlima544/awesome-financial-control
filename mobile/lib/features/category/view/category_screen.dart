import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/components/adaptive_popup/adaptive_popup.dart';
import '../../../shared/components/adaptive_popup/adaptive_popup_cubit.dart';
import '../../../shared/components/custom_list_tile/custom_list_tile.dart';
import '../../../shared/components/dismissible_delete_background/dismissible_delete_background.dart';
import '../../../shared/components/empty_state/empty_state.dart';
import '../../../shared/components/error_view/error_view.dart';
import '../bloc/category_bloc.dart';
import '../model/category_model.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryBloc()..add(const CategoryFetchRequested()),
      child: const _CategoryView(),
    );
  }
}

class _CategoryView extends StatelessWidget {
  const _CategoryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoryListTitle)),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading || state is CategoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryError) {
            return Center(
              child: ErrorView(
                message: l10n.categoryListError,
                onRetry: () => context.read<CategoryBloc>().add(
                  const CategoryFetchRequested(),
                ),
              ),
            );
          }
          if (state is CategoryData) {
            if (state.categories.isEmpty) {
              return Center(
                child: EmptyState(
                  icon: Icons.category_outlined,
                  title: l10n.categoryListEmpty,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<CategoryBloc>().add(
                const CategoryFetchRequested(),
              ),
              child: ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return _DismissibleItem(category: category, l10n: l10n);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DismissibleItem extends StatelessWidget {
  const _DismissibleItem({required this.category, required this.l10n});

  final CategoryModel category;
  final AppLocalizations l10n;

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => AdaptivePopupCubit(),
        child: AdaptivePopup(
          title: l10n.categoryDeleteConfirmTitle,
          description: l10n.categoryDeleteConfirmMessage,
          primaryButtonText: l10n.delete,
          secondaryButtonText: l10n.cancel,
          primaryColor: AppColors.error,
          onPrimaryAction: (_) => Navigator.of(dialogContext).pop(true),
          onSecondaryAction: () => Navigator.of(dialogContext).pop(false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(category.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => context.read<CategoryBloc>().add(
        CategoryDeleteRequested(category.id),
      ),
      background: const DismissibleDeleteBackground(),
      child: CustomListTile(
        title: category.name,
        leadingType: CustomListTileLeading.icon,
        leadingIcon: Icons.category_outlined,
        trailingType: CustomListTileTrailing.arrow,
        primaryColor: AppColors.primary,
        onTap: () => context.push(
          '/categories/${category.id}/edit',
          extra: context.read<CategoryBloc>(),
        ),
      ),
    );
  }
}
