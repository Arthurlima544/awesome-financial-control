import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/adaptive_popup/adaptive_popup.dart';
import 'package:afc/widgets/adaptive_popup/adaptive_popup_cubit.dart';
import 'package:afc/widgets/dismissible_delete_background/dismissible_delete_background.dart';
import 'package:afc/widgets/empty_state/empty_state.dart';
import 'package:afc/widgets/error_state/error_state.dart';
import 'package:afc/widgets/transaction_list_item/transaction_list_item.dart';

import 'package:afc/utils/config/injection.dart';
import 'package:afc/widgets/adaptive_chip/adaptive_chip_cubit.dart';
import 'package:afc/widgets/skeleton/skeleton_list.dart';
import 'package:afc/services/navigation_service.dart';
import 'package:afc/view_models/transaction_list/transaction_list_bloc.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/services/transaction_grouper.dart';
import 'package:afc/models/transaction_group.dart';
import 'package:afc/widgets/adaptive_search_bar/adaptive_search_bar.dart';
import 'package:afc/widgets/adaptive_search_bar/adaptive_search_bar_cubit.dart';
import 'package:afc/widgets/adaptive_chip/adaptive_chip.dart';
import 'package:afc/widgets/custom_date_picker/custom_date_picker.dart';
import 'package:afc/widgets/custom_date_picker/custom_date_picker_cubit.dart'
    as picker;
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:afc/services/currency_service.dart';
import 'package:afc/utils/currency_formatter.dart';
import 'package:afc/models/currency.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TransactionListBloc>()..add(const TransactionListFetchRequested()),
      child: const _TransactionListView(),
    );
  }
}

class _FilterBar extends StatefulWidget {
  const _FilterBar();

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TransactionListBloc, TransactionListState>(
      builder: (context, state) {
        if (state is! TransactionListData) return const SizedBox.shrink();

        return Container(
          color: AppColors.surface,
          child: Column(
            children: [
              BlocProvider(
                create: (_) => AdaptiveSearchBarCubit(),
                child: AdaptiveSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: l10n.transactionSearchHint,
                  onChanged: (val) => context.read<TransactionListBloc>().add(
                    TransactionListSearchChanged(val),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const _DateFilterChip(),
                    const SizedBox(width: 8),
                    const _TypeFilterChips(),
                    if (state.hasFilters) ...[
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          context.read<TransactionListBloc>().add(
                            const TransactionListClearFilters(),
                          );
                        },
                        child: Text(l10n.filterClear),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        );
      },
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<TransactionListBloc>().state;
    if (state is! TransactionListData) return const SizedBox.shrink();

    return CustomDatePicker(
      mode: picker.DatePickerMode.range,
      initialStartDate: state.dateRange?.start,
      initialEndDate: state.dateRange?.end,
      placeholder: l10n.filterDate,
      primaryColor: AppColors.primary,
      onChanged: (start, end) {
        DateTimeRange? range;
        if (start != null) {
          range = DateTimeRange(start: start, end: end ?? start);
        }
        context.read<TransactionListBloc>().add(
          TransactionListDateRangeChanged(range),
        );
      },
    );
  }
}

class _TypeFilterChips extends StatelessWidget {
  const _TypeFilterChips();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<TransactionListBloc>().state;
    if (state is! TransactionListData) return const SizedBox.shrink();

    return Row(
      children: [
        BlocProvider(
          create: (_) =>
              AdaptiveChipCubit(initialSelected: state.selectedType == null),
          child: AdaptiveChip(
            label: l10n.filterAll,
            isSelected: state.selectedType == null,
            onPressed: () => context.read<TransactionListBloc>().add(
              const TransactionListTypeFilterChanged(null),
            ),
          ),
        ),
        const SizedBox(width: 8),
        BlocProvider(
          create: (_) => AdaptiveChipCubit(
            initialSelected: state.selectedType == TransactionType.income,
          ),
          child: AdaptiveChip(
            label: l10n.filterIncome,
            isSelected: state.selectedType == TransactionType.income,
            onPressed: () => context.read<TransactionListBloc>().add(
              const TransactionListTypeFilterChanged(TransactionType.income),
            ),
          ),
        ),
        const SizedBox(width: 8),
        BlocProvider(
          create: (_) => AdaptiveChipCubit(
            initialSelected: state.selectedType == TransactionType.expense,
          ),
          child: AdaptiveChip(
            label: l10n.filterExpense,
            isSelected: state.selectedType == TransactionType.expense,
            onPressed: () => context.read<TransactionListBloc>().add(
              const TransactionListTypeFilterChanged(TransactionType.expense),
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionListView extends StatelessWidget {
  const _TransactionListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionListTitle),
        actions: [
          BlocBuilder<TransactionListBloc, TransactionListState>(
            builder: (context, state) {
              if (state is TransactionListData) {
                return IconButton(
                  icon: Icon(
                    state.groupByType ? Icons.calendar_today : Icons.grid_view,
                  ),
                  tooltip: state.groupByType
                      ? l10n.transactionListByDate
                      : l10n.transactionListByGroup,
                  onPressed: () => context.read<TransactionListBloc>().add(
                    const TransactionListToggleGrouping(),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: l10n.categoryListTitle,
            onPressed: () => context.push('/categories'),
          ),
          IconButton(
            icon: const Icon(Icons.repeat),
            tooltip: l10n.recurringTitle,
            onPressed: () => context.push('/recurring'),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: l10n.importTitle,
            onPressed: () => context.push('/import'),
          ),
        ],
      ),
      body: Column(
        children: [
          const _FilterBar(),
          Expanded(
            child: BlocBuilder<TransactionListBloc, TransactionListState>(
              builder: (context, state) {
                if (state is TransactionListLoading ||
                    state is TransactionListInitial) {
                  return const SkeletonList(itemCount: 8);
                }
                if (state is TransactionListError) {
                  return Center(
                    child: ErrorState(
                      message: l10n.transactionListError,
                      onRetry: () => context.read<TransactionListBloc>().add(
                        const TransactionListFetchRequested(),
                      ),
                    ),
                  );
                }
                if (state is TransactionListData) {
                  if (state.filteredTransactions.isEmpty) {
                    return Center(
                      child: EmptyState(
                        icon: state.hasFilters
                            ? Icons.search_off
                            : Icons.receipt_long_outlined,
                        title: state.hasFilters
                            ? l10n
                                  .transactionSearchHint // Or something like "No results"
                            : l10n.transactionListEmpty,
                      ),
                    );
                  }

                  if (state.groupByType) {
                    final grouper = TransactionGrouper();
                    final groups = grouper.group(state.filteredTransactions, {
                      'pix': l10n.transactionGroupPix,
                      'bank': l10n.transactionGroupBank,
                      'transport': l10n.transactionGroupTransport,
                      'delivery': l10n.transactionGroupDelivery,
                      'market': l10n.transactionGroupMarket,
                      'subscription': l10n.transactionGroupSubscription,
                      'other': l10n.transactionGroupOther,
                    });

                    return RefreshIndicator(
                      onRefresh: () async => context
                          .read<TransactionListBloc>()
                          .add(const TransactionListFetchRequested()),
                      child: ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocBuilder<SettingsBloc, SettingsState>(
                                builder: (context, settingsState) {
                                  final currency =
                                      settingsState.selectedCurrency;
                                  final currencyService = sl<CurrencyService>();

                                  return _GroupHeader(
                                    group: group,
                                    currency: currency,
                                    currencyService: currencyService,
                                  );
                                },
                              ),
                              ...group.transactions.map(
                                (t) => _DismissibleItem(
                                  transaction: t,
                                  l10n: l10n,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => context
                        .read<TransactionListBloc>()
                        .add(const TransactionListFetchRequested()),
                    child: ListView.builder(
                      itemCount: state.filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final t = state.filteredTransactions[index];
                        return _DismissibleItem(transaction: t, l10n: l10n);
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.group,
    required this.currency,
    required this.currencyService,
  });

  final TransactionGroup group;
  final Currency currency;
  final CurrencyService currencyService;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.neutral100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                group.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${group.transactions.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            ],
          ),
          Text(
            CurrencyFormatter.format(
              currencyService.convert(group.total, currency),
              currency,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissibleItem extends StatelessWidget {
  const _DismissibleItem({required this.transaction, required this.l10n});

  final TransactionModel transaction;
  final AppLocalizations l10n;

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => AdaptivePopupCubit(),
        child: AdaptivePopup(
          title: l10n.transactionDeleteConfirmTitle,
          description: l10n.transactionDeleteConfirmMessage,
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
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => context.read<TransactionListBloc>().add(
        TransactionDeleteRequested(transaction.id),
      ),
      background: const DismissibleDeleteBackground(),
      child: InkWell(
        onTap: () => sl<NavigationService>().push(
          '/transactions/${transaction.id}/edit',
          extra: context.read<TransactionListBloc>(),
        ),
        child: TransactionListItem(
          description: transaction.description,
          amount: transaction.amount,
          type: transaction.type == TransactionType.income
              ? TransactionItemType.income
              : TransactionItemType.expense,
          category: transaction.category,
          occurredAt: transaction.occurredAt,
        ),
      ),
    );
  }
}
