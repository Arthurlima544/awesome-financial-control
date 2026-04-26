part of 'recurring_bloc.dart';

sealed class RecurringState extends Equatable {
  const RecurringState();
  @override
  List<Object?> get props => [];
}

class RecurringInitial extends RecurringState {
  const RecurringInitial();
}

class RecurringLoading extends RecurringState {
  const RecurringLoading();
}

class RecurringLoaded extends RecurringState {
  final List<RecurringTransactionModel> rules;
  const RecurringLoaded(this.rules);

  @override
  List<Object?> get props => [rules];
}

class RecurringError extends RecurringState {
  final String message;
  const RecurringError(this.message);

  @override
  List<Object?> get props => [message];
}
