import 'package:dio/dio.dart';
import 'package:afc/utils/config/app_config.dart';

class CalculatorRepository {
  final Dio _dio;

  CalculatorRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>> calculateFire({
    required double monthlyExpenses,
    required double currentPortfolio,
    required double monthlySavings,
    required double annualReturnRate,
    required double safeWithdrawalRate,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/api/v1/calculators/fire',
        data: {
          'monthlyExpenses': monthlyExpenses,
          'currentPortfolio': currentPortfolio,
          'monthlySavings': monthlySavings,
          'annualReturnRate': annualReturnRate,
          'safeWithdrawalRate': safeWithdrawalRate,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to calculate FIRE: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to calculate FIRE: $e');
    }
  }
}
