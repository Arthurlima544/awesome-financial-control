import 'package:afc/models/bill_model.dart';
import 'package:afc/utils/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BillService {
  BillService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<List<BillModel>> getAllBills() async {
    final response = await _dio.get('/api/v1/bills');
    return (response.data as List)
        .map((json) => BillModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<BillModel> createBill(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/v1/bills', data: data);
    return BillModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BillModel> updateBill(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/api/v1/bills/$id', data: data);
    return BillModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteBill(String id) async {
    await _dio.delete('/api/v1/bills/$id');
  }
}
