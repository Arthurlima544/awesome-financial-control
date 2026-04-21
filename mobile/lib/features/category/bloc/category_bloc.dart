import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/category_model.dart';
import '../repository/category_repository.dart';

// Events

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class CategoryFetchRequested extends CategoryEvent {
  const CategoryFetchRequested();
}

class CategoryDeleteRequested extends CategoryEvent {
  const CategoryDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CategoryUpdateRequested extends CategoryEvent {
  const CategoryUpdateRequested({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

// States

abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryData extends CategoryState {
  const CategoryData(this.categories);

  final List<CategoryModel> categories;

  @override
  List<Object?> get props => [categories];
}

class CategoryError extends CategoryState {
  const CategoryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Bloc

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({CategoryRepository? repository})
    : _repository = repository ?? CategoryRepository(),
      super(CategoryInitial()) {
    on<CategoryFetchRequested>(_onFetchRequested);
    on<CategoryDeleteRequested>(_onDeleteRequested);
    on<CategoryUpdateRequested>(_onUpdateRequested);
  }

  final CategoryRepository _repository;

  Future<void> _onFetchRequested(
    CategoryFetchRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getAll();
      emit(CategoryData(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    CategoryDeleteRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final current = state;
    if (current is! CategoryData) return;
    try {
      await _repository.delete(event.id);
      final updated = current.categories
          .where((c) => c.id != event.id)
          .toList();
      emit(CategoryData(updated));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    CategoryUpdateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final current = state;
    if (current is! CategoryData) return;
    try {
      final updated = await _repository.update(event.id, event.name);
      final updatedList = current.categories.map((c) {
        return c.id == event.id ? updated : c;
      }).toList();
      emit(CategoryData(updatedList));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
