import 'package:afc/models/recurring_transaction_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:afc/utils/config/app_config.dart';

class RecurringService {
  final Dio _dio;

  RecurringService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<List<RecurringTransactionModel>> getAll() async {
    final response = await _dio.get('/api/v1/recurring');
    return (response.data as List)
        .map((e) => RecurringTransactionModel.fromJson(e))
        .toList();
  }

  Future<RecurringTransactionModel> create(
    RecurringTransactionModel recurring,
  ) async {
    final response = await _dio.post(
      '/api/v1/recurring',
      data: recurring.toJson(),
    );
    return RecurringTransactionModel.fromJson(response.data);
  }

  Future<RecurringTransactionModel> update(
    RecurringTransactionModel recurring,
  ) async {
    final response = await _dio.put(
      '/api/v1/recurring/${recurring.id}',
      data: recurring.toJson(),
    );
    return RecurringTransactionModel.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/api/v1/recurring/$id');
  }

  Future<void> processPending() async {
    await _dio.post('/api/v1/recurring/process');
  }
}
