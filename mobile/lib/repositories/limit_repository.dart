import 'package:afc/models/limit_progress_model.dart';
import 'package:afc/services/limit_service.dart';

class LimitRepository {
  LimitRepository({LimitService? service})
    : _service = service ?? LimitService();

  final LimitService _service;

  Future<List<LimitProgressModel>> getLimitsProgress() =>
      _service.fetchLimitsProgress();
}
