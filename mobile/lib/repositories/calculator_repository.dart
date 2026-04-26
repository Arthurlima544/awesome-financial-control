import 'package:dio/dio.dart';
import 'package:afc/utils/config/app_config.dart';
import 'package:afc/models/fire_calculator_result.dart';
import 'package:afc/models/compound_interest_result.dart';
import 'package:afc/models/investment_goal.dart';

class CalculatorRepository {
  final Dio _dio;

  CalculatorRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<FireCalculatorResult> calculateFire({
    required double monthlyExpenses,
    required double currentPortfolio,
    required double monthlySavings,
    required double annualReturnRate,
    required double safeWithdrawalRate,
    required bool adjustForInflation,
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
          'adjustForInflation': adjustForInflation,
        },
      );

      if (response.statusCode == 200) {
        return FireCalculatorResult.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to calculate FIRE: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to calculate FIRE: $e');
    }
  }

  Future<CompoundInterestResult> calculateCompoundInterest({
    required double initialAmount,
    required double monthlyContribution,
    required int years,
    required double annualInterestRate,
    bool adjustForInflation = false,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/api/v1/calculators/compound-interest',
        data: {
          'initialAmount': initialAmount,
          'monthlyContribution': monthlyContribution,
          'years': years,
          'annualInterestRate': annualInterestRate,
          'adjustForInflation': adjustForInflation,
        },
      );

      if (response.statusCode == 200) {
        return CompoundInterestResult.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to calculate compound interest: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to calculate compound interest: $e');
    }
  }

  Future<InvestmentGoalResponse> calculateInvestmentGoal({
    required double targetAmount,
    required DateTime targetDate,
    required double annualReturnRate,
    required double initialAmount,
    bool adjustForInflation = false,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/api/v1/calculators/investment-goal',
        data: {
          'targetAmount': targetAmount,
          'targetDate': targetDate.toIso8601String().split('T')[0],
          'annualReturnRate': annualReturnRate,
          'initialAmount': initialAmount,
          'adjustForInflation': adjustForInflation,
        },
      );

      if (response.statusCode == 200) {
        return InvestmentGoalResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to calculate investment goal: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to calculate investment goal: $e');
    }
  }
}
