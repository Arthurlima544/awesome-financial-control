import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../config/app_config.dart';
import '../model/limit_progress_model.dart';

class LimitService {
  LimitService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<List<LimitProgressModel>> fetchLimitsProgress() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/limits/progress');
    return response.data!
        .map((e) => LimitProgressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
