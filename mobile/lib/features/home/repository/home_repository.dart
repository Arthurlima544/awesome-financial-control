import '../model/summary_model.dart';
import '../model/transaction_model.dart';
import '../service/home_service.dart';

class HomeRepository {
  HomeRepository({HomeService? service}) : _service = service ?? HomeService();

  final HomeService _service;

  Future<SummaryModel> getSummary() => _service.fetchSummary();

  Future<List<TransactionModel>> getLastTransactions({int limit = 5}) =>
      _service.fetchLastTransactions(limit: limit);
}
