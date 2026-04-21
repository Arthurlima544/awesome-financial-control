part of 'stats_bloc.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();
  @override
  List<Object?> get props => [];
}

class StatsLoaded extends StatsEvent {
  const StatsLoaded();
}
