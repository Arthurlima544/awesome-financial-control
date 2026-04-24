import 'package:afc/models/investment_model.dart';
import 'package:afc/services/investment_service.dart';

class InvestmentRepository {
  InvestmentRepository({InvestmentService? service})
    : _service = service ?? InvestmentService();

  final InvestmentService _service;

  Future<List<InvestmentModel>> getAllInvestments() =>
      _service.getAllInvestments();

  Future<InvestmentModel> createInvestment(Map<String, dynamic> data) =>
      _service.createInvestment(data);

  Future<InvestmentModel> updateInvestment(
    String id,
    Map<String, dynamic> data,
  ) => _service.updateInvestment(id, data);

  Future<void> deleteInvestment(String id) => _service.deleteInvestment(id);

  Future<InvestmentModel> updatePrice(String id, double price) =>
      _service.updatePrice(id, price);

  Future<Map<String, dynamic>> getDashboardData() =>
      _service.getDashboardData();
}
