import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_refresh_event.dart';
part 'app_refresh_state.dart';

class AppRefreshBloc extends Bloc<AppRefreshEvent, AppRefreshState> {
  AppRefreshBloc() : super(const AppRefreshState(0)) {
    on<DataChanged>((event, emit) => emit(AppRefreshState(state.version + 1)));
  }
}
