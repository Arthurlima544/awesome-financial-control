import '../model/limit_model.dart';
import '../service/limit_list_service.dart';

class LimitListRepository {
  LimitListRepository({LimitListService? service})
    : _service = service ?? LimitListService();

  final LimitListService _service;

  Future<List<LimitModel>> getAll() => _service.fetchAll();

  Future<void> delete(String id) => _service.delete(id);

  Future<LimitModel> update(String id, double amount) =>
      _service.update(id, amount);
}
