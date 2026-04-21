import 'package:equatable/equatable.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/models/recurring_transaction_model.dart';

enum QuickAddTransactionStatus { initial, loading, success, failure }

class QuickAddTransactionState extends Equatable {
  const QuickAddTransactionState({
    this.status = QuickAddTransactionStatus.initial,
    this.errorMessage,
    this.description = '',
    this.amount = '',
    this.type = TransactionType.expense,
    this.category = '',
    this.isRecurring = false,
    this.frequency = RecurrenceFrequency.monthly,
  });

  final QuickAddTransactionStatus status;
  final String? errorMessage;
  final String description;
  final String amount;
  final TransactionType type;
  final String category;
  final bool isRecurring;
  final RecurrenceFrequency frequency;

  double? get parsedAmount => double.tryParse(amount.replaceAll(',', '.'));
  bool get isAmountValid => parsedAmount != null && parsedAmount! > 0;
  bool get isDescriptionValid => description.trim().isNotEmpty;
  bool get isValid => isAmountValid && isDescriptionValid;
  String? get parsedCategory =>
      category.trim().isEmpty ? null : category.trim();

  QuickAddTransactionState copyWith({
    QuickAddTransactionStatus? status,
    Object? errorMessage = const Object(),
    String? description,
    String? amount,
    TransactionType? type,
    String? category,
    bool? isRecurring,
    RecurrenceFrequency? frequency,
  }) {
    return QuickAddTransactionState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, const Object())
          ? this.errorMessage
          : errorMessage as String?,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    description,
    amount,
    type,
    category,
    isRecurring,
    frequency,
  ];
}
