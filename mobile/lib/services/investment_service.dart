import 'package:afc/models/investment_model.dart';
import 'package:afc/utils/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class InvestmentService {
  InvestmentService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<List<InvestmentModel>> getAllInvestments() async {
    final response = await _dio.get('/api/v1/investments');
    return (response.data as List)
        .map((json) => InvestmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<InvestmentModel> createInvestment(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/v1/investments', data: data);
    return InvestmentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<InvestmentModel> updateInvestment(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put('/api/v1/investments/$id', data: data);
    return InvestmentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteInvestment(String id) async {
    await _dio.delete('/api/v1/investments/$id');
  }

  Future<InvestmentModel> updatePrice(String id, double price) async {
    final response = await _dio.patch(
      '/api/v1/investments/$id/price',
      queryParameters: {'price': price},
    );
    return InvestmentModel.fromJson(response.data as Map<String, dynamic>);
  }
}
