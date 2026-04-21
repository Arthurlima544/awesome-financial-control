import 'package:afc/services/dev_tools_service.dart';

class DevToolsRepository {
  DevToolsRepository({DevToolsService? service})
    : _service = service ?? DevToolsService();

  final DevToolsService _service;

  Future<void> seed() => _service.seed();

  Future<void> reset() => _service.reset();
}
