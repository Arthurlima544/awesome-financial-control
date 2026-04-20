import '../model/monthly_stat_model.dart';
import '../service/stats_service.dart';

class StatsRepository {
  StatsRepository({StatsService? service})
    : _service = service ?? StatsService();

  final StatsService _service;

  Future<List<MonthlyStatModel>> getMonthlyStats() =>
      _service.fetchMonthlyStats();
}
