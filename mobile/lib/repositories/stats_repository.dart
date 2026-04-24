import 'package:afc/models/monthly_stat_model.dart';
import 'package:afc/models/net_worth_point.dart';
import 'package:afc/services/stats_service.dart';

class StatsRepository {
  StatsRepository({StatsService? service})
    : _service = service ?? StatsService();

  final StatsService _service;

  Future<List<MonthlyStatModel>> getMonthlyStats() =>
      _service.fetchMonthlyStats();

  Future<List<NetWorthPoint>> getNetWorthEvolution() async {
    final data = await _service.fetchNetWorthEvolution();
    return data
        .map((e) => NetWorthPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
