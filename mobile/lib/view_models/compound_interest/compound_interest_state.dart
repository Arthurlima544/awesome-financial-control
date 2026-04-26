part of 'compound_interest_bloc.dart';

enum CompoundInterestStatus { initial, loading, success, failure }

class CompoundInterestState extends Equatable {
  final CompoundInterestStatus status;
  final CompoundInterestResult? result;
  final String? errorMessage;

  const CompoundInterestState({
    this.status = CompoundInterestStatus.initial,
    this.result,
    this.errorMessage,
  });

  CompoundInterestState copyWith({
    CompoundInterestStatus? status,
    CompoundInterestResult? result,
    String? errorMessage,
  }) {
    return CompoundInterestState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}
