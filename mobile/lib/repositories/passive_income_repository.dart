import 'package:afc/services/passive_income_service.dart';
import 'package:afc/models/passive_income_data.dart';

class PassiveIncomeRepository {
  PassiveIncomeRepository({PassiveIncomeService? service})
    : _service = service ?? PassiveIncomeService();

  final PassiveIncomeService _service;

  Future<PassiveIncomeData> getDashboardData() async {
    final data = await _service.getDashboardData();
    return PassiveIncomeData.fromJson(data);
  }
}
