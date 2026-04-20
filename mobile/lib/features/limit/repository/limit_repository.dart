import '../model/limit_progress_model.dart';
import '../service/limit_service.dart';

class LimitRepository {
  LimitRepository({LimitService? service})
    : _service = service ?? LimitService();

  final LimitService _service;

  Future<List<LimitProgressModel>> getLimitsProgress() =>
      _service.fetchLimitsProgress();
}
