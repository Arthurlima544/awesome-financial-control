import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:afc/utils/config/app_config.dart';
import 'package:afc/models/monthly_report_model.dart';

class ReportService {
  ReportService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<MonthlyReportModel> fetchMonthlyReport(String month) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/reports/monthly',
      queryParameters: {'month': month},
    );
    return MonthlyReportModel.fromJson(response.data!);
  }
}
