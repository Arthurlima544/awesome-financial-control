import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../config/app_config.dart';

class DevToolsService {
  DevToolsService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<void> seed() => _dio.post<void>('/api/v1/dev/seed');

  Future<void> reset() => _dio.delete<void>('/api/v1/dev/reset');
}
