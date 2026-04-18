import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaginationDotsState extends Equatable {
  final int currentPage;
  final String? errorMessage;

  const PaginationDotsState({required this.currentPage, this.errorMessage});

  PaginationDotsState copyWith({
    int? currentPage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaginationDotsState(
      currentPage: currentPage ?? this.currentPage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [currentPage, errorMessage];
}

class PaginationDotsCubit extends Cubit<PaginationDotsState> {
  PaginationDotsCubit({int initialPage = 0})
    : super(PaginationDotsState(currentPage: initialPage));

  void setPage(int page, int totalPages) {
    if (page < 0 || page >= totalPages) {
      emit(state.copyWith(errorMessage: 'Invalid page selected.'));
    } else {
      emit(state.copyWith(currentPage: page, clearError: true));
    }
  }

  void setError(String error) {
    emit(state.copyWith(errorMessage: error));
  }

  void reset({int defaultPage = 0}) {
    emit(PaginationDotsState(currentPage: defaultPage));
  }
}
