part of 'health_score_bloc.dart';

abstract class HealthScoreEvent extends Equatable {
  const HealthScoreEvent();

  @override
  List<Object?> get props => [];
}

class LoadHealthScore extends HealthScoreEvent {
  const LoadHealthScore();
}
