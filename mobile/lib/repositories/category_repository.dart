import 'package:afc/models/category_model.dart';
import 'package:afc/services/category_service.dart';

class CategoryRepository {
  CategoryRepository({CategoryService? service})
    : _service = service ?? CategoryService();

  final CategoryService _service;

  Future<List<CategoryModel>> getAll() => _service.fetchAll();

  Future<void> delete(String id) => _service.delete(id);

  Future<CategoryModel> update(String id, String name) =>
      _service.update(id, name);
  Future<CategoryModel> create(String name) => _service.create(name);
}
