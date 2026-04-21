import 'package:afc/models/recurring_transaction_model.dart';
import 'package:afc/services/recurring_service.dart';

class RecurringRepository {
  final RecurringService _service;

  RecurringRepository({RecurringService? service})
    : _service = service ?? RecurringService();

  Future<List<RecurringTransactionModel>> getAll() => _service.getAll();

  Future<RecurringTransactionModel> create(
    RecurringTransactionModel recurring,
  ) => _service.create(recurring);

  Future<RecurringTransactionModel> update(
    RecurringTransactionModel recurring,
  ) => _service.update(recurring);

  Future<void> delete(String id) => _service.delete(id);

  Future<void> processPending() => _service.processPending();
}
