import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../config/app_config.dart';
import '../model/summary_model.dart';
import '../model/transaction_model.dart';

class HomeService {
  HomeService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<SummaryModel> fetchSummary() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/summary');
    return SummaryModel.fromJson(response.data!);
  }

  Future<List<TransactionModel>> fetchLastTransactions({int limit = 5}) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/transactions',
      queryParameters: {'limit': limit},
    );
    return response.data!
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
