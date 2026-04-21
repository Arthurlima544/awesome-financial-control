part of 'recurring_bloc.dart';

sealed class RecurringEvent {}

class LoadRecurring extends RecurringEvent {}

class ToggleRecurringActive extends RecurringEvent {
  final RecurringTransactionModel recurring;
  ToggleRecurringActive(this.recurring);
}

class DeleteRecurring extends RecurringEvent {
  final String id;
  DeleteRecurring(this.id);
}
