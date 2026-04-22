import 'package:dio/dio.dart';
import 'package:afc/models/template_model.dart';
import 'package:afc/utils/config/app_config.dart';

class TemplateService {
  final Dio _dio;

  TemplateService({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<TemplateModel>> getAll() async {
    final response = await _dio.get('${AppConfig.apiBaseUrl}/api/v1/templates');
    return (response.data as List)
        .map((e) => TemplateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TemplateModel> create(TemplateModel template) async {
    final response = await _dio.post(
      '${AppConfig.apiBaseUrl}/api/v1/templates',
      data: template.toJson(),
    );
    return TemplateModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('${AppConfig.apiBaseUrl}/api/v1/templates/$id');
  }
}
