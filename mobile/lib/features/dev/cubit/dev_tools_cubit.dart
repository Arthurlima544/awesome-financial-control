import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/dev_tools_repository.dart';

// State

enum DevToolsAction { seed, reset }

abstract class DevToolsState extends Equatable {
  const DevToolsState();
  @override
  List<Object?> get props => [];
}

class DevToolsInitial extends DevToolsState {}

class DevToolsLoading extends DevToolsState {
  const DevToolsLoading(this.action);
  final DevToolsAction action;
  @override
  List<Object?> get props => [action];
}

class DevToolsSuccess extends DevToolsState {
  const DevToolsSuccess(this.action);
  final DevToolsAction action;
  @override
  List<Object?> get props => [action];
}

class DevToolsError extends DevToolsState {
  const DevToolsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// Cubit

class DevToolsCubit extends Cubit<DevToolsState> {
  DevToolsCubit({DevToolsRepository? repository})
    : _repository = repository ?? DevToolsRepository(),
      super(DevToolsInitial());

  final DevToolsRepository _repository;

  Future<void> seed() async {
    emit(const DevToolsLoading(DevToolsAction.seed));
    try {
      await _repository.seed();
      emit(const DevToolsSuccess(DevToolsAction.seed));
    } catch (e) {
      emit(DevToolsError(e.toString()));
    }
  }

  Future<void> reset() async {
    emit(const DevToolsLoading(DevToolsAction.reset));
    try {
      await _repository.reset();
      emit(const DevToolsSuccess(DevToolsAction.reset));
    } catch (e) {
      emit(DevToolsError(e.toString()));
    }
  }
}
