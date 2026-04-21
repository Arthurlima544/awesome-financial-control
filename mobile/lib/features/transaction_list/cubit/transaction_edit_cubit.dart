import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/transaction_model.dart';

enum TransactionEditStatus { initial, loading, success, error }

class TransactionEditState extends Equatable {
  const TransactionEditState({
    this.description = '',
    this.amount = '',
    this.type = TransactionType.expense,
    this.category = '',
    this.occurredAt,
    this.status = TransactionEditStatus.initial,
    this.errorMessage,
  });

  final String description;
  final String amount;
  final TransactionType type;
  final String category;
  final DateTime? occurredAt;
  final TransactionEditStatus status;
  final String? errorMessage;

  TransactionEditState copyWith({
    String? description,
    String? amount,
    TransactionType? type,
    String? category,
    DateTime? occurredAt,
    TransactionEditStatus? status,
    String? errorMessage,
  }) {
    return TransactionEditState(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      occurredAt: occurredAt ?? this.occurredAt,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    description,
    amount,
    type,
    category,
    occurredAt,
    status,
    errorMessage,
  ];

  bool get isDescriptionValid => description.trim().isNotEmpty;

  double? get parsedAmount {
    final parsed = double.tryParse(amount.trim().replaceAll(',', '.'));
    if (parsed != null && parsed > 0) return parsed;
    return null;
  }

  bool get isAmountValid => parsedAmount != null;

  String? get parsedCategory =>
      category.trim().isEmpty ? null : category.trim();

  bool get isValid => isDescriptionValid && isAmountValid;
}

class TransactionEditCubit extends Cubit<TransactionEditState> {
  TransactionEditCubit({TransactionModel? initialTransaction})
    : super(
        TransactionEditState(
          description: initialTransaction?.description ?? '',
          amount: initialTransaction?.amount.toStringAsFixed(2) ?? '',
          type: initialTransaction?.type ?? TransactionType.expense,
          category: initialTransaction?.category ?? '',
          occurredAt: initialTransaction?.occurredAt ?? DateTime.now(),
        ),
      );

  void descriptionChanged(String value) =>
      emit(state.copyWith(description: value));

  void amountChanged(String value) => emit(state.copyWith(amount: value));

  void typeChanged(TransactionType value) => emit(state.copyWith(type: value));

  void categoryChanged(String value) => emit(state.copyWith(category: value));

  void occurredAtChanged(DateTime value) =>
      emit(state.copyWith(occurredAt: value));

  void saved() => emit(state.copyWith(status: TransactionEditStatus.success));
}
