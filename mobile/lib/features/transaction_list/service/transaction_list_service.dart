import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../config/app_config.dart';
import '../model/transaction_model.dart';

class TransactionListService {
  TransactionListService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<List<TransactionModel>> fetchAll() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/transactions');
    return response.data!
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/api/v1/transactions/$id');
  }
}
