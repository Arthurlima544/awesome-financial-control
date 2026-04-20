import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'transaction_list_item_cubit.dart';

enum TransactionItemType { income, expense }

class TransactionListItem extends StatelessWidget {
  final String description;
  final double amount;
  final TransactionItemType type;
  final String? category;
  final DateTime occurredAt;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? incomeColor;
  final Color? expenseColor;
  final Color? backgroundColor;
  final Color? selectedColor;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? focusNode;

  const TransactionListItem({
    super.key,
    required this.description,
    required this.amount,
    required this.type,
    required this.occurredAt,
    this.category,
    this.onTap,
    this.onLongPress,
    this.incomeColor,
    this.expenseColor,
    this.backgroundColor,
    this.selectedColor,
    this.customPadding,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionListItemCubit(),
      child: _TransactionListItemView(
        description: description,
        amount: amount,
        type: type,
        category: category,
        occurredAt: occurredAt,
        onTap: onTap,
        onLongPress: onLongPress,
        incomeColor: incomeColor,
        expenseColor: expenseColor,
        backgroundColor: backgroundColor,
        selectedColor: selectedColor,
        customPadding: customPadding,
        focusNode: focusNode,
      ),
    );
  }
}

class _TransactionListItemView extends StatelessWidget {
  final String description;
  final double amount;
  final TransactionItemType type;
  final String? category;
  final DateTime occurredAt;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? incomeColor;
  final Color? expenseColor;
  final Color? backgroundColor;
  final Color? selectedColor;
  final EdgeInsetsGeometry? customPadding;
  final FocusNode? focusNode;

  const _TransactionListItemView({
    required this.description,
    required this.amount,
    required this.type,
    required this.occurredAt,
    this.category,
    this.onTap,
    this.onLongPress,
    this.incomeColor,
    this.expenseColor,
    this.backgroundColor,
    this.selectedColor,
    this.customPadding,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionListItemCubit, TransactionListItemState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = MediaQuery.of(context).size.width;
            final double iconSize = (screenWidth * 0.06).clamp(20.0, 32.0);
            final double iconContainerSize = iconSize * 1.7;
            final double titleSize = (screenWidth * 0.04).clamp(13.0, 16.0);
            final double subtitleSize = (screenWidth * 0.035).clamp(11.0, 13.0);
            final double amountSize = (screenWidth * 0.04).clamp(13.0, 16.0);

            final isIncome = type == TransactionItemType.income;
            final themeIncome = incomeColor ?? const Color(0xFF10B981);
            final themeExpense = expenseColor ?? const Color(0xFFEF4444);
            final typeColor = isIncome ? themeIncome : themeExpense;

            final themeBackground = state.isSelected
                ? (selectedColor ?? typeColor.withValues(alpha: 0.08))
                : (backgroundColor ?? Colors.transparent);

            final amountPrefix = isIncome ? '+' : '-';
            final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

            return Semantics(
              label:
                  '$description ${isIncome ? "receita" : "despesa"} R\$ ${amount.toStringAsFixed(2)}',
              button: onTap != null,
              child: Focus(
                focusNode: focusNode,
                child: Material(
                  color: themeBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: onTap,
                    onLongPress: () {
                      context.read<TransactionListItemCubit>().toggleSelected();
                      onLongPress?.call();
                    },
                    child: Padding(
                      padding:
                          customPadding ??
                          EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.03,
                          ),
                      child: Row(
                        children: [
                          Container(
                            width: iconContainerSize,
                            height: iconContainerSize,
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                iconContainerSize * 0.3,
                              ),
                            ),
                            child: state.isLoading
                                ? SizedBox(
                                    width: iconSize,
                                    height: iconSize,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color: typeColor,
                                    ),
                                  )
                                : Icon(icon, size: iconSize, color: typeColor),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (category != null) ...[
                                  SizedBox(height: subtitleSize * 0.2),
                                  Text(
                                    category!,
                                    style: TextStyle(
                                      fontSize: subtitleSize,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            '$amountPrefix R\$ ${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: amountSize,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
