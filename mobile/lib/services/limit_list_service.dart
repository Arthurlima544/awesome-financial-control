import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:afc/utils/config/app_config.dart';
import 'package:afc/models/limit_model.dart';

class LimitListService {
  LimitListService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<List<LimitModel>> fetchAll() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/limits');
    return response.data!
        .map((e) => LimitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/api/v1/limits/$id');
  }

  Future<LimitModel> update(String id, double amount) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/limits/$id',
      data: {'amount': amount},
    );
    return LimitModel.fromJson(response.data!);
  }
}
