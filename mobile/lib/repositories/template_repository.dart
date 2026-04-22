import 'package:afc/models/template_model.dart';
import 'package:afc/services/template_service.dart';

class TemplateRepository {
  final TemplateService _service;

  TemplateRepository({TemplateService? service})
    : _service = service ?? TemplateService();

  Future<List<TemplateModel>> getAll() => _service.getAll();

  Future<TemplateModel> create(TemplateModel template) =>
      _service.create(template);

  Future<void> delete(String id) => _service.delete(id);
}
