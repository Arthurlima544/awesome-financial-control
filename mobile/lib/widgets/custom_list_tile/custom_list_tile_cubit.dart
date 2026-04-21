import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomListTileState extends Equatable {
  final bool isSelected;
  final String? errorMessage;

  const CustomListTileState({required this.isSelected, this.errorMessage});

  CustomListTileState copyWith({
    bool? isSelected,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CustomListTileState(
      isSelected: isSelected ?? this.isSelected,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isSelected, errorMessage];
}

class CustomListTileCubit extends Cubit<CustomListTileState> {
  CustomListTileCubit({bool initialValue = false})
    : super(CustomListTileState(isSelected: initialValue));

  void toggleValue(bool newValue) {
    emit(state.copyWith(isSelected: newValue, clearError: true));
  }

  void setError(String error) {
    emit(state.copyWith(errorMessage: error));
  }

  void reset(bool resetValue) {
    emit(CustomListTileState(isSelected: resetValue));
  }
}
