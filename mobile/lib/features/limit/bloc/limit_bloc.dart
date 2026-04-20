import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/limit_progress_model.dart';
import '../repository/limit_repository.dart';

// Events

abstract class LimitEvent extends Equatable {
  const LimitEvent();
  @override
  List<Object?> get props => [];
}

class LimitProgressLoaded extends LimitEvent {
  const LimitProgressLoaded();
}

// States

abstract class LimitState extends Equatable {
  const LimitState();
  @override
  List<Object?> get props => [];
}

class LimitInitial extends LimitState {}

class LimitLoading extends LimitState {}

class LimitLoaded extends LimitState {
  const LimitLoaded(this.limits);

  final List<LimitProgressModel> limits;

  @override
  List<Object?> get props => [limits];
}

class LimitError extends LimitState {
  const LimitError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Bloc

class LimitBloc extends Bloc<LimitEvent, LimitState> {
  LimitBloc({LimitRepository? repository})
    : _repository = repository ?? LimitRepository(),
      super(LimitInitial()) {
    on<LimitProgressLoaded>(_onProgressLoaded);
  }

  final LimitRepository _repository;

  Future<void> _onProgressLoaded(
    LimitProgressLoaded event,
    Emitter<LimitState> emit,
  ) async {
    emit(LimitLoading());
    try {
      final limits = await _repository.getLimitsProgress();
      emit(LimitLoaded(limits));
    } catch (e) {
      emit(LimitError(e.toString()));
    }
  }
}
