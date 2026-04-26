part of 'fire_calculator_bloc.dart';

enum FireCalculatorStatus { initial, loading, success, failure }

class FireCalculatorState extends Equatable {
  final FireCalculatorStatus status;
  final FireCalculatorResult? result;
  final String? errorMessage;

  const FireCalculatorState({
    this.status = FireCalculatorStatus.initial,
    this.result,
    this.errorMessage,
  });

  FireCalculatorState copyWith({
    FireCalculatorStatus? status,
    FireCalculatorResult? result,
    String? errorMessage,
  }) {
    return FireCalculatorState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}
