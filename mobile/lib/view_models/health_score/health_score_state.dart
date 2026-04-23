part of 'health_score_bloc.dart';

enum HealthScoreStatus { initial, loading, success, failure }

class HealthScoreState extends Equatable {
  final HealthScoreStatus status;
  final HealthScoreModel? healthScore;
  final String? errorMessage;

  const HealthScoreState({
    this.status = HealthScoreStatus.initial,
    this.healthScore,
    this.errorMessage,
  });

  HealthScoreState copyWith({
    HealthScoreStatus? status,
    HealthScoreModel? healthScore,
    String? errorMessage,
  }) {
    return HealthScoreState(
      status: status ?? this.status,
      healthScore: healthScore ?? this.healthScore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, healthScore, errorMessage];
}
