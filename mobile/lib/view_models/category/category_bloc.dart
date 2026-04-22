import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/models/category_model.dart';
import 'package:afc/repositories/category_repository.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'dart:async';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository;
  final AppRefreshBloc _refreshBloc;
  late final StreamSubscription _refreshSubscription;

  CategoryBloc({CategoryRepository? repository, AppRefreshBloc? refreshBloc})
    : _repository = repository ?? sl<CategoryRepository>(),
      _refreshBloc = refreshBloc ?? sl<AppRefreshBloc>(),
      super(CategoryInitial()) {
    on<CategoryFetchRequested>(_onFetchRequested);
    on<CategoryDeleteRequested>(_onDeleteRequested);
    on<CategoryUpdateRequested>(_onUpdateRequested);

    _refreshSubscription = _refreshBloc.stream.listen(
      (_) => add(const CategoryFetchRequested()),
    );
  }

  @override
  Future<void> close() {
    _refreshSubscription.cancel();
    return super.close();
  }

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
      _refreshBloc.add(DataChanged());
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
      _refreshBloc.add(DataChanged());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
