import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../config/app_config.dart';
import '../model/monthly_stat_model.dart';

class StatsService {
  StatsService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<List<MonthlyStatModel>> fetchMonthlyStats() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/stats/monthly');
    return response.data!
        .map((e) => MonthlyStatModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
