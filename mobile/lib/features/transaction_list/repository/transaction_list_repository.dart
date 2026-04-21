import '../model/transaction_model.dart';
import '../service/transaction_list_service.dart';

class TransactionListRepository {
  TransactionListRepository({TransactionListService? service})
    : _service = service ?? TransactionListService();

  final TransactionListService _service;

  Future<List<TransactionModel>> getAll() => _service.fetchAll();

  Future<void> delete(String id) => _service.delete(id);

  Future<TransactionModel> update(
    String id, {
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
  }) => _service.update(
    id,
    description: description,
    amount: amount,
    type: type,
    category: category,
    occurredAt: occurredAt,
  );

  Future<TransactionModel> create({
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
  }) => _service.create(
    description: description,
    amount: amount,
    type: type,
    category: category,
    occurredAt: occurredAt,
  );
}
