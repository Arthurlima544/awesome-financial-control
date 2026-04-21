import 'package:afc/models/summary_model.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/services/home_service.dart';

class HomeRepository {
  HomeRepository({HomeService? service}) : _service = service ?? HomeService();

  final HomeService _service;

  Future<SummaryModel> getSummary() => _service.fetchSummary();

  Future<List<TransactionModel>> getLastTransactions({int limit = 5}) =>
      _service.fetchLastTransactions(limit: limit);
}
