import '../model/transaction_model.dart';
import '../service/transaction_list_service.dart';

class TransactionListRepository {
  TransactionListRepository({TransactionListService? service})
    : _service = service ?? TransactionListService();

  final TransactionListService _service;

  Future<List<TransactionModel>> getAll() => _service.fetchAll();

  Future<void> delete(String id) => _service.delete(id);
}
