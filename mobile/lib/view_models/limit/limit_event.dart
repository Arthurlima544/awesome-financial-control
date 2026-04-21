part of 'limit_bloc.dart';

abstract class LimitEvent extends Equatable {
  const LimitEvent();
  @override
  List<Object?> get props => [];
}

class LimitProgressLoaded extends LimitEvent {
  const LimitProgressLoaded();
}
