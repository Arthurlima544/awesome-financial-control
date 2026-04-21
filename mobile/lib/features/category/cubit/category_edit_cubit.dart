import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/category_model.dart';

enum CategoryEditStatus { initial, loading, success, error }

class CategoryEditState extends Equatable {
  const CategoryEditState({
    this.name = '',
    this.status = CategoryEditStatus.initial,
    this.errorMessage,
  });

  final String name;
  final CategoryEditStatus status;
  final String? errorMessage;

  CategoryEditState copyWith({
    String? name,
    CategoryEditStatus? status,
    String? errorMessage,
  }) {
    return CategoryEditState(
      name: name ?? this.name,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [name, status, errorMessage];

  bool get isNameValid => name.trim().isNotEmpty;

  bool get isValid => isNameValid;
}

class CategoryEditCubit extends Cubit<CategoryEditState> {
  CategoryEditCubit({CategoryModel? initialCategory})
    : super(CategoryEditState(name: initialCategory?.name ?? ''));

  void nameChanged(String value) => emit(state.copyWith(name: value));

  void saved() => emit(state.copyWith(status: CategoryEditStatus.success));
}
