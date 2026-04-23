import 'package:afc/models/health_score_model.dart';
import 'package:afc/utils/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class HealthScoreService {
  HealthScoreService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<HealthScoreModel> getHealthScore() async {
    final response = await _dio.get('/api/v1/health/score');
    return HealthScoreModel.fromJson(response.data as Map<String, dynamic>);
  }
}
