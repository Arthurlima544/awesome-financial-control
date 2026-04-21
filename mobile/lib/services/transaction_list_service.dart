import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:afc/utils/config/app_config.dart';
import 'package:afc/models/transaction_model.dart';

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

  Future<TransactionModel> update(
    String id, {
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/transactions/$id',
      data: {
        'description': description,
        'amount': amount,
        'type': type.toUpperCase(),
        'category': category,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
      },
    );
    return TransactionModel.fromJson(response.data!);
  }

  Future<TransactionModel> create({
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/transactions',
      data: {
        'description': description,
        'amount': amount,
        'type': type.toUpperCase(),
        'category': category,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
      },
    );
    return TransactionModel.fromJson(response.data!);
  }
}
