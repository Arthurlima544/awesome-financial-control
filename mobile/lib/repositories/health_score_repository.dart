import 'package:afc/models/health_score_model.dart';
import 'package:afc/services/health_score_service.dart';

class HealthScoreRepository {
  final HealthScoreService _service;

  HealthScoreRepository({HealthScoreService? service})
    : _service = service ?? HealthScoreService();

  Future<HealthScoreModel> getHealthScore() => _service.getHealthScore();
}
