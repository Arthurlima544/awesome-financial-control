part of 'category_bloc.dart';

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
