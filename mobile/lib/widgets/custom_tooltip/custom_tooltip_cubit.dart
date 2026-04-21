import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TooltipPosition { top, bottom, left, right }

class CustomTooltipState extends Equatable {
  final bool isVisible;
  final String? errorMessage;

  const CustomTooltipState({this.isVisible = false, this.errorMessage});

  CustomTooltipState copyWith({bool? isVisible, String? errorMessage}) {
    return CustomTooltipState(
      isVisible: isVisible ?? this.isVisible,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isVisible, errorMessage];
}

class CustomTooltipCubit extends Cubit<CustomTooltipState> {
  CustomTooltipCubit() : super(const CustomTooltipState());

  void show() => emit(state.copyWith(isVisible: true));

  void hide() => emit(state.copyWith(isVisible: false));

  void toggle() => emit(state.copyWith(isVisible: !state.isVisible));

  void setError(String message) => emit(state.copyWith(errorMessage: message));

  void reset() => emit(const CustomTooltipState());
}
