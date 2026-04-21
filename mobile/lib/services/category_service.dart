import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:afc/utils/config/app_config.dart';
import 'package:afc/models/category_model.dart';

class CategoryService {
  CategoryService({Dio? dio}) : _dio = dio ?? _buildDio();

  static Dio _buildDio() {
    final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }
    return dio;
  }

  final Dio _dio;

  Future<List<CategoryModel>> fetchAll() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/categories');
    return response.data!
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/api/v1/categories/$id');
  }

  Future<CategoryModel> update(String id, String name) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/categories/$id',
      data: {'name': name},
    );
    return CategoryModel.fromJson(response.data!);
  }
}
