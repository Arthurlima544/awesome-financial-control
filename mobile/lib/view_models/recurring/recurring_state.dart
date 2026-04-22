part of 'recurring_bloc.dart';

sealed class RecurringState {}

class RecurringInitial extends RecurringState {}

class RecurringLoading extends RecurringState {}

class RecurringLoaded extends RecurringState {
  final List<RecurringTransactionModel> rules;
  RecurringLoaded(this.rules);
}

class RecurringError extends RecurringState {
  final String message;
  RecurringError(this.message);
}
