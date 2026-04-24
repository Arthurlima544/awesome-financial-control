import 'package:afc/services/passive_income_service.dart';

class PassiveIncomeRepository {
  PassiveIncomeRepository({PassiveIncomeService? service})
    : _service = service ?? PassiveIncomeService();

  final PassiveIncomeService _service;

  Future<Map<String, dynamic>> getDashboardData() =>
      _service.getDashboardData();
}
