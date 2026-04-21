import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmptyStateState extends Equatable {
  const EmptyStateState({this.isVisible = true});

  final bool isVisible;

  EmptyStateState copyWith({bool? isVisible}) {
    return EmptyStateState(isVisible: isVisible ?? this.isVisible);
  }

  @override
  List<Object?> get props => [isVisible];
}

class EmptyStateCubit extends Cubit<EmptyStateState> {
  EmptyStateCubit() : super(const EmptyStateState());

  void setVisible(bool visible) => emit(state.copyWith(isVisible: visible));
}
