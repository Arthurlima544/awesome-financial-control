part of 'recurring_bloc.dart';

sealed class RecurringEvent extends Equatable {
  const RecurringEvent();
  @override
  List<Object?> get props => [];
}

class LoadRecurring extends RecurringEvent {
  const LoadRecurring();
}

class ToggleRecurringActive extends RecurringEvent {
  final RecurringTransactionModel recurring;
  const ToggleRecurringActive(this.recurring);

  @override
  List<Object?> get props => [recurring];
}

class DeleteRecurring extends RecurringEvent {
  final String id;
  const DeleteRecurring(this.id);

  @override
  List<Object?> get props => [id];
}
