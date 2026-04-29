import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/models/limit_progress_model.dart';
import 'package:afc/repositories/limit_repository.dart';

part 'limit_event.dart';
part 'limit_state.dart';

class LimitBloc extends Bloc<LimitEvent, LimitState> {
  LimitBloc({LimitRepository? repository})
    : _repository = repository ?? sl<LimitRepository>(),
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
