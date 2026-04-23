import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:afc/utils/config/app_config.dart';
import 'package:afc/models/goal_model.dart';

class GoalService {
  GoalService({Dio? dio}) : _dio = dio ?? _buildDio();

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

  Future<List<GoalModel>> fetchGoals() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/goals');
    return response.data!.map((json) => GoalModel.fromJson(json)).toList();
  }

  Future<GoalModel> createGoal(Map<String, dynamic> data) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/goals',
      data: data,
    );
    return GoalModel.fromJson(response.data!);
  }

  Future<GoalModel> updateGoal(String id, Map<String, dynamic> data) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/goals/$id',
      data: data,
    );
    return GoalModel.fromJson(response.data!);
  }

  Future<void> deleteGoal(String id) async {
    await _dio.delete('/api/v1/goals/$id');
  }

  Future<GoalModel> addContribution(String id, double amount) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/goals/$id/contribute',
      queryParameters: {'amount': amount},
    );
    return GoalModel.fromJson(response.data!);
  }
}
