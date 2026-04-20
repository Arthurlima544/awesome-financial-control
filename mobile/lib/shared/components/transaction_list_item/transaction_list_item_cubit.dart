import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionListItemState extends Equatable {
  const TransactionListItemState({
    this.isSelected = false,
    this.isLoading = false,
  });

  final bool isSelected;
  final bool isLoading;

  TransactionListItemState copyWith({bool? isSelected, bool? isLoading}) {
    return TransactionListItemState(
      isSelected: isSelected ?? this.isSelected,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [isSelected, isLoading];
}

class TransactionListItemCubit extends Cubit<TransactionListItemState> {
  TransactionListItemCubit() : super(const TransactionListItemState());

  void toggleSelected() => emit(state.copyWith(isSelected: !state.isSelected));

  void setLoading(bool loading) => emit(state.copyWith(isLoading: loading));
}
