import 'package:flutter_test/flutter_test.dart';
import 'package:afc/models/fire_calculator_result.dart';
import 'package:afc/models/compound_interest_result.dart';
import 'package:afc/models/passive_income_data.dart';
import 'package:afc/models/investment_dashboard_data.dart';

void main() {
  group('FireCalculatorResult', () {
    test('fromJson creates correct object', () {
      final json = {
        'fireNumber': 1000000.0,
        'monthsToFire': 120,
        'retirementDate': '2034-04-26',
        'yearlyTimeline': [
          {'year': 0.0, 'portfolioValue': 0.0},
          {'year': 1.0, 'portfolioValue': 50000.0},
        ],
        'fiScore': 5.0,
      };

      final result = FireCalculatorResult.fromJson(json);

      expect(result.fireNumber, 1000000.0);
      expect(result.monthsToFire, 120);
      expect(result.retirementDate, DateTime(2034, 4, 26));
      expect(result.yearlyTimeline.length, 2);
      expect(result.yearlyTimeline[1].portfolioValue, 50000.0);
      expect(result.fiScore, 5.0);
    });
  });

  group('CompoundInterestResult', () {
    test('fromJson creates correct object', () {
      final json = {
        'finalAmount': 500000.0,
        'totalInvested': 300000.0,
        'totalInterest': 200000.0,
        'timeline': [
          {'year': 0.0, 'accumulated': 1000.0, 'invested': 1000.0},
        ],
      };

      final result = CompoundInterestResult.fromJson(json);

      expect(result.finalAmount, 500000.0);
      expect(result.totalInvested, 300000.0);
      expect(result.totalInterest, 200000.0);
      expect(result.timeline.length, 1);
    });
  });

  group('PassiveIncomeData', () {
    test('fromJson creates correct object', () {
      final json = {
        'freedomIndex': 45.5,
        'totalPassiveIncomeCurrentMonth': 1500.0,
        'monthlyProgression': [
          {'month': '2024-01', 'amount': 1200.0},
        ],
        'incomeByInvestment': {'PETR4': 500.0, 'VALE3': 300.0},
      };

      final result = PassiveIncomeData.fromJson(json);

      expect(result.freedomIndex, 45.5);
      expect(result.totalPassiveIncomeCurrentMonth, 1500.0);
      expect(result.monthlyProgression.length, 1);
      expect(result.incomeByInvestment['PETR4'], 500.0);
    });
  });

  group('InvestmentDashboardData', () {
    test('fromJson creates correct object', () {
      final json = {
        'totalProfitLoss': 10000.0,
        'totalProfitLossPercentage': 5.2,
        'currentTotalValue': 200000.0,
        'totalInvested': 190000.0,
        'allocationByType': {'Stocks': 70.0, 'FIIs': 30.0},
        'assetPerformance': [
          {
            'ticker': 'AAPL',
            'name': 'Apple Inc.',
            'profitLoss': 2000.0,
            'percentage': 10.0,
          },
        ],
      };

      final result = InvestmentDashboardData.fromJson(json);

      expect(result.totalProfitLoss, 10000.0);
      expect(result.totalProfitLossPercentage, 5.2);
      expect(result.allocationByType['Stocks'], 70.0);
      expect(result.assetPerformance[0].ticker, 'AAPL');
    });
  });
}
